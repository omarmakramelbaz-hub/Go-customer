import 'package:flutter/material.dart';
import '../../../../go_services/customer_services.dart';
import '../../../../go_services/service_widgets.dart';
import '../../../../go_stores/store_orders_screen.dart';
import '../../../../helpers/translation/all_translation.dart';
import 'legacy_delegats_orders_screen.dart' as legacy;

class DelegateOrdersScreen extends StatelessWidget {
  const DelegateOrdersScreen({super.key});
  static const routeName = 'DelegateOrdersScreen';
  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    return DefaultTabController(length: 3, child: Scaffold(
      appBar: AppBar(title: Text(ar ? 'طلباتي' : 'My orders'), bottom: TabBar(tabs: [
        Tab(text: ar ? 'المتاجر' : 'Stores'), Tab(text: ar ? 'الخدمات' : 'Services'), Tab(text: ar ? 'التوصيل' : 'Delivery'),
      ])),
      body: TabBarView(children: [const CustomerStoreOrdersScreen(),
        ServiceGate(partner: false, ar: ar, fallback: (_) => const legacy.DelegateOrdersScreen(),
          builder: (api, caps) => CustomerServiceHub(api: api, capabilities: caps, ar: ar, title: ar ? 'شغلاناتي' : 'My jobs')),
        const legacy.DelegateOrdersScreen(),
      ]),
    ));
  }
}
