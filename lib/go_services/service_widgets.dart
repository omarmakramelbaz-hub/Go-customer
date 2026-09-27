import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'service_api.dart';

String st(bool ar, String a, String e) => ar ? a : e;
Widget serviceCard(Widget child) => Card(margin: const EdgeInsets.symmetric(vertical: 7), child: Padding(padding: const EdgeInsets.all(16), child: child));
Widget serviceText(String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Text(text, style: const TextStyle(height: 1.5)));
String localTime(dynamic value) { final date = DateTime.tryParse('$value'); return date == null ? '—' : date.toLocal().toString().substring(0, 16); }

/// Legacy fallback is explicit for existing order history only. New service
/// requests wait for quotations instead of silently using direct assignment.
class ServiceGate extends StatefulWidget {
  const ServiceGate({super.key, required this.partner, required this.ar, this.fallback, this.title, required this.builder, this.api});
  final bool partner;
  final bool ar;
  final WidgetBuilder? fallback;
  final String? title;
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
    setState(() => error = null);
    try { final value = await api.capabilities(); if (mounted) setState(() => caps = value); }
    catch (e) { if (mounted) setState(() => error = '$e'); }
  }
  @override
  void dispose() { if (widget.api == null) api.close(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (error != null) return Center(child: serviceCard(Column(mainAxisSize: MainAxisSize.min, children: [Text(error!), TextButton(onPressed: load, child: Text(st(widget.ar, 'إعادة المحاولة', 'Retry')))])));
    if (caps == null) return const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()));
    if (caps!.ready) return widget.builder(api, caps!);
    if (widget.fallback != null) return widget.fallback!(context);
    return Directionality(
      textDirection: widget.ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title ?? st(widget.ar, 'طلب صنايعي', 'Request a professional'))),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          const Icon(Icons.request_quote_outlined, size: 52),
          const SizedBox(height: 16),
          Text(st(widget.ar, 'عروض المصنعية غير متاحة حاليًا', 'Labour quotations are currently unavailable'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          serviceText(st(widget.ar, 'هتوصف الشغلانة، والصنايعية المتاحين في منطقتك يرسلوا عروضهم. إنت تختار السعر ونطاق الشغل المناسبين قبل الاتفاق.', 'Describe the job, receive quotes from available local professionals, then choose the price and scope before agreeing.')),
          serviceText(st(widget.ar, 'لم يتم إرسال طلب أو اختيار صنايعي. تقدر تتابع طلباتك السابقة من «طلباتي».', 'No request has been sent and no professional selected. Existing requests remain available in My orders.')),
          FilledButton(onPressed: load, child: Text(st(widget.ar, 'إعادة المحاولة', 'Retry'))),
        ]),
      ),
    );
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
  Timer? timer;
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); load(); timer = Timer.periodic(const Duration(seconds: 15), (_) { if (mounted && foreground && TickerMode.of(context) && (ModalRoute.of(context)?.isCurrent ?? true)) load(); }); }
  @override
  void didUpdateWidget(covariant ServiceJobList oldWidget) { super.didUpdateWidget(oldWidget); if (oldWidget.scope != widget.scope) { pages = 1; jobs = []; initialized = false; load(); } }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { foreground = state == AppLifecycleState.resumed; if (foreground) load(); }
  Future<void> load({bool more = false}) async {
    if (loading || (more && nextPage == null)) return;
    final scope = widget.scope; final requestedPage = more ? nextPage! : 1;
    setState(() => loading = true);
    try {
      var page = await widget.api.jobs(scope: scope, page: requestedPage);
      final items = serviceMaps(page['items']); var loaded = requestedPage;
      while (!more && page['next_page'] != null && loaded < pages) { page = await widget.api.jobs(scope: scope, page: serviceId(page['next_page'])); items.addAll(serviceMaps(page['items'])); loaded++; }
      if (!mounted || scope != widget.scope) return;
      setState(() { jobs = more ? [...jobs, ...items] : items; nextPage = page['next_page'] == null ? null : serviceId(page['next_page']); pages = loaded; error = null; initialized = true; });
    } catch (e) { if (mounted && scope == widget.scope) setState(() { error = '$e'; initialized = true; }); }
    finally { if (mounted) { setState(() => loading = false); if (scope != widget.scope) load(); } }
  }
  @override
  void dispose() { timer?.cancel(); WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  Future<void> open(Map<String, dynamic> job) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ServiceJobScreen(api: widget.api, ar: widget.ar, id: serviceId(job['id']))));
    if (!mounted) return; widget.onChanged?.call(); await load();
  }
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    if (loading && !initialized) const LinearProgressIndicator(),
    if (error != null) serviceCard(Column(children: [Text(error!), Text(st(widget.ar, 'البيانات قديمة حتى نجاح التحديث.', 'Information may be stale until refreshed.')), TextButton(onPressed: loading ? null : () => load(), child: Text(st(widget.ar, 'إعادة المحاولة', 'Retry')))])),
    if (initialized && jobs.isEmpty && error == null) serviceCard(Text(st(widget.ar, 'لا توجد شغلانات في هذه القائمة حاليًا.', 'No jobs in this list yet.'))),
    for (final job in jobs) serviceCard(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('#${job['id']} · ${serviceState(job['status']?.toString(), widget.ar)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      serviceText('${job['description'] ?? ''}'),
      if (serviceMaps(job['offers']).isNotEmpty) serviceText(st(widget.ar, '${serviceMaps(job['offers']).length} عرض · اضغط لمراجعة الأسعار', '${serviceMaps(job['offers']).length} quote(s) · Review prices')),
      FilledButton(onPressed: () => open(job), child: Text(st(widget.ar, 'عرض الشغلانة والعروض', 'View job and quotes'))),
    ])),
    if (nextPage != null) TextButton(onPressed: loading ? null : () => load(more: true), child: Text(st(widget.ar, 'عرض المزيد', 'Load more'))),
  ]);
}

