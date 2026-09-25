import 'package:flutter/material.dart';

import '../../../custom_widgets/go_drive_brand.dart';
import 'service_photo_sprite.dart';

abstract final class GoHomeStyle {
  static const ink = Color(0xff171A1F);
  static const orange = Color(0xffFD7201);
  static const muted = Color(0xff7D8490);
  static const border = Color(0xffECEEF1);
}

class GoService {
  const GoService(this.key, this.ar, this.en, this.imageIndex, this.icon);
  final String key;
  final String ar;
  final String en;
  final int imageIndex;
  final IconData icon;
}

// Preserve the existing API profession keys and all 19 service entry points.
const goServices = <GoService>[
  GoService('delivery_courier', 'طلب مندوب توصيل', 'Delivery courier', 0, Icons.delivery_dining),
  GoService('appliance_technician', 'فني صيانة ثلاجات وغسالات', 'Fridge & washer technician', 1, Icons.home_repair_service),
  GoService('plumber', 'سباك', 'Plumber', 2, Icons.plumbing),
  GoService('painter', 'نقاش', 'Painter', 3, Icons.format_paint),
  GoService('tile_installer', 'فني تركيب بلاط', 'Tile installer', 4, Icons.grid_view),
  GoService('marble_installer', 'فني تركيب رخام', 'Marble installer', 5, Icons.square_foot),
  GoService('blacksmith', 'حداد', 'Blacksmith', 6, Icons.construction),
  GoService('electrician', 'كهربائي', 'Electrician', 7, Icons.electrical_services),
  GoService('satellite_technician', 'فني تركيب وصيانة الدش', 'Satellite technician', 8, Icons.satellite_alt),
  GoService('furniture_carpenter', 'نجار أثاث', 'Furniture carpenter', 9, Icons.carpenter),
  GoService('ac_technician', 'فني تكييف', 'AC technician', 10, Icons.ac_unit),
  GoService('construction_worker', 'عامل بناء', 'Construction worker', 11, Icons.engineering),
  GoService('auto_mechanic', 'ميكانيكي سيارات', 'Auto mechanic', 12, Icons.car_repair),
  GoService('auto_electrician', 'كهربائي سيارات', 'Auto electrician', 12, Icons.electric_car),
  GoService('mens_barber', 'كوافير رجالي', 'Men barber', 13, Icons.content_cut),
  GoService('womens_hairdresser', 'كوافيرة سيدات', 'Women hairdresser', 13, Icons.face_retouching_natural),
  GoService('tailor', 'خياط', 'Tailor', 14, Icons.checkroom),
  GoService('male_cleaner', 'عامل نظافة', 'Male cleaner', 15, Icons.cleaning_services),
  GoService('female_cleaner', 'عاملة نظافة', 'Female cleaner', 15, Icons.cleaning_services),
];

