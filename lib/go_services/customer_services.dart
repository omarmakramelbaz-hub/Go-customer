import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/hive/hive_methods.dart';
import '../helpers/routes/app_routers_import.dart';
import '../view/layout/auth/screen/login_screen.dart';
import 'service_api.dart';
import 'service_widgets.dart';

class CustomerServiceHub extends StatefulWidget {
  const CustomerServiceHub({super.key, required this.api, required this.capabilities, required this.ar, required this.title, this.professionKey, this.legacyBuilder});
  final ServiceApi api;
  final ServiceCapabilities capabilities;
  final bool ar;
  final String title;
  final String? professionKey;
  final WidgetBuilder? legacyBuilder;
  @override
  State<CustomerServiceHub> createState() => _CustomerServiceHubState();
}
class _CustomerServiceHubState extends State<CustomerServiceHub> {
  String scope = 'open';
  int revision = 0;
  String t(String a, String e) => st(widget.ar, a, e);
  Future<void> create() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(MaterialPageRoute(builder: (_) => ServiceRequestForm(api: widget.api, ar: widget.ar, professionKey: widget.professionKey!, title: widget.title)));
    if (result == null || !mounted) return;
    setState(() { revision++; scope = 'open'; });
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ServiceJobScreen(api: widget.api, ar: widget.ar, id: serviceId(result['id']))));
    if (mounted) setState(() => revision++);
  }
  @override
  Widget build(BuildContext context) => Directionality(textDirection: widget.ar ? TextDirection.rtl : TextDirection.ltr, child: Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: HiveMethods.getToken() == null ? Center(child: FilledButton(onPressed: () async { await NamedNavigatorImpl.push(LoginScreen.routeName); if (mounted) setState(() {}); }, child: Text(t('سجل الدخول لطلب صنايعي', 'Sign in to request a professional')))) : ListView(padding: const EdgeInsets.all(18), children: [
      if (widget.professionKey != null) serviceCard(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(t('اوصف الشغلانة، وسيب الصنايعية تقدم عروضها', 'Describe the job and receive quotations'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        serviceText(t('حدد موقع التنفيذ وأرفق صورًا واضحة. قارن نطاق الشغل والمصنعية قبل اختيار العرض؛ السعر لا يتحدد تلقائيًا.', 'Choose the work location and add clear photos. Compare the scope and labour price before accepting; no price is selected automatically.')),
        FilledButton(onPressed: widget.capabilities.enabled ? create : null, child: Text(t('اطلب ${widget.title}', 'Request ${widget.title}'))),
        if (!widget.capabilities.enabled) serviceText(t('إنشاء طلبات جديدة متوقف مؤقتًا. يمكنك متابعة طلباتك القائمة.', 'New requests are paused. You can still manage existing jobs.')),
      ])),
      Text(t('شغلاناتي وعروض الأسعار', 'My jobs and quotations'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
      Wrap(spacing: 8, children: [for (final entry in {'open': t('الجارية', 'Current'), 'history': t('السابقة', 'History')}.entries) ChoiceChip(label: Text(entry.value), selected: scope == entry.key, onSelected: (_) => setState(() => scope = entry.key))]),
      ServiceJobList(key: ValueKey(revision), api: widget.api, ar: widget.ar, scope: scope),
      if (widget.legacyBuilder != null) TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: widget.legacyBuilder!)), child: Text(t('عرض نظام الاختيار المباشر السابق', 'View previous direct-request flow'))),
    ]),
  ));
}

