import 'package:flutter/material.dart';
import '../../../../go_services/customer_services.dart';
import '../../../../go_services/service_widgets.dart';
import '../../../../helpers/translation/all_translation.dart';
import 'legacy_profession_partners_screen.dart' as legacy;

/// Preserve the existing home-card route and retain the old flow until the
/// backend schema exists. No backend switch or payment setting is modified.
class ProfessionPartnersScreen extends StatelessWidget {
  const ProfessionPartnersScreen({super.key, required this.professionKey, required this.title});
  final String professionKey;
  final String title;
  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    return Scaffold(body: ServiceGate(partner: false, ar: ar,
      fallback: (_) => legacy.ProfessionPartnersScreen(professionKey: professionKey, title: title),
      builder: (api, caps) => CustomerServiceHub(api: api, capabilities: caps, ar: ar, professionKey: professionKey, title: title,
        legacyBuilder: (_) => legacy.ProfessionPartnersScreen(professionKey: professionKey, title: title))));
  }
}
