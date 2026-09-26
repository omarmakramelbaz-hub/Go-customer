import 'package:flutter/material.dart';

import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/go_master_ui.dart';
import '../../home/widgets/go_customer_home_view.dart';

/// Presentation adapter: no fabricated price, review count or availability.
class GoPartnerDetailScreen extends StatelessWidget {
  const GoPartnerDetailScreen({super.key, required this.partner, required this.professionKey,
    required this.title, required this.isArabic, required this.onRequest});
  final Map<String, dynamic> partner;
  final String professionKey;
  final String title;
  final bool isArabic;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final photo = partner['photo']?.toString() ?? '';
    final name = partner['name']?.toString() ?? (isArabic ? 'مقدم خدمة' : 'Service provider');
    final distance = partner['distance_km'];
    final radius = partner['work_radius_km'];
    final matches = goServices.where((service) => service.key == professionKey);
    final service = matches.isEmpty ? null : matches.first;
    Widget fallback() => service == null ? const Icon(Icons.handyman_outlined, size: 72, color: GoDesign.orange)
      : GoServicePhoto(index: service.imageIndex);
    return Directionality(textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(backgroundColor: GoDesign.paper,
        appBar: CustomAppBar(title: Text(isArabic ? 'تفاصيل الخدمة' : 'Service details')),
        body: SafeArea(top: false, child: ListView(padding: EdgeInsets.zero, children: [
          AspectRatio(aspectRatio: 1.5, child: ColoredBox(color: GoDesign.canvas,
            child: photo.isEmpty ? fallback() : Image.network(photo, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback()))),
          Padding(padding: const EdgeInsets.all(20), child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: GoDesign.ink)),
              const SizedBox(height: 8),
              Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: GoDesign.ink)),
              const SizedBox(height: 12),
              if (distance != null) Text(isArabic ? 'على بُعد $distance كم منك' : '$distance km away',
                style: const TextStyle(color: GoDesign.muted, fontSize: 14)),
              if (radius != null) ...[
                const SizedBox(height: 6),
                Text(isArabic ? 'نطاق العمل: $radius كم' : 'Service radius: $radius km',
                  style: const TextStyle(color: GoDesign.muted, fontSize: 14)),
              ],
              const SizedBox(height: 22),
              GoSurface(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.request_quote_outlined, color: GoDesign.orange, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(isArabic ? 'السعر بعد عرض مقدم الخدمة' : 'Price by provider quotation',
                    style: const TextStyle(color: GoDesign.ink, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(isArabic ? 'اشرح المطلوب وأرفق الصور. يعرض مقدم الخدمة السعر لتراجعه وتوافق عليه قبل تنفيذ الخدمة.'
                    : 'Describe the work and attach photos. Review and accept the provider’s quotation before the service.',
                    style: const TextStyle(color: GoDesign.muted, height: 1.6, fontSize: 14)),
                ])),
              ])),
              const SizedBox(height: 20),
              Row(children: [
                const Icon(Icons.location_on_outlined, color: GoDesign.orange),
                const SizedBox(width: 8),
                Expanded(child: Text(isArabic ? 'الخدمة في موقعك المحدد' : 'Service at your selected location',
                  style: const TextStyle(color: GoDesign.ink, fontSize: 14))),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                const Icon(Icons.description_outlined, color: GoDesign.orange),
                const SizedBox(width: 8),
                Expanded(child: Text(isArabic ? 'تفاصيل الطلب والصور في الخطوة التالية' : 'Add request details and photos in the next step',
                  style: const TextStyle(color: GoDesign.ink, fontSize: 14))),
              ]),
            ],
          )),
        ])),
        bottomNavigationBar: SafeArea(top: false, child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: CustomButton(text: isArabic ? 'اطلب الآن' : 'Request service', onPressed: onRequest))),
      ),
    );
  }
}