/// Retains an identical submission after an uncertain network result. Backend
/// request_key deduplication, rather than a client success animation, owns creation.
class ServiceRequestForm extends StatefulWidget {
  const ServiceRequestForm({super.key, required this.api, required this.ar, required this.professionKey, required this.title});
  final ServiceApi api;
  final bool ar;
  final String professionKey;
  final String title;
  @override
  State<ServiceRequestForm> createState() => _ServiceRequestFormState();
}
class _ServiceRequestFormState extends State<ServiceRequestForm> {
  final form = GlobalKey<FormState>();
  final description = TextEditingController();
  final area = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();
  final photos = <XFile>[];
  final requestKey = List.generate(32, (_) => Random.secure().nextInt(16).toRadixString(16)).join();
  LatLng? location;
  DateTime? schedule;
  Map<String, dynamic>? frozen;
  bool sending = false;
  String? error;
  String t(String a, String e) => st(widget.ar, a, e);
  @override
  void dispose() { description.dispose(); area.dispose(); address.dispose(); phone.dispose(); super.dispose(); }
  Future<void> pickPhotos() async {
    try {
      final picked = await ImagePicker().pickMultiImage(maxWidth: 1800, maxHeight: 1800, imageQuality: 85);
      final valid = <XFile>[];
      for (final image in picked.take(5 - photos.length)) { if (await image.length() > 5 * 1024 * 1024) throw ServiceFailure(t('الحد الأقصى للصورة ٥ ميجابايت.', 'Maximum photo size is 5 MB.')); valid.add(image); }
      if (mounted) setState(() => photos.addAll(valid));
    } catch (e) { if (mounted) setState(() => error = '$e'); }
  }
  Future<void> chooseLocation() async {
    final result = await Navigator.of(context).push<LatLng>(MaterialPageRoute(builder: (_) => _WorkLocation(ar: widget.ar, initial: location)));
    if (result != null && mounted) setState(() => location = result);
  }
  Future<void> chooseTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(context: context, initialDate: schedule ?? now, firstDate: now, lastDate: now.add(const Duration(days: 365)));
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(schedule ?? now.add(const Duration(hours: 1))));
    if (time == null || !mounted) return;
    final value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() { if (value.isAfter(DateTime.now())) { schedule = value; error = null; } else { error = t('اختر موعدًا في المستقبل.', 'Choose a future time.'); } });
  }
  Future<void> send() async {
    if (sending) return;
    if (frozen == null) {
      if (!form.currentState!.validate()) return;
      if (location == null) { setState(() => error = t('حدد موقع تنفيذ الشغل على الخريطة أولًا.', 'Select the work location on the map first.')); return; }
      frozen = {'request_key': requestKey, 'profession_key': widget.professionKey, 'description': description.text.trim(), 'area': area.text.trim(), 'address': address.text.trim(), 'phone': phone.text.trim(), 'lat': location!.latitude, 'lng': location!.longitude, if (schedule != null) 'scheduled_at': schedule!.toUtc().toIso8601String()};
    }
    setState(() { sending = true; error = null; });
    try {
      final body = FormData.fromMap(frozen!);
      for (final photo in photos) { body.files.add(MapEntry('photos[]', MultipartFile.fromBytes(await photo.readAsBytes(), filename: photo.name.isEmpty ? 'job.jpg' : photo.name))); }
      final job = await widget.api.create(body);
      if (mounted) Navigator.pop(context, job);
    } catch (e) {
      if (mounted) setState(() {
        error = '$e';
        // Definite validation/auth failures may be corrected. For a timeout/5xx,
        // keep the same key AND payload; the server may already have created it.
        if (e is ServiceFailure && [400, 401, 403, 422].contains(e.status)) frozen = null;
      });
    } finally { if (mounted) setState(() => sending = false); }
  }
  @override
  Widget build(BuildContext context) {
    final locked = sending || frozen != null;
    return Directionality(textDirection: widget.ar ? TextDirection.rtl : TextDirection.ltr, child: PopScope(canPop: !sending, child: Scaffold(
      appBar: AppBar(title: Text(t('وصف الشغلانة', 'Describe the job'))),
      body: Form(key: form, child: ListView(padding: const EdgeInsets.all(18), children: [
        Text(widget.title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        TextFormField(controller: description, enabled: !locked, maxLines: 5, maxLength: 2000, decoration: InputDecoration(labelText: t('مطلوب إيه بالضبط؟', 'What exactly needs doing?'), hintText: t('المشكلة، عدد القطع، المقاسات، والشغل المطلوب...', 'Problem, quantities, dimensions and required work...')), validator: (v) => (v?.trim().length ?? 0) < 10 ? t('اكتب وصفًا لا يقل عن ١٠ أحرف.', 'Write at least 10 characters.') : null),
        OutlinedButton.icon(onPressed: locked ? null : chooseLocation, icon: const Icon(Icons.location_on_outlined), label: Text(location == null ? t('حدد موقع التنفيذ بدبوس الخريطة', 'Pin the work location') : t('موقع التنفيذ محدد — تعديل', 'Work location selected — edit'))),
        TextFormField(controller: area, enabled: !locked, maxLength: 150, decoration: InputDecoration(labelText: t('المنطقة أو الحي', 'Area or district')), validator: (v) => (v?.trim().length ?? 0) < 2 ? t('أدخل المنطقة', 'Enter the area') : null),
        TextFormField(controller: address, enabled: !locked, maxLength: 500, decoration: InputDecoration(labelText: t('العنوان التفصيلي (يظهر بعد الاتفاق)', 'Exact address (shared after agreement)')), validator: (v) => (v?.trim().length ?? 0) < 5 ? t('أدخل عنوانًا واضحًا', 'Enter a clear address') : null),
        TextFormField(controller: phone, enabled: !locked, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: t('رقم التواصل', 'Contact phone')), validator: (v) => !RegExp(r'^\+?[0-9]{10,15}$').hasMatch(v?.trim() ?? '') ? t('أدخل رقمًا من ١٠ إلى ١٥ رقمًا بالأرقام الإنجليزية.', 'Enter 10–15 digits; use 0–9.') : null),
        const SizedBox(height: 15),
        OutlinedButton.icon(onPressed: locked || photos.length >= 5 ? null : pickPhotos, icon: const Icon(Icons.add_photo_alternate_outlined), label: Text(t('إضافة صور (${photos.length}/٥)', 'Add photos (${photos.length}/5)'))),
        for (var i = 0; i < photos.length; i++) ListTile(leading: const Icon(Icons.image_outlined), title: Text(photos[i].name), trailing: IconButton(onPressed: locked ? null : () => setState(() => photos.removeAt(i)), icon: const Icon(Icons.close))),
        serviceText(t('لا تضع أرقام تواصل أو بيانات حساسة في الوصف أو الصور؛ سيشاهدها الصنايعية المدعوون.', 'Do not include contact details or sensitive information in descriptions/photos; invited professionals can see them.')),
        OutlinedButton(onPressed: locked ? null : chooseTime, child: Text(schedule == null ? t('تحديد موعد اختياري', 'Set an optional time') : localTime(schedule!.toIso8601String()))),
        if (schedule != null) TextButton(onPressed: locked ? null : () => setState(() => schedule = null), child: Text(t('بدون موعد محدد', 'No fixed time'))),
        serviceText(t('لن تختار صنايعي الآن. ستصلك عروض نهائية توضح المصنعية ونطاق العمل والخامات لتختار بنفسك.', 'You do not choose a professional yet. You will receive final quotes covering labour, scope and materials to compare.')),
        if (frozen != null && !sending) serviceText(t('قد يكون الطلب اتسجل رغم انقطاع الاتصال. إعادة المحاولة ترسل نفس الطلب، وليس طلبًا جديدًا. راجع شغلاناتك قبل إنشاء طلب آخر.', 'The job may exist despite the connection error. Retry submits the same request, not a new one. Check My jobs before creating another.')),
        if (error != null) serviceText(error!),
        FilledButton(onPressed: sending ? null : send, child: Text(sending ? t('جاري الإرسال...', 'Submitting...') : frozen != null ? t('إعادة إرسال نفس الطلب', 'Retry the same request') : t('إرسال والبحث عن صنايعية', 'Submit and find professionals'))),
      ])),
    )));
  }
}

