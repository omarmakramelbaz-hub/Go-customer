import 'package:flutter/material.dart';
import '../../../../go_services/customer_services.dart';
import '../../../../go_services/service_widgets.dart';
import '../../../../helpers/translation/all_translation.dart';

/// New professional requests always use quotations. Existing requests remain
/// accessible through Orders while the marketplace is unavailable.
class ProfessionPartnersScreen extends StatelessWidget {
  const ProfessionPartnersScreen({super.key, required this.professionKey, required this.title});
  final String professionKey;
  final String title;
  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    return Scaffold(body: ServiceGate(
      partner: false,
      ar: ar,
      title: title,
      builder: (api, caps) => CustomerServiceHub(
        api: api,
        capabilities: caps,
        ar: ar,
        professionKey: professionKey,
        title: title,
      ),
    ));
  }
}
