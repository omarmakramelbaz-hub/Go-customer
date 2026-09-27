import 'package:flutter/material.dart';

import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../custom_widgets/go_drive_brand.dart';
import 'service_photo_sprite.dart';
import 'go_product_department.dart';

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
  GoService('delivery_courier', 'طلب مندوب توصيل', 'Delivery courier', 0,
      Icons.delivery_dining),
  GoService('appliance_technician', 'فني صيانة ثلاجات وغسالات',
      'Appliance repair', 1, Icons.home_repair_service),
  GoService('plumber', 'سباك', 'Plumber', 2, Icons.plumbing),
  GoService('painter', 'نقاش', 'Painter', 3, Icons.format_paint),
  GoService(
      'tile_installer', 'فني تركيب بلاط', 'Tile installer', 4, Icons.grid_view),
  GoService('marble_installer', 'فني تركيب رخام', 'Marble installer', 5,
      Icons.square_foot),
  GoService('blacksmith', 'حداد', 'Blacksmith', 6, Icons.construction),
  GoService(
      'electrician', 'كهربائي', 'Electrician', 7, Icons.electrical_services),
  GoService('satellite_technician', 'فني تركيب وصيانة الدش',
      'Satellite technician', 8, Icons.satellite_alt),
  GoService('furniture_carpenter', 'نجار أثاث', 'Furniture carpenter', 9,
      Icons.carpenter),
  GoService('ac_technician', 'فني تكييف', 'Air conditioning technician', 10,
      Icons.ac_unit),
  GoService('construction_worker', 'عامل بناء', 'Construction worker', 11,
      Icons.engineering),
  GoService(
      'auto_mechanic', 'ميكانيكي سيارات', 'Car mechanic', 12, Icons.car_repair),
  GoService('auto_electrician', 'كهربائي سيارات', 'Auto electrician', 12,
      Icons.electric_car),
  GoService(
      'mens_barber', 'كوافير رجالي', 'Men’s barber', 13, Icons.content_cut),
  GoService('womens_hairdresser', 'كوافيرة سيدات', 'Women’s hairdresser', 13,
      Icons.face_retouching_natural),
  GoService('tailor', 'خياط', 'Tailor', 14, Icons.checkroom),
  GoService('male_cleaner', 'عامل نظافة', 'Male cleaner', 15,
      Icons.cleaning_services),
  GoService('female_cleaner', 'عاملة نظافة', 'Female cleaner', 15,
      Icons.cleaning_services),
];

class GoCustomerHomeView extends StatefulWidget {
  const GoCustomerHomeView(
      {super.key,
      required this.isArabic,
      required this.firstName,
      required this.locationTitle,
      required this.locationSubtitle,
      required this.notificationCount,
      required this.onAddress,
      required this.onNotifications,
      required this.onService,
      this.drawer});
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
  final _scroll = ScrollController();
  final _departmentKeys = {
    for (final item in GoProductDepartment.values) item: GlobalKey()
  };
  String _search = '';
  bool get ar => widget.isArabic;
  String t(String a, String e) => ar ? a : e;

