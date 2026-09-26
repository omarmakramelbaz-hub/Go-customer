import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/go_master_ui.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/screen/login_screen.dart';
import 'go_partner_detail_screen.dart';

class ProfessionPartnersScreen extends StatefulWidget {
  const ProfessionPartnersScreen({super.key, required this.professionKey, required this.title});
  final String professionKey;
  final String title;
  @override
  State<ProfessionPartnersScreen> createState() => _ProfessionPartnersScreenState();
}

class _ProfessionPartnersScreenState extends State<ProfessionPartnersScreen> {
  final _search = TextEditingController();
  bool _loading = true;
  String? _error;
  double? _lat;
  double? _lng;
  List<Map<String, dynamic>> _partners = [];
  String _query = '';
  int _sort = 0;
  bool get ar => context.languageCode == 'ar';
  String t(String a, String e) => ar ? a : e;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _loading = false;
          _error = t('فعّل إذن الموقع لعرض مقدمي الخدمة المتاحين حولك.', 'Allow location access to find providers near you.');
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _lat = position.latitude;
      _lng = position.longitude;
      final response = await ApiHelper.instance.get(Urls.professionPartners(widget.professionKey),
        queryParameters: {'lat': _lat, 'lng': _lng}, hasToken: false);
      if (!mounted) return;
      if (response.state == ResponseState.complete) {
        final raw = response.data is Map ? response.data['data'] : null;
        setState(() {
          _partners = raw is List ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : [];
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = response.data is Map ? response.data['message']?.toString() : null;
          _error ??= t('تعذر تحميل مقدمي الخدمة.', 'Unable to load providers.');
        });
      }
    } catch (_) {
      if (mounted) setState(() {
        _loading = false;
        _error = t('تعذر تحديد موقعك أو تحميل مقدمي الخدمة.', 'Unable to find your location or load providers.');
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _query.trim().toLowerCase();
    final items = _partners.where((p) => q.isEmpty || (p['name']?.toString().toLowerCase() ?? '').contains(q)).toList();
    if (_sort == 1) {
      double distance(Map<String, dynamic> p) => double.tryParse('${p['distance_km']}') ?? double.infinity;
      items.sort((a, b) => distance(a).compareTo(distance(b)));
    } else if (_sort == 2) {
      items.sort((a, b) => '${a['name'] ?? ''}'.compareTo('${b['name'] ?? ''}'));
    }
    return items;
  }

  void _request(Map<String, dynamic> partner) {
    if (HiveMethods.getToken() == null) {
      NamedNavigatorImpl.push(LoginScreen.routeName);
      return;
    }
    if (_lat == null || _lng == null) return;
    showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _CreatePartnerRequestSheet(partner: partner, professionKey: widget.professionKey,
        professionTitle: widget.title, lat: _lat!, lng: _lng!));
  }

  void _details(Map<String, dynamic> partner) => Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => GoPartnerDetailScreen(partner: partner, professionKey: widget.professionKey,
      title: widget.title, isArabic: ar, onRequest: () => _request(partner))));

  Future<void> _filters() async {
    final labels = [t('الترتيب الافتراضي', 'Recommended order'), t('الأقرب إليك', 'Nearest to you'), t('الاسم', 'Name')];
    var choice = _sort;
    final result = await showModalBottomSheet<int>(context: context,
      builder: (sheet) => StatefulBuilder(builder: (context, refresh) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: Text(t('البحث والتصفية', 'Search and filters'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
            IconButton(onPressed: () => Navigator.pop(sheet), icon: const Icon(Icons.close)),
          ]),
          ...List.generate(labels.length, (i) => RadioListTile<int>(value: i, groupValue: choice,
            title: Text(labels[i]), activeColor: GoDesign.orange,
            onChanged: (value) => refresh(() => choice = value!))),
          const SizedBox(height: 12),
          Text(t('تحديد السعر يتم بعرض من مقدم الخدمة، لذلك لا نعرض ترتيبًا بأسعار غير مؤكدة.',
            'Prices are agreed through provider quotations, not estimated rankings.'),
            style: const TextStyle(color: GoDesign.muted, fontSize: 12, height: 1.5)),
          const SizedBox(height: 18),
          CustomButton(text: t('عرض النتائج', 'Show results'), onPressed: () => Navigator.pop(sheet, choice)),
        ]),
      ))));
    if (result != null && mounted) setState(() => _sort = result);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Directionality(textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(backgroundColor: GoDesign.paper,
        appBar: CustomAppBar(title: Text(widget.title)),
        body: RefreshIndicator(onRefresh: _load, child: ListView(
          physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(20), children: [
            TextField(controller: _search, onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(hintText: t('ابحث باسم مقدم الخدمة…', 'Search by provider name…'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(tooltip: t('التصفية', 'Filters'), onPressed: _filters,
                  icon: const Icon(Icons.tune, color: GoDesign.orange)))),
            const SizedBox(height: 18),
            Text(t('مقدمو الخدمة المتاحون حولك', 'Available providers near you'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GoDesign.ink)),
            const SizedBox(height: 6),
            Text(t('اختر مقدم الخدمة، وراجع التفاصيل قبل إرسال الطلب.', 'Choose a provider and review the details before sending a request.'),
              style: const TextStyle(color: GoDesign.muted, height: 1.5, fontSize: 13)),
            const SizedBox(height: 20),
            if (_loading) const Padding(padding: EdgeInsets.all(60), child: Center(child: CircularProgressIndicator()))
            else if (_error != null) _state(Icons.location_off_outlined, _error!, retry: true)
            else if (items.isEmpty) _state(Icons.person_search_outlined,
              t('لا يوجد مقدم خدمة مطابق داخل نطاقك حاليًا.', 'No matching providers in your area right now.'))
            else ...items.map(_partnerCard),
          ],
        )),
      ),
    );
  }

  Widget _state(IconData icon, String text, {bool retry = false}) => GoSurface(child: Column(children: [
    Icon(icon, color: GoDesign.orange, size: 44), const SizedBox(height: 16),
    Text(text, textAlign: TextAlign.center, style: const TextStyle(color: GoDesign.ink, height: 1.5)),
    if (retry) TextButton(onPressed: _load, child: Text(t('إعادة المحاولة', 'Try again'))),
  ]));

  Widget _partnerCard(Map<String, dynamic> partner) {
    final photo = partner['photo']?.toString() ?? '';
    final distance = partner['distance_km'];
    return GoSurface(margin: const EdgeInsets.only(bottom: 14), child: Column(children: [
      Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: Container(width: 66, height: 66,
          color: GoDesign.orangeTint,
          child: photo.isEmpty ? const Icon(Icons.person_outline, color: GoDesign.orange, size: 32)
            : Image.network(photo, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person_outline, color: GoDesign.orange, size: 32)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(partner['name']?.toString() ?? t('مقدم خدمة', 'Service provider'),
            style: const TextStyle(color: GoDesign.ink, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Text(distance == null ? t('داخل نطاقك', 'In your area') : t('$distance كم منك', '$distance km away'),
            style: const TextStyle(color: GoDesign.muted, fontSize: 13)),
        ])),
      ]),
      const SizedBox(height: 14),
      CustomButton(text: t('عرض التفاصيل', 'View details'), onPressed: () => _details(partner)),
    ]));
  }
}

