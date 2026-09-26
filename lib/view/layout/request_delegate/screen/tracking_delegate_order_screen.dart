import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/url_launcher_methods.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../../custom_widgets/global_widgets/connect_support_widget.dart';
import '../../../custom_widgets/go_master_ui.dart';
import '../../chat/screen/chat_screen.dart';
import '../controller/request_delegate_controller.dart';
import '../widget/tracking_delegate_order_widget.dart';

class TrackingDelegateOrderArgs {
  final int id;
  final VoidCallback? onSuccess;
  TrackingDelegateOrderArgs({required this.id, this.onSuccess});
}

class TrackingDelegateOrderScreen extends StatefulWidget {
  final TrackingDelegateOrderArgs args;
  static const routeName = 'TrackingDelegateOrderScreen';
  const TrackingDelegateOrderScreen({super.key, required this.args});
  @override
  State<TrackingDelegateOrderScreen> createState() => _TrackingDelegateOrderScreenState();
}

class _TrackingDelegateOrderScreenState extends State<TrackingDelegateOrderScreen> {
  late RequestDelegateController requestDelegateController;
  LatLng? origin;
  LatLng? destination;
  Timer? _liveTimer;
  bool _offerDialogOpen = false;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      requestDelegateController = context.read<RequestDelegateController>();
      requestDelegateController.initialDelegateOrderDetails();
      await _refresh();
      if (!mounted) return;
      _liveTimer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
    });
  }

  LatLng? _point(String? lat, String? lng) {
    final a = double.tryParse(lat ?? '');
    final b = double.tryParse(lng ?? '');
    if (a == null || b == null || !a.isFinite || !b.isFinite || a < -90 || a > 90 || b < -180 || b > 180) return null;
    return LatLng(a, b);
  }

  Future<void> _refresh() async {
    if (!mounted || _refreshing) return;
    _refreshing = true;
    try {
      await requestDelegateController.getDelegateOrderDetails(id: widget.args.id);
      if (!mounted) return;
      final order = requestDelegateController.delegateOrderDetails;
      setState(() {
        origin = _point(order?.fromLat, order?.fromLng);
        destination = _point(order?.toLat, order?.toLng);
      });
      await requestDelegateController.getAcceptedDelegate(delegateOrderId: widget.args.id);
      if (mounted) _showRevisedOfferIfNeeded();
    } finally { _refreshing = false; }
  }

  Future<void> _showRevisedOfferIfNeeded() async {
    final offer = requestDelegateController.acceptedDelegate?.activeOffer;
    if (_offerDialogOpen || offer == null || offer.status != 'price_revision' || !mounted) return;
    _offerDialogOpen = true;
    final ar = context.languageCode == 'ar';
    await showDialog<void>(context: context, barrierDismissible: false, builder: (dialogContext) => AlertDialog(
      title: Text(ar ? 'عرض سعر جديد من المندوب' : 'New price offer'),
      content: Text(ar ? 'المندوب اقترح سعر توصيل جديد بقيمة ${offer.price} جنيه. لن يتغير سعر الطلب إلا بعد موافقتك.'
        : 'The driver proposed a new fare of ${offer.price} EGP. Your fare changes only if you accept.'),
      actions: [
        TextButton(onPressed: () async {
          final ok = await requestDelegateController.respondToRevisedOffer(orderId: widget.args.id, status: 'declined');
          if (ok && dialogContext.mounted) Navigator.pop(dialogContext);
        }, child: Text(ar ? 'رفض' : 'Decline')),
        FilledButton(onPressed: () async {
          final ok = await requestDelegateController.respondToRevisedOffer(orderId: widget.args.id, status: 'accepted');
          if (ok && dialogContext.mounted) Navigator.pop(dialogContext);
          if (ok && mounted) await requestDelegateController.getDelegateOrderDetails(id: widget.args.id);
        }, child: Text(ar ? 'قبول السعر الجديد' : 'Accept new fare')),
      ],
    ));
    _offerDialogOpen = false;
  }

  @override
  void dispose() { _liveTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => PopScope(onPopInvokedWithResult: (didPop, _) {
    if (didPop) widget.args.onSuccess?.call();
  }, child: Consumer<RequestDelegateController>(builder: (context, controller, _) {
    final ar = context.languageCode == 'ar';
    final order = controller.delegateOrderDetails;
    return Scaffold(backgroundColor: GoDesign.paper,
      appBar: CustomAppBar(title: Text(ar ? 'متابعة الطلب' : 'Track request')),
      body: SafeArea(top: false, child: ApiResponseWidget(
        apiResponse: controller.delegateOrderDetailsApiResponse,
        onReload: () => controller.getDelegateOrderDetails(id: widget.args.id), isEmpty: order == null,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text('${ar ? 'طلب رقم' : 'Request'} #${widget.args.id}',
            style: const TextStyle(color: GoDesign.muted, fontSize: 13)),
          const SizedBox(height: 22),
          GoSurface(child: TrackingDelegateOrderWidget(status: order?.status ?? '', orderDate: order?.createdAt)),
          if (order?.delegateId != null) ...[
            const SizedBox(height: 16),
            GoSurface(child: Row(children: [
              CustomImage(path: order?.delegateLogo == null ? AppImages.delegateRDIcon : order?.delegateLogo ?? '',
                type: order?.delegateLogo == null ? ImageType.svg : ImageType.network,
                width: 46, height: 46, radius: 23),
              const SizedBox(width: 12),
              Expanded(child: Text(order?.delegateName ?? '',
                style: const TextStyle(color: GoDesign.ink, fontSize: 17, fontWeight: FontWeight.w700))),
            ])),
          ],
          const SizedBox(height: 18),
          _address(ar ? 'عنوان الاستلام' : 'Pickup address', order?.fromAddress ?? ''),
          const SizedBox(height: 12),
          _address(ar ? 'عنوان التوصيل' : 'Delivery address', order?.toAddress ?? ''),
          if (origin != null && destination != null) ...[
            const SizedBox(height: 12),
            ExpansionTile(tilePadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(ar ? 'عرض المواقع على الخريطة' : 'View locations on the map',
                style: const TextStyle(fontSize: 14, color: GoDesign.ink)),
              leading: const Icon(Icons.map_outlined, color: GoDesign.orange),
              children: [_buildMap()]),
          ],
          const SizedBox(height: 20),
          GoSurface(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('orderDetails'.tr, style: const TextStyle(color: GoDesign.ink, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(order?.description ?? '', style: const TextStyle(color: GoDesign.muted, height: 1.5)),
            const Divider(height: 26, color: GoDesign.border),
            Wrap(alignment: WrapAlignment.spaceBetween, spacing: 16, runSpacing: 10, children: [
              Text('deliverCost'.tr, style: const TextStyle(color: GoDesign.ink, fontWeight: FontWeight.w600)),
              Text(order?.actualPrice == null ? '—' : 'pound'.tr.replaceAll('{}', '${order?.actualPrice}'),
                style: const TextStyle(color: GoDesign.orange, fontSize: 17, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.account_balance_wallet_outlined, color: GoDesign.orange, size: 21),
              const SizedBox(width: 10),
              Expanded(child: Text(_paymentLabel(order?.paymentType), style: const TextStyle(color: GoDesign.ink, fontSize: 14))),
            ]),
          ])),
          if (order?.status == 'accepted') ...[
            const SizedBox(height: 18),
            TextButton.icon(style: TextButton.styleFrom(foregroundColor: GoDesign.danger),
              onPressed: () => controller.cancelOrder(orderId: order!.id!, onSuccess: () => NamedNavigatorImpl.pop()),
              icon: const Icon(Icons.cancel_outlined), label: Text('cancelOrder'.tr)),
          ],
          const SizedBox(height: 20),
          const ConnectSupportWidget(isDark: false),
        ]),
      )),
      bottomNavigationBar: order?.delegateId == null ? null : SafeArea(top: false,
        child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 14), child: Row(children: [
          if (order?.delegateMobile?.isNotEmpty == true)
            Expanded(child: OutlinedButton.icon(onPressed: () => UrlLauncherMethods.makePhoneCall(order?.delegateMobile ?? ''),
              icon: const Icon(Icons.call_outlined), label: Text(ar ? 'اتصال' : 'Call'))),
          if (order?.delegateFcmId != null) ...[
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(onPressed: () => NamedNavigatorImpl.push(ChatScreen.routeName,
              arguments: ChatScreenArgs(senderDeviceToken: order?.userFcmId ?? '', accountType: 'vendor', isVendor: false,
                vendorDeviceToken: order?.resturantVendorDeviceToken ?? '', receiverDeviceToken: order?.delegateFcmId ?? '',
                senderName: order?.userName ?? '', receiverName: order?.delegateName ?? '', orderId: 'VD${order?.id ?? ''}')),
              icon: const Icon(Icons.chat_bubble_outline), label: Text(ar ? 'مراسلة' : 'Message'))),
          ],
        ]))),
    );
  }));

  String _paymentLabel(String? value) {
    switch (value) {
      case 'cash': return 'cash'.tr;
      case 'online': return 'visa'.tr;
      case 'v_cash': return 'vfCash'.tr;
      case 'wallet': return 'appWallet'.tr;
      default: return value ?? '—';
    }
  }

  Widget _address(String title, String address) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Icon(Icons.location_on_outlined, color: GoDesign.orange, size: 23), const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: GoDesign.ink, fontSize: 14, fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      Text(address, style: const TextStyle(color: GoDesign.muted, fontSize: 13, height: 1.5)),
    ])),
  ]);

  Widget _buildMap() => ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(height: 230,
    child: GoogleMap(mapType: MapType.normal, zoomControlsEnabled: false,
      initialCameraPosition: CameraPosition(target: origin!, zoom: 16),
      markers: {Marker(markerId: const MarkerId('origin'), position: origin!),
        Marker(markerId: const MarkerId('destination'), position: destination!)},
      onMapCreated: (map) => map.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(
        southwest: LatLng(origin!.latitude < destination!.latitude ? origin!.latitude : destination!.latitude,
          origin!.longitude < destination!.longitude ? origin!.longitude : destination!.longitude),
        northeast: LatLng(origin!.latitude > destination!.latitude ? origin!.latitude : destination!.latitude,
          origin!.longitude > destination!.longitude ? origin!.longitude : destination!.longitude)), 60)),
    )));
}
