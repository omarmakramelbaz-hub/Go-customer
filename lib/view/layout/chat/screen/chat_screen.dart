import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/date_methods.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/custom_loading/custom_loading.dart';
import '../../../custom_widgets/no_data_widget/no_data_widget.dart';
import '../../auth/controller/auth_controller.dart';
import '../../orders/widgets/messages_widget.dart';
import '../controller/chat_controller.dart';
import '../model/chat_model.dart';

class ChatScreenArgs {
  final String orderId;
  final String receiverDeviceToken;
  final String senderDeviceToken;
  final String senderName;
  final String receiverName;
  final String vendorDeviceToken;
  final bool isVendor;
  final String accountType;
  ChatScreenArgs({required this.receiverDeviceToken, required this.senderDeviceToken,
    required this.senderName, required this.receiverName, required this.orderId,
    required this.vendorDeviceToken, required this.isVendor, required this.accountType, int? delegateId});
}

class ChatScreen extends StatefulWidget {
  final ChatScreenArgs args;
  static const routeName = 'ChatScreen';
  const ChatScreen({super.key, required this.args});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageEC = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.microtask(() { if (mounted) context.read<ChatController>().initial(widget.args.orderId); });
  }
  @override
  void dispose() { _messageEC.dispose(); super.dispose(); }

  void _send(ChatController controller) {
    final text = _messageEC.text;
    if (text.trim().isEmpty) return;
    final id = context.read<AuthController>().profile?.id;
    if (id == null) return;
    controller.send(text, id, widget.args.receiverDeviceToken, widget.args.senderDeviceToken,
      widget.args.senderName, widget.args.receiverName, widget.args.vendorDeviceToken,
      widget.args.isVendor, widget.args.accountType);
    _messageEC.clear();
  }

  @override
  Widget build(BuildContext context) => Consumer<ChatController>(builder: (context, controller, _) {
    final ar = context.languageCode == 'ar';
    return Scaffold(backgroundColor: GoDesign.paper,
      appBar: CustomAppBar(height: 64, centerTitle: false,
        title: Row(children: [
          const CircleAvatar(radius: 17, backgroundColor: Color(0xFF26363D),
            child: Icon(Icons.person_outline, color: Colors.white, size: 22)),
          const SizedBox(width: 10),
          Expanded(child: Text(widget.args.receiverName.trim().isEmpty ? 'messages'.tr : widget.args.receiverName,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700))),
        ])),
      body: SafeArea(top: false, child: Column(children: [
        Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: controller.chatStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.none || snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CustomLoading());
            }
            if (!snapshot.hasData) return const NoDataWidget();
            final messages = snapshot.data!.docs.map((doc) => ChatMessageModel.fromJson(doc.data())).toList();
            return GroupedListView<ChatMessageModel, DateTime>(
              elements: messages,
              groupBy: (message) => DateTime(message.messageTime!.year, message.messageTime!.month, message.messageTime!.day),
              itemComparator: (a, b) => a.messageTime!.compareTo(b.messageTime!),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              groupItemBuilder: (context, message, groupStart, groupEnd) => MessageWidget(message: message),
              groupSeparatorBuilder: (date) => Padding(padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(child: Text(DateMethods.formatToDate(date.toIso8601String()),
                  style: const TextStyle(color: GoDesign.muted, fontSize: 11)))),
              separator: const SizedBox(height: 4), reverse: true, order: GroupedListOrder.DESC,
            );
          },
        )),
        Container(padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: const BoxDecoration(color: GoDesign.paper,
            border: Border(top: BorderSide(color: GoDesign.border))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: CustomFormField(controller: _messageEC,
              hintText: ar ? 'اكتب رسالتك…' : 'Write a message…',
              fillColor: GoDesign.canvas, maxLines: 4, minLines: 1,
              keyboardType: TextInputType.multiline)),
            const SizedBox(width: 10),
            IconButton.filled(
              tooltip: ar ? 'إرسال' : 'Send',
              style: IconButton.styleFrom(backgroundColor: GoDesign.orange,
                foregroundColor: Colors.white, minimumSize: const Size(48, 48)),
              onPressed: () => _send(controller), icon: const Icon(Icons.send_rounded, size: 22)),
          ])),
      ])),
    );
  });
}
