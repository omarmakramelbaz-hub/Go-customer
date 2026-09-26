import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../controller/notifications_controller.dart';
import '../model/notifications_model.dart';
import '../widget/notification_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late PusherController _pusherController;
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _pusherController = context.read<PusherController>();
    _pusherController.addEventListener('notification.updated', _handleVendorNotificationUpdated);
  }
  void _handleVendorNotificationUpdated(PusherEvent event) {
    try {
      final jsonData = jsonDecode(event.data) as Map<String, dynamic>;
      if (!mounted) return;
      context.read<NotificationsController>().addNotificationToTop(NotificationsModel.fromJson(jsonData));
    } catch (e, stackTrace) {
      log('Error handling Pusher event: $e');
      log('Stack trace: $stackTrace');
    }
  }
  @override
  void dispose() {
    _pusherController.removeEventListener('notification.updated', _handleVendorNotificationUpdated);
    super.dispose();
  }

  List<NotificationsModel> _filter(List<NotificationsModel> list) => list.where((item) {
    final type = item.data?.data?.notificationType;
    if (_selectedCategory == 0) return true;
    if (_selectedCategory == 4) return type == null || (type != 1 && type != 2 && type != 3);
    return type == _selectedCategory;
  }).toList();

  Future<void> _clear(NotificationsController controller, bool ar) async {
    if (controller.notifications.isEmpty) return;
    final confirmed = await showDialog<bool>(context: context, builder: (dialog) => AlertDialog(
      title: Text(ar ? 'حذف جميع الإشعارات؟' : 'Delete all notifications?'),
      content: Text(ar ? 'سيتم حذف الإشعارات الحالية. الإشعارات الجديدة ستظهر بشكل طبيعي.'
        : 'Current notifications will be removed. New notifications will still arrive.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(ar ? 'إلغاء' : 'Cancel')),
        FilledButton(onPressed: () => Navigator.pop(dialog, true),
          style: FilledButton.styleFrom(backgroundColor: GoDesign.danger), child: Text(ar ? 'حذف الكل' : 'Delete all')),
      ],
    ));
    if (confirmed != true || !mounted) return;
    await controller.clearAllNotifications();
    if (mounted) setState(() => _selectedCategory = 0);
  }

  @override
  Widget build(BuildContext context) => Consumer<NotificationsController>(builder: (context, controller, _) {
    final ar = context.languageCode == 'ar';
    final labels = ar ? ['الكل', 'الطلبات', 'العروض', 'المعاملات', 'النظام']
      : ['All', 'Orders', 'Offers', 'Transactions', 'System'];
    final visible = _filter(controller.notifications);
    Widget list() => RefreshIndicator(onRefresh: controller.getNotifications,
      child: visible.isEmpty
        ? ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(32), children: [
            const SizedBox(height: 70),
            const Icon(Icons.notifications_none_rounded, size: 64, color: GoDesign.orange),
            const SizedBox(height: 20),
            Text(ar ? 'لا توجد إشعارات هنا بعد' : 'No notifications here yet', textAlign: TextAlign.center,
              style: const TextStyle(color: GoDesign.ink, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(ar ? 'تحديثات طلباتك وخدماتك ستظهر هنا.' : 'Updates about your orders and services will appear here.',
              textAlign: TextAlign.center, style: const TextStyle(color: GoDesign.muted, height: 1.5)),
          ])
        : ListView.separated(physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            itemCount: visible.length, separatorBuilder: (_, __) => const Divider(height: 1, color: GoDesign.border),
            itemBuilder: (_, index) => NotificationWidget(notification: visible[index],
              orderId: visible[index].data?.data?.id ?? 0)),
    );
    return Scaffold(backgroundColor: GoDesign.paper,
      appBar: CustomAppBar(title: Text(ar ? 'الإشعارات' : 'Notifications'), actions: [
        PopupMenuButton<int>(tooltip: ar ? 'خيارات الإشعارات' : 'Notification options',
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) { if (value == 1) _clear(controller, ar); },
          itemBuilder: (_) => [PopupMenuItem(value: 1, enabled: controller.notifications.isNotEmpty,
            child: Text(ar ? 'حذف جميع الإشعارات' : 'Delete all notifications'))]),
      ]),
      body: SafeArea(top: false, child: Column(children: [
        SingleChildScrollView(scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(children: List.generate(labels.length, (index) => Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(label: Text(labels[index]), selected: _selectedCategory == index,
              selectedColor: GoDesign.orangeTint, backgroundColor: GoDesign.canvas,
              labelStyle: TextStyle(color: _selectedCategory == index ? GoDesign.orange : GoDesign.ink),
              onSelected: (_) => setState(() => _selectedCategory = index))))),
        ),
        Expanded(child: ApiResponseWidget(apiResponse: controller.notificationsResponse,
          onReload: controller.getNotifications, isEmpty: controller.notifications.isEmpty,
          emptyWidget: list(), child: list())),
      ])),
    );
  });
}
