import 'package:flutter/material.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/date_methods.dart';
import '../model/request_delegate_order_model.dart';
import '../screen/tracking_delegate_order_screen.dart';

class DelegateOrderWidget extends StatelessWidget {
  const DelegateOrderWidget({super.key, required this.requestDelegateOrderModel});
  final RequestDelegateOrderModel requestDelegateOrderModel;

  @override
  Widget build(BuildContext context) {
    final order = requestDelegateOrderModel;
    final ended = const ['completed', 'cancelled', 'declined'].contains(order.status);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Material(color: GoDesign.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GoDesign.cardRadius),
          side: const BorderSide(color: GoDesign.border)),
        child: InkWell(borderRadius: BorderRadius.circular(GoDesign.cardRadius),
          onTap: order.id == null ? null : () => NamedNavigatorImpl.push(TrackingDelegateOrderScreen.routeName,
            arguments: TrackingDelegateOrderArgs(id: order.id!)),
          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              const Icon(Icons.receipt_long_outlined, color: GoDesign.orange, size: 23),
              const SizedBox(width: 10),
              Expanded(child: Text('${order.orderNo ?? order.id ?? ''}',
                style: const TextStyle(color: GoDesign.ink, fontSize: 16, fontWeight: FontWeight.w700))),
              Flexible(child: buildOrderStatusContainer(context: context, orderStatus: order.status ?? '')),
            ]),
            const SizedBox(height: 10),
            Text(DateMethods.formatOrderDate(order.createdAt ?? ''),
              style: const TextStyle(color: GoDesign.muted, fontSize: 12)),
            const SizedBox(height: 12),
            Text(order.description ?? '', style: const TextStyle(color: GoDesign.ink, fontSize: 15, height: 1.5)),
            const Divider(height: 26, color: GoDesign.border),
            Wrap(alignment: WrapAlignment.spaceBetween, spacing: 14, runSpacing: 10, children: [
              Text(order.actualPrice == null ? '—' : 'pound'.tr.replaceAll('{}', '${order.actualPrice}'),
                style: const TextStyle(color: GoDesign.orange, fontSize: 16, fontWeight: FontWeight.w700)),
              if (!ended) Text('trackingYourOrder'.tr,
                style: const TextStyle(color: GoDesign.orange, fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ])),
        ),
      ),
    );
  }

  Widget buildOrderStatusContainer({required String orderStatus, required BuildContext context}) {
    final key = switch (orderStatus) {
      'accepted' => 'orderAccepted', 'pending' => 'pending', 'shipped' => 'orderReceived',
      'completed' => 'orderDelivered', 'cancelled' || 'declined' => 'canceled', _ => '',
    };
    final color = switch (orderStatus) {
      'completed' || 'shipped' => GoDesign.success,
      'cancelled' || 'declined' => GoDesign.danger, _ => GoDesign.orange,
    };
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(8)),
      child: Text(key.isEmpty ? orderStatus : key.tr,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)));
  }
}