  @override
  void dispose() {
    _query.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _openDepartment(GoProductDepartment department) {
    FocusManager.instance.primaryFocus?.unfocus();
    _query.clear();
    setState(() => _search = '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = _departmentKeys[department]!.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(target,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: 0.02);
      }
    });
  }

  void _allServices() => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GoDesign.paper,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(GoDesign.sheetRadius))),
      builder: (sheet) => Directionality(
            textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
            child: SafeArea(
                child: SizedBox(
              height: MediaQuery.sizeOf(sheet).height * .75,
              child: Column(children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                    child: Row(children: [
                      Expanded(
                          child: Text(t('كل الخدمات', 'All services'),
                              style: const TextStyle(
                                  color: GoDesign.ink,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800))),
                      IconButton(
                          tooltip: t('إغلاق', 'Close'),
                          onPressed: () => Navigator.pop(sheet),
                          icon: const Icon(Icons.close)),
                    ])),
                Expanded(
                    child: ListView.separated(
                        itemCount: goServices.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: GoDesign.border),
                        itemBuilder: (_, index) {
                          final service = goServices[index];
                          return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                      width: 58,
                                      height: 44,
                                      child: GoServicePhoto(
                                          index: service.imageIndex))),
                              title: Text(ar ? service.ar : service.en,
                                  style: const TextStyle(
                                      color: GoDesign.ink,
                                      fontWeight: FontWeight.w600)),
                              trailing: const Icon(Icons.chevron_right,
                                  color: GoDesign.orange, size: 21),
                              onTap: () {
                                Navigator.pop(sheet);
                                widget.onService(service);
                              });
                        })),
              ]),
            )),
          ));

  @override
  Widget build(BuildContext context) {
    final search = _search.trim().toLowerCase();
    final matchingServices = goServices
        .where((service) =>
            search.isEmpty ||
            service.ar.contains(search) ||
            service.en.toLowerCase().contains(search))
        .toList();
    final services =
        search.isEmpty ? matchingServices.take(9).toList() : matchingServices;
    final departments = GoProductDepartment.values
        .where((item) => search.isEmpty || item.matches(search))
        .toList();
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: const ValueKey('go-approved-home-v2'),
        backgroundColor: GoDesign.deepInk,
        drawer: widget.drawer,
        body: SafeArea(
            bottom: false,
            child: ColoredBox(
              color: GoDesign.canvas,
              child: SingleChildScrollView(
                controller: _scroll,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Center(
                    child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                            decoration: const BoxDecoration(
                                color: GoDesign.deepInk,
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(24))),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _header(),
                                  if (search.isEmpty)
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 6, 20, 20),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  t('كل اللي تحتاجه، عندك',
                                                      'Everything you need, nearby'),
                                                  style: const TextStyle(
                                                      color: GoDesign.paper,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      height: 1.35)),
                                              const SizedBox(height: 6),
                                              Text(
                                                  t('مشترياتك وخدماتك اليومية في مكان واحد',
                                                      'Your everyday shopping and services in one place'),
                                                  style: const TextStyle(
                                                      color: Color(0xFFC0C5CB),
                                                      fontSize: 13,
                                                      height: 1.5)),
                                            ])),
                                  _searchField(),
                                ])),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _shortcuts(),
                                  const SizedBox(height: 18),
                                  if (services.isNotEmpty) ...[
                                    Row(children: [
                                      Expanded(
                                          child: Text(
                                              t('اطلب خدمة', 'Book a service'),
                                              style: const TextStyle(
                                                  color: GoDesign.ink,
                                                  fontSize: 21,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      TextButton(
                                          key: const ValueKey('go-home-book'),
                                          onPressed: _allServices,
                                          child:
                                              Text(t('عرض الكل', 'View all'))),
                                    ]),
                                    const SizedBox(height: 6),
                                    LayoutBuilder(
                                        builder: (context, constraints) {
                                      final columns =
                                          constraints.maxWidth >= 860
                                              ? 6
                                              : constraints.maxWidth >= 560
                                                  ? 4
                                                  : 3;
                                      final width = (constraints.maxWidth -
                                              (columns - 1) * 10) /
                                          columns;
                                      final textHeight =
                                          MediaQuery.textScalerOf(context)
                                                  .scale(12) *
                                              1.35 *
                                              3;
                                      return GridView.builder(
                                          shrinkWrap: true,
                                          primary: false,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: columns,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                  mainAxisExtent:
                                                      (width - 10) / 1.5 +
                                                          textHeight +
                                                          15),
                                          itemCount: services.length,
                                          itemBuilder: (_, index) =>
                                              _serviceCard(services[index]));
                                    }),
                                  ],
                                  for (final department in departments)
                                    Padding(
                                        key: _departmentKeys[department],
                                        padding: const EdgeInsets.only(top: 28),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(department.title(ar),
                                                  style: const TextStyle(
                                                      color: GoDesign.ink,
                                                      fontSize: 21,
                                                      fontWeight:
                                                          FontWeight.w800)),
                                              const SizedBox(height: 12),
                                              GoProductDepartmentCard(
                                                  department: department,
                                                  isArabic: ar),
                                            ])),
                                  if (services.isEmpty && departments.isEmpty)
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 44, horizontal: 12),
                                        child: Column(children: [
                                          const Icon(Icons.search_off_rounded,
                                              size: 34, color: GoDesign.muted),
                                          const SizedBox(height: 12),
                                          Text(
                                              t('لا توجد نتائج مطابقة للبحث',
                                                  'No matching results'),
                                              style: const TextStyle(
                                                  color: GoDesign.authMuted,
                                                  fontSize: 15)),
                                        ])),
                                ])),
                      ]),
                )),
              ),
            )),
      ),
    );
  }

  Widget _shortcuts() => LayoutBuilder(builder: (context, constraints) {
        final large = MediaQuery.textScalerOf(context).scale(13) > 18;
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final department in GoProductDepartment.values) ...[
            if (department != GoProductDepartment.values.first)
              const SizedBox(width: 8),
            Expanded(
                child: Material(
              color: GoDesign.orangeTint,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                key: ValueKey('go-product-${department.name}'),
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openDepartment(department),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 11),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(department.icon,
                            color: GoDesign.orange, size: large ? 22 : 19),
                        const SizedBox(height: 5),
                        Text(department.title(ar),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Color(0xFF8B4100),
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ])),
                ),
              ),
            )),
          ],
        ]);
      });

  Widget _header() => Builder(
      builder: (context) => Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
            child: Row(children: [
              Expanded(
                  child: Material(
                color: const Color(0xFF25292F),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                    key: const ValueKey('go-home-address'),
                    onTap: widget.onAddress,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 10),
                      child: Row(children: [
                        const Icon(Icons.location_on_outlined,
                            color: GoDesign.orange, size: 21),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(widget.locationTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: GoDesign.paper,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(widget.locationSubtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xFFBEC4CB), fontSize: 11)),
                            ])),
                      ]),
                    )),
              )),
              const SizedBox(width: 10),
              const SizedBox(
                  width: 60, child: GoDriveBrand(size: 24, light: true)),
              const SizedBox(width: 3),
              IconButton(
                  key: const ValueKey('go-home-notifications'),
                  tooltip: t('الإشعارات', 'Notifications'),
                  onPressed: widget.onNotifications,
                  constraints:
                      const BoxConstraints(minHeight: 48, minWidth: 40),
                  icon: Badge(
                      isLabelVisible: widget.notificationCount > 0,
                      backgroundColor: GoDesign.orange,
                      label: Text('${widget.notificationCount}'),
                      child: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 22))),
              if (widget.drawer != null)
                IconButton(
                    tooltip: t('القائمة', 'Menu'),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    constraints:
                        const BoxConstraints(minHeight: 48, minWidth: 40),
                    icon:
                        const Icon(Icons.menu, color: Colors.white, size: 22)),
            ]),
          ));

  Widget _searchField() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: TextField(
            key: const ValueKey('go-home-search'),
            controller: _query,
            onChanged: (value) => setState(() => _search = value),
            style: const TextStyle(color: GoDesign.ink, fontSize: 14),
            decoration: InputDecoration(
              hintText:
                  t('ابحث عن قسم أو خدمة…', 'Search departments or services…'),
              hintStyle:
                  const TextStyle(color: GoDesign.authMuted, fontSize: 13),
              filled: true,
              fillColor: GoDesign.paper,
              prefixIcon: const Icon(Icons.search, color: GoDesign.ink),
              suffixIcon: _search.isEmpty
                  ? null
                  : IconButton(
                      tooltip: t('مسح البحث', 'Clear search'),
                      onPressed: () {
                        _query.clear();
                        setState(() => _search = '');
                      },
                      icon: const Icon(Icons.close, color: GoDesign.orange)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            )),
      );

  Widget _serviceCard(GoService service) => Material(
        key: ValueKey('go-service-${service.key}'),
        color: GoDesign.paper,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: () => widget.onService(service),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: GoDesign.border),
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(4),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                            aspectRatio: 1.5,
                            child: GoServicePhoto(index: service.imageIndex))),
                    const SizedBox(height: 7),
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(ar ? service.ar : service.en,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: GoDesign.ink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 1.35)))),
                  ]),
            )),
      );
}

class GoServicePhoto extends StatelessWidget {
  const GoServicePhoto({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => ClipRect(
          child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
            width: 180,
            height: 120,
            child: Stack(children: [
              Positioned(
                  left: -(index % 4) * 180.0,
                  top: -(index ~/ 4) * 120.0,
                  width: 720,
                  height: 480,
                  child: Image.memory(goServiceSpriteBytes,
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.high)),
            ])),
      ));
}
