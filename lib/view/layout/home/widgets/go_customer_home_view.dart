import 'package:flutter/material.dart';

import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../custom_widgets/go_drive_brand.dart';
import 'service_photo_sprite.dart';

abstract final class GoHomeStyle {
  static const ink = GoDesign.deepInk;
  static const orange = GoDesign.orange;
  static const muted = GoDesign.muted;
  static const border = GoDesign.border;
}

class GoService {
  const GoService(this.key, this.ar, this.en, this.imageIndex, this.icon);
  final String key;
  final String ar;
  final String en;
  final int imageIndex;
  final IconData icon;
}

// API profession keys are stable. Display changes must never rename them.
const goServices = <GoService>[
  GoService('delivery_courier', 'طلب مندوب توصيل', 'Delivery courier', 0, Icons.delivery_dining),
  GoService('appliance_technician', 'فني صيانة ثلاجات وغسالات', 'Appliance repair', 1, Icons.home_repair_service),
  GoService('plumber', 'سباك', 'Plumber', 2, Icons.plumbing),
  GoService('painter', 'نقاش', 'Painter', 3, Icons.format_paint),
  GoService('tile_installer', 'فني تركيب بلاط', 'Tile installer', 4, Icons.grid_view),
  GoService('marble_installer', 'فني تركيب رخام', 'Marble installer', 5, Icons.square_foot),
  GoService('blacksmith', 'حداد', 'Blacksmith', 6, Icons.construction),
  GoService('electrician', 'كهربائي', 'Electrician', 7, Icons.electrical_services),
  GoService('satellite_technician', 'فني تركيب وصيانة الدش', 'Satellite technician', 8, Icons.satellite_alt),
  GoService('furniture_carpenter', 'نجار أثاث', 'Furniture carpenter', 9, Icons.carpenter),
  GoService('ac_technician', 'فني تكييف', 'Air conditioning technician', 10, Icons.ac_unit),
  GoService('construction_worker', 'عامل بناء', 'Construction worker', 11, Icons.engineering),
  GoService('auto_mechanic', 'ميكانيكي سيارات', 'Car mechanic', 12, Icons.car_repair),
  GoService('auto_electrician', 'كهربائي سيارات', 'Auto electrician', 12, Icons.electric_car),
  GoService('mens_barber', 'كوافير رجالي', 'Men’s barber', 13, Icons.content_cut),
  GoService('womens_hairdresser', 'كوافيرة سيدات', 'Women’s hairdresser', 13, Icons.face_retouching_natural),
  GoService('tailor', 'خياط', 'Tailor', 14, Icons.checkroom),
  GoService('male_cleaner', 'عامل نظافة', 'Male cleaner', 15, Icons.cleaning_services),
  GoService('female_cleaner', 'عاملة نظافة', 'Female cleaner', 15, Icons.cleaning_services),
];

class GoCustomerHomeView extends StatefulWidget {
  const GoCustomerHomeView({super.key, required this.isArabic, required this.firstName,
    required this.locationTitle, required this.locationSubtitle, required this.notificationCount,
    required this.onAddress, required this.onNotifications, required this.onService, this.drawer});
  final bool isArabic;
  final String firstName;
  final String locationTitle;
  final String locationSubtitle;
  final int notificationCount;
  final VoidCallback onAddress;
  final VoidCallback onNotifications;
  final ValueChanged<GoService> onService;
  final Widget? drawer;
  @override
  State<GoCustomerHomeView> createState() => _GoCustomerHomeViewState();
}

class _GoCustomerHomeViewState extends State<GoCustomerHomeView> {
  final _query = TextEditingController();
  String _search = '';
  bool get ar => widget.isArabic;
  String t(String a, String e) => ar ? a : e;
  @override
  void dispose() { _query.dispose(); super.dispose(); }

