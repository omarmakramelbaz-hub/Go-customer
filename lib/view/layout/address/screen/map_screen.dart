import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/location_service.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/custom_loading/custome_dots_loading.dart';
import '../../map/model/place_autocomplete_model/place_autocomplete_model.dart';
import '../../map/utils/google_maps_place_service.dart';

typedef OnBackCallback = void Function(double lat, double lng);

@immutable
class LocationState {
  final double? latitude;
  final double? longitude;
  final List<Placemark>? placemarks;
  final bool isLoading;
  final String? error;
  const LocationState({this.latitude, this.longitude, this.placemarks, this.isLoading = false, this.error});
  LocationState copyWith({double? latitude, double? longitude, List<Placemark>? placemarks, bool? isLoading, String? error}) =>
    LocationState(latitude: latitude ?? this.latitude, longitude: longitude ?? this.longitude,
      placemarks: placemarks ?? this.placemarks, isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
  bool get hasValidCoordinates => latitude != null && longitude != null;
  LatLng get latLng => LatLng(latitude ?? 0, longitude ?? 0);
}

@immutable
class SearchState {
  final List<PlaceModel> results;
  final bool isVisible;
  final bool isLoading;
  final String? error;
  const SearchState({this.results = const [], this.isVisible = false, this.isLoading = false, this.error});
  SearchState copyWith({List<PlaceModel>? results, bool? isVisible, bool? isLoading, String? error}) =>
    SearchState(results: results ?? this.results, isVisible: isVisible ?? this.isVisible,
      isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
  SearchState hide() => copyWith(isVisible: false, results: []);
  SearchState show() => copyWith(isVisible: true);
  SearchState loading() => copyWith(isLoading: true, error: null);
  SearchState withResults(List<PlaceModel> results) => copyWith(results: results, isLoading: false, isVisible: true);
  SearchState withError(String error) => copyWith(error: error, isLoading: false);
}

@immutable
class MapScreenArgs {
  final OnBackCallback onBack;
  const MapScreenArgs({required this.onBack});
  void safeOnBack(double lat, double lng) {
    if (_isValidCoordinate(lat, lng)) { onBack(lat, lng); }
    else { log('Invalid coordinates: lat=$lat, lng=$lng'); }
  }
  static bool _isValidCoordinate(double lat, double lng) => lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
}

class MapScreen extends StatefulWidget {
  static const String routeName = 'MapScreen';
  final MapScreenArgs args;
  const MapScreen({super.key, required this.args});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  late final LocationService _locationService;
  late final PlacesService _placesService;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  GoogleMapController? _mapController;
  LocationState _locationState = const LocationState();
  SearchState _searchState = const SearchState();
  bool _isManualSelection = false;
  String? _selectedPlaceDescription;
  String? _sessionToken;
  Timer? _searchDebounce;
  static const _searchDebounceDelay = Duration(milliseconds: 500);
  static const _defaultZoom = 14.0;
  static const _initialZoom = 12.0;
  bool get ar => context.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _placesService = PlacesService();
    _searchController = TextEditingController()..addListener(_onSearchTextChanged);
    _searchFocusNode = FocusNode()..addListener(_onSearchFocusChanged);
    _locationService.listenToLocation((location) {
      if (mounted && !_isManualSelection && location.latitude != null && location.longitude != null) {
        _updateLocationState(location.latitude!, location.longitude!, shouldUpdatePlacemarks: true);
      }
    });
    _determineInitialPosition();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    _locationService.dispose();
    _searchController.removeListener(_onSearchTextChanged);
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _determineInitialPosition() async {
    if (!mounted) return;
    setState(() => _locationState = _locationState.copyWith(isLoading: true));
    try {
      final location = await _locationService.getCurrentLocation();
      if (location?.latitude != null && location?.longitude != null) {
        await _updateLocationState(location!.latitude!, location.longitude!, shouldUpdatePlacemarks: true);
      } else if (mounted) {
        setState(() => _locationState = _locationState.copyWith(isLoading: false, error: 'Location unavailable'));
      }
    } catch (e) {
      if (mounted) setState(() => _locationState = _locationState.copyWith(isLoading: false, error: 'Failed to get current location: $e'));
      log('Failed to get location: $e');
    }
  }

