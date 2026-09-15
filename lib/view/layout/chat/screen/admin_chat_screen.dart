import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/date_methods.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/custom_loading/custom_loading.dart';
import '../../../custom_widgets/no_data_widget/no_data_widget.dart';
import '../../auth/controller/auth_controller.dart';
import '../../orders/widgets/admin_message_widget.dart';
import '../controller/admin_chat_controller.dart';
import '../model/admin_chat_model.dart';

class AdminChatScreenArgs {
  final String senderId;
  final String receiverId;
  final int adminId;
  final String adminDeviceToken;

  AdminChatScreenArgs({
    required this.senderId,
    required this.receiverId,
    required this.adminId,
    required this.adminDeviceToken,
  });
}

class AdminChatScreen extends StatefulWidget {
  final AdminChatScreenArgs args;
  static const routeName = 'AdminChatScreen';

  const AdminChatScreen({super.key, required this.args});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final _messageEC = TextEditingController();
  @override
  void initState() {
    Future.microtask(() {
      context.read<AdminChatController>().initial(widget.args.senderId, widget.args.receiverId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminChatController>(
      builder: (context, chatController, _) {
        return Scaffold(
          appBar: CustomAppBar(
            height: 90,
            radius: 60,
            actions: const [],
            title: Text('messages'.tr),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: chatController.chatStream,
                  builder: (context, snapshot) {
                    log(snapshot.connectionState.name);
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return const Center(child: CustomLoading());
                      case ConnectionState.waiting:
                        return const Center(child: CustomLoading());
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          List<AdminChatMessageModel> messages =
                              snapshot.data!.docs.map((e) => AdminChatMessageModel.fromJson(e.data())).toList();

                          return GroupedListView<AdminChatMessageModel, DateTime>(
                            elements: messages,
                            groupBy: (element) => DateTime(
                              element.messageTime!.year,
                              element.messageTime!.month,
                              element.messageTime!.day,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            itemComparator: (item1, item2) => item1.messageTime!.compareTo(item2.messageTime!),
                            groupItemBuilder: (context, element, groupStart, groupEnd) {
                              return AdminMessageWidget(message: element);
                            },
                            groupSeparatorBuilder: (date) =>
                                Center(child: Text(DateMethods.formatToDate(date.toIso8601String()))),
                            separator: 15.sbH,
                            reverse: true,
                            order: GroupedListOrder.DESC,
                          );
                        } else {
                          return const NoDataWidget();
                        }
                      case ConnectionState.done:
                        return const CustomLoading();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(child: CustomFormField(controller: _messageEC)),
                    IconButton(
                      onPressed: () {
                        final txt = _messageEC.text;
                        if (_messageEC.text != '') {
                          chatController.send(
                            'admin',
                            context.read<AuthController>().profile!.name!,
                            txt,
                            context.read<AuthController>().profile!.id!.toString(),
                            widget.args.adminId.toString(),
                            widget.args.adminDeviceToken,
                          );
                        }

                        _messageEC.clear();
                      },
                      icon: Icon(Icons.send_rounded, color: AppColors.mainAppColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
