import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'helpers/app/app.dart';
import 'helpers/app/init_services.dart';

const String _facebookAppId = String.fromEnvironment('FACEBOOK_APP_ID');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb && _facebookAppId.isNotEmpty) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: _facebookAppId,
      cookie: true,
      xfbml: true,
      version: 'v21.0',
    );
  }

  await initServices();
  runApp(const MyApp());
}
