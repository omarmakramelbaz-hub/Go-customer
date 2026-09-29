import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../helpers/theme/app_colors.dart';
import '../helpers/theme/app_text_style.dart';
import '../view/custom_widgets/popups/go_popups.dart';

bool isArabic(BuildContext context) => Localizations.localeOf(context).languageCode == 'ar';
String storeText(BuildContext context, String ar, String en) => isArabic(context) ? ar : en;

/// Public catalog fields only. Unavailable ratings and prices remain unknown.
class GoStoreSummary {
  GoStoreSummary(this.data);
  final Map<String, dynamic> data;
  String? get name => data['name']?.toString();
  String? get address => data['address']?.toString();
  String? get cityName => data['city_name']?.toString();
  String? get cityname => cityName;
  String? get logo => data['logo_url']?.toString();
  String? get bgImage => data['cover_url']?.toString();
  num? get avgRate => num.tryParse('${data['avg_rate'] ?? ''}');
  dynamic get serviceFees => data['service_fees'];
  dynamic get minOrderPrice => data['min_order_price'];
  String? get deliveryTime => data['delivery_time']?.toString();
  double? get distance => double.tryParse('${data['distance_km'] ?? ''}');
  bool get nearby => data['nearby'] == true;
}

class StoreImage extends StatelessWidget {
  const StoreImage({super.key, required this.imageUrl, required this.height, required this.width, this.radius = 0, this.fit = BoxFit.cover});
  final String imageUrl;
  final double height, width, radius;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) {
    Widget placeholder() => ColoredBox(color: const Color(0xFFFFF0E4), child: Center(child: Icon(Icons.storefront_rounded, size: math.min(height * .42, 48), color: AppColors.mainAppColor)));
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: SizedBox(height: height, width: width,
      child: imageUrl.trim().isEmpty ? placeholder() : Image.network(imageUrl, fit: fit,
        errorBuilder: (_, __, ___) => placeholder(), loadingBuilder: (_, child, progress) => progress == null ? child : placeholder())));
  }
}

/// Mirrors Fasakhansta's RestaurantsScreen layout with GO catalog data.
class StoreBrowseView extends StatelessWidget {
  const StoreBrowseView({super.key, required this.title, required this.address, required this.hasAddress,
    required this.onAddress, required this.items, required this.nearby, required this.total, required this.nearbyTotal,
    required this.loading, required this.failed, required this.onRefresh, required this.onRetry,
    required this.search, required this.onSearch, required this.sort, required this.onSort,
    required this.onOpen, required this.hasMore, required this.onMore});
  final String title, address, sort;
  final bool hasAddress, loading, failed, hasMore;
  final int total, nearbyTotal;
  final List<Map<String, dynamic>> items, nearby;
  final TextEditingController search;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onAddress;
  final VoidCallback onRetry, onMore;
  final ValueChanged<String> onSearch, onSort;
  final ValueChanged<Map<String, dynamic>> onOpen;

