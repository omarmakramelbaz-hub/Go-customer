import 'package:flutter/material.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/utils/date_methods.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../orders/screen/tracking_your_order_screen.dart';
import '../../request_delegate/screen/request_delegate_screen.dart';
import '../../wallet/screen/wallet_screen.dart';
import '../model/notifications_model.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationsModel notification;
  final int? orderId;
  const NotificationWidget({super.key, required this.notification, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final type = notification.data?.data?.notificationType;
    final logo = (notification.data?.logo ?? '').trim();
    final icon = type == 1 ? Icons.receipt_long_outlined : type == 2 ? Icons.local_offer_outlined
      : type == 3 ? Icons.account_balance_wallet_outlined : Icons.notifications_none_rounded;
    return Material(color: GoDesign.paper, child: InkWell(
      onTap: () => _handleTap(type),
      borderRadius: BorderRadius.circular(GoDesign.radius),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 42, height: 42, padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(color: GoDesign.orangeTint, shape: BoxShape.circle),
            child: type == 1 && logo.isNotEmpty
              ? ClipOval(child: CustomNetworkImage(imageUrl: logo, width: 32, height: 32, radius: 0, fit: BoxFit.cover))
              : Container(decoration: const BoxDecoration(color: GoDesign.orange, shape: BoxShape.circle),
                  child: Icon(icon, size: 18, color: Colors.white))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(notification.data?.title ?? '',
              style: const TextStyle(color: GoDesign.ink, fontSize: 15, fontWeight: FontWeight.w700, height: 1.35)),
            const SizedBox(height: 5),
            Text(notification.data?.text ?? '',
              style: const TextStyle(color: GoDesign.muted, fontSize: 13, height: 1.5)),
            const SizedBox(height: 6),
            Text(DateMethods.timeAgo(notification.createdAt ?? '', context),
              style: const TextStyle(color: GoDesign.muted, fontSize: 11)),
          ])),
        ]),
      ),
    ));
  }

  void _handleTap(int? type) {
    if (type == 3) {
      NamedNavigatorImpl.push(WalletScreen.routeName);
      return;
    }
    if (type != 1) return;
    if (notification.data?.data?.orderType == 'shipping') {
      NamedNavigatorImpl.push(RequestDelegateScreen.routeName);
      return;
    }
    if ((orderId ?? 0) > 0) {
      NamedNavigatorImpl.push(TrackingYourOrderScreen.routeName,
        arguments: TrackingYourOrderArgs(id: orderId!));
    }
  }
}