  Future<void> _updateLocationState(double lat, double lng, {bool shouldUpdatePlacemarks = false}) async {
    List<Placemark>? placemarks;
    if (shouldUpdatePlacemarks) {
      try { placemarks = await placemarkFromCoordinates(lat, lng); }
      catch (e) { log('Failed to get placemarks: $e'); }
    }
    if (!mounted) return;
    setState(() => _locationState = _locationState.copyWith(latitude: lat, longitude: lng,
      placemarks: placemarks ?? _locationState.placemarks, isLoading: false, error: null));
    if (_mapController != null) await _mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
  }

  void _onSearchTextChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) { setState(() => _searchState = _searchState.hide()); return; }
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDelay, () => _performSearch(query));
  }
  void _onSearchFocusChanged() {
    if (!_searchFocusNode.hasFocus) _forceHideSearchUI();
    else if (_searchController.text.isNotEmpty) setState(() => _searchState = _searchState.show());
  }
  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() => _searchState = _searchState.loading());
    try {
      _sessionToken ??= const Uuid().v4();
      final results = await _placesService.getPredictions(input: query, sesstionToken: _sessionToken!);
      if (mounted) setState(() => _searchState = _searchState.withResults(results));
    } catch (e) {
      if (mounted) setState(() => _searchState = _searchState.withError('Search failed: $e'));
      log('Search error: $e');
    }
  }
  Future<void> _onPlaceSelected(PlaceModel place) async {
    if (place.placeId == null) return;
    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      _searchFocusNode.unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
      _searchController.text = place.description ?? '';
      setState(() => _searchState = _searchState.hide());
      await Future.delayed(const Duration(milliseconds: 30));
      final details = await _placesService.getPlaceDetails(placeId: place.placeId!);
      final lat = details.geometry?.location?.lat;
      final lng = details.geometry?.location?.lng;
      if (lat == null || lng == null || !mounted) return;
      _locationService.pauseLocationStream();
      _isManualSelection = true;
      _selectedPlaceDescription = place.description;
      await _updateLocationState(lat, lng);
      if (!mounted) return;
      if (_mapController != null) await _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), _defaultZoom));
      widget.args.safeOnBack(lat, lng);
    } catch (e, stack) { log('Place selection error: $e'); log('Stack trace: $stack'); }
  }
  void _onMapTap(LatLng latLng) {
    _locationService.pauseLocationStream();
    _isManualSelection = true;
    _selectedPlaceDescription = null;
    _forceHideSearchUI();
    _updateLocationState(latLng.latitude, latLng.longitude);
    widget.args.safeOnBack(latLng.latitude, latLng.longitude);
  }
  void _forceHideSearchUI() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _searchFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    if (mounted) setState(() => _searchState = _searchState.hide());
  }
  Future<void> _resumeLocationTracking() async {
    _isManualSelection = false;
    _selectedPlaceDescription = null;
    _locationService.resumeLocationStream();
    await _determineInitialPosition();
  }
  void _onCameraIdle() { if (_searchState.isVisible) _forceHideSearchUI(); }
  void _clearSearch() { _searchController.clear(); setState(() => _searchState = _searchState.hide()); }
  void _onScaffoldTap() { if (_searchState.isVisible) _forceHideSearchUI(); }

  @override
  Widget build(BuildContext context) => GestureDetector(behavior: HitTestBehavior.translucent,
    onTap: _onScaffoldTap,
    child: Scaffold(
      resizeToAvoidBottomInset: true, backgroundColor: GoDesign.paper,
      appBar: CustomAppBar(title: Text(ar ? 'اختر موقعك' : 'Choose your location')),
      floatingActionButton: FloatingActionButton.small(
        tooltip: ar ? 'موقعي الحالي' : 'My location',
        backgroundColor: GoDesign.paper, foregroundColor: GoDesign.ink,
        onPressed: _resumeLocationTracking, child: const Icon(Icons.my_location)),
      body: _locationState.isLoading ? const Center(child: CustomDotsLoading()) : _buildMapContent(),
      bottomNavigationBar: _buildConfirmButton(),
    ),
  );

  Widget _buildMapContent() {
    if (!_locationState.hasValidCoordinates) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.location_off_outlined, color: GoDesign.orange, size: 48),
        const SizedBox(height: 16),
        Text(ar ? 'تعذر تحديد الموقع. راجع إذن الموقع وحاول مرة أخرى.' : 'Location unavailable. Check location permission and try again.',
          textAlign: TextAlign.center, style: const TextStyle(color: GoDesign.muted, height: 1.5)),
        const SizedBox(height: 16),
        FilledButton(onPressed: _determineInitialPosition, child: Text(ar ? 'إعادة المحاولة' : 'Try again')),
      ])));
    }
    return Stack(children: [
      Positioned.fill(child: GoogleMap(
        onTap: _onMapTap,
        markers: {Marker(markerId: const MarkerId('currentLocation'), position: _locationState.latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure))},
        zoomControlsEnabled: false, mapType: MapType.normal, onCameraIdle: _onCameraIdle,
        onMapCreated: (controller) {
          _mapController = controller;
          if (_locationState.hasValidCoordinates) controller.animateCamera(CameraUpdate.newLatLng(_locationState.latLng));
        },
        initialCameraPosition: CameraPosition(target: _locationState.latLng, zoom: _initialZoom))),
      Padding(padding: const EdgeInsets.all(18), child: Column(children: [
        CustomFormField(controller: _searchController, focusNode: _searchFocusNode,
          hintText: ar ? 'ابحث عن عنوان…' : 'Search for an address…',
          suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch) : const Icon(Icons.search)),
        if (_searchState.isVisible) _buildSearchResultsList(),
      ])),
    ]);
  }

  Widget _buildSearchResultsList() {
    if (!_searchState.isLoading && _searchState.error == null && _searchState.results.isEmpty) return const SizedBox.shrink();
    return Container(margin: const EdgeInsets.only(top: 10),
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .35),
      decoration: BoxDecoration(color: GoDesign.paper, borderRadius: BorderRadius.circular(12), boxShadow: GoDesign.cardShadow),
      child: _searchState.isLoading ? const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())
        : _searchState.error != null ? Padding(padding: const EdgeInsets.all(16), child: Text(
            ar ? 'تعذر البحث. حاول مرة أخرى.' : 'Search unavailable. Please try again.',
            style: const TextStyle(color: GoDesign.danger)))
        : ListView.builder(padding: EdgeInsets.zero, shrinkWrap: true,
            itemCount: _searchState.results.length, itemBuilder: (_, index) {
              final place = _searchState.results[index];
              return ListTile(leading: const Icon(Icons.location_on_outlined, color: GoDesign.orange),
                title: Text(place.description ?? ''), onTap: () => _onPlaceSelected(place));
            }),
    );
  }

  Widget? _buildConfirmButton() {
    if (!_locationState.hasValidCoordinates) return null;
    final placemarks = _locationState.placemarks;
    final placemark = placemarks == null || placemarks.isEmpty ? null : placemarks.first;
    final address = _selectedPlaceDescription ?? (!_isManualSelection && placemark != null
      ? [placemark.locality, placemark.street].whereType<String>().where((part) => part.isNotEmpty).join('، ') : '');
    return SafeArea(top: false, child: Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(color: GoDesign.paper, border: Border(top: BorderSide(color: GoDesign.border))),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.location_on, color: GoDesign.orange, size: 28), const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ar ? 'الموقع المحدد' : 'Selected location',
              style: const TextStyle(color: GoDesign.ink, fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 5),
            Text(address.isNotEmpty ? address : '${_locationState.latitude!.toStringAsFixed(5)}, ${_locationState.longitude!.toStringAsFixed(5)}',
              maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: GoDesign.muted, fontSize: 13)),
          ])),
        ]),
        const SizedBox(height: 16),
        CustomButton(text: ar ? 'تأكيد الموقع' : 'Confirm location', onPressed: () {
          widget.args.safeOnBack(_locationState.latitude!, _locationState.longitude!);
          Navigator.pop(context);
        }),
      ]),
    ));
  }
}