  String tr(BuildContext c, String ar, String en) => storeText(c, ar, en);
  Map<String, String> filters(BuildContext c) => {
    'name': tr(c, 'الكل', 'All'), 'nearest': tr(c, 'الأقرب', 'Nearest'),
    'rating': tr(c, 'الأعلى تقييماً', 'Top rated'), 'delivery': tr(c, 'الأسرع توصيلاً', 'Fastest delivery'),
  };
  // GO stores do not publish rating/time data yet. Never invent sorting scores.
  bool enabled(String value) => value == 'name' || (value == 'nearest' && hasAddress);
  void showFilters(BuildContext context) => showGoModalBottomSheet(context: context,
    builder: (sheet) => GoSheet(title: tr(context, 'ترتيب المتاجر', 'Sort stores'), icon: Icons.tune_rounded,
      child: Column(mainAxisSize: MainAxisSize.min, children: filters(context).entries.map((entry) => RadioListTile<String>(
        value: entry.key, groupValue: sort, activeColor: AppColors.mainAppColor,
        title: Text(entry.value, style: AppTextStyle.text14BS()),
        onChanged: enabled(entry.key) ? (value) { if (value != null) onSort(value); Navigator.pop(sheet); } : null,
      )).toList())));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF9FAFB),
    body: SafeArea(child: Column(children: [
      _TopBar(title: title, onBack: () => Navigator.maybePop(context)),
      Expanded(child: RefreshIndicator(color: AppColors.mainAppColor, onRefresh: onRefresh,
        child: ListView(physics: const AlwaysScrollableScrollPhysics(), keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, padding: const EdgeInsets.fromLTRB(16, 4, 16, 28), children: [
          Text(tr(context, 'اطلب من أقرب متجر أو تصفح كل المتاجر', 'Find nearby stores or browse them all'), textAlign: TextAlign.center,
            style: AppTextStyle.text13RG(color: const Color(0xFF777777))),
          const SizedBox(height: 16),
          _LocationCard(address: address, onChange: onAddress),
          const SizedBox(height: 22),
          _SectionHeader(icon: Icons.location_on_rounded, title: tr(context, 'متاجر قريبة منك', 'Nearby stores'),
            subtitle: tr(context, 'متاجر بالقرب من عنوان التوصيل الحالي', 'Stores near your current delivery address'), accent: const Color(0xFF0A857A), count: nearbyTotal),
          const SizedBox(height: 12),
          if (loading && nearby.isEmpty)
            const SizedBox(height: 112, child: Center(child: CircularProgressIndicator()))
          else if (nearby.isEmpty)
            _EmptySection(icon: Icons.delivery_dining_rounded,
              title: failed ? tr(context, 'تعذّر تحميل المتاجر القريبة', 'Could not load nearby stores') : hasAddress ? tr(context, 'لا توجد متاجر قريبة من عنوانك حالياً', 'No nearby stores at this address yet') : tr(context, 'حدد عنوان التوصيل', 'Choose a delivery address'),
              subtitle: tr(context, 'جرّب تغيير عنوان التوصيل أو تصفح كل المتاجر بالأسفل', 'Change your address or browse all stores below'))
          else
            SizedBox(height: 252 + math.max(0.0, MediaQuery.textScalerOf(context).scale(14) - 14) * 6,
              child: ListView.separated(scrollDirection: Axis.horizontal, padding: EdgeInsets.zero,
                itemCount: nearby.length, separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) { final item = GoStoreSummary(nearby[i]); return KeyedSubtree(key: ValueKey('go-nearby-store-${nearby[i]['id']}'),
                  child: _NearbyRestaurantCard(restaurant: item, distance: item.distance, onTap: () => onOpen(nearby[i]))); })),
          const SizedBox(height: 28),
          _SectionHeader(icon: Icons.storefront_rounded, title: tr(context, 'كل المتاجر', 'All stores'),
            subtitle: tr(context, 'جميع المتاجر المتاحة في هذا القسم', 'Every available store in this department'), accent: AppColors.mainAppColor, count: total),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: TextField(key: const ValueKey('go-store-search'), controller: search, onChanged: onSearch,
            textInputAction: TextInputAction.search, maxLength: 150,
            decoration: InputDecoration(counterText: '', hintText: tr(context, 'ابحث عن متجر', 'Search stores'),
              hintStyle: AppTextStyle.text13RG(color: const Color(0xFFAAAAAA)), prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF111111)),
              filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 14),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE7E7E7))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.mainAppColor, width: 1.3))))),
            const SizedBox(width: 10),
            InkWell(borderRadius: BorderRadius.circular(15), onTap: () => showFilters(context), child: Container(height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFE7E7E7)), boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 3))]),
              child: Row(children: [const Icon(Icons.tune_rounded, size: 19), const SizedBox(width: 5), Text(tr(context, 'فلتر', 'Filter'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))]))),
          ]),
          const SizedBox(height: 12),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: filters(context).entries.map((entry) {
            final selected = sort == entry.key;
            return Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: ChoiceChip(label: Text(entry.value), selected: selected,
              onSelected: enabled(entry.key) ? (_) => onSort(entry.key) : null, showCheckmark: false,
              side: BorderSide(color: selected ? AppColors.mainAppColor.withValues(alpha: .25) : const Color(0xFFE9E9E9)),
              selectedColor: const Color(0xFFFFF0E4), backgroundColor: Colors.white,
              labelStyle: AppTextStyle.text12BS(color: selected ? AppColors.mainAppColor : const Color(0xFF6B6B6B)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))));
          }).toList())),
          const SizedBox(height: 14),
          if (loading) const LinearProgressIndicator(),
          if (failed) Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Column(children: [
            Text(tr(context, 'تعذّر تحميل البيانات. حاول مرة أخرى.', 'Could not load the catalog. Please try again.'), textAlign: TextAlign.center),
            TextButton(onPressed: loading ? null : onRetry, child: Text(tr(context, 'إعادة المحاولة', 'Retry'))),
          ])),
          if (!loading && !failed && items.isEmpty) _EmptySection(icon: Icons.store_mall_directory_outlined,
            title: search.text.trim().isEmpty ? tr(context, 'لا توجد متاجر مسجلة في هذا القسم حاليًا', 'No stores are listed in this department yet') : tr(context, 'لا توجد متاجر مطابقة', 'No matching stores'),
            subtitle: search.text.trim().isEmpty ? tr(context, 'اسحب لأسفل لتحديث المتاجر', 'Pull down to refresh stores') : tr(context, 'جرّب كلمة بحث أخرى', 'Try another search')),
          for (final item in items) Padding(padding: const EdgeInsets.only(bottom: 11), child: KeyedSubtree(key: ValueKey('go-store-item-${item['id']}'),
            child: _AllRestaurantCard(restaurant: GoStoreSummary(item), distance: GoStoreSummary(item).distance,
              deliversHere: GoStoreSummary(item).nearby, onTap: () => onOpen(item)))),
          if (hasMore && !failed) TextButton(onPressed: loading ? null : onMore, child: Text(tr(context, 'عرض المزيد', 'Load more'))),
        ]))),
    ])),
  );
}

