import 'dart:async';
import 'package:flutter/material.dart';
import '../go_services/order_checkout_screen.dart';
import '../go_services/service_api.dart';
import '../view/custom_widgets/popups/go_popups.dart';
import 'store_order_api.dart';
import 'store_order_widgets.dart';

class CustomerStoreOrdersScreen extends StatefulWidget {
  const CustomerStoreOrdersScreen({super.key, this.api});
  final StoreOrderApi? api;
  @override
  State<CustomerStoreOrdersScreen> createState() => _CustomerStoreOrdersScreenState();
}
class _CustomerStoreOrdersScreenState extends State<CustomerStoreOrdersScreen> with WidgetsBindingObserver {
  late final StoreOrderApi api = widget.api ?? StoreOrderApi();
  Timer? timer;
  List<Map<String, dynamic>> orders = [];
  bool history = false, busy = false, foreground = true;
  int page = 1, lastPage = 1, generation = 0;
  String? error;
  bool get ar => Localizations.localeOf(context).languageCode == 'ar';
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); load(); timer = Timer.periodic(const Duration(seconds: 8), (_) { if (foreground && !busy && !history) load(); }); }
  @override
  void dispose() { generation++; timer?.cancel(); WidgetsBinding.instance.removeObserver(this); if (widget.api == null) api.close(); super.dispose(); }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { foreground = state == AppLifecycleState.resumed; if (foreground && !busy) load(); }
  Future<void> load({bool more = false}) async {
    final request = ++generation;
    setState(() { busy = true; error = null; });
    try {
      final r = await api.orders(history: history, page: more ? page + 1 : 1);
      if (!mounted || request != generation) return;
      setState(() { if (!more) orders.clear(); orders.addAll((r['orders'] as List).map((e) => Map<String, dynamic>.from(e))); page = r['page'] as int; lastPage = r['last_page'] as int; });
    } catch (e) { if (mounted && request == generation) setState(() => error = '$e'); }
    finally { if (mounted && request == generation) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(padding: const EdgeInsets.all(14), child: SegmentedButton<bool>(segments: [ButtonSegment(value: false, label: Text(ar ? 'الحالية' : 'Active')), ButtonSegment(value: true, label: Text(ar ? 'السابقة' : 'History'))],
      selected: {history}, onSelectionChanged: (v) { setState(() { history = v.first; orders.clear(); }); load(); })),
    if (busy && orders.isEmpty) const LinearProgressIndicator(),
    Expanded(child: RefreshIndicator(onRefresh: load, child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16), children: [
      if (error != null) ...[Text(error!), TextButton(onPressed: () => load(), child: Text(ar ? 'إعادة المحاولة' : 'Retry'))],
      if (!busy && error == null && orders.isEmpty) Padding(padding: const EdgeInsets.all(40), child: Text(ar ? 'لا توجد طلبات متاجر هنا حتى الآن' : 'No store orders here yet', textAlign: TextAlign.center)),
      for (final o in orders) Card(child: ListTile(contentPadding: const EdgeInsets.all(16), leading: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFFD7201)),
        title: Text('${o['store_name']} · ${o['number']}'), subtitle: Text('${storeState(o['status'], ar)}\n${o['total']} ${ar ? 'ج.م' : 'EGP'}'), isThreeLine: true,
        trailing: const Icon(Icons.chevron_right), onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerStoreOrderScreen(orderId: o['id'] as int, initial: o))); if (mounted) load(); })),
      if (page < lastPage) TextButton(onPressed: busy ? null : () => load(more: true), child: Text(ar ? 'عرض المزيد' : 'Load more')),
    ]))),
  ]);
}

class CustomerStoreOrderScreen extends StatefulWidget {
  const CustomerStoreOrderScreen({super.key, required this.orderId, this.initial, this.api});
  final int orderId;
  final Map<String, dynamic>? initial;
  final StoreOrderApi? api;
  @override
  State<CustomerStoreOrderScreen> createState() => _CustomerStoreOrderScreenState();
}
class _CustomerStoreOrderScreenState extends State<CustomerStoreOrderScreen> with WidgetsBindingObserver {
  late final StoreOrderApi api = widget.api ?? StoreOrderApi();
  Map<String, dynamic>? order;
  Timer? timer;
  bool reading = false, busy = false, foreground = true;
  String? error;
  bool get ar => Localizations.localeOf(context).languageCode == 'ar';
  @override
  void initState() { super.initState(); order = widget.initial; WidgetsBinding.instance.addObserver(this); refresh(); timer = Timer.periodic(const Duration(seconds: 5), (_) { if (foreground && !busy) refresh(); }); }
  @override
  void dispose() { timer?.cancel(); WidgetsBinding.instance.removeObserver(this); if (widget.api == null) api.close(); super.dispose(); }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { foreground = state == AppLifecycleState.resumed; if (foreground) refresh(); }
  Future<void> refresh() async {
    if (reading) return;
    reading = true;
    try { final r = await api.order(widget.orderId); if (mounted) setState(() { order = Map<String, dynamic>.from(r['order']); error = null; }); }
    catch (e) { if (mounted) setState(() => error = '$e'); }
    finally { reading = false; }
  }
  Future<void> cancel() async {
    final yes = await showGoDialog<bool>(context: context, builder: (c) => AlertDialog(title: Text(ar ? 'إلغاء الطلب؟' : 'Cancel order?'),
      content: Text(ar ? 'يمكن الإلغاء قبل قبول المتجر. المبالغ المدفوعة أونلاين يُتابع استردادها مع الدعم.' : 'Cancellation is available before store acceptance. Online refunds are followed up with support.'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: Text(ar ? 'رجوع' : 'Back')), FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(ar ? 'إلغاء الطلب' : 'Cancel order'))]));
    if (yes != true || !mounted) return;
    setState(() { busy = true; error = null; });
    try { final r = await api.action(widget.orderId, 'cancel', order!['revision'] as int); if (mounted) setState(() => order = Map<String, dynamic>.from(r['order'])); goWalletChanges.value++; }
    catch (e) { if (mounted) setState(() => error = '$e'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> pay() async {
    setState(() { busy = true; error = null; });
    try {
      final r = await api.checkout(widget.orderId);
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => GoOrderCheckoutScreen(orderId: widget.orderId, url: r['link'] as String, storeOrder: true,
        onPaid: () { goWalletChanges.value++; refresh(); })));
      await refresh();
    } catch (e) { if (mounted) setState(() => error = '$e'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(ar ? 'تفاصيل طلب المتجر' : 'Store order details')),
    body: order == null && error == null ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(onRefresh: refresh,
      child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(20), children: [
        if (order != null) StoreOrderBody(order: order!, ar: ar),
        if (error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        if (order?['can_pay'] == true) Padding(padding: const EdgeInsets.only(top: 20), child: FilledButton.icon(onPressed: busy ? null : pay, icon: const Icon(Icons.payment), label: Text(ar ? 'الدفع الآن' : 'Pay now'))),
        if ((order?['actions'] as List? ?? []).contains('cancel')) TextButton(onPressed: busy ? null : cancel, child: Text(ar ? 'إلغاء الطلب' : 'Cancel order')),
        if (busy) const LinearProgressIndicator(),
      ])));
}