class _CreatePartnerRequestSheet extends StatefulWidget {
  const _CreatePartnerRequestSheet({required this.partner, required this.professionKey,
    required this.professionTitle, required this.lat, required this.lng});
  final Map<String, dynamic> partner;
  final String professionKey;
  final String professionTitle;
  final double lat;
  final double lng;
  @override
  State<_CreatePartnerRequestSheet> createState() => _CreatePartnerRequestSheetState();
}

class _CreatePartnerRequestSheetState extends State<_CreatePartnerRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _photos = [];
  bool _sending = false;
  bool get ar => context.languageCode == 'ar';
  String t(String a, String e) => ar ? a : e;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthController>().profile;
    _phone.text = profile?.mobile ?? '';
    _address.text = profile?.address ?? '';
  }
  @override
  void dispose() { _description.dispose(); _phone.dispose(); _address.dispose(); super.dispose(); }

  Future<void> _pickPhotos() async {
    final images = await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1400);
    if (!mounted || images.isEmpty) return;
    setState(() => _photos.addAll(images.take(5 - _photos.length)));
  }

  Future<void> _send() async {
    if (_sending || !_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      final uploads = <MultipartFile>[];
      for (final photo in _photos) {
        uploads.add(MultipartFile.fromBytes(await photo.readAsBytes(),
          filename: photo.name.isEmpty ? 'request.jpg' : photo.name));
      }
      // Keep the existing request contract, including photo uploads, unchanged.
      final body = FormData.fromMap({
        'partner_id': widget.partner['id'], 'profession_key': widget.professionKey,
        'description': _description.text.trim(), 'customer_phone': _phone.text.trim(),
        'customer_lat': widget.lat, 'customer_lng': widget.lng, 'address': _address.text.trim(),
        if (uploads.isNotEmpty) 'photos': uploads,
      });
      final response = await ApiHelper.instance.post(Urls.partnerServiceRequests, body: body);
      if (!mounted) return;
      if (response.state == ResponseState.complete) {
        final messenger = ScaffoldMessenger.of(context);
        final message = t('تم إرسال الطلب إلى ${widget.partner['name'] ?? 'مقدم الخدمة'}',
          'Request sent to ${widget.partner['name'] ?? 'the provider'}');
        Navigator.pop(context);
        messenger.showSnackBar(SnackBar(content: Text(message)));
      } else {
        final message = response.data is Map ? response.data['message']?.toString() : null;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? t('تعذر إرسال الطلب.', 'Unable to send request.'))));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        t('تعذر إرسال الطلب. حاول مرة أخرى.', 'Unable to send request. Please try again.'))));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
    child: SafeArea(top: false, child: Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .92),
      decoration: const BoxDecoration(color: GoDesign.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom + 20),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(color: GoDesign.deepInk, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Expanded(child: Text(t('تأكيد الطلب', 'Confirm request'),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
              IconButton(onPressed: _sending ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white)),
            ])),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            GoSurface(child: Row(children: [
              const Icon(Icons.handyman_outlined, color: GoDesign.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.professionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('${widget.partner['name'] ?? ''}', style: const TextStyle(color: GoDesign.muted)),
              ])),
            ])),
            const SizedBox(height: 20),
            TextFormField(controller: _address, decoration: _dec(t('عنوان الخدمة', 'Service address'), Icons.location_on_outlined),
              validator: (v) => v == null || v.trim().length < 3 ? t('اكتب وصف العنوان', 'Enter the service address') : null),
            const SizedBox(height: 14),
            TextFormField(controller: _phone, keyboardType: TextInputType.phone,
              decoration: _dec(t('رقم التواصل', 'Contact phone'), Icons.phone_outlined),
              validator: (v) => v == null || v.replaceAll(RegExp(r'\D'), '').length < 10
                ? t('اكتب رقم هاتف صحيح', 'Enter a valid phone number') : null),
            const SizedBox(height: 14),
            TextFormField(controller: _description, minLines: 3, maxLines: 7, maxLength: 2000,
              decoration: _dec(t('تفاصيل الخدمة المطلوبة', 'Describe the required service'), Icons.notes_outlined),
              validator: (v) => v == null || v.trim().length < 5 ? t('اكتب تفاصيل الطلب', 'Enter request details') : null),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: _photos.length >= 5 || _sending ? null : _pickPhotos,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(t('إضافة صور (اختياري) ${_photos.length}/5', 'Add photos (optional) ${_photos.length}/5'))),
            if (_photos.isNotEmpty) Wrap(spacing: 7, runSpacing: 7,
              children: List.generate(_photos.length, (i) => InputChip(label: Text(t('صورة ${i + 1}', 'Photo ${i + 1}')),
                onDeleted: _sending ? null : () => setState(() => _photos.removeAt(i))))),
            const SizedBox(height: 18),
            Text(t('السعر والموعد بعد اتفاقك مع مقدم الخدمة.', 'Price and timing are agreed with the provider.'),
              style: const TextStyle(color: GoDesign.muted, fontSize: 13, height: 1.5)),
            const SizedBox(height: 18),
            CustomButton(text: t('تأكيد الطلب', 'Confirm request'), isLoading: _sending, onPressed: _send),
          ])),
        ])),
      ),
    )),
  );

  InputDecoration _dec(String label, IconData icon) => InputDecoration(labelText: label,
    prefixIcon: Icon(icon, color: GoDesign.muted), filled: true, fillColor: GoDesign.paper);
}
