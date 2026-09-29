import 'dart:async';
import 'package:flutter/material.dart';
import '../helpers/networking/api_helper.dart';
import '../helpers/networking/urls.dart';
import '../helpers/translation/all_translation.dart';
import 'hosted_checkout.dart';

class GoOrderCheckoutScreen extends StatefulWidget {
  const GoOrderCheckoutScreen({super.key, required this.orderId, required this.url, required this.onPaid, this.storeOrder = false});
  final int orderId;
  final bool storeOrder;
  final String url;
  final VoidCallback onPaid;
  @override
  State<GoOrderCheckoutScreen> createState() => _GoOrderCheckoutScreenState();
}

class _GoOrderCheckoutScreenState extends State<GoOrderCheckoutScreen> {
  Timer? timer;
  bool checking = false;
  bool opening = false;
  bool done = false;
  String? error;
  String? status;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => refresh());
    refresh();
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  Future<void> refresh() async {
    if (checking || done) return;
    checking = true;
    try {
      final response = await ApiHelper.instance.get(widget.storeOrder ? '${Urls.baseUrl}go-stores/orders/${widget.orderId}' : '${Urls.baseUrl}go-orders/${widget.orderId}/payment-status');
      if (!mounted) return;
      if (response.state != ResponseState.complete) {
        setState(() => error = response.data['message']?.toString());
        return;
      }
      setState(() { status = (widget.storeOrder ? response.data['data']['order']['payment_status'] : response.data['data']['status'])?.toString(); error = null; });
      if (status == 'paid' && !opening) {
        done = true; timer?.cancel();
        Navigator.of(context).pop();
        widget.onPaid();
      }
    } finally { checking = false; }
  }
  Future<void> pay() async {
    setState(() { opening = true; error = null; });
    try { await openGoCheckout(context, widget.url, ar: context.languageCode == 'ar'); }
    catch (e) { if (mounted) setState(() => error = '$e'); }
    finally { if (mounted) { setState(() => opening = false); await refresh(); } }
  }
  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    final closed = ['cancelled', 'review', 'refund_pending', 'refunded'].contains(status);
    return Scaffold(appBar: AppBar(title: Text(ar ? 'دفع قيمة الطلب' : 'Order payment')),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.lock_outline, size: 48), const SizedBox(height: 24),
          Text(ar ? 'طلب رقم ${widget.orderId}' : 'Order ${widget.orderId}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(closed ? (ar ? 'الدفع مغلق أو تحت المراجعة. راجع تفاصيل الطلب.' : 'Payment is closed or under review. Check the order details.')
            : (ar ? 'أكمل الدفع من خلال Paymob. سيتم تأكيد الطلب بعد التحقق من وصول المبلغ.' : 'Complete payment through Paymob. Your order is confirmed after the payment is verified.')),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: opening || closed ? null : pay, icon: const Icon(Icons.payment),
            label: Text(ar ? 'فتح صفحة الدفع' : 'Open checkout')),
          TextButton(onPressed: refresh, child: Text(ar ? 'تحديث حالة الدفع' : 'Refresh payment status')),
          if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ]))),
    );
  }
}
