import 'package:flutter/material.dart';

import '../../../../helpers/legal/go_customer_legal.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../custom_widgets/go_legal_document.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const String routeName = 'PrivacyPolicyScreen';
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) => GoLegalDocumentView(
    document: GoCustomerLegal.privacy,
    onSupport: () => NamedNavigatorImpl.push('ContactUsScreen'),
    onRelatedDocument: () => NamedNavigatorImpl.push('TermsAndConditionsScreen'),
  );
}
