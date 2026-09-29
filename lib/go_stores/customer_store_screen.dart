import 'dart:async';
import 'package:flutter/material.dart';

import '../helpers/hive/hive_methods.dart';
import '../helpers/networking/api_helper.dart';
import '../helpers/networking/urls.dart';
import '../view/custom_widgets/popups/go_popups.dart';
import '../view/layout/address/model/address_model.dart';
import '../view/layout/address/screen/address_screen.dart';
import 'store_browse_view.dart';

typedef StoreRead = Future<Map<String, dynamic>> Function(
  String path,
  Map<String, dynamic> query,
);
Future<Map<String, dynamic>> readGoStores(
  String path,
  Map<String, dynamic> query,
) async {
  final response = await ApiHelper.instance.get(
    '${Urls.baseUrl}go-stores/browse$path',
    queryParameters: query,
  );
  if (response.state != ResponseState.complete ||
      response.data is! Map ||
      response.data['data'] is! Map) {
    throw StateError('Store catalog unavailable');
  }
  return Map<String, dynamic>.from(response.data['data']);
}

class CustomerStoreScreen extends StatefulWidget {
  const CustomerStoreScreen({
    super.key,
    required this.kind,
    required this.title,
    this.storeId,
    this.read = readGoStores,
    this.selectAddress,
  });
  final String kind;
  final String title;
  final int? storeId;
  final StoreRead read;
  final Future<AddressModel?> Function(BuildContext)? selectAddress;
  @override
  State<CustomerStoreScreen> createState() => _StoreState();
}

class _StoreState extends State<CustomerStoreScreen> {
  final items = <Map<String, dynamic>>[];
  final nearby = <Map<String, dynamic>>[];
  final search = TextEditingController();
  Timer? debounce;
  int generation = 0;
  int total = 0;
  int nearbyTotal = 0;
  String sort = 'name';
  AddressModel? selectedAddress;
  bool loading = false;
  bool failed = false;
  int page = 0;
  int lastPage = 1;
  Map<String, dynamic>? store;
  bool get ar => Localizations.localeOf(context).languageCode == 'ar';
  bool get detail => widget.storeId != null;
  @override
  void initState() {
    super.initState();
    final userId = HiveMethods.getUserId();
    final token = HiveMethods.getToken();
    final saved = userId == null || HiveMethods.isGuestMode() || token == null || token.isEmpty
        ? null : HiveMethods.getDeliveryAddress(userId);
    if (saved != null) selectedAddress = AddressModel.fromJson(saved);
    load();
  }

  @override
  void dispose() {
    generation++;
    debounce?.cancel();
    search.dispose();
    super.dispose();
  }

  Future<void> changeAddress() async {
    AddressModel? address;
    if (widget.selectAddress != null) {
      address = await widget.selectAddress!(context);
    } else {
      final token = HiveMethods.getToken();
      if (HiveMethods.isGuestMode() || token == null || token.isEmpty) {
        await Navigator.of(context).pushNamed('LoginScreen');
        return;
      }
      address = await Navigator.of(context).push<AddressModel>(MaterialPageRoute(
        builder: (_) => const AddressScreen(selectForDelivery: true),
      ));
    }
    if (!mounted || address == null) return;
    final userId = HiveMethods.getUserId();
    if (userId != null) await HiveMethods.saveDeliveryAddress(userId, address.toJson());
    if (!mounted) return;
    setState(() { selectedAddress = address; nearby.clear(); nearbyTotal = 0; });
    final lat = double.tryParse(address.lat ?? '');
    final lng = double.tryParse(address.lng ?? '');
    if (lat != null && lng != null && lat.abs() <= 90 && lng.abs() <= 180) {
      HiveMethods.updateLat(lat);
      HiveMethods.updateLan(lng);
    }
    await load();
  }

  String get addressLabel => [selectedAddress?.address, selectedAddress?.streetName, selectedAddress?.areaName, selectedAddress?.cityName]
      .whereType<String>().map((e) => e.trim()).firstWhere((e) => e.isNotEmpty,
        orElse: () => ar ? 'حدد عنوان التوصيل لعرض المتاجر القريبة' : 'Choose an address to see nearby stores');

  void searchChanged(String value) {
    debounce?.cancel();
    // Invalidate previous responses immediately, including while typing.
    generation++;
    setState(() { loading = true; failed = false; items.clear(); });
    debounce = Timer(const Duration(milliseconds: 300), () => load());
  }

