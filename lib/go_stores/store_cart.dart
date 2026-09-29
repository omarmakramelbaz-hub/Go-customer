import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../helpers/hive/hive_methods.dart';

int storeCents(Object? value) {
  final parts = '${value ?? '0'}'.split('.');
  return int.parse(parts.first) * 100 + int.parse(parts.length == 1 ? '0' : parts[1].padRight(2, '0').substring(0, 2));
}
String storeMoney(int cents) => '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

/// Persisted per account. An uncertain checkout keeps its exact payload/key until recovered.
class GoStoreCart extends ChangeNotifier {
  GoStoreCart({Map<String, dynamic>? saved, this.save}) {
    if (saved != null) {
      try {
        store = saved['store'] == null ? null : Map<String, dynamic>.from(saved['store']);
        lines.addAll((saved['lines'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)));
        pending = saved['pending'] == null ? null : Map<String, dynamic>.from(saved['pending']);
      } catch (_) { store = null; lines.clear(); pending = null; }
    }
  }
  static GoStoreCart? _session;
  static String? _sessionKey;
  static GoStoreCart session() {
    final key = 'goStoreCart:${HiveMethods.isGuestMode() ? 'guest' : HiveMethods.getUserId() ?? 'guest'}';
    if (_session == null || _sessionKey != key) {
      _sessionKey = key;
      final raw = Hive.box('app').get(key);
      Map<String, dynamic>? saved;
      try { if (raw is String) saved = Map<String, dynamic>.from(jsonDecode(raw)); } catch (_) { saved = null; }
      _session = GoStoreCart(saved: saved,
        save: (value) => Hive.box('app').put(key, jsonEncode(value)));
    }
    return _session!;
  }
  final Future<void> Function(Map<String, dynamic>)? save;
  Map<String, dynamic>? store;
  final List<Map<String, dynamic>> lines = [];
  Map<String, dynamic>? pending;
  bool get locked => pending != null;
  int get count => lines.fold(0, (n, e) => n + (e['quantity'] as int));
  int get subtotal => lines.fold(0, (n, e) => n + storeCents(e['unit_price']) * (e['quantity'] as int));
  Map<String, dynamic> toJson() => {'store': store, 'lines': lines, 'pending': pending};
  Future<void> _changed() async { await save?.call(toJson()); notifyListeners(); }
  Future<void> add(Map<String, dynamic> shop, Map<String, dynamic> product, Map<String, dynamic>? option, int quantity, {bool replace = false}) async {
    if (locked) throw StateError('Checkout is pending');
    if (quantity < 1 || quantity > 99) throw ArgumentError('Invalid quantity');
    if (store != null && store!['id'] != shop['id'] && lines.isNotEmpty) {
      if (!replace) throw StateError('Another store');
      lines.clear();
    }
    store = Map.of(shop);
    final index = lines.indexWhere((l) => l['product_id'] == product['id'] && l['option_id'] == option?['id']);
    final oldQty = index < 0 ? 0 : lines[index]['quantity'] as int;
    final line = {'product_id': product['id'], 'option_id': option?['id'], 'name': product['name'], 'unit': product['unit'],
      'option_label': option?['label'], 'image_url': product['image_url'], 'unit_price': option?['price'] ?? product['price'], 'quantity': (oldQty + quantity).clamp(1, 99)};
    if (index < 0) { if (lines.length >= 50) throw StateError('Cart limit'); lines.add(line); } else { lines[index] = line; }
    await _changed();
  }
  Future<void> quantity(int index, int quantity) async {
    if (locked) return;
    if (quantity <= 0) { lines.removeAt(index); } else { lines[index]['quantity'] = quantity.clamp(1, 99); }
    if (lines.isEmpty) store = null;
    await _changed();
  }
  Map<String, dynamic> payload({required String fulfillment, int? addressId, String notes = ''}) => {
    'store_id': store!['id'], 'fulfillment': fulfillment, if (fulfillment == 'delivery') 'address_id': addressId, 'notes': notes.trim(),
    'items': lines.map((l) => {'product_id': l['product_id'], 'option_id': l['option_id'], 'quantity': l['quantity']}).toList(),
  };
  Future<Map<String, dynamic>> beginSubmit(Map<String, dynamic> payload, String quote, String method) async {
    pending ??= {...payload, 'quote_token': quote, 'payment_method': method, 'request_key': const Uuid().v4()};
    await _changed();
    return Map<String, dynamic>.from(pending!);
  }
  Future<void> rejected() async { pending = null; await _changed(); }
  Future<void> clear({bool completed = false}) async {
    if (locked && !completed) return;
    lines.clear(); store = null; pending = null; await _changed();
  }
}