class _TopBar extends StatelessWidget {
  _TopBar({required this.onBack, required this.title});
  final VoidCallback onBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: IconButton(
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: 21),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  textDirection: isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
                  style: AppTextStyle.text20BS(),
                ),
              ),
            ),
            SizedBox(width: 52),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  _LocationCard({required this.address, required this.onChange});
  final String address;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xFFFFF9F4),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Color(0xFFFFDFC3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.mainAppColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.location_on_rounded, color: Colors.white, size: 27),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(storeText(context, 'عنوان التوصيل الحالي', 'Current delivery address'), style: AppTextStyle.text12RG(color: Color(0xFF777777))),
                SizedBox(height: 4),
                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.text14BS(),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          OutlinedButton(
            onPressed: onChange,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.mainAppColor),
              foregroundColor: AppColors.mainAppColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            child: Text(storeText(context, 'تغيير العنوان', 'Change address'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.count,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: accent.withValues(alpha: .10), shape: BoxShape.circle),
          child: Icon(icon, color: accent, size: 24),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyle.text20BS()),
              SizedBox(height: 2),
              Text(subtitle, style: AppTextStyle.text12RG(color: Color(0xFF808080))),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(color: accent.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
          child: Text('$count', style: AppTextStyle.text12BS(color: accent)),
        ),
      ],
    );
  }
}

class _NearbyRestaurantCard extends StatelessWidget {
  _NearbyRestaurantCard({
    required this.restaurant,
    required this.distance,
    required this.onTap,
  });

