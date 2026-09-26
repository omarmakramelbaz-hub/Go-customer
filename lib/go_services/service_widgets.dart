import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'service_api.dart';

String st(bool ar, String arabic, String english) => ar ? arabic : english;
Widget serviceCard(Widget child) => Card(margin: const EdgeInsets.symmetric(vertical: 7), child: Padding(padding: const EdgeInsets.all(16), child: child));
Widget serviceText(String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Text(text, style: const TextStyle(height: 1.5)));

/// A genuine old-server 404 retains the legacy UI. Connection failures do not.
/// schema_ready also keeps existing bookings accessible while new work is off.
class ServiceGate extends StatefulWidget {
  const ServiceGate({super.key, required this.partner, required this.ar, required this.fallback, required this.builder, this.api});
  final bool partner;
  final bool ar;
  final WidgetBuilder fallback;
  final Widget Function(ServiceApi, ServiceCapabilities) builder;
  final ServiceApi? api;
  @override
  State<ServiceGate> createState() => _ServiceGateState();
}
class _ServiceGateState extends State<ServiceGate> {
  late final ServiceApi api = widget.api ?? ServiceApi(partner: widget.partner);
  ServiceCapabilities? caps;
  String? error;
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    setState(() { error = null; });
    try { final value = await api.capabilities(); if (mounted) setState(() => caps = value); }
    catch (e) { if (mounted) setState(() => error = '$e'); }
  }
  @override
  void dispose() { if (widget.api == null) api.close(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (error != null) return Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(error!), TextButton(onPressed: load, child: Text(st(widget.ar, 'إعادة المحاولة', 'Retry')))])));
    if (caps == null) return const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()));
    return caps!.ready ? widget.builder(api, caps!) : widget.fallback(context);
  }
}

class ServiceJobList extends StatefulWidget {
  const ServiceJobList({super.key, required this.api, required this.ar, this.scope = 'open', this.onChanged});
  final ServiceApi api;
  final bool ar;
  final String scope;
  final VoidCallback? onChanged;
  @override
  State<ServiceJobList> createState() => _ServiceJobListState();
}
class _ServiceJobListState extends State<ServiceJobList> with WidgetsBindingObserver {
  List<Map<String, dynamic>> jobs = [];
  int? nextPage;
  int pages = 1;
  bool loading = false;
  bool initialized = false;
  bool foreground = true;
  String? error;
  String? rate;
  Timer? timer;
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); load(); timer = Timer.periodic(const Duration(seconds: 15), (_) { if (mounted && foreground && TickerMode.of(context) && (ModalRoute.of(context)?.isCurrent ?? true)) load(); }); }
  @override
  void didUpdateWidget(covariant ServiceJobList oldWidget) { super.didUpdateWidget(oldWidget); if (oldWidget.scope != widget.scope) { pages = 1; jobs = []; initialized = false; load(); } }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { foreground = state == AppLifecycleState.resumed; if (foreground) load(); }
  Future<void> load({bool more = false}) async {
    if (loading || (more && nextPage == null)) return;
    final scope = widget.scope;
    final requestedPage = more ? nextPage! : 1;
    setState(() => loading = true);
    try {
      var page = await widget.api.jobs(scope: scope, page: requestedPage);
      var items = serviceMaps(page['items']);
      var loaded = requestedPage;
      // Refresh all pages the user opened; never silently drop page two.
      while (!more && page['next_page'] != null && loaded < pages) { page = await widget.api.jobs(scope: scope, page: serviceId(page['next_page'])); items.addAll(serviceMaps(page['items'])); loaded++; }
      if (!mounted || scope != widget.scope) return;
      setState(() { jobs = more ? [...jobs, ...items] : items; nextPage = page['next_page'] == null ? null : serviceId(page['next_page']); pages = loaded; rate = page['commission_rate']?.toString(); error = null; initialized = true; });
    } catch (e) { if (mounted && scope == widget.scope) setState(() { error = '$e'; initialized = true; }); }
    finally { if (mounted) { setState(() => loading = false); if (scope != widget.scope) load(); } }
  }
  @override
  void dispose() { timer?.cancel(); WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  Future<void> open(Map<String, dynamic> job) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ServiceJobScreen(api: widget.api, ar: widget.ar, id: serviceId(job['id']), commissionRate: rate)));
    if (!mounted) return;
    widget.onChanged?.call();
    await load();
  }
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    if (loading && !initialized) const LinearProgressIndicator(),
    if (error != null) serviceCard(Column(children: [Text(error!), Text(st(widget.ar, 'البيانات قديمة حتى نجاح التحديث.', 'Information may be stale until refreshed.')), TextButton(onPressed: loading ? null : () => load(), child: Text(st(widget.ar, 'إعادة المحاولة', 'Retry')))])),
    if (initialized && jobs.isEmpty && error == null) serviceCard(Text(st(widget.ar, 'لا توجد شغلانات في هذه القائمة حاليًا.', 'No jobs in this list yet.'))),
    for (final job in jobs) serviceCard(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('#${job['id']} · ${serviceState(job['status']?.toString(), widget.ar)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      serviceText('${job['description'] ?? ''}'),
      Text('${job['area'] ?? ''}'),
      if (serviceMaps(job['offers']).isNotEmpty) serviceText(st(widget.ar, '${serviceMaps(job['offers']).length} عرض · اضغط لمراجعة الأسعار', '${serviceMaps(job['offers']).length} quote(s) · Review prices')),
      if (widget.api.partner && job['recipient_status'] == 'quoted') serviceText(st(widget.ar, 'عرضك أُرسل؛ بانتظار اختيار العميل.', 'Quote sent; awaiting the customer.')),
      FilledButton(onPressed: () => open(job), child: Text(st(widget.ar, 'عرض الشغلانة والعروض', 'View job and quotes'))),
    ])),
    if (nextPage != null) TextButton(onPressed: loading ? null : () => load(more: true), child: Text(st(widget.ar, 'عرض المزيد', 'Load more'))),
  ]);
}

