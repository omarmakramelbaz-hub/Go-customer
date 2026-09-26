import 'package:flutter/material.dart';

import '../../../../helpers/legal/go_customer_legal.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../custom_widgets/go_legal_document.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  static const String routeName = 'TermsAndConditionsScreen';
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) => GoLegalDocumentView(
    document: GoCustomerLegal.terms,
    onSupport: () => NamedNavigatorImpl.push('ContactUsScreen'),
    onRelatedDocument: () => NamedNavigatorImpl.push('PrivacyPolicyScreen'),
  );
}