  final GoStoreSummary restaurant;
  final double? distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width * .72, 278.0);
    final image = (restaurant.bgImage ?? '').trim().isNotEmpty ? restaurant.bgImage! : (restaurant.logo ?? '');

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFFF0F0F0)),
              boxShadow: [BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 5))],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 118,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      StoreImage(imageUrl: image, height: 118, width: width, radius: 0, fit: BoxFit.cover),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x09000000), Color(0x33000000)],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFF0A857A),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 13),
                              SizedBox(width: 4),
                              Text(storeText(context, 'بالقرب منك', 'Nearby'), style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(11, 9, 11, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.text16BS(),
                      ),
                      SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Color(0xFFFF7A00), size: 17),
                          SizedBox(width: 3),
                          Text(_rate(restaurant.avgRate), style: AppTextStyle.text12BS()),
                        ],
                      ),
                      SizedBox(height: 9),
                      Divider(height: 1, color: Color(0xFFF0F0F0)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _MiniMetric(icon: Icons.location_on_outlined, value: _distance(context, distance), label: storeText(context, 'المسافة', 'Distance'))),
                          Expanded(child: _MiniMetric(icon: Icons.delivery_dining_rounded, value: _money(context, restaurant.serviceFees), label: storeText(context, 'التوصيل', 'Delivery'))),
                          Expanded(child: _MiniMetric(icon: Icons.schedule_rounded, value: _delivery(restaurant.deliveryTime), label: storeText(context, 'الوقت', 'Time'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AllRestaurantCard extends StatelessWidget {
  _AllRestaurantCard({
    required this.restaurant,
    required this.distance,
    required this.deliversHere,
    required this.onTap,
  });

  final GoStoreSummary restaurant;
  final double? distance;
  final bool deliversHere;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = (restaurant.logo ?? '').trim().isNotEmpty ? restaurant.logo! : (restaurant.bgImage ?? '');
    final address = (restaurant.address ?? '').trim().isNotEmpty
        ? restaurant.address!
        : (restaurant.cityName ?? restaurant.cityname ?? '');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: Color(0xFFF0F0F0)),
            boxShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: StoreImage(imageUrl: image, height: 78, width: 84, radius: 0, fit: BoxFit.cover),
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.text16BS(),
                              ),
                            ),
                            if (deliversHere)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F7F4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(storeText(context, 'بالقرب منك', 'Nearby'), style: TextStyle(color: Color(0xFF0A857A), fontSize: 9, fontWeight: FontWeight.w700)),
                              ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF8A8A8A)),
                            SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.text11RG(color: Color(0xFF7E7E7E)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 17, color: Color(0xFFFF7A00)),
                            SizedBox(width: 3),
                            Text(_rate(restaurant.avgRate), style: AppTextStyle.text12BS()),
                            if (distance != null) ...[
                              SizedBox(width: 12),
                              Icon(Icons.near_me_outlined, size: 14, color: Color(0xFF0A857A)),
                              SizedBox(width: 3),
                              Text(_distance(context, distance), style: AppTextStyle.text11BS(color: Color(0xFF0A857A))),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(isArabic(context) ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, color: AppColors.mainAppColor, size: 23),
                ],
              ),
              SizedBox(height: 10),
              Divider(height: 1, color: Color(0xFFF1F1F1)),
              SizedBox(height: 9),
              Row(
                children: [
                  Expanded(child: _MiniMetric(icon: Icons.schedule_rounded, value: _delivery(restaurant.deliveryTime), label: storeText(context, 'وقت التوصيل', 'Delivery time'))),
                  _verticalDivider(),
                  Expanded(child: _MiniMetric(icon: Icons.delivery_dining_rounded, value: _money(context, restaurant.serviceFees), label: storeText(context, 'رسوم التوصيل', 'Delivery fee'))),
                  _verticalDivider(),
                  Expanded(child: _MiniMetric(icon: Icons.shopping_bag_outlined, value: _money(context, restaurant.minOrderPrice), label: storeText(context, 'الحد الأدنى', 'Minimum order'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider() => Container(width: 1, height: 37, color: Color(0xFFEDEDED));
}

class _MiniMetric extends StatelessWidget {
  _MiniMetric({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Color(0xFF0A857A)),
        SizedBox(height: 3),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyle.text11BS()),
        SizedBox(height: 1),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyle.text9RG(color: Color(0xFF888888))),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  _EmptySection({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: AppColors.mainAppColor),
          SizedBox(height: 9),
          Text(title, textAlign: TextAlign.center, style: AppTextStyle.text14BS()),
          SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: AppTextStyle.text11RG(color: Color(0xFF888888))),
        ],
      ),
    );
  }
}


String _rate(num? value) => value == null ? '—' : value.toStringAsFixed(1);
String _money(BuildContext context, dynamic value) {
  final number = value is num ? value : num.tryParse('${value ?? ''}');
  if (number == null) return '—';
  return '${number.toStringAsFixed(number % 1 == 0 ? 0 : 2)} ${storeText(context, 'ج', 'EGP')}';
}
String _delivery(String? value) => value == null || value.trim().isEmpty ? '—' : value;
String _distance(BuildContext context, double? value) => value == null ? '—' : '${value.toStringAsFixed(value < 10 ? 1 : 0)} ${storeText(context, 'كم', 'km')}';
