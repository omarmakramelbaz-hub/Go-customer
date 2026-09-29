import 'package:flutter/material.dart';
import '../view/custom_widgets/popups/go_popups.dart';
import 'store_order_widgets.dart';
import 'store_cart.dart';

class ProductCartSheet extends StatefulWidget {
  const ProductCartSheet({super.key, required this.product, required this.onAdd});
  final Map<String, dynamic> product;
  final Future<bool> Function(Map<String, dynamic>? option, int quantity) onAdd;
  @override
  State<ProductCartSheet> createState() => _ProductCartSheetState();
}
class _ProductCartSheetState extends State<ProductCartSheet> {
  String selected = '';
  int quantity = 1;
  bool busy = false;
  String? error;
  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final p = widget.product;
    final options = (p['options'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
    final choices = options.where((o) => o['id'] == selected).toList();
    final option = choices.isEmpty ? null : choices.first;
    final price = option?['price'] ?? p['price'];
    return GoSheet(title: '${p['name']}', icon: Icons.shopping_bag_outlined, busy: busy, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(child: StorePhoto(url: p['image_url']?.toString(), size: 210)), const SizedBox(height: 14),
      if ('${p['description'] ?? ''}'.isNotEmpty) Text('${p['description']}'),
      const SizedBox(height: 12),
      RadioListTile<String>(value: '', groupValue: selected, onChanged: busy ? null : (v) => setState(() => selected = v!),
        title: Text('${p['unit'] ?? (ar ? 'العبوة الأساسية' : 'Standard')}'), secondary: Text('${p['price']} ${ar ? 'ج.م' : 'EGP'}')),
      for (final o in options) RadioListTile<String>(value: '${o['id']}', groupValue: selected, onChanged: busy ? null : (v) => setState(() => selected = v!),
        title: Text('${o['label']}'), secondary: Text('${o['price']} ${ar ? 'ج.م' : 'EGP'}')),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(key: const ValueKey('product-quantity-minus'), onPressed: busy || quantity <= 1 ? null : () => setState(() => quantity--), icon: const Icon(Icons.remove_circle_outline)),
        Text('$quantity', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        IconButton(key: const ValueKey('product-quantity-plus'), onPressed: busy || quantity >= 99 ? null : () => setState(() => quantity++), icon: const Icon(Icons.add_circle_outline)),
      ]),
      if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      const SizedBox(height: 12),
      FilledButton.icon(key: const ValueKey('add-product-to-cart'), onPressed: busy ? null : () async {
        setState(() { busy = true; error = null; });
        try { final added = await widget.onAdd(option, quantity); if (added && context.mounted) Navigator.pop(context); }
        catch (_) { if (mounted) setState(() => error = ar ? 'تعذر إضافة المنتج. راجع السلة وحاول مرة أخرى.' : 'Could not add product. Check your cart and retry.'); }
        finally { if (mounted) setState(() => busy = false); }
      }, icon: const Icon(Icons.add_shopping_cart), label: Text('${ar ? 'أضف للسلة' : 'Add to cart'} · ${storeMoney(storeCents(price) * quantity)} ${ar ? 'ج.م' : 'EGP'}')),
    ]));
  }
}
