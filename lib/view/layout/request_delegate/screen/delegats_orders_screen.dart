import 'package:flutter/material.dart';
import '../../../../go_services/customer_services.dart';
import '../../../../go_services/service_widgets.dart';
import '../../../../helpers/translation/all_translation.dart';
import 'legacy_delegats_orders_screen.dart' as legacy;

/// Keep the existing Orders route and delivery history; marketplace bookings
/// are also reachable after app restart, independently of any service category.
class DelegateOrdersScreen extends StatelessWidget {
  const DelegateOrdersScreen({super.key});
  static const routeName = 'DelegateOrdersScreen';
  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    return Scaffold(body: ServiceGate(partner: false, ar: ar,
      fallback: (_) => const legacy.DelegateOrdersScreen(),
      builder: (api, caps) => DefaultTabController(length: 2, child: Scaffold(
        appBar: AppBar(title: Text(st(ar, 'طلباتي', 'My orders')), bottom: TabBar(tabs: [Tab(text: st(ar, 'الصنايعية والخدمات', 'Professionals')), Tab(text: st(ar, 'التوصيل', 'Delivery'))])),
        body: TabBarView(children: [CustomerServiceHub(api: api, capabilities: caps, ar: ar, title: st(ar, 'شغلاناتي', 'My jobs')), const legacy.DelegateOrdersScreen()]),
      ))));
  }
}
