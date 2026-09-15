import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../view/layout/bottom_navigation/bottom_navigation_bar_screen.dart';
import '../../view/layout/chat/screen/admin_chat_screen.dart';
import '../../view/layout/chat/screen/chat_screen.dart';
import '../../view/layout/notifications/model/notfication_from_firebase_model.dart';
import '../../view/layout/orders/screen/tracking_your_order_screen.dart';
import '../../view/layout/request_delegate/screen/request_delegate_screen.dart';
import '../../view/layout/wallet/screen/wallet_screen.dart';
import '../delivery_activity/delivery_activity_push_handler.dart';
import '../routes/app_routers_import.dart';
import 'firebase_options.dart';

part 'firebase_notification_helper.dart';
part 'local_notification.dart';
part 'notification_operation.dart';
