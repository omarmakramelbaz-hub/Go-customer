import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../auth/controller/auth_controller.dart';
import '../../request_delegate/screen/request_delegate_screen.dart';
import '../../partner_search/screen/profession_partners_screen.dart';
import '../widgets/service_photo_sprite.dart';

class GoServicesHomeScreen extends StatefulWidget {
  const GoServicesHomeScreen({
    super.key,
    required this.onOpenNotifications,
  });

  final VoidCallback onOpenNotifications;

  @override
  State<GoServicesHomeScreen> createState() => _GoServicesHomeScreenState();
}

class _GoServicesHomeScreenState extends State<GoServicesHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const _ink = Color(0xFF171A1F);
  static const _muted = Color(0xFF7E8790);
  static const _bg = Color(0xFFF8F9FB);
  static const _line = Color(0xFFE8ECEF);
  static const _gold = Color(0xFFE7B84A);

  bool get _ar => context.languageCode == 'ar';

  final List<_ServiceItem> _services = const [
    _ServiceItem(
      arTitle: 'طلب مندوب توصيل',
      enTitle: 'Delivery courier',
      arSubtitle: 'استلام وتوصيل الطلبات',
      enSubtitle: 'Pickup and delivery',
      icon: Icons.delivery_dining_rounded,
      accent: Color(0xFFFF6500),
      imageIndex: 0,
      isDelivery: true,
    ),
    _ServiceItem(
      arTitle: 'فني صيانة ثلاجات وغسالات',
      enTitle: 'Fridge & washer technician',
      arSubtitle: 'صيانة وإصلاح الأجهزة',
      enSubtitle: 'Repair and maintenance',
      icon: Icons.home_repair_service_rounded,
      accent: Color(0xFF327FE7),
      imageIndex: 1,
    ),
    _ServiceItem(
      arTitle: 'سباك',
      enTitle: 'Plumber',
      arSubtitle: 'سباكة وصيانة منزلية',
      enSubtitle: 'Plumbing services',
      icon: Icons.plumbing_rounded,
      accent: Color(0xFF0B9BB5),
      imageIndex: 2,
    ),
    _ServiceItem(
      arTitle: 'نقاش',
      enTitle: 'Painter',
      arSubtitle: 'دهانات وتشطيبات',
      enSubtitle: 'Painting and finishing',
      icon: Icons.format_paint_rounded,
      accent: Color(0xFF8B5CF6),
      imageIndex: 3,
    ),
    _ServiceItem(
      arTitle: 'فني تركيب بلاط',
      enTitle: 'Tile installer',
      arSubtitle: 'تركيب وتشطيب البلاط',
      enSubtitle: 'Tile installation',
      icon: Icons.grid_view_rounded,
      accent: Color(0xFF5C6BC0),
      imageIndex: 4,
    ),
    _ServiceItem(
      arTitle: 'فني تركيب رخام',
      enTitle: 'Marble installer',
      arSubtitle: 'تركيب وتشطيب الرخام',
      enSubtitle: 'Marble installation',
      icon: Icons.square_foot_rounded,
      accent: Color(0xFF8D6E63),
      imageIndex: 5,
    ),
    _ServiceItem(
      arTitle: 'حداد',
      enTitle: 'Blacksmith',
      arSubtitle: 'أعمال الحديد والصيانة',
      enSubtitle: 'Metal work and repair',
      icon: Icons.construction_rounded,
      accent: Color(0xFF455A64),
      imageIndex: 6,
    ),
    _ServiceItem(
      arTitle: 'كهربائي',
      enTitle: 'Electrician',
      arSubtitle: 'كهرباء وصيانة منزلية',
      enSubtitle: 'Electrical services',
      icon: Icons.electrical_services_rounded,
      accent: Color(0xFFF2A900),
      imageIndex: 7,
    ),
    _ServiceItem(
      arTitle: 'فني تركيب وصيانة الدش',
      enTitle: 'Satellite technician',
      arSubtitle: 'تركيب وصيانة وضبط الإشارة',
      enSubtitle: 'Satellite install and repair',
      icon: Icons.satellite_alt_rounded,
      accent: Color(0xFF1565C0),
      imageIndex: 8,
    ),
    _ServiceItem(
      arTitle: 'نجار أثاث',
      enTitle: 'Furniture carpenter',
      arSubtitle: 'نجارة وصيانة الأثاث',
      enSubtitle: 'Furniture carpentry',
      icon: Icons.carpenter_rounded,
      accent: Color(0xFFA56A2A),
      imageIndex: 9,
    ),
    _ServiceItem(
      arTitle: 'فني تكييف',
      enTitle: 'AC technician',
      arSubtitle: 'تركيب وصيانة التكييف',
      enSubtitle: 'AC installation and repair',
      icon: Icons.ac_unit_rounded,
      accent: Color(0xFF29A3E8),
      imageIndex: 10,
    ),
    _ServiceItem(
      arTitle: 'عامل بناء',
      enTitle: 'Construction worker',
      arSubtitle: 'أعمال البناء والتجهيز',
      enSubtitle: 'Building and site work',
      icon: Icons.engineering_rounded,
      accent: Color(0xFFE67E22),
      imageIndex: 11,
    ),
    _ServiceItem(
      arTitle: 'ميكانيكي سيارات',
      enTitle: 'Auto mechanic',
      arSubtitle: 'صيانة وإصلاح السيارات',
      enSubtitle: 'Car repair and service',
      icon: Icons.car_repair_rounded,
      accent: Color(0xFF37474F),
      imageIndex: 12,
    ),
    _ServiceItem(
      arTitle: 'كهربائي سيارات',
      enTitle: 'Auto electrician',
      arSubtitle: 'كهرباء وأعطال السيارات',
      enSubtitle: 'Automotive electrical',
      icon: Icons.electric_car_rounded,
      accent: Color(0xFF546E7A),
      imageIndex: 12,
    ),
    _ServiceItem(
      arTitle: 'كوافير رجالي',
      enTitle: 'Men barber',
      arSubtitle: 'حلاقة وعناية رجالية',
      enSubtitle: 'Men grooming',
      icon: Icons.content_cut_rounded,
      accent: Color(0xFF263238),
      imageIndex: 13,
    ),
    _ServiceItem(
      arTitle: 'كوافيرة سيدات',
      enTitle: 'Women hairdresser',
      arSubtitle: 'تصفيف وعناية للسيدات',
      enSubtitle: 'Women beauty and hair',
      icon: Icons.face_retouching_natural_rounded,
      accent: Color(0xFFE4487C),
      imageIndex: 13,
    ),
    _ServiceItem(
      arTitle: 'خياط',
      enTitle: 'Tailor',
      arSubtitle: 'تفصيل وتعديلات الملابس',
      enSubtitle: 'Tailoring and alterations',
      icon: Icons.checkroom_rounded,
      accent: Color(0xFFB98638),
      imageIndex: 14,
    ),
    _ServiceItem(
      arTitle: 'عامل نظافة',
      enTitle: 'Male cleaner',
      arSubtitle: 'تنظيف المنازل والمكاتب',
      enSubtitle: 'Home and office cleaning',
      icon: Icons.cleaning_services_rounded,
      accent: Color(0xFF00A6A6),
      imageIndex: 15,
    ),
    _ServiceItem(
      arTitle: 'عاملة نظافة',
      enTitle: 'Female cleaner',
      arSubtitle: 'تنظيف المنازل والمكاتب',
      enSubtitle: 'Home and office cleaning',
      icon: Icons.cleaning_services_rounded,
      accent: Color(0xFF7CB342),
      imageIndex: 15,
    ),
  ];

  static const Map<String, String> _professionKeys = {
    'فني صيانة ثلاجات وغسالات': 'appliance_technician',
    'سباك': 'plumber',
    'نقاش': 'painter',
    'فني تركيب بلاط': 'tile_installer',
    'فني تركيب رخام': 'marble_installer',
    'حداد': 'blacksmith',
    'كهربائي': 'electrician',
    'فني تركيب وصيانة الدش': 'satellite_technician',
    'نجار أثاث': 'furniture_carpenter',
    'فني تكييف': 'ac_technician',
    'عامل بناء': 'construction_worker',
    'ميكانيكي سيارات': 'auto_mechanic',
    'كهربائي سيارات': 'auto_electrician',
    'كوافير رجالي': 'mens_barber',
    'كوافيرة سيدات': 'womens_hairdresser',
    'خياط': 'tailor',
    'عامل نظافة': 'male_cleaner',
    'عاملة نظافة': 'female_cleaner',
  };

  static const _allSpecialties = [
    'مندوب توصيل',
    'فني صيانة ثلاجات وغسالات',
    'سباك',
    'نقاش',
    'فني تركيب بلاط',
    'فني تركيب رخام',
    'حداد',
    'كهربائي',
    'فني تركيب وصيانة الدش',
    'نجار أثاث',
    'فني تكييف',
    'عامل بناء',
    'ميكانيكي سيارات',
    'كهربائي سيارات',
    'كوافير رجالي',
    'كوافيرة سيدات',
    'خياط',
    'عامل نظافة',
    'عاملة نظافة',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ServiceItem> get _filteredServices {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _services;
    return _services.where((s) {
      return s.arTitle.toLowerCase().contains(q) ||
          s.enTitle.toLowerCase().contains(q) ||
          s.arSubtitle.toLowerCase().contains(q) ||
          s.enSubtitle.toLowerCase().contains(q);
    }).toList();
  }

  String _firstName(String? value) {
    final clean = (value ?? '').trim();
    if (clean.isEmpty) return '';
    return clean.split(RegExp(r'\s+')).first;
  }

  ({String title, String subtitle}) _location(AuthController auth) {
    final profile = auth.profile;
    var city = (profile?.cityName ?? HiveMethods.getCity() ?? '').trim();
    var detail = (profile?.address ?? profile?.areaTitle ?? '').trim();
    final selectedId = HiveMethods.getSelectedCity();

    for (final item in profile?.userAddresses ?? []) {
      if (selectedId != null && item.id == selectedId) {
        final selectedCity = (item.cityName ?? '').trim();
        final selectedDetail = (item.streetName ??
                item.addressName ??
                item.areaName ??
                item.address ??
                '')
            .trim();
        if (selectedCity.isNotEmpty) city = selectedCity;
        if (selectedDetail.isNotEmpty) detail = selectedDetail;
        break;
      }
    }

    if (city.isEmpty) city = _ar ? 'موقعك الحالي' : 'Your location';
    if (detail.isEmpty) {
      detail = _ar ? 'حدد عنوانك للخدمات القريبة' : 'Choose your address';
    }
    return (title: city, subtitle: detail);
  }

  void _openDelivery() => NamedNavigatorImpl.push(RequestDelegateScreen.routeName);

  void _openService(_ServiceItem service) {
    if (service.isDelivery) {
      _openDelivery();
      return;
    }

    final professionKey = _professionKeys[service.arTitle];
    if (professionKey == null) {
      _showComingSoon(service.arTitle, service.enTitle);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfessionPartnersScreen(
          professionKey: professionKey,
          title: _ar ? service.arTitle : service.enTitle,
        ),
      ),
    );
  }

  void _showComingSoon(String arTitle, String enTitle) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7DBDF),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.mainAppColor.withOpacity(.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.engineering_rounded,
                  color: AppColors.mainAppColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _ar ? arTitle : enTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _ar
                    ? 'الخدمة أصبحت جزءًا من منصة GO، وسيتم ربط مقدمي الخدمة ونظام الحجز والتسعير في المرحلة التالية.'
                    : 'This service is now part of GO. Provider matching, booking and pricing will be connected next.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: _muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mainAppColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(
                    _ar ? 'تمام' : 'Got it',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllServices() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Directionality(
        textDirection: _ar ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * .78,
            ),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7DBDF),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _ar ? 'كل الخدمات' : 'All services',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _ar ? 'اختار الخدمة اللي محتاجها' : 'Choose the service you need',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: _allSpecialties.map((service) {
                        final delivery = service == 'مندوب توصيل';
                        return ActionChip(
                          avatar: Icon(
                            delivery
                                ? Icons.delivery_dining_rounded
                                : Icons.engineering_outlined,
                            size: 18,
                            color: delivery
                                ? Colors.white
                                : AppColors.mainAppColor,
                          ),
                          backgroundColor: delivery
                              ? AppColors.mainAppColor
                              : const Color(0xFFFFF4EC),
                          side: BorderSide(
                            color: delivery
                                ? AppColors.mainAppColor
                                : const Color(0xFFFFDDC5),
                          ),
                          label: Text(
                            service,
                            style: TextStyle(
                              color: delivery ? Colors.white : _ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            if (delivery) {
                              _openDelivery();
                            } else {
                              final key = _professionKeys[service];
                              if (key != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProfessionPartnersScreen(
                                      professionKey: key,
                                      title: service,
                                    ),
                                  ),
                                );
                              } else {
                                _showComingSoon(service, service);
                              }
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = auth.profile;
    final location = _location(auth);
    final firstName = _firstName(profile?.name);
    final notifications =
        profile?.notificaionsCount ?? HiveMethods.getNotificationsCount() ?? 0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: _ar ? TextDirection.rtl : TextDirection.ltr,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _header(
                  firstName: firstName,
                  city: location.title,
                  address: location.subtitle,
                  notifications: notifications,
                ),
              ),
              SliverToBoxAdapter(child: _search()),
              SliverToBoxAdapter(child: _hero()),
              SliverToBoxAdapter(child: _servicesSection()),
              SliverToBoxAdapter(child: _premium()),
              SliverToBoxAdapter(child: _offers()),
              SliverToBoxAdapter(child: _trustStrip()),
              const SliverToBoxAdapter(child: SizedBox(height: 54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header({
    required String firstName,
    required String city,
    required String address,
    required int notifications,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _locationButton(city, address),
              const Spacer(),
              _brand(),
              const Spacer(),
              _notificationButton(notifications),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: _ar ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👋', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 7),
                Text(
                  firstName.isEmpty
                      ? (_ar ? 'مرحباً بك' : 'Welcome')
                      : (_ar ? 'مرحباً $firstName' : 'Hi $firstName'),
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _ar ? '• اطلب خدمتك بسهولة' : '• Services made simple',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _brand() {
    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 34,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -2.4,
              ),
              children: [
                TextSpan(
                  text: 'G',
                  style: TextStyle(color: AppColors.mainAppColor),
                ),
                const TextSpan(
                  text: 'O',
                  style: TextStyle(color: _ink),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          _ar ? 'كل الخدمات عندك' : 'Every service, one app',
          style: const TextStyle(
            color: _ink,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _locationButton(String city, String address) {
    return InkWell(
      onTap: () {
        if (HiveMethods.getToken() == null) {
          NamedNavigatorImpl.push('LoginScreen');
        } else {
          NamedNavigatorImpl.push('AddressScreen');
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        constraints: const BoxConstraints(minWidth: 158, maxWidth: 178),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _line),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              color: AppColors.mainAppColor,
              size: 23,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _ink,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationButton(int count) {
    return InkWell(
      onTap: widget.onOpenNotifications,
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _line),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: _ink,
              size: 26,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                constraints: const BoxConstraints(minWidth: 25, minHeight: 25),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D3A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '+99' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: _ar
              ? 'ابحث عن الخدمة اللي تحتاجها ...'
              : 'Search for a service...',
          hintStyle: const TextStyle(
            color: Color(0xFFA3AAB1),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: _ink, size: 27),
          suffixIcon: Container(
            margin: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: _query.isEmpty
                  ? _showAllServices
                  : () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
              icon: Icon(
                _query.isEmpty ? Icons.tune_rounded : Icons.close_rounded,
                color: AppColors.mainAppColor,
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: AppColors.mainAppColor.withOpacity(.65),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: InkWell(
        onTap: _openDelivery,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 222,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF123047), Color(0xFF07131D)],
            ),
            border: Border.all(
              color: const Color(0xFF1E4158),
              width: .8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GoHeroBackgroundPainter(
                      accent: AppColors.mainAppColor,
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 10,
                top: 18,
                bottom: 14,
                width: 168,
                child: _GoCourierHeroArt(),
              ),
              Positioned(
                left: 155,
                top: 0,
                bottom: 0,
                width: 92,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xF20A1823),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 18,
                top: 20,
                bottom: 17,
                width: 196,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ar ? 'محتاج مندوب؟' : 'Need a courier?',
                      style: TextStyle(
                        color: AppColors.mainAppColor,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        height: 1.03,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _ar ? 'نوصل لك في أسرع وقت' : 'Fast, safe delivery',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _ar ? 'طلباتك .. في أمان' : 'Your delivery is in safe hands',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.70),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        _heroProof(Icons.star_rounded, _ar ? 'موثوق' : 'Trusted'),
                        _heroDivider(),
                        _heroProof(Icons.bolt_rounded, _ar ? 'سريع' : 'Fast'),
                        _heroDivider(),
                        _heroProof(Icons.shield_outlined, _ar ? 'آمن' : 'Safe'),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 19),
                      decoration: BoxDecoration(
                        color: AppColors.mainAppColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mainAppColor.withOpacity(.26),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _ar ? 'اطلب الآن' : 'Book now',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroProof(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFFC928), size: 20),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroDivider() => Container(
        width: 1,
        height: 28,
        color: Colors.white.withOpacity(.16),
      );

  Widget _servicesSection() {
    final filtered = _filteredServices;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(
            title: _ar ? 'خدماتنا' : 'Our services',
            subtitle: _ar ? 'كل ما تحتاجه في مكان واحد' : 'Everything in one place',
            action: _ar ? 'عرض الكل' : 'View all',
            onAction: _showAllServices,
          ),
          const SizedBox(height: 11),
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _line),
              ),
              child: Text(
                _ar
                    ? 'لم نجد خدمة مطابقة. اضغط عرض الكل لرؤية كل التخصصات.'
                    : 'No matching service. Tap View all to browse all specialties.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 11,
                childAspectRatio: .68,
              ),
              itemBuilder: (_, index) => _serviceCard(filtered[index]),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    String? subtitle,
    required String action,
    required VoidCallback onAction,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: onAction,
          icon: Icon(
            _ar
                ? Icons.arrow_back_ios_new_rounded
                : Icons.arrow_forward_ios_rounded,
            size: 13,
            color: AppColors.mainAppColor,
          ),
          label: Text(
            action,
            style: TextStyle(
              color: AppColors.mainAppColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _ink,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _serviceCard(_ServiceItem service) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _openService(service),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(7, 7, 7, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: service.isDelivery
                  ? AppColors.mainAppColor.withOpacity(.55)
                  : _line,
              width: service.isDelivery ? 1.35 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _ServiceSpritePhoto(
                index: service.imageIndex,
                badgeIcon: service.icon,
                badgeColor: service.accent,
                highlight: service.isDelivery,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  _ar ? service.arTitle : service.enTitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 11.4,
                    fontWeight: FontWeight.w900,
                    height: 1.23,
                  ),
                ),
              ),
              const Spacer(),
              Align(
                alignment: _ar ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: service.isDelivery
                        ? AppColors.mainAppColor
                        : const Color(0xFFF3F5F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _ar
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: service.isDelivery
                        ? Colors.white
                        : const Color(0xFF9AA2A9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premium() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 17),
      child: InkWell(
        onTap: () => _showComingSoon('GO Premium', 'GO Premium'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF07121B), Color(0xFF112C42)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFBE8B27), width: .9),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD979), Color(0xFFD59C2E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(
                      _ar ? 'اكتشف المزيد' : 'Explore',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Icon(Icons.arrow_back_rounded, color: _ink, size: 18),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Row(
                    children: [
                      Text(
                        'GO PREMIUM',
                        style: TextStyle(
                          color: Color(0xFFFFD568),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                      SizedBox(width: 7),
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: _gold,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _ar
                        ? 'أولوية في الوصول • فنيين معتمدين • عروض حصرية'
                        : 'Priority • verified providers • exclusive offers',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.72),
                      fontSize: 9.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _offers() {
    final items = [
      (
        _ar ? 'خصم على أول طلب' : 'First order discount',
        _ar ? 'توصيل سريع بسعر أقل' : 'Fast delivery for less',
        Icons.percent_rounded,
        const Color(0xFFFF6500),
      ),
      (
        _ar ? 'صيانة التكييف' : 'AC maintenance',
        _ar ? 'احجز فني متخصص' : 'Book a specialist',
        Icons.ac_unit_rounded,
        const Color(0xFF2F80ED),
      ),
      (
        _ar ? 'خدمات النظافة' : 'Cleaning services',
        _ar ? 'خدمة منزلية مرنة' : 'Flexible home cleaning',
        Icons.cleaning_services_rounded,
        const Color(0xFF0BA9A0),
      ),
    ];

    final cardWidth = (MediaQuery.sizeOf(context).width - 42) / 2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 17),
      child: Column(
        children: [
          _sectionTitle(
            title: _ar ? 'عروض خاصة' : 'Special offers',
            action: _ar ? 'عرض الكل' : 'View all',
            onAction: () => _showComingSoon('العروض', 'Offers'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 116,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: _ar,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final item = items[index];
                return InkWell(
                  onTap: index == 0
                      ? _openDelivery
                      : () => _showComingSoon(item.$1, item.$1),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _line),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x09000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 49,
                          height: 49,
                          decoration: BoxDecoration(
                            color: item.$4.withOpacity(.10),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(item.$3, color: item.$4, size: 25),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.$1,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  color: _ink,
                                  fontSize: 12.5,
                                  height: 1.2,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item.$2,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 9.5,
                                  height: 1.25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _trustStrip() {
    final items = [
      (
        Icons.verified_user_outlined,
        _ar ? 'مقدمو خدمة موثوقون' : 'Trusted providers',
      ),
      (
        Icons.bolt_rounded,
        _ar ? 'وصول سريع' : 'Fast arrival',
      ),
      (
        Icons.credit_card_rounded,
        _ar ? 'دفع آمن ومتنوع' : 'Secure payment',
      ),
      (
        Icons.support_agent_rounded,
        _ar ? 'دعم مستمر' : 'Always-on support',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(
                child: Column(
                  children: [
                    Icon(items[i].$1, color: _ink, size: 22),
                    const SizedBox(height: 7),
                    Text(
                      items[i].$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 9.3,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (i != items.length - 1)
                Container(width: 1, height: 42, color: _line),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoCourierHeroArt extends StatelessWidget {
  const _GoCourierHeroArt();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 8,
          right: 8,
          top: 10,
          bottom: 10,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF6A00).withOpacity(.28),
                  const Color(0xFFFF6A00).withOpacity(.06),
                  Colors.transparent,
                ],
                stops: const [0, .55, 1],
              ),
            ),
          ),
        ),
        Positioned(
          left: 18,
          bottom: 30,
          child: Container(
            width: 122,
            height: 122,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F2534),
              border: Border.all(
                color: const Color(0xFFFF7A17).withOpacity(.58),
                width: 1.3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4A000000),
                  blurRadius: 18,
                  offset: Offset(0, 9),
                ),
              ],
            ),
            child: const Icon(
              Icons.delivery_dining_rounded,
              color: Color(0xFFFF6A00),
              size: 82,
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 18,
          child: _HeroBadge(
            icon: Icons.inventory_2_rounded,
            size: 42,
          ),
        ),
        Positioned(
          left: 1,
          top: 45,
          child: _HeroBadge(
            icon: Icons.location_on_rounded,
            size: 38,
          ),
        ),
        Positioned(
          right: 13,
          bottom: 17,
          child: _HeroBadge(
            icon: Icons.bolt_rounded,
            size: 36,
          ),
        ),
        Positioned(
          left: 34,
          bottom: 7,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6A00),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'GO',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
                fontStyle: FontStyle.italic,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: -.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.icon,
    required this.size,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF173246).withOpacity(.96),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(.16),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: const Color(0xFFFFA45C),
        size: size * .48,
      ),
    );
  }
}

class _GoHeroBackgroundPainter extends CustomPainter {
  const _GoHeroBackgroundPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final route = Paint()
      ..color = Colors.white.withOpacity(.075)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final glow = Paint()
      ..color = accent.withOpacity(.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * .03, size.height * .80)
      ..cubicTo(
        size.width * .10,
        size.height * .56,
        size.width * .24,
        size.height * .68,
        size.width * .29,
        size.height * .43,
      )
      ..cubicTo(
        size.width * .34,
        size.height * .22,
        size.width * .42,
        size.height * .34,
        size.width * .48,
        size.height * .12,
      );

    canvas.drawPath(path, glow);
    canvas.drawPath(path, route);

    final dotPaint = Paint()..color = accent.withOpacity(.72);
    for (final p in [
      Offset(size.width * .04, size.height * .80),
      Offset(size.width * .29, size.height * .43),
      Offset(size.width * .48, size.height * .12),
    ]) {
      canvas.drawCircle(p, 3.5, dotPaint);
      canvas.drawCircle(
        p,
        7.2,
        Paint()..color = accent.withOpacity(.10),
      );
    }

    final speed = Paint()
      ..color = Colors.white.withOpacity(.055)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (.22 + (i * .095));
      canvas.drawLine(
        Offset(size.width * .03, y),
        Offset(size.width * (.13 + i * .012), y),
        speed,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GoHeroBackgroundPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

class _ServiceSpritePhoto extends StatelessWidget {
  const _ServiceSpritePhoto({
    required this.index,
    required this.badgeIcon,
    required this.badgeColor,
    required this.highlight,
  });

  final int index;
  final IconData badgeIcon;
  final Color badgeColor;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final column = index % 4;
    final row = index ~/ 4;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth;
        final cellHeight = cellWidth * (120 / 180);

        return SizedBox(
          width: cellWidth,
          height: cellHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: -column * cellWidth,
                  top: -row * cellHeight,
                  width: cellWidth * 4,
                  height: cellHeight * 4,
                  child: Image.memory(
                    goServiceSpriteBytes,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(.05),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.94),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: highlight
                            ? AppColors.mainAppColor.withOpacity(.28)
                            : Colors.white.withOpacity(.55),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      badgeIcon,
                      size: 15,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ServiceItem {
  const _ServiceItem({
    required this.arTitle,
    required this.enTitle,
    required this.arSubtitle,
    required this.enSubtitle,
    required this.icon,
    required this.accent,
    required this.imageIndex,
    this.isDelivery = false,
  });

  final String arTitle;
  final String enTitle;
  final String arSubtitle;
  final String enSubtitle;
  final IconData icon;
  final Color accent;
  final int imageIndex;
  final bool isDelivery;
}
