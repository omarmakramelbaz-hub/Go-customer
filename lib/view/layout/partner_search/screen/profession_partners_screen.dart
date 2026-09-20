import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/screen/login_screen.dart';

class ProfessionPartnersScreen extends StatefulWidget {
  const ProfessionPartnersScreen({
    super.key,
    required this.professionKey,
    required this.title,
  });

  final String professionKey;
  final String title;

  @override
  State<ProfessionPartnersScreen> createState() => _ProfessionPartnersScreenState();
}

class _ProfessionPartnersScreenState extends State<ProfessionPartnersScreen> {
  static const _ink = Color(0xFF0B1721);
  static const _muted = Color(0xFF7D8790);
  static const _bg = Color(0xFFF7F8FA);
  static const _line = Color(0xFFE7EBEE);

  final _search = TextEditingController();
  bool _loading = true;
  String? _error;
  double? _lat;
  double? _lng;
  List<Map<String, dynamic>> _partners = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _loading = false;
          _error = 'فعّل إذن الموقع لعرض مقدمي الخدمة المتاحين حولك.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _lat = position.latitude;
      _lng = position.longitude;

      final response = await ApiHelper.instance.get(
        Urls.professionPartners(widget.professionKey),
        queryParameters: {'lat': _lat, 'lng': _lng},
        hasToken: false,
      );

