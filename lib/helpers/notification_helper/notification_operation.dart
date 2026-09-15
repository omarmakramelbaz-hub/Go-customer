part of 'notification_helper.dart';

Future<void> scheduleNotification(String title, String subtitle, String data) async {
  var rng = math.Random();
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'faskhaninja_channel_sound_id',
    'FaskhaNinja Notifications (Sound)',
    channelDescription: 'This channel is used for FaskhaNinja app notifications with sound',
    importance: Importance.high,
    priority: Priority.high,
    colorized: true,
    color: Color(0xff469D8F),
    playSound: true,
  );
  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(presentSound: true);
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  await _notificationsPlugin!.show(rng.nextInt(100000), title, subtitle, platformChannelSpecifics, payload: data);
}

Future<NotificationSettings> iOSPermission() {
  return _firebaseMessaging!.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    sound: true,
  );
}

void handlePath(NotificationResponse dataMap) {
  final String? payload = dataMap.payload;
  if (payload != null) {
    final data = json.decode(payload);
    _onNotificationTaped(RemoteMessage(data: data));
  }
}

void _onNotificationTaped(RemoteMessage message) {
  final msg = json.encode(message.data);
  var body = json.decode(msg);
  final data = NotificationFromFirebaseMode.fromJson(body);

  switch (data.notificationType.toString()) {
    case '1':
      if (data.orderType.toString() == 'shipping') {
        NamedNavigatorImpl.push(RequestDelegateScreen.routeName);
      } else {
        NamedNavigatorImpl.push(
          TrackingYourOrderScreen.routeName,
          arguments: TrackingYourOrderArgs(id: int.parse(data.orderId.toString())),
        );
      }
      break;

    case '3':
      NamedNavigatorImpl.push(
        WalletScreen.routeName,
        arguments: TrackingYourOrderArgs(id: int.parse(data.orderId.toString())),
      );
      break;

    case '8':
      NamedNavigatorImpl.push(
        ChatScreen.routeName,
        arguments: ChatScreenArgs(
          senderDeviceToken: data.receiverDeviceToken.toString(),
          accountType: data.accountType.toString(),
          isVendor: false,
          vendorDeviceToken: data.receiverDeviceToken.toString(),
          receiverDeviceToken: data.senderDeviceToken.toString(),
          senderName: data.receiverName.toString(),
          receiverName: data.senderName.toString(),
          orderId: data.orderId.toString(),
        ),
      );
      break;

    case '10':
      NamedNavigatorImpl.push(
        AdminChatScreen.routeName,
        arguments: AdminChatScreenArgs(
          senderId: data.senderId.toString(),
          receiverId: data.receiverId.toString(),
          adminId: int.parse(data.senderId.toString()),
          adminDeviceToken: data.senderDeviceToken.toString(),
        ),
      );
      break;

    default:
      NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName);
  }
}