/// Customer-only detail screen. A revision counter discards any poll started
/// before a mutation, preventing old quotes from replacing the accepted state.
class ServiceJobScreen extends StatefulWidget {
  const ServiceJobScreen({super.key, required this.api, required this.ar, required this.id});
  final ServiceApi api;
  final bool ar;
  final int id;
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
  int revision = 0;
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
    loading = true; final epoch = revision;
    try {
      final data = await widget.api.job(widget.id); final capabilities = await widget.api.capabilities();
      if (mounted && epoch == revision && !busy) setState(() { job = data; caps = capabilities; stale = false; error = null; });
    } catch (e) { if (mounted && epoch == revision) setState(() { error = '$e'; stale = true; }); }
    finally { loading = false; }
  }
  @override
  void dispose() { timer?.cancel(); WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  Future<void> run(Future<Map<String, dynamic>> Function() action) async {
    if (busy || stale) return;
    revision++; setState(() { busy = true; error = null; });
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
    String? cancellationFee;
    if (state == 'cancelled' && job?['status'] == 'booked') {
      final policy = job?['cancellation'];
      if (policy is! Map || policy['fee'] == null) { setState(() => error = t('حدّث الطلب لعرض قيمة الإلغاء أولًا.', 'Refresh the job to load the cancellation fee first.')); return; }
      cancellationFee = policy['fee'].toString();
      if (!await confirm(t('تأكيد الإلغاء وخصم خدمة التطبيق', 'Confirm cancellation and app fee'), t('عند إلغائك بعد القبول، تُخصم خدمة التطبيق بنسبة ${policy['rate']}%، بقيمة $cancellationFee ج.م من محفظتك، وتُرد العمولة للصنايعي. أي مبلغ محجوز للشغل يُرد قبل حساب الخصم. هل توافق؟', 'Cancelling after acceptance debits the ${policy['rate']}% app service fee (EGP $cancellationFee) from your wallet and refunds the professional’s commission. Any wallet hold for the job is released before this debit. Do you agree?'))) return;
    }
    if (state == 'cancelled' || state == 'disputed') { reason = await showDialog<String>(context: context, builder: (_) => _ReasonForm(ar: ar)); if (reason == null) return; }
    else {
      final message = job?['payment_method'] == 'cash'
        ? t('أؤكد اكتمال الشغل ودفع ${job?['price']} ج.م للصنايعي نقدًا.', 'I confirm completion and cash payment of EGP ${job?['price']}.')
        : t('أؤكد اكتمال الشغل وأوافق على صرف المبلغ المحجوز للصنايعي.', 'I confirm completion and release of the held payment to the professional.');
      if (!await confirm(t('تأكيد الإتمام', 'Confirm completion'), message)) return;
    }
    if (mounted) await run(() => widget.api.status(widget.id, state, reason: reason, cashPaid: state == 'completed' && job?['payment_method'] == 'cash', cancellationFee: cancellationFee));
  }
  Future<void> pay() async {
    if (busy || stale) return;
    revision++; setState(() => busy = true);
    try {
      final data = await widget.api.checkout(widget.id); final uri = Uri.tryParse('${data['url']}');
      if (uri == null || uri.scheme != 'https' || uri.host != 'accept.paymob.com' || uri.userInfo.isNotEmpty || !uri.path.startsWith('/unifiedcheckout/')) throw const ServiceFailure('رابط دفع غير صالح / Invalid checkout URL.');
      if (!mounted) return;
      if (kIsWeb) { if (!await launchUrl(uri, webOnlyWindowName: '_blank')) throw const ServiceFailure('تعذر فتح صفحة الدفع / Could not open payment page.'); }
      else { await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _HostedCheckout(url: uri.toString(), ar: ar))); }
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
    if (caps?.enabled == true && job != null && serviceOfferLive(job!, offer)) ...[
      action(t('اختيار هذا العرض', 'Choose this quote'), () => chooseOffer(offer)),
      OutlinedButton(onPressed: busy || stale ? null : () async { if (await confirm(t('رفض العرض', 'Reject quote'), t('سيستمر البحث عن صنايعية آخرين مع الاحتفاظ بالعروض الأخرى.', 'Search continues with other professionals; other quotes remain available.')) && mounted) await run(() => widget.api.reject(widget.id, serviceId(offer['id']))); }, child: Text(t('رفض واستمرار البحث', 'Reject and keep searching'))),
    ],
  ]));
  @override
  Widget build(BuildContext context) {
    final data = job; final status = data?['status'];
    return Directionality(textDirection: ar ? TextDirection.rtl : TextDirection.ltr, child: Scaffold(appBar: AppBar(title: Text(t('الشغلانة #${widget.id}', 'Job #${widget.id}'))), body: RefreshIndicator(onRefresh: load, child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16), children: [
      if (busy) const LinearProgressIndicator(),
      if (error != null) serviceCard(Column(children: [Text(error!), TextButton(onPressed: busy ? null : load, child: Text(t('تحديث الحالة', 'Check status')))])),
      if (data == null && error == null) const Center(child: CircularProgressIndicator()),
      if (data != null) ...[
        Text(serviceState(status?.toString(), ar), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)), serviceText('${data['description'] ?? ''}'),
        if (data['scheduled_at'] != null) serviceText(t('الموعد المطلوب: ${localTime(data['scheduled_at'])}', 'Requested time: ${localTime(data['scheduled_at'])}')),
        if (data['photos'] is List && (data['photos'] as List).isNotEmpty) SizedBox(height: 155, child: ListView(scrollDirection: Axis.horizontal, children: [for (final photo in (data['photos'] as List).whereType<String>()) Padding(padding: const EdgeInsets.all(4), child: InkWell(onTap: () => showDialog<void>(context: context, builder: (_) => Dialog(child: InteractiveViewer(child: Image.network(photo, errorBuilder: (_, __, ___) => Text(t('حدّث الشغلانة لإعادة تحميل الصورة.', 'Refresh the job to reload the photo.')))))), child: Image.network(photo, width: 155, height: 155, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(width: 155, child: Icon(Icons.broken_image_outlined)))))])),
        if (data['location'] is Map) serviceCard(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          serviceText('${(data['location'] as Map)['address'] ?? ''}'),
          TextButton(onPressed: () { final p = data['location'] as Map; launchUrl(Uri.https('www.google.com', '/maps', {'q': '${p['lat']},${p['lng']}'}), mode: LaunchMode.externalApplication); }, child: Text(t('موقع التنفيذ على الخريطة', 'Work location on map'))),
          if (data['partner_name'] != null) serviceText(t('الصنايعي: ${data['partner_name']}', 'Professional: ${data['partner_name']}')),
          if (data['partner_phone'] != null) serviceText(t('رقم التواصل: ${data['partner_phone']}', 'Contact: ${data['partner_phone']}')),
        ])),
        if (status == 'searching') serviceText(t('البحث مستمر حتى ${localTime(data['search_until'])}. لا يتم اختيار عرض تلقائيًا.', 'Search continues until ${localTime(data['search_until'])}. No quote is accepted automatically.')),
        if (caps != null && !caps!.enabled) serviceText(t('استقبال الطلبات والعروض الجديدة متوقف مؤقتًا. متابعة الطلبات القائمة متاحة.', 'New jobs and quotes are paused. Existing bookings remain accessible.')),
        for (final offer in serviceMaps(data['offers'])) offerCard(offer),
        if (data['accepted_offer_id'] != null) serviceCard(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(t('القيمة المتفق عليها: ${data['price']} ج.م', 'Agreed price: EGP ${data['price']}'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          serviceText(paymentLabel(data['payment_method']?.toString(), ar)), serviceText(serviceState(data['payment_status']?.toString(), ar)),
          if (status == 'booked' && data['payment_status'] == 'unpaid') ...[serviceText(t('أكمل الدفع قبل ${localTime(data['payment_due_at'])}. الرجوع من صفحة الدفع وحده ليس تأكيدًا؛ ننتظر تحقق الخادم.', 'Pay before ${localTime(data['payment_due_at'])}. Returning from checkout is not confirmation; server verification is required.')), action(t('فتح صفحة الدفع الآمنة', 'Open secure checkout'), pay)],
        ])),
        if (status == 'awaiting_confirmation') action(t('تأكيد الإتمام والدفع', 'Confirm completion and payment'), () => changeStatus('completed')),
        if (status == 'booked' && data['cancellation'] is Map) serviceText(t('إذا ألغيت بعد القبول، تتحمل خدمة التطبيق: ${(data['cancellation'] as Map)['rate']}% = ${(data['cancellation'] as Map)['fee']} ج.م من محفظتك.', 'If you cancel after acceptance, you bear the app fee: ${(data['cancellation'] as Map)['rate']}% = EGP ${(data['cancellation'] as Map)['fee']} from your wallet.')),
        if (status == 'cancelled' && data['cancellation'] is Map && (data['cancellation'] as Map)['charged_to'] != null) serviceText((data['cancellation'] as Map)['charged_to'] == 'customer' ? t('تم خصم ${(data['cancellation'] as Map)['fee']} ج.م من محفظتك لخدمة التطبيق لأنك ألغيت الطلب.', 'EGP ${(data['cancellation'] as Map)['fee']} was debited from your wallet for the app fee because you cancelled.') : t('الصنايعي ألغى الطلب وتحمل خدمة التطبيق. لا توجد عليك رسوم إلغاء.', 'The professional cancelled and bears the app fee. You owe no cancellation fee.')),
        if (['searching', 'booked'].contains(status)) OutlinedButton(onPressed: busy || stale ? null : () => changeStatus('cancelled'), child: Text(status == 'booked' ? t('إلغاء وتحمل خدمة التطبيق', 'Cancel and bear the app fee') : t('إلغاء الشغلانة', 'Cancel job'))),
        if (['in_progress', 'awaiting_confirmation'].contains(status)) OutlinedButton(onPressed: busy || stale ? null : () => changeStatus('disputed'), child: Text(t('تسجيل اعتراض', 'Open dispute'))),
        if (status == 'disputed' || data['payment_status'] == 'refund_pending') serviceText(t('الحالة تحتاج متابعة الدعم؛ لا يتم صرف المبلغ أو رد الدفع الإلكتروني تلقائيًا من هذه الشاشة.', 'Support review is required; this screen does not automatically release disputed funds or refund gateway payments.')),
      ],
    ]))));
  }
}