      if (!mounted) return;
      if (response.state == ResponseState.complete) {
        final raw = response.data is Map ? response.data['data'] : null;
        setState(() {
          _partners = raw is List
              ? raw
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : [];
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = response.data is Map
              ? response.data['message']?.toString() ?? 'تعذر تحميل مقدمي الخدمة.'
              : 'تعذر تحميل مقدمي الخدمة.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'تعذر تحديد موقعك أو تحميل مقدمي الخدمة.';
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _partners;
    return _partners.where((p) {
      final name = p['name']?.toString().toLowerCase() ?? '';
      return name.contains(q);
    }).toList();
  }

  void _request(Map<String, dynamic> partner) {
    if (HiveMethods.getToken() == null) {
      NamedNavigatorImpl.push(LoginScreen.routeName);
      return;
    }
    if (_lat == null || _lng == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePartnerRequestSheet(
        partner: partner,
        professionKey: widget.professionKey,
        professionTitle: widget.title,
        lat: _lat!,
        lng: _lng!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.title,
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w900),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF12344C), Color(0xFF071723)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.handyman_rounded,
                        color: AppColors.mainAppColor,
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مقدمو الخدمة المتاحون حولك',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'نعرض فقط الشركاء المعتمدين الذين يشمل نطاق عملهم موقعك الحالي.',
                            style: TextStyle(
                              color: Color(0xFFC8D4DD),
                              height: 1.45,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _search,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم مقدم الخدمة...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: _line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: AppColors.mainAppColor),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 70),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _StateCard(
                  icon: Icons.location_off_outlined,
                  title: _error!,
                  action: 'إعادة المحاولة',
                  onTap: _load,
                )
              else if (items.isEmpty)
                const _StateCard(
                  icon: Icons.person_search_rounded,
                  title: 'لا يوجد مقدم خدمة معتمد داخل نطاق موقعك حاليًا.',
                )
              else
                ...items.map(_partnerCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _partnerCard(Map<String, dynamic> partner) {
    final photo = partner['photo']?.toString();
    final distance = partner['distance_km'];
    final radius = partner['work_radius_km'];

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 66,
              height: 66,
              color: const Color(0xFFFFF1E8),
              child: photo != null && photo.isNotEmpty
                  ? Image.network(
                      photo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_rounded,
                        color: Color(0xFFE85504),
                        size: 34,
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      color: Color(0xFFE85504),
                      size: 34,
                    ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner['name']?.toString() ?? 'مقدم خدمة',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  distance == null
                      ? 'داخل نطاقك'
                      : '$distance كم منك • نطاق العمل $radius كم',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        color: Color(0xFF178C4B), size: 16),
                    SizedBox(width: 4),
                    Text(
                      'شريك معتمد',
                      style: TextStyle(
                        color: Color(0xFF178C4B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => _request(partner),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.mainAppColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('اطلب',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _CreatePartnerRequestSheet extends StatefulWidget {
  const _CreatePartnerRequestSheet({
    required this.partner,
    required this.professionKey,
    required this.professionTitle,
    required this.lat,
    required this.lng,
  });

  final Map<String, dynamic> partner;
  final String professionKey;
  final String professionTitle;
  final double lat;
  final double lng;

  @override
  State<_CreatePartnerRequestSheet> createState() =>
      _CreatePartnerRequestSheetState();
}

class _CreatePartnerRequestSheetState extends State<_CreatePartnerRequestSheet> {
  static const _ink = Color(0xFF0B1721);
  static const _muted = Color(0xFF7D8790);

  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _photos = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthController>().profile;
    _phone.text = profile?.mobile ?? '';
    _address.text = profile?.address ?? '';
  }

  @override
  void dispose() {
    _description.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final images = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1400,
    );
    if (!mounted || images.isEmpty) return;
    setState(() {
      final remaining = 5 - _photos.length;
      _photos.addAll(images.take(remaining));
    });
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    try {
      final uploads = <MultipartFile>[];
      for (final photo in _photos) {
        uploads.add(
          MultipartFile.fromBytes(
            await photo.readAsBytes(),
            filename: photo.name.isEmpty ? 'request.jpg' : photo.name,
          ),
        );
      }

      final body = FormData.fromMap({
        'partner_id': widget.partner['id'],
        'profession_key': widget.professionKey,
        'description': _description.text.trim(),
        'customer_phone': _phone.text.trim(),
        'customer_lat': widget.lat,
        'customer_lng': widget.lng,
        'address': _address.text.trim(),
        if (uploads.isNotEmpty) 'photos': uploads,
      });

      final response = await ApiHelper.instance.post(
        Urls.partnerServiceRequests,
        body: body,
      );

      if (!mounted) return;
      if (response.state == ResponseState.complete) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          Navigator.of(context, rootNavigator: true).context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال الطلب إلى ${widget.partner['name'] ?? 'مقدم الخدمة'}',
            ),
          ),
        );
      } else {
        final message = response.data is Map
            ? response.data['message']?.toString() ?? 'تعذر إرسال الطلب.'
            : 'تعذر إرسال الطلب.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إرسال الطلب. حاول مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .88,
          ),
          margin: const EdgeInsets.all(10),
          padding: EdgeInsets.fromLTRB(
            18,
            10,
            18,
            18 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8DDE0),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'طلب ${widget.professionTitle}',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'إلى ${widget.partner['name'] ?? 'مقدم الخدمة'}',
                    style: const TextStyle(
                      color: _muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _description,
                    minLines: 4,
                    maxLines: 7,
                    maxLength: 2000,
                    decoration: _dec(
                      'اشرح المطلوب بالتفصيل',
                      Icons.notes_rounded,
                    ),
                    validator: (v) => v == null || v.trim().length < 5
                        ? 'اكتب تفاصيل الطلب'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: _dec('رقم التواصل', Icons.phone_outlined),
                    validator: (v) =>
                        v == null ||
                                v.replaceAll(RegExp(r'\D'), '').length < 10
                            ? 'اكتب رقم هاتف صحيح'
                            : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _address,
                    decoration:
                        _dec('وصف العنوان', Icons.location_on_outlined),
                    validator: (v) => v == null || v.trim().length < 3
                        ? 'اكتب وصف العنوان'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _photos.length >= 5 ? null : _pickPhotos,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(
                      _photos.isEmpty
                          ? 'إضافة صور للمشكلة (اختياري)'
                          : 'الصور المضافة: ${_photos.length}/5',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mainAppColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  if (_photos.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: List.generate(
                        _photos.length,
                        (index) => InputChip(
                          label: Text('صورة ${index + 1}'),
                          onDeleted: () =>
                              setState(() => _photos.removeAt(index)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _sending ? 'جاري الإرسال...' : 'إرسال الطلب',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.mainAppColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.mainAppColor),
        filled: true,
        fillColor: const Color(0xFFFAFBFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E6E9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.mainAppColor),
        ),
      );
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    this.action,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EBEE)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 46, color: const Color(0xFFE85504)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0B1721),
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (action != null && onTap != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onTap, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}
