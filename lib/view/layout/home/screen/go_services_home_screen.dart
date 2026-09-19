import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../auth/controller/auth_controller.dart';
import '../../request_delegate/screen/request_delegate_screen.dart';

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

  static const _ink = Color(0xFF0B1721);
  static const _muted = Color(0xFF7E8790);
  static const _bg = Color(0xFFF7F8FA);
  static const _line = Color(0xFFE8ECEF);
  static const _gold = Color(0xFFE7B84A);

  bool get _ar => context.languageCode == 'ar';

  final List<_ServiceItem> _services = const [
    _ServiceItem(
      arTitle: 'طلب مندوب توصيل',
      enTitle: 'Delivery courier',
      arSubtitle: 'طرود، مشتريات ومستندات',
      enSubtitle: 'Parcels, shopping and documents',
      icon: Icons.delivery_dining_rounded,
      accent: Color(0xFFFF6500),
      isDelivery: true,
    ),
    _ServiceItem(
      arTitle: 'صيانة الأجهزة',
      enTitle: 'Appliance repair',
      arSubtitle: 'ثلاجات، غسالات وأجهزة منزلية',
      enSubtitle: 'Fridges, washers and appliances',
      icon: Icons.home_repair_service_rounded,
      accent: Color(0xFF327FE7),
    ),
    _ServiceItem(
      arTitle: 'خدمات منزلية',
      enTitle: 'Home services',
      arSubtitle: 'سباك، كهربائي، نجار',
      enSubtitle: 'Plumber, electrician, carpenter',
      icon: Icons.handyman_rounded,
      accent: Color(0xFF1FA279),
    ),
    _ServiceItem(
      arTitle: 'تشطيبات وديكور',
      enTitle: 'Finishing & décor',
      arSubtitle: 'نقاش، بلاط، رخام وحدادة',
      enSubtitle: 'Painting, tiles, marble and metal',
      icon: Icons.format_paint_rounded,
      accent: Color(0xFF8B5CF6),
    ),
    _ServiceItem(
      arTitle: 'خدمات السيارات',
      enTitle: 'Car services',
      arSubtitle: 'ميكانيكي وكهربائي سيارات',
      enSubtitle: 'Mechanic and auto electrician',
      icon: Icons.directions_car_filled_rounded,
      accent: Color(0xFF3D4A59),
    ),
    _ServiceItem(
      arTitle: 'خدمات النظافة',
      enTitle: 'Cleaning',
      arSubtitle: 'عامل أو عاملة نظافة',
      enSubtitle: 'Home cleaning professionals',
      icon: Icons.cleaning_services_rounded,
      accent: Color(0xFF08A5C7),
    ),
    _ServiceItem(
      arTitle: 'تجميل وعناية شخصية',
      enTitle: 'Beauty & grooming',
      arSubtitle: 'كوافير رجالي وسيدات',
      enSubtitle: 'Men and women grooming',
      icon: Icons.content_cut_rounded,
      accent: Color(0xFFE4487C),
    ),
    _ServiceItem(
      arTitle: 'خياطة وتعديلات',
      enTitle: 'Tailoring',
      arSubtitle: 'خياط وتعديلات ملابس',
      enSubtitle: 'Tailoring and alterations',
      icon: Icons.checkroom_rounded,
      accent: Color(0xFFB98638),
    ),
  ];

  static const _allSpecialties = [
    'مندوب توصيل',
    'صيانة ثلاجات',
    'صيانة غسالات',
    'سباك',
    'كهربائي',
    'نقاش',
    'فني تركيب بلاط',
    'فني تركيب رخام',
    'حداد',
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
    _showComingSoon(service.arTitle, service.enTitle);
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
                              _showComingSoon(service, service);
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
              const SliverToBoxAdapter(child: SizedBox(height: 26)),
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
        constraints: const BoxConstraints(maxWidth: 145),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 17),
      child: InkWell(
        onTap: _openDelivery,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 224,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF122838), Color(0xFF06101A)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 20,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: -20,
                top: 12,
                bottom: 0,
                width: 205,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: .72,
                      colors: [
                        AppColors.mainAppColor.withOpacity(.28),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -2,
                bottom: 0,
                width: 190,
                height: 196,
                child: Image.asset(
                  'assets/images/deliveryRiderV2.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(
                left: 152,
                top: 0,
                bottom: 0,
                width: 86,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF0A1721).withOpacity(.94),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 19,
                top: 22,
                bottom: 18,
                width: 190,
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
                        color: Colors.white.withOpacity(.68),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: AppColors.mainAppColor,
                        borderRadius: BorderRadius.circular(15),
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
                            size: 19,
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
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: .76,
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
          padding: const EdgeInsets.fromLTRB(7, 11, 7, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: service.isDelivery
                  ? AppColors.mainAppColor.withOpacity(.42)
                  : _line,
              width: service.isDelivery ? 1.25 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x09000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: service.accent.withOpacity(.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(service.icon, color: service.accent, size: 25),
              ),
              const SizedBox(height: 9),
              Text(
                _ar ? service.arTitle : service.enTitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 11.3,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              Align(
                alignment:
                    _ar ? Alignment.centerLeft : Alignment.centerRight,
                child: Icon(
                  _ar
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: service.isDelivery
                      ? AppColors.mainAppColor
                      : const Color(0xFFAFB6BC),
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

class _ServiceItem {
  const _ServiceItem({
    required this.arTitle,
    required this.enTitle,
    required this.arSubtitle,
    required this.enSubtitle,
    required this.icon,
    required this.accent,
    this.isDelivery = false,
  });

  final String arTitle;
  final String enTitle;
  final String arSubtitle;
  final String enSubtitle;
  final IconData icon;
  final Color accent;
  final bool isDelivery;
}