class _AcceptOffer extends StatefulWidget {
  const _AcceptOffer({required this.ar, required this.offer, required this.methods});
  final bool ar;
  final Map<String, dynamic> offer;
  final List<String> methods;
  @override
  State<_AcceptOffer> createState() => _AcceptOfferState();
}
class _AcceptOfferState extends State<_AcceptOffer> {
  String? method; bool agreed = false;
  @override
  Widget build(BuildContext context) => AlertDialog(title: Text(st(widget.ar, 'مراجعة الاتفاق', 'Review agreement')), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text('${widget.offer['name']} · ${widget.offer['price']} EGP', style: const TextStyle(fontWeight: FontWeight.bold)), serviceText('${widget.offer['scope']}'),
    serviceText(widget.offer['materials_included'] == true ? st(widget.ar, 'الخامات المذكورة مشمولة', 'Stated materials included') : st(widget.ar, 'الخامات غير مشمولة', 'Materials excluded')),
    for (final item in widget.methods) RadioListTile<String>(value: item, groupValue: method, onChanged: (v) => setState(() => method = v), title: Text(paymentLabel(item, widget.ar))),
    if (method == 'wallet') serviceText(st(widget.ar, 'سيتم حجز كامل قيمة الشغل من محفظتك لحين تأكيد الإتمام.', 'The full price will be held from your wallet until completion.')),
    if (method != null && !['cash', 'wallet'].contains(method)) serviceText(st(widget.ar, 'بعد الاتفاق افتح صفحة الدفع وأكمل العملية قبل انتهاء المهلة.', 'After booking, open checkout and pay before the deadline.')),
    serviceText(st(widget.ar, 'بعد الاتفاق، الطرف الذي يلغي يتحمل خدمة التطبيق${widget.offer['cancellation_fee'] == null ? '' : ': ${widget.offer['cancellation_rate']}% = ${widget.offer['cancellation_fee']} ج.م'}. إذا ألغيت أنت، تخصم من محفظتك.', 'After agreement, the cancelling party bears the app fee${widget.offer['cancellation_fee'] == null ? '' : ': ${widget.offer['cancellation_rate']}% = EGP ${widget.offer['cancellation_fee']}'}. If you cancel, it is debited from your wallet.')),
    CheckboxListTile(value: agreed, onChanged: (v) => setState(() => agreed = v == true), title: Text(st(widget.ar, 'راجعت السعر ونطاق الشغل وأوافق على العرض.', 'I reviewed and agree to the price and scope.'))),
  ])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(st(widget.ar, 'رجوع', 'Back'))), FilledButton(onPressed: agreed && method != null ? () => Navigator.pop(context, method) : null, child: Text(st(widget.ar, 'قبول العرض', 'Accept quote')))]);
}
class _ReasonForm extends StatefulWidget {
  const _ReasonForm({required this.ar}); final bool ar;
  @override
  State<_ReasonForm> createState() => _ReasonFormState();
}
class _ReasonFormState extends State<_ReasonForm> {
  final input = TextEditingController();
  @override
  void dispose() { input.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(title: Text(st(widget.ar, 'سبب الإجراء', 'Reason')), content: TextField(controller: input, maxLength: 500, maxLines: 3, decoration: InputDecoration(labelText: st(widget.ar, 'السبب (٣ أحرف على الأقل)', 'Reason (at least 3 characters)'))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(st(widget.ar, 'رجوع', 'Back'))), FilledButton(onPressed: () { if (input.text.trim().length >= 3) Navigator.pop(context, input.text.trim()); }, child: Text(st(widget.ar, 'تأكيد', 'Confirm')))]);
}

/// Native hosted checkout. Navigation does not mutate balances/payment state.
class _HostedCheckout extends StatelessWidget {
  const _HostedCheckout({required this.url, required this.ar}); final String url; final bool ar;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(st(ar, 'الدفع الآمن', 'Secure checkout'))), body: InAppWebView(initialUrlRequest: URLRequest(url: WebUri(url)), initialSettings: InAppWebViewSettings(javaScriptEnabled: true, useShouldOverrideUrlLoading: true), shouldOverrideUrlLoading: (controller, action) async {
    final uri = Uri.tryParse('${action.request.url}');
    return uri != null && ['https', 'about'].contains(uri.scheme) ? NavigationActionPolicy.ALLOW : NavigationActionPolicy.CANCEL;
  }));
}
