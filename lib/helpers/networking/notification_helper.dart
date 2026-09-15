// import 'dart:convert';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// import '../../view/layout/bottom_navigation/bottom_navigation_bar_screen.dart';
// import '../../view/layout/chat/screen/admin_chat_screen.dart';
// import '../../view/layout/chat/screen/chat_screen.dart';
// import '../../view/layout/notifications/model/notfication_from_firebase_model.dart';
// import '../../view/layout/orders/screen/tracking_your_order_screen.dart';
// import '../../view/layout/request_delegate/screen/request_delegate_screen.dart';
// import '../../view/layout/wallet/screen/wallet_screen.dart';
// import '../routes/app_routers_import.dart';
// import '../utils/logger.dart';
//
// class NotificationHelper {
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   void initialize() {
//     const InitializationSettings settings = InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/launcher_icon'),
//       iOS: DarwinInitializationSettings(),
//     );
//     _flutterLocalNotificationsPlugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (notificationResponse) {
//         _handleNotificationTap(notificationResponse);
//       },
//     );
//   }
//
//   void display(RemoteMessage message) async {
//     try {
//       // Define the Android Notification Channel ID, which should match the ID used in MainActivity.
//       const String channelId = 'faskhaninja_channel_id'; // Make sure this matches the channel ID in MainActivity
//
//       var android = const AndroidNotificationDetails(
//         channelId, // Use the same ID here
//         'FaskhaNinja Notifications', // Channel name
//         channelDescription: 'This channel is used for FaskhaNinja app notifications', // Channel description
//         importance: Importance.high,
//         priority: Priority.high,
//         colorized: true,
//         color: Color(0xff469D8F),
//         playSound: false, // Disable default sound
//       );
//
//       var iOS = const DarwinNotificationDetails();
//       var platform = NotificationDetails(android: android, iOS: iOS);
//
//       // Show the notification
//       _flutterLocalNotificationsPlugin.show(
//         0,
//         message.notification?.title,
//         message.notification?.body,
//         platform,
//         payload: json.encode(message.data),
//       );
//     } catch (e) {
//       PrintLog.e('Error displaying notification: ${e.toString()}');
//     }
//   }
//
//   void _handleNotificationTap(NotificationResponse notificationResponse) {
//     final String? payload = notificationResponse.payload;
//     if (payload != null) {
//       PrintLog.i('Notification tapped with payload: $payload');
//
//       final data = json.decode(payload);
//
//       _onNotificationTaped(RemoteMessage(data: data));
//     }
//   }
//
//   void _onNotificationTaped(RemoteMessage message) {
//     final msg = json.encode(message.data);
//     var body = json.decode(msg);
//     final data = NotificationFromFirebaseMode.fromJson(body);
//
//     switch (data.notificationType.toString()) {
//       case '1':
//         if (data.orderType.toString() == 'shipping') {
//           NamedNavigatorImpl.pushNamed(
//             RequestDelegateScreen.routeName,
//           );
//         } else {
//           NamedNavigatorImpl.pushNamed(
//             TrackingYourOrderScreen.routeName,
//             arguments: TrackingYourOrderArgs(id: int.parse(data.orderId.toString())),
//           );
//         }
//         break;
//
//       case '3':
//         NamedNavigatorImpl.pushNamed(
//           WalletScreen.routeName,
//           arguments: TrackingYourOrderArgs(id: int.parse(data.orderId.toString())),
//         );
//         break;
//
//       case '8':
//         NamedNavigatorImpl.pushNamed(
//           ChatScreen.routeName,
//           arguments: ChatScreenArgs(
//             senderDeviceToken: data.receiverDeviceToken.toString(),
//             accountType: data.accountType.toString(),
//             isVendor: false,
//             vendorDeviceToken: data.receiverDeviceToken.toString(),
//             receiverDeviceToken: data.senderDeviceToken.toString(),
//             senderName: data.receiverName.toString(),
//             receiverName: data.senderName.toString(),
//             orderId: data.orderId.toString(),
//           ),
//         );
//         break;
//
//       case '10':
//         NamedNavigatorImpl.pushNamed(
//           AdminChatScreen.routeName,
//           arguments: AdminChatScreenArgs(
//             senderId: data.senderId.toString(),
//             receiverId: data.receiverId.toString(),
//             adminId: int.parse(data.senderId.toString()),
//             adminDeviceToken: data.senderDeviceToken.toString(),
//           ),
//         );
//         break;
//
//       default:
//         NamedNavigatorImpl.pushNamed(
//           BottomNavigationBarScreen.routeName,
//         );
//     }
//   }
// }
