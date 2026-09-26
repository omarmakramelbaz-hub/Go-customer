import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view/layout/address/controller/address_controller.dart';
import '../../view/layout/auth/controller/auth_controller.dart';
import '../../view/layout/home/controller/home_controller.dart';
import '../../view/layout/my_account/controller/my_account_controller.dart';
import '../../view/layout/on_boarding/screen/splash_screen.dart';
import '../../view/layout/request_delegate/controller/request_delegate_controller.dart';
import '../../view/layout/wallet/controller/wallet_controller.dart';
import '../pusher_service/pusher_controller.dart';
import '../delivery_activity/delivery_provider.dart';
import '../routes/app_routers_import.dart';
import '../theme/theme.dart';
import '../translation/all_translation.dart';
import '../translation/main_app_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    mainAppBloc.getShared();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => DeliveryProvider()),
      ChangeNotifierProvider(create: (_) => AuthController()),
      ChangeNotifierProvider(create: (_) => HomeController()),
      ChangeNotifierProvider(create: (_) => WalletController()),
      ChangeNotifierProvider(
        create: (_) => MyAccountController()
          ..initialSetting()
          ..getSetting(),
      ),
      ChangeNotifierProvider(create: (_) => AddressController()),
      ChangeNotifierProvider(create: (_) => RequestDelegateController()),
      ChangeNotifierProvider(create: (_) => PusherController()),
    ],
    child: StreamBuilder<String>(
      stream: mainAppBloc.langStream,
      initialData: GlobalTranslations.currentLanguage,
      builder: (context, language) => MaterialApp(
        title: 'Go Customer',
        locale: Locale(language.data ?? 'ar'),
        supportedLocales: GlobalTranslations.supportedLocales(),
        localizationsDelegates: context.localizationsDelegates,
        debugShowCheckedModeBanner: false,
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        initialRoute: SplashScreen.routeName,
        onGenerateRoute: NamedNavigatorImpl.onGenerateRoute,
        navigatorKey: NamedNavigatorImpl.navigatorState,
        theme: theme(context),
      ),
    ),
  );
}