class _WorkLocation extends StatefulWidget {
  const _WorkLocation({required this.ar, this.initial});
  final bool ar;
  final LatLng? initial;
  @override
  State<_WorkLocation> createState() => _WorkLocationState();
}
class _WorkLocationState extends State<_WorkLocation> {
  LatLng? pin;
  GoogleMapController? map;
  String? error;
  bool locating = false;
  @override
  void initState() { super.initState(); pin = widget.initial; }
  @override
  void dispose() { map?.dispose(); super.dispose(); }
  Future<void> locate() async {
    if (locating) return;
    setState(() => locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) throw ServiceFailure(st(widget.ar, 'اختار الدبوس يدويًا أو فعّل إذن الموقع.', 'Pick the location manually or allow location access.'));
      final point = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 20));
      if (!mounted) return;
      setState(() { pin = LatLng(point.latitude, point.longitude); error = null; });
      await map?.animateCamera(CameraUpdate.newLatLngZoom(pin!, 16));
    } catch (e) { if (mounted) setState(() => error = '$e'); }
    finally { if (mounted) setState(() => locating = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(st(widget.ar, 'موقع تنفيذ الشغل', 'Work location'))), body: Column(children: [
    Padding(padding: const EdgeInsets.all(12), child: Text(st(widget.ar, 'اضغط على مكان التنفيذ أو اسحب الدبوس؛ مش لازم يكون موقع موبايلك الحالي.', 'Tap the work location or drag the pin; it need not be your current phone location.'))),
    Expanded(child: GoogleMap(initialCameraPosition: CameraPosition(target: pin ?? const LatLng(30.0444, 31.2357), zoom: pin == null ? 7 : 16), onMapCreated: (controller) => map = controller, onTap: (point) => setState(() => pin = point), markers: {if (pin != null) Marker(markerId: const MarkerId('work'), position: pin!, draggable: true, onDragEnd: (point) => setState(() => pin = point))}, myLocationButtonEnabled: false, zoomControlsEnabled: true)),
    if (error != null) Padding(padding: const EdgeInsets.all(8), child: Text(error!)),
    SafeArea(top: false, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [OutlinedButton(onPressed: locating ? null : locate, child: Text(st(widget.ar, 'استخدم موقعي الحالي', 'Use my current location'))), FilledButton(onPressed: pin == null ? null : () => Navigator.pop(context, pin), child: Text(st(widget.ar, 'تأكيد موقع التنفيذ', 'Confirm work location')))]))),
  ]));
}