  Future<void> load({bool more = false}) async {
    if (more && loading) return;
    debounce?.cancel();
    final request = ++generation;
    final lat = double.tryParse(selectedAddress?.lat ?? '');
    final lng = double.tryParse(selectedAddress?.lng ?? '');
    setState(() {
      loading = true;
      failed = false;
      if (!more) items.clear();
    });
    try {
      final result = await widget.read(detail ? '/${widget.storeId}' : '', {
        'kind': widget.kind,
        'page': more ? page + 1 : 1,
        if (!detail) ...{
          'search': search.text.trim(),
          'sort': sort,
          if (lat != null && lng != null && lat.abs() <= 90 && lng.abs() <= 180) ...{'lat': lat, 'lng': lng},
        },
      });
      if (!mounted || request != generation) return;
      setState(() {
        if (!more) items.clear();
        items.addAll(
          (result[detail ? 'products' : 'stores'] as List? ?? []).map(
            (e) => Map<String, dynamic>.from(e),
          ),
        );
        page = (result['page'] as num?)?.toInt() ?? 1;
        lastPage = (result['last_page'] as num?)?.toInt() ?? 1;
        total = (result['total'] as num?)?.toInt() ?? items.length;
        if (!detail) {
          nearby.clear();
          nearby.addAll((result['nearby_stores'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)));
          nearbyTotal = (result['nearby_total'] as num?)?.toInt() ?? nearby.length;
        }
        store = result['store'] is Map
            ? Map<String, dynamic>.from(result['store'])
            : null;
      });
    } catch (_) {
      if (mounted && request == generation) setState(() => failed = true);
    } finally {
      if (mounted && request == generation) setState(() => loading = false);
    }
  }

  Widget photo(String? url, {double size = 90}) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: SizedBox(
      width: size,
      height: size,
      child: url == null || url.isEmpty
          ? const ColoredBox(
              color: Color(0xFFFFF0E4),
              child: Icon(
                Icons.storefront_outlined,
                color: Color(0xFFFD7201),
                size: 32,
              ),
            )
          : Image.network(
              url,
              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported_outlined),
            ),
    ),
  );
  void openProduct(Map<String, dynamic> product) => showGoModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => GoSheet(
      title: '${product['name']}',
      icon: Icons.shopping_bag_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: photo(product['image_url']?.toString(), size: 220)),
          const SizedBox(height: 16),
          Text(
            '${product['price']} ${ar ? 'ج.م' : 'EGP'} / ${product['unit'] ?? ''}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if ('${product['description'] ?? ''}'.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('${product['description']}'),
            ),
          for (final option in product['options'] as List? ?? [])
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${option['label']}'),
              trailing: Text('${option['price']} ${ar ? 'ج.م' : 'EGP'}'),
            ),
        ],
      ),
    ),
  );
  void openStore(Map<String, dynamic> item) {
    final id = int.tryParse('${item['id']}');
    if (id == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerStoreScreen(
      kind: widget.kind, title: '${item['name']}', storeId: id, read: widget.read,
      selectAddress: widget.selectAddress,
    )));
  }
  @override
  Widget build(BuildContext context) => detail ? buildDetails(context) : StoreBrowseView(
    title: widget.title, address: addressLabel, hasAddress: selectedAddress != null,
    onAddress: changeAddress, items: items, nearby: nearby, total: total, nearbyTotal: nearbyTotal,
    loading: loading, failed: failed, onRefresh: load, onRetry: () => load(),
    search: search, onSearch: searchChanged, sort: sort,
    onSort: (value) { setState(() => sort = value); load(); },
    onOpen: openStore, hasMore: page < lastPage, onMore: () => load(more: true),
  );

  Widget buildDetails(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(store?['name']?.toString() ?? widget.title)),
    body: RefreshIndicator(
      onRefresh: load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (store != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text('${store!['address'] ?? ''}'),
            ),
          if (loading) const LinearProgressIndicator(),
          if (failed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text(
                    ar
                        ? 'تعذّر تحميل البيانات. حاول مرة أخرى.'
                        : 'Could not load the catalog. Please try again.',
                  ),
                  TextButton(
                    onPressed: loading ? null : () => load(),
                    child: Text(ar ? 'إعادة المحاولة' : 'Retry'),
                  ),
                ],
              ),
            ),
          if (!loading && !failed && items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 58,
                    color: Color(0xFFFD7201),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    detail
                        ? (ar
                              ? 'لا توجد منتجات متاحة في هذا المتجر حاليًا'
                              : 'No products are available in this store yet')
                        : (ar
                              ? 'لا توجد متاجر مسجلة في هذا القسم حاليًا'
                              : 'No stores are listed in this department yet'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          for (final item in items)
            Card(
              margin: const EdgeInsets.only(bottom: 14),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: ValueKey('go-store-item-${item['id']}'),
                onTap: () {
                  if (detail) {
                    openProduct(item);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerStoreScreen(
                          kind: widget.kind,
                          title: '${item['name']}',
                          storeId: (item['id'] as num).toInt(),
                          read: widget.read,
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      photo(
                        (item[detail ? 'image_url' : 'logo_url'])?.toString(),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['name']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              detail
                                  ? '${item['price']} ${ar ? 'ج.م' : 'EGP'} / ${item['unit'] ?? ''}'
                                  : '${item['address'] ?? ''}',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ),
          if (page < lastPage)
            TextButton(
              onPressed: loading ? null : () => load(more: true),
              child: Text(ar ? 'عرض المزيد' : 'Load more'),
            ),
        ],
      ),
    ),
  );
}