class ServiceJobScreen extends StatefulWidget {
  const ServiceJobScreen({super.key, required this.api, required this.ar, required this.id, this.commissionRate});
  final ServiceApi api;
  final bool ar;
  final int id;
  final String? commissionRate;
  @override
  State<ServiceJobScreen> createState() => _ServiceJobScreenState();
}
class _ServiceJobScreenState extends State<ServiceJobScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? job;
  ServiceCapabilities? caps;
  bool loading = false;
  bool busy = false;
  bool foreground = true;
  bool stale = true;
  String? error;
  Timer? timer;
  bool get ar => widget.ar;
  String t(String a, String e) => st(ar, a, e);
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); load(); timer = Timer.periodic(const Duration(seconds: 10), (_) { if (mounted && foreground && (ModalRoute.of(context)?.isCurrent ?? true)) load(); }); }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { foreground = state == AppLifecycleState.resumed; if (foreground) load(); }
  Future<void> load() async {
    if (loading || busy) return;
    loading = true;
    try {
      final data = await widget.api.job(widget.id);
      final capabilities = await widget.api.capabilities();
      if (mounted) setState(() { job = data; caps = capabilities; stale = false; error = null; });
    } catch (e) { if (mounted) setState(() { error = '$e'; stale = true; }); }
    finally { loading = false; }
  }
  @override
  void dispose() { timer?.cancel(); WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  Future<void> run(Future<Map<String, dynamic>> Function() action) async {
    if (busy || stale) return;
    setState(() { busy = true; error = null; });
    try { final data = await action(); if (mounted) setState(() { job = data; stale = false; }); }
    catch (e) { if (mounted) setState(() { error = '$e'; stale = true; }); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<bool> confirm(String title, String text) async => await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: Text(title), content: Text(text), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t('رجوع', 'Back'))), FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(t('تأكيد', 'Confirm')))])) ?? false;
  Future<void> chooseOffer(Map<String, dynamic> offer) async {
    if (job == null || !serviceOfferLive(job!, offer) || busy || stale) return;
    final method = await showDialog<String>(context: context, builder: (_) => _AcceptOffer(ar: ar, offer: offer, methods: caps?.methods ?? const []));
    if (method != null && mounted) await run(() => widget.api.accept(widget.id, serviceId(offer['id']), method));
  }
  Future<void> changeStatus(String state) async {
    String? reason;
    if (state == 'cancelled' || state == 'disputed') {
      final input = TextEditingController();
      reason = await showDialog<String>(context: context, builder: (c) => AlertDialog(title: Text(state == 'cancelled' ? t('إلغاء الشغلانة', 'Cancel job') : t('تسجيل اعتراض', 'Open dispute')), content: TextField(controller: input, maxLength: 500, maxLines: 3, decoration: InputDecoration(labelText: t('السبب (٣ أحرف على الأقل)', 'Reason (at least 3 characters)'))), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(t('رجوع', 'Back'))), FilledButton(onPressed: () { if (input.text.trim().length >= 3) Navigator.pop(c, input.text.trim()); }, child: Text(t('تأكيد', 'Confirm')))]));
      // Dialog transition may still hold the controller; let the widget dispose it.
      if (reason == null) return;
    } else {
      final message = state == 'completed'
        ? (job?['payment_method'] == 'cash' ? t('أؤكد اكتمال الشغل ودفع ${job?['price']} ج.م للصنايعي نقدًا.', 'I confirm completion and cash payment of EGP ${job?['price']}.') : t('أؤكد اكتمال الشغل وأوافق على صرف المبلغ المحجوز للصنايعي.', 'I confirm completion and release of the held payment to the professional.'))
        : (state == 'in_progress' ? t('تأكيد بدء تنفيذ الشغل المتفق عليه؟', 'Start the agreed work?') : t('سيُطلب من العميل تأكيد إتمام الشغل.', 'The customer will be asked to confirm completion.'));
      if (!await confirm(t('تأكيد الإجراء', 'Confirm action'), message)) return;
    }
    if (mounted) await run(() => widget.api.status(widget.id, state, reason: reason, cashPaid: state == 'completed' && job?['payment_method'] == 'cash'));
  }
  Future<void> quote() async {
    final data = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => _QuoteForm(ar: ar, rate: widget.commissionRate));
    if (data != null && mounted) await run(() => widget.api.quote(widget.id, data));
  }
  Future<void> pay() async {
    if (busy || stale) return;
    setState(() => busy = true);
    try {
      final data = await widget.api.checkout(widget.id);
      final uri = Uri.tryParse('${data['url']}');
      if (uri == null || uri.scheme != 'https' || uri.host != 'accept.paymob.com' || uri.userInfo.isNotEmpty || !uri.path.startsWith('/unifiedcheckout/')) throw const ServiceFailure('رابط دفع غير صالح / Invalid checkout URL.');
      if (!mounted) return;
      if (kIsWeb) {
        if (!await launchUrl(uri, webOnlyWindowName: '_blank')) throw const ServiceFailure('تعذر فتح صفحة الدفع / Could not open payment page.');
      } else {
        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _HostedCheckout(url: uri.toString(), ar: ar)));
      }
      // Browser/webview navigation NEVER marks a payment successful.
      if (mounted) setState(() => error = t('حالة الدفع تتحدث بعد تأكيد الخادم. يمكنك الرجوع للتطبيق بأمان.', 'Payment updates after server verification. Return to the app to check.'));
    } catch (e) { if (mounted) setState(() => error = '$e'); }
    finally { if (mounted) { setState(() => busy = false); await load(); } }
  }
  Widget action(String label, VoidCallback callback) => Padding(padding: const EdgeInsets.only(top: 10), child: FilledButton(onPressed: busy || stale ? null : callback, child: Text(label)));
  Widget offerCard(Map<String, dynamic> offer) => serviceCard(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text('${offer['name'] ?? ''} · ${offer['price']} ${t('ج.م', 'EGP')}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
    serviceText(serviceState(offer['status']?.toString(), ar)), serviceText('${offer['scope'] ?? ''}'),
    serviceText(offer['materials_included'] == true ? t('يشمل الخامات المذكورة في نطاق العرض', 'Includes the materials stated in the scope') : t('مصنعية فقط؛ الخامات غير مشمولة', 'Labour only; materials excluded')),
    serviceText(t('الوصول: ${offer['arrival_minutes']} دقيقة · مدة العمل: ${offer['duration_minutes']} دقيقة', 'Arrival: ${offer['arrival_minutes']} min · Work: ${offer['duration_minutes']} min')),
    serviceText(t('صالح حتى: ${localTime(offer['expires_at'])}', 'Valid until: ${localTime(offer['expires_at'])}')),
    if (offer['commission'] != null) serviceText(t('عمولتك على هذا العرض: ${offer['commission']} ج.م، تخصم بعد قبول العميل فقط.', 'Your commission: EGP ${offer['commission']}, debited only on customer acceptance.')),
    if (!widget.api.partner && caps?.enabled == true && job != null && serviceOfferLive(job!, offer)) ...[
      action(t('اختيار هذا العرض', 'Choose this quote'), () => chooseOffer(offer)),
      OutlinedButton(onPressed: busy || stale ? null : () async { if (await confirm(t('رفض العرض', 'Reject quote'), t('سيستمر البحث عن صنايعية آخرين مع الاحتفاظ بالعروض الأخرى.', 'Search continues with other professionals; other quotes remain available.')) && mounted) await run(() => widget.api.reject(widget.id, serviceId(offer['id']))); }, child: Text(t('رفض واستمرار البحث', 'Reject and keep searching'))),
    ],
  ]));
  @override
  Widget build(BuildContext context) {
    final data = job;
    final status = data?['status'];
    final selected = data != null && serviceSelected(data);
    final partner = widget.api.partner;
    return Directionality(textDirection: ar ? TextDirection.rtl : TextDirection.ltr, child: Scaffold(
      appBar: AppBar(title: Text(t('الشغلانة #${widget.id}', 'Job #${widget.id}'))),
      body: RefreshIndicator(onRefresh: load, child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16), children: [
        if (busy) const LinearProgressIndicator(),
        if (error != null) serviceCard(Column(children: [Text(error!), TextButton(onPressed: busy ? null : load, child: Text(t('تحديث الحالة', 'Check status')))])),
        if (data == null && error == null) const Center(child: CircularProgressIndicator()),
        if (data != null) ...[
          Text(serviceState(status?.toString(), ar), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
          serviceText('${data['description'] ?? ''}'), serviceText('${data['area'] ?? ''}'),
          if (data['scheduled_at'] != null) serviceText(t('الموعد المطلوب: ${localTime(data['scheduled_at'])}', 'Requested time: ${localTime(data['scheduled_at'])}')),
          if (data['photos'] is List && (data['photos'] as List).isNotEmpty) SizedBox(height: 155, child: ListView(scrollDirection: Axis.horizontal, children: [for (final photo in (data['photos'] as List).whereType<String>()) Padding(padding: const EdgeInsets.all(4), child: InkWell(onTap: () => showDialog<void>(context: context, builder: (_) => Dialog(child: InteractiveViewer(child: Image.network(photo, errorBuilder: (_, __, ___) => Text(t('حدّث الشغلانة لإعادة تحميل الصورة.', 'Refresh the job to reload the photo.')))))), child: Image.network(photo, width: 155, height: 155, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(width: 155, child: Icon(Icons.broken_image_outlined)))))])),
          if (data['location'] is Map) serviceCard(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            serviceText('${(data['location'] as Map)['address'] ?? ''}'),
            TextButton(onPressed: () { final location = data['location'] as Map; launchUrl(Uri.https('www.google.com', '/maps', {'q': '${location['lat']},${location['lng']}'}), mode: LaunchMode.externalApplication); }, child: Text(t('موقع التنفيذ على الخريطة', 'Work location on map'))),
            if ((partner ? data['phone'] : data['partner_phone']) != null) serviceText(t('رقم التواصل: ${partner ? data['phone'] : data['partner_phone']}', 'Contact: ${partner ? data['phone'] : data['partner_phone']}')),
          ])) else serviceText(t('العنوان التفصيلي ورقم العميل يظهران بعد الاتفاق فقط.', 'Exact address and customer phone are shared only after agreement.')),
          if (status == 'searching') serviceText(t('البحث مستمر حتى ${localTime(data['search_until'])}. لا يتم اختيار عرض تلقائيًا.', 'Search continues until ${localTime(data['search_until'])}. No quote is accepted automatically.')),
          if (caps != null && !caps!.enabled) serviceText(t('استقبال الطلبات والعروض الجديدة متوقف مؤقتًا. متابعة الطلبات القائمة متاحة.', 'New jobs and quotes are paused. Existing bookings remain accessible.')),
          if (partner && caps?.enabled == true && serviceCanQuote(data)) action(t('إرسال عرض مصنعية', 'Send labour quote'), quote),
          if (partner && status == 'searching' && ['invited', 'quoted'].contains(data['recipient_status'])) OutlinedButton(onPressed: busy || stale ? null : () async { if (await confirm(t('تخطي الشغلانة', 'Skip job'), t('لن يستمر عرضك في المنافسة على هذه الشغلانة.', 'Your quote will no longer be available for this job.')) && mounted) await run(() => widget.api.skip(widget.id)); }, child: Text(t('غير مناسب لي', 'Not for me'))),
          for (final offer in serviceMaps(data['offers'])) offerCard(offer),
          if (data['accepted_offer_id'] != null) serviceCard(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(t('القيمة المتفق عليها: ${data['price']} ج.م', 'Agreed price: EGP ${data['price']}'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            serviceText(paymentLabel(data['payment_method']?.toString(), ar)), serviceText(serviceState(data['payment_status']?.toString(), ar)),
            if (data['commission'] != null) serviceText(t('العمولة المسجلة: ${data['commission']} ج.م؛ لا تخصم مرة ثانية عند الإتمام.', 'Recorded commission: EGP ${data['commission']}; not charged again at completion.')),
            if (!partner && status == 'booked' && data['payment_status'] == 'unpaid') ...[serviceText(t('أكمل الدفع قبل ${localTime(data['payment_due_at'])}', 'Pay before ${localTime(data['payment_due_at'])}')), action(t('فتح صفحة الدفع الآمنة', 'Open secure checkout'), pay)],
          ])),
          if (partner && selected && status == 'booked' && ['cash_due', 'held'].contains(data['payment_status'])) action(t('بدء الشغل', 'Start work'), () => changeStatus('in_progress')),
          if (partner && selected && status == 'in_progress') action(t('أنهيت الشغل — اطلب تأكيد العميل', 'Work finished — request confirmation'), () => changeStatus('awaiting_confirmation')),
          if (!partner && status == 'awaiting_confirmation') action(t('تأكيد الإتمام والدفع', 'Confirm completion and payment'), () => changeStatus('completed')),
          if ((!partner || selected) && ['searching', 'booked'].contains(status)) OutlinedButton(onPressed: busy || stale ? null : () => changeStatus('cancelled'), child: Text(t('إلغاء الشغلانة', 'Cancel job'))),
          if ((!partner || selected) && ['in_progress', 'awaiting_confirmation'].contains(status)) OutlinedButton(onPressed: busy || stale ? null : () => changeStatus('disputed'), child: Text(t('تسجيل اعتراض', 'Open dispute'))),
          if (status == 'disputed' || data['payment_status'] == 'refund_pending') serviceText(t('الحالة تحتاج متابعة الدعم؛ لا يتم صرف المبلغ أو رد الدفع الإلكتروني تلقائيًا من هذه الشاشة.', 'Support review is required; this screen does not automatically release disputed funds or refund gateway payments.')),
        ],
      ])),
    ));
  }
}
String localTime(dynamic value) { final date = DateTime.tryParse('$value'); return date == null ? '—' : date.toLocal().toString().substring(0, 16); }

