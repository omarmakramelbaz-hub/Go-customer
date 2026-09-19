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

  bool get _isArabic => context.languageCode == 'ar';

  static const _deep = Color(0xFF0D1721);
  static const _muted = Color(0xFF7D858D);
  static const _surface = Color(0xFFF6F7F9);

  final List<_ServiceItem> _services = const [
    _ServiceItem(
      arTitle: 'طلب مندوب توصيل',
      enTitle: 'Delivery courier',
      arSubtitle: 'طرود، مشتريات ومستندات',
      enSubtitle: 'Parcels, shopping and documents',
      icon: Icons.delivery_dining_rounded,
      accent: Color(0xFFFF6B00),
      isDelivery: true,
    ),
    _ServiceItem(
      arTitle: 'صيانة الأجهزة',
      enTitle: 'Appliance repair',
      arSubtitle: 'ثلاجات، غسالات وأجهزة',
      enSubtitle: 'Fridges, washers and appliances',
      icon: Icons.home_repair_service_rounded,
      accent: Color(0xFF2F80ED),
    ),
    _ServiceItem(
      arTitle: 'خدمات منزلية',
      enTitle: 'Home services',
      arSubtitle: 'سباك، كهربائي، نجار',
      enSubtitle: 'Plumber, electrician, carpenter',
      icon: Icons.handyman_rounded,
      accent: Color(0xFF1F9D73),
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
      accent: Color(0xFF334155),
    ),
    _ServiceItem(
      arTitle: 'خدمات النظافة',
      enTitle: 'Cleaning',
      arSubtitle: 'عامل أو عاملة نظافة',
      enSubtitle: 'Home cleaning professionals',
      icon: Icons.cleaning_services_rounded,
      accent: Color(0xFF06A6C7),
    ),
    _ServiceItem(
      arTitle: 'تجميل وعناية شخصية',
      enTitle: 'Beauty & grooming',
      arSubtitle: 'كوافير رجالي وسيدات',
      enSubtitle: 'Men and women grooming',
      icon: Icons.content_cut_rounded,
      accent: Color(0xFFE5487C),
    ),
    _ServiceItem(
      arTitle: 'خياطة وتعديلات',
      enTitle: 'Tailoring',
      arSubtitle: 'خياط وتعديلات ملابس',
      enSubtitle: 'Tailoring and alterations',
      icon: Icons.checkroom_rounded,
      accent: Color(0xFFC0873A),
    ),
  ];

  static const List<String> _allArabicSpecialties = [
    'مندوب توصيل',
    'صيانة ثلاجات',
    'صيانة غسالات',
    'سباك',
    'كهربائي',
    'نقاش',
    'فني تركيب بلاط',
    'فني تركيب رخام',
    'حداد',
    'فني تركيب وصيانة دش',
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
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _services;
    return _services.where((service) {
      return service.arTitle.toLowerCase().contains(query) ||
          service.enTitle.toLowerCase().contains(query) ||
          service.arSubtitle.toLowerCase().contains(query) ||
          service.enSubtitle.toLowerCase().contains(query);
    }).toList();
  }

  void _openDelivery() {
    NamedNavigatorImpl.push(RequestDelegateScreen.routeName);
  }

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
                _isArabic ? arTitle : enTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _deep,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _isArabic
                    ? 'تم تجهيز الخدمة داخل الواجهة الجديدة، وسيتم ربط مقدمي الخدمة ونظام الطلبات في المرحلة التالية.'
                    : 'This service is ready in the new interface. Provider matching and booking will be connected next.',
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
                    _isArabic ? 'تمام' : 'Got it',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
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
      builder: (sheetContext) {
        return Directionality(
          textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
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
                    _isArabic ? 'كل الخدمات' : 'All services',
                    style: const TextStyle(
                      color: _deep,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isArabic
                        ? 'اختار الخدمة اللي محتاجها'
                        : 'Choose the service you need',
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
                        children: _allArabicSpecialties.map((service) {
                          final isDelivery = service == 'مندوب توصيل';
                          return ActionChip(
                            avatar: Icon(
                              isDelivery
                                  ? Icons.delivery_dining_rounded
                                  : Icons.engineering_outlined,
                              size: 18,
                              color: isDelivery
                                  ? Colors.white
                                  : AppColors.mainAppColor,
                            ),
                            backgroundColor: isDelivery
                                ? AppColors.mainAppColor
                                : const Color(0xFFFFF4EC),
                            side: BorderSide(
                              color: isDelivery
                                  ? AppColors.mainAppColor
                                  : const Color(0xFFFFDDC5),
                            ),
                            label: Text(
                              service,
                              style: TextStyle(
                                color: isDelivery ? Colors.white : _deep,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              if (isDelivery) {
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
        );
      },
    );
  }

  String _firstName(String? name) {
    final clean = (name ?? '').trim();
    if (clean.isEmpty) return '';
    return clean.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = auth.profile;
    final firstName = _firstName(profile?.name);
    final city = (profile?.cityName ?? HiveMethods.getCity() ?? '').trim();
    final address = (profile?.address ?? profile?.areaTitle ?? '').trim();
    final notifications =
        profile?.notificaionsCount ?? HiveMethods.getNotificationsCount() ?? 0;

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(
                  firstName: firstName,
                  city: city,
                  address: address,
                  notifications: notifications,
                ),
              ),
              SliverToBoxAdapter(child: _buildSearch()),
              SliverToBoxAdapter(child: _buildHero()),
              SliverToBoxAdapter(child: _buildServicesSection()),
              SliverToBoxAdapter(child: _buildPremiumBanner()),
              SliverToBoxAdapter(child: _buildOffers()),
              SliverToBoxAdapter(child: _buildTrustStrip()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String firstName,
    required String city,
    required String address,
    required int notifications,
  }) {
    final locationTitle =
        city.isNotEmpty ? city : (_isArabic ? 'موقعك الحالي' : 'Your location');
    final locationSub = address.isNotEmpty
        ? address
        : (_isArabic ? 'حدد عنوانك للخدمات القريبة' : 'Set your address');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              _notificationButton(notifications),
              const Spacer(),
              Column(
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
                          letterSpacing: -2,
                        ),
                        children: [
                          TextSpan(
                            text: 'G',
                            style: TextStyle(color: AppColors.mainAppColor),
                          ),
                          const TextSpan(
                            text: 'O',
                            style: TextStyle(color: _deep),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    _isArabic ? 'كل الخدمات عندك' : 'Every service, one app',
                    style: const TextStyle(
                      color: _deep,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _locationButton(locationTitle, locationSub),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment:
                _isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  color: _deep,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(
                    text: firstName.isEmpty
                        ? (_isArabic ? 'أهلاً بك' : 'Welcome')
                        : (_isArabic
                              ? 'مرحباً $firstName'
                              : 'Hi $firstName'),
                  ),
                  TextSpan(
                    text: _isArabic
                        ? '  •  اطلب خدمتك بسهولة'
                        : '  •  Services made simple',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationButton(int count) {
    return InkWell(
      onTap: widget.onOpenNotifications,
      borderRadius: BorderRadius.circular(17),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0xFFE8EBEE)),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: _deep,
              size: 25,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D3A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _locationButton(String title, String subtitle) {
    return InkWell(
      onTap: () {
        if (HiveMethods.getToken() == null) {
          NamedNavigatorImpl.push('LoginScreen');
        } else {
          NamedNavigatorImpl.push('AddAddressScreen');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 150),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              color: AppColors.mainAppColor,
              size: 23,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _deep,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _muted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: _isArabic
              ? 'ابحث عن الخدمة اللي تحتاجها ...'
              : 'Search for a service...',
          hintStyle: const TextStyle(
            color: Color(0xFFA2A8AE),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: _deep, size: 25),
          suffixIcon: _query.isEmpty
              ? IconButton(
                  onPressed: _showAllServices,
                  icon: Icon(
                    Icons.tune_rounded,
                    color: AppColors.mainAppColor,
                  ),
                )
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close_rounded, color: _muted),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE8EBEE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.mainAppColor.withOpacity(.65),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: InkWell(
        onTap: _openDelivery,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 210,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF111E29), Color(0xFF071019)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x21000000),
                blurRadius: 20,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: -10,
                bottom: -5,
                width: 205,
                height: 195,
                child: Opacity(
                  opacity: .97,
                  child: Image.asset(
                    'assets/images/deliveryRiderV2.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                left: 136,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF0C1721).withOpacity(.88),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                top: 24,
                bottom: 20,
                width: 185,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isArabic ? 'محتاج مندوب؟' : 'Need a courier?',
                      style: TextStyle(
                        color: AppColors.mainAppColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isArabic
                          ? 'نوصل لك في أسرع وقت'
                          : 'Fast, safe delivery',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _isArabic
                          ? 'طلباتك .. في أمان'
                          : 'Your delivery is in safe hands',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.72),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      decoration: BoxDecoration(
                        color: AppColors.mainAppColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isArabic ? 'اطلب الآن' : 'Book now',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 7),
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

  Widget _buildServicesSection() {
    final filtered = _filteredServices;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TextButton(
                onPressed: _showAllServices,
                child: Text(
                  _isArabic ? 'عرض الكل' : 'View all',
                  style: TextStyle(
                    color: AppColors.mainAppColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _isArabic ? 'خدماتنا' : 'Our services',
                    style: const TextStyle(
                      color: _deep,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _isArabic
                        ? 'كل ما تحتاجه في مكان واحد'
                        : 'Everything you need in one place',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                _isArabic
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
              itemBuilder: (context, index) {
                final service = filtered[index];
                return _serviceCard(service);
              },
            ),
        ],
      ),
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
          padding: const EdgeInsets.fromLTRB(7, 12, 7, 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: service.isDelivery
                  ? AppColors.mainAppColor.withOpacity(.35)
                  : const Color(0xFFE9ECEF),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: service.accent.withOpacity(.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  service.icon,
                  color: service.accent,
                  size: 25,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                _isArabic ? service.arTitle : service.enTitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _deep,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              Icon(
                _isArabic
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 12,
                color: service.isDelivery
                    ? AppColors.mainAppColor
                    : const Color(0xFFADB3B9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: InkWell(
        onTap: () => _showComingSoon('GO Premium', 'GO Premium'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF071019), Color(0xFF16212B)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD77A), Color(0xFFC69130)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back_rounded,
                      color: _deep,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isArabic ? 'اكتشف المزيد' : 'Explore',
                      style: const TextStyle(
                        color: _deep,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFE8BA58),
                        size: 22,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'GO PREMIUM',
                        style: TextStyle(
                          color: Color(0xFFF1C86B),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isArabic
                        ? 'أولوية في الوصول • فنيين معتمدين • عروض حصرية'
                        : 'Priority • verified providers • exclusive offers',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.72),
                      fontSize: 10,
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

  Widget _buildOffers() {
    final offers = [
      (
        _isArabic ? 'خصم على أول طلب' : 'First order offer',
        _isArabic ? 'توصيل أسرع بسعر أقل' : 'Faster delivery for less',
        Icons.delivery_dining_rounded,
        const Color(0xFFFF6B00),
      ),
      (
        _isArabic ? 'صيانة التكييف' : 'AC service',
        _isArabic ? 'احجز فني متخصص' : 'Book a specialist',
        Icons.ac_unit_rounded,
        const Color(0xFF2F80ED),
      ),
      (
        _isArabic ? 'خدمات النظافة' : 'Cleaning offer',
        _isArabic ? 'خدمة منزلية مرنة' : 'Flexible home cleaning',
        Icons.cleaning_services_rounded,
        const Color(0xFF08A59C),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () => _showComingSoon('العروض', 'Offers'),
                child: Text(
                  _isArabic ? 'عرض الكل' : 'View all',
                  style: TextStyle(
                    color: AppColors.mainAppColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _isArabic ? 'عروض خاصة' : 'Special offers',
                style: const TextStyle(
                  color: _deep,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: _isArabic,
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final offer = offers[index];
                return InkWell(
                  onTap: index == 0
                      ? _openDelivery
                      : () => _showComingSoon(offer.$1, offer.$1),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 218,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: offer.$4.withOpacity(.10),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(offer.$3, color: offer.$4, size: 25),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                offer.$1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _deep,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                offer.$2,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 10,
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

  Widget _buildTrustStrip() {
    final items = [
      (
        Icons.verified_user_outlined,
        _isArabic ? 'مقدمو خدمة موثوقون' : 'Trusted providers',
      ),
      (
        Icons.schedule_rounded,
        _isArabic ? 'وصول سريع' : 'Fast arrival',
      ),
      (
        Icons.credit_card_rounded,
        _isArabic ? 'دفع آمن ومتنوع' : 'Secure payment',
      ),
      (
        Icons.support_agent_rounded,
        _isArabic ? 'دعم مستمر' : 'Always-on support',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Row(
          children: items.map((item) {
            return Expanded(
              child: Column(
                children: [
                  Icon(item.$1, color: _deep, size: 22),
                  const SizedBox(height: 7),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      color: _deep,
                      fontSize: 9.5,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
