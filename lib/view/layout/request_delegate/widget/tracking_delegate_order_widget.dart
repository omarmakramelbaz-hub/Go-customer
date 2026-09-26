import 'package:flutter/material.dart';

import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/utils/date_methods.dart';

class TrackingDelegateOrderWidget extends StatelessWidget {
  final String status;
  final String? orderDate;
  const TrackingDelegateOrderWidget({super.key, required this.status, this.orderDate});

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    if (status == 'cancelled') {
      return _stateCard(ar ? 'تم إلغاء الطلب' : 'Order cancelled', Icons.cancel_outlined, GoDesign.danger);
    }
    const states = {'pending': 1, 'accepted': 2, 'shipped': 3, 'completed': 4};
    final stage = states[status];
    if (stage == null) {
      return _stateCard(status.isEmpty ? (ar ? 'بانتظار تحديث الحالة' : 'Awaiting status update') : status,
        Icons.info_outline, GoDesign.muted);
    }
    final labels = ar
      ? ['تم تسجيل الطلب', 'البحث عن مندوب', 'تم الاتفاق — المندوب في الطريق', 'تم استلام الطلب من المرسل', 'تم التوصيل']
      : ['Request received', 'Finding a driver', 'Driver confirmed and on the way', 'Order picked up', 'Delivered'];
    return Column(children: List.generate(labels.length, (i) {
      final done = i <= stage;
      final current = i == stage && status != 'completed';
      final color = done ? GoDesign.success : const Color(0xFFCCD3D9);
      return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 28, child: Column(children: [
          Container(width: 24, height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(done ? Icons.check : Icons.circle, size: done ? 15 : 7, color: Colors.white)),
          if (i < labels.length - 1) Expanded(child: Container(width: 2,
            color: i < stage ? GoDesign.success : GoDesign.border)),
        ])),
        const SizedBox(width: 14),
        Expanded(child: Padding(padding: EdgeInsets.only(top: 2, bottom: i == labels.length - 1 ? 0 : 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(labels[i], style: TextStyle(color: done ? GoDesign.ink : GoDesign.muted,
              fontSize: 15, fontWeight: done ? FontWeight.w700 : FontWeight.w500, height: 1.4)),
            if (i == 0 && orderDate != null && orderDate!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(DateMethods.formatToDate(orderDate!), style: const TextStyle(color: GoDesign.muted, fontSize: 12)),
            ],
            if (current) ...[
              const SizedBox(height: 6),
              Text(ar ? 'الحالة الحالية' : 'Current status',
                style: const TextStyle(color: GoDesign.orange, fontSize: 12)),
            ],
          ]))),
      ]));
    }));
  }

  Widget _stateCard(String text, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(GoDesign.radius)),
    child: Row(children: [Icon(icon, color: color), const SizedBox(width: 10),
      Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700)))]));
}