class _AcceptOffer extends StatefulWidget {
  const _AcceptOffer({required this.ar, required this.offer, required this.methods});
  final bool ar;
  final Map<String, dynamic> offer;
  final List<String> methods;
  @override
  State<_AcceptOffer> createState() => _AcceptOfferState();
}
class _AcceptOfferState extends State<_AcceptOffer> {
  String? method;
  bool agreed = false;
  @override
  Widget build(BuildContext context) => AlertDialog(title: Text(st(widget.ar, 'مراجعة الاتفاق', 'Review agreement')), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text('${widget.offer['name']} · ${widget.offer['price']} EGP', style: const TextStyle(fontWeight: FontWeight.bold)),
    serviceText('${widget.offer['scope']}'),
    serviceText(widget.offer['materials_included'] == true ? st(widget.ar, 'الخامات المذكورة مشمولة', 'Stated materials included') : st(widget.ar, 'الخامات غير مشمولة', 'Materials excluded')),
    for (final item in widget.methods) RadioListTile<String>(value: item, groupValue: method, onChanged: (v) => setState(() => method = v), title: Text(paymentLabel(item, widget.ar))),
    if (method == 'wallet') serviceText(st(widget.ar, 'سيتم حجز كامل قيمة الشغل من محفظتك لحين تأكيد الإتمام.', 'The full price will be held from your wallet until completion.')),
    if (method != null && !['cash', 'wallet'].contains(method)) serviceText(st(widget.ar, 'بعد الاتفاق افتح صفحة الدفع وأكمل العملية قبل انتهاء المهلة.', 'After booking, open checkout and pay before the deadline.')),
    CheckboxListTile(value: agreed, onChanged: (v) => setState(() => agreed = v == true), title: Text(st(widget.ar, 'راجعت السعر ونطاق الشغل وأوافق على العرض.', 'I reviewed and agree to the price and scope.'))),
  ])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(st(widget.ar, 'رجوع', 'Back'))), FilledButton(onPressed: agreed && method != null ? () => Navigator.pop(context, method) : null, child: Text(st(widget.ar, 'قبول العرض', 'Accept quote')))]);
}