/// Testable presentation, isolated from sessions, payments and network calls.
class GoCustomerHomeView extends StatefulWidget {
  const GoCustomerHomeView({
    super.key,
    required this.isArabic,
    required this.firstName,
    required this.locationTitle,
    required this.locationSubtitle,
    required this.notificationCount,
    required this.onAddress,
    required this.onNotifications,
    required this.onService,
    this.drawer,
  });
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
  String t(String arabic, String english) => ar ? arabic : english;
  List<GoService> get matches => goServices.where((s) =>
      '${s.ar} ${s.en}'.toLowerCase().contains(_search.trim().toLowerCase())).toList();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _allServices() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheet) => Directionality(
        textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(sheet).height * .72,
            child: Column(children: [
              Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                Expanded(child: Text(t('كل الخدمات', 'All services'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
                IconButton(onPressed: () => Navigator.pop(sheet), tooltip: t('إغلاق', 'Close'), icon: const Icon(Icons.close)),
              ])),
              Expanded(child: ListView.builder(
                itemCount: goServices.length,
                itemBuilder: (_, index) {
                  final service = goServices[index];
                  return ListTile(
                    leading: Icon(service.icon, color: GoHomeStyle.orange),
                    title: Text(ar ? service.ar : service.en),
                    trailing: const Icon(Icons.chevron_left, size: 18),
                    onTap: () { Navigator.pop(sheet); widget.onService(service); },
                  );
                },
              )),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = matches;
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: const ValueKey('go-approved-home-v2'),
        backgroundColor: GoHomeStyle.ink,
        drawer: widget.drawer,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _searchField()),
            SliverToBoxAdapter(child: _hero()),
            SliverToBoxAdapter(child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('خدماتنا', 'Our services'), style: const TextStyle(color: GoHomeStyle.ink, fontWeight: FontWeight.w900, fontSize: 21)),
                  Text(t('كل ما تحتاجه في مكان واحد', 'Everything in one place'), style: const TextStyle(color: GoHomeStyle.muted, fontSize: 12)),
                ])),
                TextButton(onPressed: _allServices, child: Text(t('عرض الكل', 'View all'), style: const TextStyle(color: GoHomeStyle.orange, fontWeight: FontWeight.w800))),
              ]),
            )),
            SliverToBoxAdapter(child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: services.isEmpty
                    ? Padding(padding: const EdgeInsets.all(32), child: Text(t('لا توجد خدمة بهذا الاسم', 'No matching service'), textAlign: TextAlign.center))
                    : LayoutBuilder(builder: (_, constraints) {
                        final columns = constraints.maxWidth >= 900 ? 6 : constraints.maxWidth >= 600 ? 4 : 3;
                        final textScale = MediaQuery.textScalerOf(context).scale(1);
                        final cardWidth = (constraints.maxWidth - 10 * (columns - 1)) / columns;
                        final height = cardWidth * 2 / 3 + 64 * textScale;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: services.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns, crossAxisSpacing: 10, mainAxisSpacing: 12, mainAxisExtent: height,
                          ),
                          itemBuilder: (_, index) => _serviceCard(services[index]),
                        );
                      }),
              ),
            )),
            SliverToBoxAdapter(child: ColoredBox(color: Colors.white, child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(children: [
                // Existing service shortcuts retained, without invented discounts.
                Wrap(spacing: 8, runSpacing: 8, children: [
                  ActionChip(avatar: const Icon(Icons.ac_unit, size: 18), label: Text(t('صيانة التكييف', 'AC maintenance')), onPressed: () => widget.onService(goServices[10])),
                  ActionChip(avatar: const Icon(Icons.cleaning_services, size: 18), label: Text(t('خدمات النظافة', 'Cleaning services')), onPressed: () => widget.onService(goServices[17])),
                ]),
                const SizedBox(height: 16),
                const GoDriveBrand(size: 30),
                const SizedBox(height: 8),
                Text(t('كل الخدمات عندك', 'Every service, one app'), style: const TextStyle(color: GoHomeStyle.muted, fontWeight: FontWeight.w600)),
              ]),
            ))),
          ]),
        ),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
    child: Column(children: [
      Row(children: [
        if (widget.drawer != null) Builder(builder: (scaffoldContext) => IconButton(
          tooltip: t('القائمة', 'Menu'), onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
        )),
        Expanded(child: InkWell(
          key: const ValueKey('go-home-address'),
          onTap: widget.onAddress,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.location_on, color: GoHomeStyle.orange, size: 21),
              const SizedBox(width: 5),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.locationTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: GoHomeStyle.ink, fontWeight: FontWeight.w800)),
                Text(widget.locationSubtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: GoHomeStyle.muted)),
              ])),
            ]),
          ),
        )),
        const SizedBox(width: 12),
        Column(children: [
          const GoDriveBrand(size: 30, light: true),
          const SizedBox(height: 3),
          Text(t('كل الخدمات عندك', 'Every service, one app'), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(width: 8),
        Stack(children: [
          IconButton(key: const ValueKey('go-home-notifications'), tooltip: t('الإشعارات', 'Notifications'), onPressed: widget.onNotifications,
              icon: const Icon(Icons.notifications_outlined, color: Colors.white)),
          if (widget.notificationCount > 0) const Positioned(top: 8, right: 9, child: CircleAvatar(radius: 4, backgroundColor: GoHomeStyle.orange)),
        ]),
      ]),
      const SizedBox(height: 14),
      Align(alignment: AlignmentDirectional.centerStart, child: Text(
        widget.firstName.isEmpty ? t('أهلاً بك في GO', 'Welcome to GO') : t('مرحباً ${widget.firstName}', 'Hi ${widget.firstName}'),
        style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
      )),
    ]),
  );

  Widget _searchField() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
    child: TextField(
      key: const ValueKey('go-home-search'),
      controller: _query,
      onChanged: (value) => setState(() => _search = value),
      style: const TextStyle(color: GoHomeStyle.ink, fontSize: 13),
      decoration: InputDecoration(
        hintText: t('ابحث عن الخدمة التي تحتاجها…', 'Search for a service…'),
        hintStyle: const TextStyle(color: GoHomeStyle.muted),
        filled: true, fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search, color: GoHomeStyle.ink),
        suffixIcon: IconButton(
          tooltip: _search.isEmpty ? t('كل الخدمات', 'All services') : t('مسح البحث', 'Clear search'),
          onPressed: _search.isEmpty ? _allServices : () { _query.clear(); setState(() => _search = ''); },
          icon: Icon(_search.isEmpty ? Icons.tune : Icons.close, color: GoHomeStyle.orange),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    ),
  );

  Widget _hero() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
    child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xff0D1B24), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white12)),
      child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(flex: 6, child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('محتاج خدمة؟', 'Need a service?'), style: const TextStyle(color: GoHomeStyle.orange, fontWeight: FontWeight.w900, fontSize: 24)),
            const SizedBox(height: 6),
            Text(t('اختار خدمتك\nوسيب الباقي علينا', 'Choose your service.\nWe take care of the rest.'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, height: 1.4)),
            const SizedBox(height: 14),
            FilledButton.icon(
              key: const ValueKey('go-home-book'), onPressed: _allServices,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(t('اطلب الآن', 'Book now')),
              style: FilledButton.styleFrom(backgroundColor: GoHomeStyle.orange, foregroundColor: Colors.white,
                  minimumSize: const Size(0, 46), padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ))),
        Expanded(flex: 4, child: Stack(fit: StackFit.expand, children: [
          const GoServicePhoto(index: 0),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xdd0D1B24)]))),
          const Positioned(bottom: 12, left: 12, right: 12, child: Center(child: GoDriveBrand(size: 32, light: true))),
        ])),
      ])),
    ),
  );

  Widget _serviceCard(GoService service) => Material(
    key: ValueKey('go-service-${service.key}'),
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: service.key == 'delivery_courier' ? GoHomeStyle.orange : GoHomeStyle.border)),
    clipBehavior: Clip.antiAlias,
    child: InkWell(onTap: () => widget.onService(service), child: Padding(
      padding: const EdgeInsets.all(6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: AspectRatio(aspectRatio: 1.5, child: Stack(fit: StackFit.expand, children: [
          GoServicePhoto(index: service.imageIndex),
          Positioned(top: 4, right: 4, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)), child: Icon(service.icon, size: 13, color: GoHomeStyle.orange))),
        ]))),
        Expanded(child: Center(child: Text(ar ? service.ar : service.en,
            textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: GoHomeStyle.ink, fontSize: 11.5, height: 1.25, fontWeight: FontWeight.w800)))),
      ]),
    )),
  );
}

class GoServicePhoto extends StatelessWidget {
  const GoServicePhoto({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => ClipRect(child: FittedBox(
    fit: BoxFit.cover,
    child: SizedBox(width: 180, height: 120, child: Stack(children: [
      Positioned(left: -(index % 4) * 180.0, top: -(index ~/ 4) * 120.0, width: 720, height: 480,
          child: Image.memory(goServiceSpriteBytes, fit: BoxFit.fill, gaplessPlayback: true, filterQuality: FilterQuality.high)),
    ])),
  ));
}