  void _allServices() => showModalBottomSheet<void>(context: context, isScrollControlled: true,
    backgroundColor: GoDesign.paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheet) => Directionality(textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(child: SizedBox(height: MediaQuery.sizeOf(sheet).height * .75,
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 12, 8), child: Row(children: [
            Expanded(child: Text(t('كل الخدمات', 'All services'),
              style: const TextStyle(color: GoDesign.ink, fontSize: 21, fontWeight: FontWeight.w800))),
            IconButton(tooltip: t('إغلاق', 'Close'), onPressed: () => Navigator.pop(sheet), icon: const Icon(Icons.close)),
          ])),
          Expanded(child: ListView.separated(itemCount: goServices.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: GoDesign.border),
            itemBuilder: (_, index) {
              final service = goServices[index];
              return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: ClipRRect(borderRadius: BorderRadius.circular(8),
                  child: SizedBox(width: 58, height: 44, child: GoServicePhoto(index: service.imageIndex))),
                title: Text(ar ? service.ar : service.en, style: const TextStyle(color: GoDesign.ink, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.location_on, color: GoDesign.orange, size: 19),
                onTap: () { Navigator.pop(sheet); widget.onService(service); });
            })),
        ]),
      )),
    ));

  @override
  Widget build(BuildContext context) {
    final search = _search.trim().toLowerCase();
    final services = goServices.where((service) => search.isEmpty ||
      service.ar.toLowerCase().contains(search) || service.en.toLowerCase().contains(search)).toList();
    return Directionality(textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(key: const ValueKey('go-approved-home-v2'),
        backgroundColor: GoDesign.deepInk, drawer: widget.drawer,
        body: SafeArea(bottom: false, child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverToBoxAdapter(child: _searchField()),
          if (search.isEmpty) SliverToBoxAdapter(child: _hero()),
          SliverToBoxAdapter(child: Container(color: GoDesign.paper,
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 4), child: Row(children: [
              Expanded(child: Text(t('خدماتنا', 'Our services'),
                style: const TextStyle(color: GoDesign.ink, fontSize: 21, fontWeight: FontWeight.w800))),
              TextButton(onPressed: _allServices, child: Text(t('عرض الكل', 'View all'))),
            ]))),
          if (services.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: ColoredBox(color: GoDesign.paper,
              child: Center(child: Padding(padding: const EdgeInsets.all(28),
                child: Text(t('لا توجد خدمة مطابقة للبحث', 'No matching services'),
                  style: const TextStyle(color: GoDesign.muted, fontSize: 16))))))
          else
            SliverToBoxAdapter(child: ColoredBox(color: GoDesign.paper, child: LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 6 : constraints.maxWidth >= 600 ? 4 : 3;
              final cardWidth = (constraints.maxWidth - 32 - (columns - 1) * 10) / columns;
              final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
              return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns,
                  crossAxisSpacing: 10, mainAxisSpacing: 10, mainAxisExtent: cardWidth / 1.5 + 58 * scale),
                itemCount: services.length, itemBuilder: (_, index) => _serviceCard(services[index]));
            }))),
          if (services.isNotEmpty) SliverFillRemaining(hasScrollBody: false, child: Container(color: GoDesign.paper,
            alignment: Alignment.topCenter, padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
            child: Text(t('كل الخدمات عندك', 'Every service, one app'),
              style: const TextStyle(color: GoDesign.muted, fontSize: 13)))),
        ])),
      ),
    );
  }

  Widget _header() => Builder(builder: (context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
    child: Row(children: [
      Expanded(child: Material(color: GoDesign.paper, borderRadius: BorderRadius.circular(12),
        child: InkWell(key: const ValueKey('go-home-address'), onTap: widget.onAddress,
          borderRadius: BorderRadius.circular(12), child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(children: [
              const Icon(Icons.location_on, color: GoDesign.orange, size: 22),
              const SizedBox(width: 5),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.locationTitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: GoDesign.ink, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(widget.locationSubtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: GoDesign.muted, fontSize: 10)),
              ])),
            ]),
          )),
      )),
      const SizedBox(width: 12),
      SizedBox(width: 74, child: Column(mainAxisSize: MainAxisSize.min, children: [
        const GoDriveBrand(size: 25, light: true),
        Text(t('كل الخدمات عندك', 'Every service'), textAlign: TextAlign.center,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 8)),
      ])),
      const SizedBox(width: 4),
      IconButton(key: const ValueKey('go-home-notifications'), tooltip: t('الإشعارات', 'Notifications'),
        onPressed: widget.onNotifications, constraints: const BoxConstraints(minHeight: 48, minWidth: 40),
        icon: Badge(isLabelVisible: widget.notificationCount > 0,
          backgroundColor: GoDesign.orange, label: Text('${widget.notificationCount}'),
          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 23))),
      if (widget.drawer != null) IconButton(tooltip: t('القائمة', 'Menu'),
        onPressed: () => Scaffold.of(context).openDrawer(),
        constraints: const BoxConstraints(minHeight: 48, minWidth: 40),
        icon: const Icon(Icons.menu, color: Colors.white, size: 22)),
    ]),
  ));

  Widget _searchField() => Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: TextField(key: const ValueKey('go-home-search'), controller: _query,
      onChanged: (value) => setState(() => _search = value),
      style: const TextStyle(color: GoDesign.ink, fontSize: 14),
      decoration: InputDecoration(hintText: t('ابحث عن الخدمة التي تحتاجها…', 'Search for a service…'),
        hintStyle: const TextStyle(color: GoDesign.muted, fontSize: 13),
        filled: true, fillColor: GoDesign.paper, prefixIcon: const Icon(Icons.search, color: GoDesign.ink),
        suffixIcon: IconButton(tooltip: _search.isEmpty ? t('كل الخدمات', 'All services') : t('مسح البحث', 'Clear search'),
          onPressed: _search.isEmpty ? _allServices : () { _query.clear(); setState(() => _search = ''); },
          icon: Icon(_search.isEmpty ? Icons.tune : Icons.close, color: GoDesign.orange)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14))),
  );

  Widget _hero() => Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
    child: ClipRRect(borderRadius: BorderRadius.circular(16), child: IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(flex: 6, child: Padding(padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t('محتاج فني؟', 'Need a pro?'), style: const TextStyle(color: GoDesign.orange, fontSize: 25, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(t('اختار خدمتك\nوسيب الباقي علينا', 'Choose your service.\nWe take care of the rest.'),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.4)),
            const SizedBox(height: 18),
            FilledButton.icon(key: const ValueKey('go-home-book'), onPressed: _allServices,
              style: FilledButton.styleFrom(backgroundColor: GoDesign.orange, foregroundColor: Colors.white,
                minimumSize: const Size(0, 48), padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.arrow_forward, size: 17),
              label: Text(t('اطلب الآن', 'Book now'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
          ]))),
        Expanded(flex: 4, child: Stack(fit: StackFit.expand, children: [
          const GoServicePhoto(index: 2),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter,
            end: Alignment.bottomCenter, colors: [Colors.transparent, GoDesign.deepInk]))),
        ])),
      ]),
    )),
  );

  Widget _serviceCard(GoService service) => Material(key: ValueKey('go-service-${service.key}'),
    color: GoDesign.paper, borderRadius: BorderRadius.circular(12), clipBehavior: Clip.antiAlias,
    child: InkWell(onTap: () => widget.onService(service), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ClipRRect(borderRadius: BorderRadius.circular(12), child: AspectRatio(aspectRatio: 1.5,
        child: Stack(fit: StackFit.expand, children: [
          GoServicePhoto(index: service.imageIndex),
          PositionedDirectional(top: 5, end: 5, child: Container(width: 24, height: 24,
            decoration: const BoxDecoration(color: GoDesign.paper, shape: BoxShape.circle),
            child: Icon(service.icon, size: 14, color: GoDesign.orange))),
        ]))),
      Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(2, 6, 2, 2), child: Text(ar ? service.ar : service.en,
        textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: GoDesign.ink, fontSize: 12, fontWeight: FontWeight.w700, height: 1.25)))),
    ])),
  );
}

class GoServicePhoto extends StatelessWidget {
  const GoServicePhoto({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => ClipRect(child: FittedBox(fit: BoxFit.cover,
    child: SizedBox(width: 180, height: 120, child: Stack(children: [
      Positioned(left: -(index % 4) * 180.0, top: -(index ~/ 4) * 120.0, width: 720, height: 480,
        child: Image.memory(goServiceSpriteBytes, fit: BoxFit.fill, gaplessPlayback: true, filterQuality: FilterQuality.high)),
    ])),
  ));
}