class _QuoteForm extends StatefulWidget {
  const _QuoteForm({required this.ar, this.rate});
  final bool ar;
  final String? rate;
  @override
  State<_QuoteForm> createState() => _QuoteFormState();
}
class _QuoteFormState extends State<_QuoteForm> {
  final form = GlobalKey<FormState>();
  final price = TextEditingController();
  final scope = TextEditingController();
  final arrival = TextEditingController(text: '30');
  final duration = TextEditingController(text: '60');
  bool materials = false;
  bool agreed = false;
  @override
  void dispose() { price.dispose(); scope.dispose(); arrival.dispose(); duration.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(title: Text(st(widget.ar, 'عرض المصنعية النهائي', 'Final labour quote')), content: SingleChildScrollView(child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [
    TextFormField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: st(widget.ar, 'السعر النهائي بالجنيه', 'Final price in EGP')), validator: (v) => normalizeServicePrice(v ?? '') == null ? st(widget.ar, 'أدخل سعرًا صحيحًا من ١ إلى مليون جنيه', 'Enter a price from EGP 1 to 1,000,000') : null),
    TextFormField(controller: scope, maxLines: 3, maxLength: 2000, decoration: InputDecoration(labelText: st(widget.ar, 'الشغل المشمول بالعرض بالتحديد', 'Exactly what the quote includes')), validator: (v) => (v?.trim().length ?? 0) < 5 ? st(widget.ar, 'وضح نطاق العمل', 'Describe the scope') : null),
    SwitchListTile(value: materials, onChanged: (v) => setState(() => materials = v), title: Text(st(widget.ar, 'السعر يشمل الخامات المذكورة', 'Includes the specified materials'))),
    TextFormField(controller: arrival, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: st(widget.ar, 'الوصول خلال (دقيقة)', 'Arrival in minutes')), validator: (v) => (int.tryParse(v ?? '') ?? 0) < 5 || (int.tryParse(v ?? '') ?? 0) > 10080 ? '5–10080' : null),
    TextFormField(controller: duration, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: st(widget.ar, 'مدة العمل (دقيقة)', 'Work duration in minutes')), validator: (v) => (int.tryParse(v ?? '') ?? 0) < 5 || (int.tryParse(v ?? '') ?? 0) > 43200 ? '5–43200' : null),
    serviceText(st(widget.ar, 'عمولة حسابك${widget.rate == null ? '' : ' ${widget.rate}%'} تخصم عند قبول العميل فقط، ويجب توفر رصيد يغطيها.', 'Your account commission${widget.rate == null ? '' : ' ${widget.rate}%'} is charged only on customer acceptance; sufficient balance is required.')),
    CheckboxListTile(value: agreed, onChanged: (v) => setState(() => agreed = v == true), title: Text(st(widget.ar, 'هذا عرض نهائي للنطاق المذكور، ولا يتغير من طرف واحد.', 'This price is final for the stated scope and cannot be changed unilaterally.'))),
  ]))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(st(widget.ar, 'رجوع', 'Back'))), FilledButton(onPressed: !agreed ? null : () { if (form.currentState!.validate()) Navigator.pop(context, <String, dynamic>{'price': normalizeServicePrice(price.text), 'scope': scope.text.trim(), 'materials_included': materials, 'arrival_minutes': int.parse(arrival.text), 'duration_minutes': int.parse(duration.text)}); }, child: Text(st(widget.ar, 'إرسال العرض', 'Send quote')))]);
}

/// Native hosted checkout, with the same WebView approach as existing payments.
/// No redirect callback mutates a balance or marks a job paid.
class _HostedCheckout extends StatelessWidget {
  const _HostedCheckout({required this.url, required this.ar});
  final String url;
  final bool ar;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(st(ar, 'الدفع الآمن', 'Secure checkout'))), body: InAppWebView(initialUrlRequest: URLRequest(url: WebUri(url)), initialSettings: InAppWebViewSettings(javaScriptEnabled: true, useShouldOverrideUrlLoading: true), shouldOverrideUrlLoading: (controller, action) async {
    final uri = Uri.tryParse('${action.request.url}');
    if (uri == null) return NavigationActionPolicy.CANCEL;
    if (!['https', 'about'].contains(uri.scheme)) return NavigationActionPolicy.CANCEL;
    return NavigationActionPolicy.ALLOW;
  }));
}
