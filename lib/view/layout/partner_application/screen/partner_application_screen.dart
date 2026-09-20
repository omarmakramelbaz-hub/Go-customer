import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/theme/app_colors.dart';

class PartnerApplicationScreen extends StatefulWidget {
  const PartnerApplicationScreen({super.key});

  @override
  State<PartnerApplicationScreen> createState() => _PartnerApplicationScreenState();
}

class _PartnerApplicationScreenState extends State<PartnerApplicationScreen> {
  static const _orange = Color(0xFFE85504);
  static const _navy = Color(0xFF0B1721);
  static const _muted = Color(0xFF7D8790);
  static const _bg = Color(0xFFF7F8FA);

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _phone = TextEditingController();
  final _paymentIdentifier = TextEditingController();

  final _picker = ImagePicker();
  XFile? _photo;
  String? _professionKey;
  int _radiusKm = 5;
  String _paymentMethod = 'vodafone_cash';
  double? _lat;
  double? _lng;
  bool _termsAccepted = false;
  bool _submitting = false;
  bool _locating = false;

  final List<Map<String, String>> _professions = const [
    {'key': 'delivery_courier', 'ar': 'مندوب توصيل'},
    {'key': 'appliance_technician', 'ar': 'فني صيانة ثلاجات وغسالات'},
    {'key': 'plumber', 'ar': 'سباك'},
    {'key': 'painter', 'ar': 'نقاش'},
    {'key': 'tile_installer', 'ar': 'فني تركيب بلاط'},
    {'key': 'marble_installer', 'ar': 'فني تركيب رخام'},
    {'key': 'blacksmith', 'ar': 'حداد'},
    {'key': 'electrician', 'ar': 'كهربائي'},
    {'key': 'satellite_technician', 'ar': 'فني تركيب وصيانة الدش'},
    {'key': 'furniture_carpenter', 'ar': 'نجار أثاث'},
    {'key': 'ac_technician', 'ar': 'فني تكييف'},
    {'key': 'construction_worker', 'ar': 'عامل بناء'},
    {'key': 'auto_mechanic', 'ar': 'ميكانيكي سيارات'},
    {'key': 'auto_electrician', 'ar': 'كهربائي سيارات'},
    {'key': 'mens_barber', 'ar': 'كوافير رجالي'},
    {'key': 'womens_hairdresser', 'ar': 'كوافيرة سيدات'},
    {'key': 'tailor', 'ar': 'خياط'},
    {'key': 'male_cleaner', 'ar': 'عامل نظافة'},
    {'key': 'female_cleaner', 'ar': 'عاملة نظافة'},
  ];

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _phone.dispose();
    _paymentIdentifier.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
    );
    if (image != null && mounted) setState(() => _photo = image);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فعّل إذن الموقع لتحديد نطاق عملك.')),
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
        });
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photo == null) {
      _message('أضف صورة شخصية واضحة.');
      return;
    }
    if (_professionKey == null) {
      _message('اختر المهنة.');
      return;
    }
    if (_lat == null || _lng == null) {
      _message('حدد موقعك الحالي أولاً.');
      return;
    }
    if (!_termsAccepted) {
      _message('يجب الموافقة على شروط وأحكام الانضمام.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final bytes = await _photo!.readAsBytes();
      final body = FormData.fromMap({
        'photo': MultipartFile.fromBytes(
          bytes,
          filename: _photo!.name.isEmpty ? 'partner.jpg' : _photo!.name,
        ),
        'full_name': _name.text.trim(),
        'age': int.parse(_age.text.trim()),
        'profession_key': _professionKey,
        'lat': _lat,
        'lng': _lng,
        'mobile': _phone.text.trim(),
        'payment_method': _paymentMethod,
        'payment_identifier': _paymentIdentifier.text.trim(),
        'work_radius_km': _radiusKm,
        'terms_accepted': 1,
      });

      final response = await ApiHelper.instance.post(
        Urls.partnerApplications,
        body: body,
        hasToken: false,
      );

      if (!mounted) return;
      if (response.state == ResponseState.complete) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const PartnerApplicationSuccessScreen(),
          ),
        );
      } else {
        final message = response.data is Map
            ? (response.data['message']?.toString() ?? 'تعذر إرسال الطلب.')
            : 'تعذر إرسال الطلب.';
        _message(message);
      }
    } catch (_) {
      if (mounted) _message('تعذر إرسال الطلب. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'الانضمام إلى شركاء GO',
            style: TextStyle(fontWeight: FontWeight.w900, color: _navy),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                _hero(),
                const SizedBox(height: 16),
                _section(
                  icon: Icons.person_outline_rounded,
                  title: 'بياناتك الشخصية',
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _pickPhoto,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5EE),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFD9C2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _photo == null
                                      ? Icons.add_a_photo_outlined
                                      : Icons.check_circle_rounded,
                                  color: _photo == null ? _orange : Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _photo == null
                                      ? 'أضف صورة شخصية واضحة'
                                      : 'تم اختيار الصورة — اضغط لتغييرها',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: _navy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _name,
                        label: 'الاسم بالكامل',
                        icon: Icons.badge_outlined,
                        validator: (v) =>
                            (v == null || v.trim().length < 3) ? 'اكتب الاسم بالكامل' : null,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        controller: _age,
                        label: 'السن',
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final value = int.tryParse(v ?? '');
                          if (value == null || value < 18 || value > 75) {
                            return 'السن يجب أن يكون بين 18 و75 سنة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _field(
                        controller: _phone,
                        label: 'رقم الهاتف',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            (v == null || v.replaceAll(RegExp(r'\D'), '').length < 10)
                                ? 'اكتب رقم هاتف صحيح'
                                : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _section(
                  icon: Icons.handyman_outlined,
                  title: 'المهنة ونطاق العمل',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _professionKey,
                        isExpanded: true,
                        decoration: _decoration('اختر المهنة', Icons.work_outline_rounded),
                        items: _professions
                            .map(
                              (p) => DropdownMenuItem(
                                value: p['key'],
                                child: Text(p['ar']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _professionKey = value),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _locating ? null : _useCurrentLocation,
                          icon: _locating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  _lat == null
                                      ? Icons.my_location_rounded
                                      : Icons.check_circle_rounded,
                                ),
                          label: Text(
                            _lat == null
                                ? 'تحديد موقعي الحالي'
                                : 'تم تحديد الموقع بنجاح',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _orange,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Color(0xFFFFCFB2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'المسافة التي يمكنك العمل داخلها',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _navy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [5, 10, 15, 20]
                            .map(
                              (km) => ChoiceChip(
                                selected: _radiusKm == km,
                                label: Text('$km كم'),
                                onSelected: (_) => setState(() => _radiusKm = km),
                                selectedColor: _orange,
                                labelStyle: TextStyle(
                                  color: _radiusKm == km ? Colors.white : _navy,
                                  fontWeight: FontWeight.w800,
                                ),
                                side: BorderSide(
                                  color: _radiusKm == km
                                      ? _orange
                                      : const Color(0xFFE4E7EA),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _section(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'استلام المستحقات',
                  child: Column(
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'vodafone_cash',
                            label: Text('Vodafone Cash'),
                            icon: Icon(Icons.phone_android_rounded),
                          ),
                          ButtonSegment(
                            value: 'instapay',
                            label: Text('Instapay'),
                            icon: Icon(Icons.account_balance_rounded),
                          ),
                        ],
                        selected: {_paymentMethod},
                        onSelectionChanged: (value) {
                          setState(() => _paymentMethod = value.first);
                        },
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _paymentIdentifier,
                        label: _paymentMethod == 'vodafone_cash'
                            ? 'رقم محفظة Vodafone Cash'
                            : 'رقم الهاتف / عنوان Instapay',
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            (v == null || v.trim().length < 5) ? 'اكتب بيانات الاستلام' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _termsCard(),
                const SizedBox(height: 18),
                SizedBox(
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      _submitting ? 'جاري إرسال الطلب...' : 'إرسال طلب الانضمام',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
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

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF102D43), Color(0xFF07141E)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Color(0x22FFFFFF),
            child: Icon(Icons.groups_2_rounded, color: Colors.white, size: 30),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حوّل مهنتك إلى فرص عمل قريبة منك',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'املأ بياناتك مرة واحدة، وبعد المراجعة سيظهر حسابك للعملاء داخل كارت مهنتك وفي نطاق العمل الذي تختاره.',
                  style: TextStyle(
                    color: Color(0xFFC8D4DD),
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8ECEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 20,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _orange),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _decoration(label, icon),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _orange),
      filled: true,
      fillColor: const Color(0xFFFAFBFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE3E7EA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE3E7EA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _orange, width: 1.4),
      ),
    );
  }

  Widget _termsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8ECEF)),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: _termsAccepted,
            onChanged: (value) =>
                setState(() => _termsAccepted = value ?? false),
            activeColor: _orange,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'أوافق على شروط وأحكام الانضمام كشريك',
              style: TextStyle(
                color: _navy,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: const Text(
              'تأكيد صحة البيانات، الالتزام بجودة الخدمة، احترام العملاء، استخدام الموقع لتحديد نطاق العمل، وسياسات المنصة والخصوصية.',
              style: TextStyle(color: _muted, height: 1.45),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _showTerms,
              icon: const Icon(Icons.description_outlined),
              label: const Text('عرض الشروط كاملة'),
            ),
          ),
        ],
      ),
    );
  }

  void _showTerms() {
    const terms = [
      'يجب ألا يقل عمر مقدم الخدمة عن 18 عامًا.',
      'يقر مقدم الطلب بأن البيانات والصورة ورقم الهاتف وبيانات الاستلام المقدمة صحيحة وتخصه.',
      'يلتزم مقدم الخدمة بامتلاك الخبرة المناسبة للمهنة التي اختارها وبجودة تنفيذ الخدمة.',
      'يوافق مقدم الخدمة على استخدام موقعه لتحديد نطاق استقبال الطلبات، وعلى التتبع أثناء تنفيذ الطلب عند تفعيل هذه الميزة.',
      'يلتزم مقدم الخدمة باحترام العميل والمحافظة على ممتلكاته وخصوصيته وعدم استخدام المنصة في أي نشاط مخالف للقانون.',
      'تُطبق العمولات أو رسوم المنصة والأسعار السارية وقت تنفيذ الطلب كما تظهر داخل التطبيق.',
      'يحق لإدارة GO تعليق أو إيقاف الحساب عند وجود بيانات غير صحيحة أو شكاوى جسيمة أو مخالفة للشروط.',
      'تُعالج البيانات اللازمة لتشغيل الحساب واستقبال الطلبات وفق سياسة الخصوصية، ولا يتم عرض بيانات Vodafone Cash أو Instapay للعملاء.',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'شروط الانضمام إلى شركاء GO',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                ...terms.map(
                  (term) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: _orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            term,
                            style: const TextStyle(height: 1.5, color: _navy),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      setState(() => _termsAccepted = true);
                    },
                    style: FilledButton.styleFrom(backgroundColor: _orange),
                    child: const Text('موافق'),
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

class PartnerApplicationSuccessScreen extends StatelessWidget {
  const PartnerApplicationSuccessScreen({super.key});

  static const _downloadUrl = String.fromEnvironment(
    'GO_PARTNER_DOWNLOAD_URL',
    defaultValue:
        'https://play.google.com/store/apps/details?id=com.smartvesion.fasakhaninja_delegate',
  );

  Future<void> _download(BuildContext context) async {
    final uri = Uri.parse(_downloadUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سيتم توفير رابط التحميل قريبًا.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF8EF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 72,
                    color: Color(0xFF1C9B55),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'تم استلام طلبك بنجاح',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B1721),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'طلبك الآن قيد المراجعة. بعد الموافقة ستتمكن من استخدام تطبيق شركاء GO واستقبال الطلبات المتوافقة مع مهنتك ونطاق عملك.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.6,
                    color: Color(0xFF7D8790),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_rounded, color: Color(0xFFE85504)),
                      SizedBox(width: 8),
                      Text(
                        'الحالة: قيد المراجعة',
                        style: TextStyle(
                          color: Color(0xFFE85504),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () => _download(context),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text(
                      'تحميل تطبيق شركاء GO',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE85504),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: const Text('العودة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
