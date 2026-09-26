import 'package:flutter/material.dart';

import '../../helpers/legal/go_customer_legal.dart';
import '../../helpers/theme/go_design_tokens.dart';
import 'custom_app_bar/custom_app_bar.dart';
import 'go_drive_brand.dart';

/// No settings/API/provider dependency: a restaurant policy can never replace
/// these documents, and reading them does not require signing in.
class GoLegalDocumentView extends StatelessWidget {
  const GoLegalDocumentView({super.key, required this.document,
    required this.onSupport, required this.onRelatedDocument});

  final GoLegalDocument document;
  final VoidCallback onSupport;
  final VoidCallback onRelatedDocument;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final other = document.id == GoCustomerLegal.privacy.id
        ? GoCustomerLegal.terms : GoCustomerLegal.privacy;
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: ValueKey('go-legal-${document.id}'),
        backgroundColor: GoDesign.paper,
        appBar: CustomAppBar(title: Text(document.title(ar))),
        body: SafeArea(top: false, child: SingleChildScrollView(
          key: ValueKey('go-legal-scroll-${document.id}'),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Align(alignment: Alignment.topCenter, child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const GoDriveBrand(size: 26),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Go Customer', textDirection: TextDirection.ltr,
                    style: TextStyle(color: GoDesign.ink, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(ar ? 'آخر تحديث: 26 سبتمبر 2026' : 'Last updated: 26 September 2026',
                    style: const TextStyle(color: GoDesign.muted, fontSize: 12, height: 1.5)),
                ])),
              ]),
              const SizedBox(height: 22),
              Container(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: GoDesign.orangeTint,
                  borderRadius: BorderRadius.circular(GoDesign.radius)),
                child: Text(document.summary(ar),
                  style: const TextStyle(color: GoDesign.ink, fontSize: 15, height: 1.7))),
              const SizedBox(height: 26),
              SelectionArea(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                children: document.sections.map((section) => Padding(
                  key: ValueKey('go-legal-${document.id}-${section.id}'),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Semantics(header: true, child: Text(section.title(ar),
                      style: const TextStyle(color: GoDesign.ink, fontSize: 18,
                        fontWeight: FontWeight.w800, height: 1.5))),
                    const SizedBox(height: 10),
                    ...section.body(ar).split('\n\n').map((paragraph) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(paragraph,
                        style: const TextStyle(color: GoDesign.ink, fontSize: 16, height: 1.7)))),
                    const Divider(height: 16, color: GoDesign.border),
                  ]),
                )).toList())),
              Text(ar ? 'لديك سؤال أو طلب متعلق بهذه البنود؟' : 'Have a question or request about this document?',
                style: const TextStyle(color: GoDesign.muted, fontSize: 14, height: 1.6)),
              const SizedBox(height: 12),
              FilledButton(
                key: const ValueKey('go-legal-support'),
                onPressed: onSupport,
                style: FilledButton.styleFrom(backgroundColor: GoDesign.orange,
                  foregroundColor: GoDesign.paper,
                  minimumSize: const Size(48, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GoDesign.radius))),
                child: Text(ar ? 'المساعدة والدعم' : 'Help and support',
                  textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              TextButton(key: const ValueKey('go-legal-related'),
                onPressed: onRelatedDocument, child: Text(other.title(ar), textAlign: TextAlign.center)),
              const SizedBox(height: 12),
              Text(GoCustomerLegal.revision, textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: GoDesign.muted, fontSize: 10, height: 1.5)),
            ]),
          )),
        )),
      ),
    );
  }
}
