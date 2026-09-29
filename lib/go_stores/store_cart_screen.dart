import 'package:flutter/material.dart';
import '../go_services/service_api.dart';
import '../helpers/hive/hive_methods.dart';
import '../view/custom_widgets/popups/go_popups.dart';
import '../view/layout/address/model/address_model.dart';
import '../view/layout/address/screen/address_screen.dart';
import 'store_cart.dart';
import 'store_order_api.dart';
import 'store_order_widgets.dart';
import 'store_orders_screen.dart';

class StoreCartScreen extends StatefulWidget {
  const StoreCartScreen({super.key, this.cart, this.api, this.selectAddress, this.onOrder});
  final GoStoreCart? cart;
  final StoreOrderApi? api;
  final Future<AddressModel?> Function(BuildContext)? selectAddress;
  final ValueChanged<Map<String, dynamic>>? onOrder;
  @override
  State<StoreCartScreen> createState() => _StoreCartScreenState();
}

class _StoreCartScreenState extends State<StoreCartScreen> {
  late final GoStoreCart cart = widget.cart ?? GoStoreCart.session();
  late final StoreOrderApi api = widget.api ?? StoreOrderApi();
  final notes = TextEditingController();
  AddressModel? address;
  String fulfillment = 'delivery', method = 'cash';
  Map<String, dynamic>? quote;
  bool busy = false;
  String? error;
  bool get ar => Localizations.localeOf(context).languageCode == 'ar';
  @override
  void initState() {
    super.initState();
    if (widget.cart == null) {
      final user = HiveMethods.getUserId();
      final saved = user == null ? null : HiveMethods.getDeliveryAddress(user);
      if (saved != null) address = AddressModel.fromJson(saved);
    }
    cart.addListener(changed);
  }
  void changed() { if (mounted) setState(() {}); }
  @override
  void dispose() { cart.removeListener(changed); notes.dispose(); if (widget.api == null) api.close(); super.dispose(); }
  void invalidate() => setState(() { quote = null; error = null; });
  Future<void> selectAddress() async {
    final chosen = widget.selectAddress != null ? await widget.selectAddress!(context) : await Navigator.push<AddressModel>(context,
      MaterialPageRoute(builder: (_) => const AddressScreen(selectForDelivery: true)));
    if (!mounted || chosen == null) return;
    if (widget.cart == null) {
      final user = HiveMethods.getUserId();
      if (user != null) await HiveMethods.saveDeliveryAddress(user, chosen.toJson());
    }
    if (!mounted) return;
    setState(() { address = chosen; quote = null; error = null; });
  }
  Map<String, dynamic> payload() => cart.payload(fulfillment: fulfillment, addressId: address?.id, notes: notes.text);
  Future<void> review() async {
    if (fulfillment == 'delivery' && address?.id == null) { setState(() => error = ar ? 'اختَر عنوان التوصيل أولًا' : 'Choose a delivery address first'); return; }
    setState(() { busy = true; error = null; });
    try {
      final result = await api.quote(payload());
      if (!mounted) return;
      setState(() { quote = result; if (!(result['payment_methods'] as List? ?? []).contains(method)) method = 'cash'; });
    } catch (e) { if (mounted) setState(() => error = '$e'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> submit() async {
    if (busy || (!cart.locked && quote == null)) return;
    setState(() { busy = true; error = null; });
    try {
      final body = cart.pending ?? await cart.beginSubmit(payload(), quote!['quote_token'] as String, method);
      final response = await api.submit(body);
      final order = Map<String, dynamic>.from(response['order']);
      await cart.clear(completed: true);
      goWalletChanges.value++;
      if (!mounted) return;
      if (widget.onOrder != null) { widget.onOrder!(order); }
      else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => CustomerStoreOrderScreen(orderId: order['id'] as int, initial: order)));
      }
    } on ServiceFailure catch (e) {
      // A definitive validation rejection can be edited. A lost/5xx response
      // must keep the original idempotency key and exact cart for recovery.
      if ([400, 401, 403, 404, 409, 422].contains(e.status)) { await cart.rejected(); quote = null; }
      if (mounted) setState(() => error = e.message);
    } catch (e) { if (mounted) setState(() => error = '$e'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> clear() async {
    final yes = await showGoDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: Text(ar ? 'حذف السلة؟' : 'Clear cart?'), content: Text(ar ? 'سيتم حذف المنتجات الموجودة بالسلة.' : 'All products will be removed.'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: Text(ar ? 'رجوع' : 'Back')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(ar ? 'حذف' : 'Clear'))]));
    if (yes == true) { await cart.clear(); if (mounted) invalidate(); }
  }
  @override
  Widget build(BuildContext context) {
    final disabled = busy || cart.locked;
    final methods = (quote?['payment_methods'] as List? ?? ['cash', 'wallet', 'mobile_wallet', 'card']).cast<String>();
    return Scaffold(backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: Text(ar ? 'سلة المنتجات' : 'Shopping cart'), actions: [if (cart.lines.isNotEmpty)
        IconButton(onPressed: disabled ? null : clear, tooltip: ar ? 'حذف السلة' : 'Clear cart', icon: const Icon(Icons.delete_outline))]),
      body: cart.lines.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.shopping_cart_outlined, size: 70, color: Color(0xFFFD7201)),
        const SizedBox(height: 20), Text(ar ? 'سلتك فاضية' : 'Your cart is empty'), TextButton(onPressed: () => Navigator.maybePop(context), child: Text(ar ? 'تصفح المنتجات' : 'Browse products'))]))
        : ListView(padding: const EdgeInsets.fromLTRB(18, 16, 18, 24), children: [
          Card(child: ListTile(leading: const Icon(Icons.storefront, color: Color(0xFFFD7201)),
            title: Text(ar ? 'طلبك من' : 'Your order from'), subtitle: Text('${cart.store?['name']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            trailing: TextButton(onPressed: disabled ? null : () => Navigator.maybePop(context), child: Text(ar ? 'أضف المزيد' : 'Add more')))),
          const SizedBox(height: 12),
          for (var i = 0; i < cart.lines.length; i++) item(i, disabled),
          const SizedBox(height: 18),
          Text(ar ? 'استلام الطلب' : 'Fulfillment', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SegmentedButton<String>(segments: [ButtonSegment(value: 'delivery', label: Text(ar ? 'توصيل' : 'Delivery'), icon: const Icon(Icons.delivery_dining)),
            ButtonSegment(value: 'pickup', label: Text(ar ? 'من المتجر' : 'Pickup'), icon: const Icon(Icons.storefront))], selected: {fulfillment},
            onSelectionChanged: disabled ? null : (v) { fulfillment = v.first; invalidate(); }),
          const SizedBox(height: 12),
          if (fulfillment == 'delivery') Card(child: ListTile(onTap: disabled ? null : selectAddress, leading: const Icon(Icons.location_on_outlined),
            title: Text(address?.address ?? address?.streetName ?? (ar ? 'اختَر عنوان التوصيل' : 'Choose delivery address')),
            trailing: const Icon(Icons.chevron_right)))
          else Text('${cart.store?['address'] ?? ''}'),
          const SizedBox(height: 14),
          TextField(controller: notes, enabled: !disabled, maxLength: 1000, maxLines: 2, onChanged: (_) => invalidate(),
            decoration: InputDecoration(labelText: ar ? 'ملاحظات للمتجر (اختياري)' : 'Notes for the store (optional)', border: const OutlineInputBorder())),
          const SizedBox(height: 14),
          if (!cart.locked) ...[
            Text(ar ? 'طريقة الدفع' : 'Payment method', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            for (final value in methods) RadioListTile<String>(value: value, groupValue: method,
              onChanged: busy ? null : (v) => setState(() => method = v!), title: Text(storePayment(value, ar))),
          ],
          Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
            StoreTotalRow(ar ? 'المنتجات' : 'Products', quote?['subtotal'] ?? storeMoney(cart.subtotal), ar: ar),
            if (quote != null) ...[StoreTotalRow(ar ? 'التوصيل' : 'Delivery', quote!['delivery'], ar: ar), const Divider(),
              StoreTotalRow(ar ? 'الإجمالي' : 'Total', quote!['total'], ar: ar, strong: true)]
            else Text(ar ? 'راجع الإجمالي لحساب رسوم التوصيل وتأكيد الأسعار.' : 'Review the total to confirm prices and delivery fees.'),
          ]))),
          if (cart.locked) Padding(padding: const EdgeInsets.all(12), child: Text(ar ? 'جارٍ متابعة تأكيد طلبك. أعد المحاولة لاسترجاع نفس الطلب بدون تكراره.' : 'Your submission is being recovered. Retry safely to retrieve the same order.')),
          if (error != null) Padding(padding: const EdgeInsets.all(12), child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        ]),
      bottomNavigationBar: cart.lines.isEmpty ? null : SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: FilledButton.icon(
        key: const ValueKey('store-checkout-submit'), onPressed: busy ? null : (cart.locked || quote != null ? submit : review),
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFD7201), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(54)),
        icon: busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.shopping_bag_outlined),
        label: Text(cart.locked ? (ar ? 'استكمال تأكيد الطلب' : 'Recover order') : quote == null ? (ar ? 'مراجعة الإجمالي' : 'Review total') : (ar ? 'تنفيذ الطلب · ${quote!['total']} ج.م' : 'Place order · ${quote!['total']} EGP')),
      ))),
    );
  }
  Widget item(int i, bool disabled) {
    final line = cart.lines[i];
    final quoted = (quote?['items'] as List?)?.where((e) => e['product_id'] == line['product_id'] && e['option_id'] == line['option_id']).firstOrNull;
    final price = quoted?['unit_price'] ?? line['unit_price'];
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Row(children: [StorePhoto(url: line['image_url']?.toString()), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('${line['name']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), Text('${line['option_label'] ?? line['unit'] ?? ''}'), Text('$price ${ar ? 'ج.م' : 'EGP'}')]))]),
      Row(children: [IconButton(tooltip: ar ? 'حذف المنتج' : 'Remove product', onPressed: disabled ? null : () async { await cart.quantity(i, 0); if (mounted) invalidate(); }, icon: const Icon(Icons.delete_outline)),
        const Spacer(), IconButton(key: ValueKey('cart-minus-$i'), onPressed: disabled ? null : () async { await cart.quantity(i, (line['quantity'] as int) - 1); if (mounted) invalidate(); }, icon: const Icon(Icons.remove_circle_outline)),
        Text('${line['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(key: ValueKey('cart-plus-$i'), onPressed: disabled || line['quantity'] == 99 ? null : () async { await cart.quantity(i, (line['quantity'] as int) + 1); if (mounted) invalidate(); }, icon: const Icon(Icons.add_circle_outline))]),
    ])));
  }
}

class StoreCartButton extends StatelessWidget {
  const StoreCartButton({super.key, this.floating = false});
  final bool floating;
  @override
  Widget build(BuildContext context) {
    final cart = GoStoreCart.session();
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return ListenableBuilder(listenable: cart, builder: (context, _) {
      void open() => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreCartScreen()));
      if (floating) return cart.count == 0 ? const SizedBox.shrink() : FloatingActionButton.extended(onPressed: open,
        backgroundColor: const Color(0xFFFD7201), foregroundColor: Colors.white, icon: const Icon(Icons.shopping_cart_outlined), label: Text('${ar ? 'السلة' : 'Cart'} · ${cart.count}'));
      return IconButton(tooltip: ar ? 'السلة' : 'Cart', onPressed: open, icon: Badge(isLabelVisible: cart.count > 0, label: Text('${cart.count}'), child: const Icon(Icons.shopping_cart_outlined)));
    });
  }
}
