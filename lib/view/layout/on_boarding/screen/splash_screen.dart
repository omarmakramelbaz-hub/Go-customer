import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/go_master_ui.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/screen/login_screen.dart';
import '../../auth/screen/create_new_account_screen.dart';
import '../../bottom_navigation/bottom_navigation_bar_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = 'SplashScreen';
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _failed = false;
  bool _loading = false;
  final DateTime _openingStartedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSession());
  }

  Future<void> _restoreSession() async {
    if (_loading || !mounted) return;
    setState(() {
      _failed = false;
      _loading = true;
    });
    HiveMethods.updateFirstTime();
    if (kIsWeb && Uri.base.host.endsWith('github.io')) {
      HiveMethods.updateIsVisitor(true);
      _open(BottomNavigationBarScreen.routeName);
      return;
    }
    if (HiveMethods.getToken() == null) {
      _open(LoginScreen.routeName);
      return;
    }
    final auth = context.read<AuthController>();
    await auth.getProfile();
    if (!mounted) return;
    if (auth.profileResponse.state == ResponseState.unauthorized) {
      await HiveMethods.deleteToken();
      _open(LoginScreen.routeName);
      return;
    }
    if (auth.profileResponse.state != ResponseState.complete || auth.profile == null) {
      setState(() {
        _failed = true;
        _loading = false;
      });
      return;
    }
    if (!kIsWeb) {
      final localAuth = LocalAuthentication();
      try {
        if (await localAuth.isDeviceSupported()) {
          final accepted = await localAuth.authenticate(
            localizedReason: context.languageCode == 'ar'
                ? 'تأكيد هويتك للدخول إلى Go Drive'
                : 'Authenticate to open Go Drive',
            persistAcrossBackgrounding: true,
          );
          if (!accepted) {
            _open(LoginScreen.routeName);
            return;
          }
        }
      } catch (_) {
        _open(LoginScreen.routeName);
        return;
      }
    }
    if (!mounted) return;
    HiveMethods.updateIsVisitor(false);
    final profile = auth.profile!;
    if (profile.id != null) {
      HiveMethods.updateUserId(profile.id);
      await context.read<PusherController>().initPusher(
        channelName: 'private-user.${profile.id}', userId: profile.id!,
        token: profile.token ?? HiveMethods.getToken()!,
      );
    }
    _open(profile.email == null
        ? CreateNewAccountScreen.routeName : BottomNavigationBarScreen.routeName);
  }

  Future<void> _open(String route) async {
    final elapsed = DateTime.now().difference(_openingStartedAt).inMilliseconds;
    final remainingMs = 3000 - elapsed;
    if (remainingMs > 0) await Future.delayed(Duration(milliseconds: remainingMs));
    if (mounted) NamedNavigatorImpl.push(route, clean: true);
  }

  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: GoDesign.deepInk,
        body: GoSplashBackdrop(child: SizedBox.expand(child: SafeArea(
          child: Center(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              GoBrandHeader(light: true, size: 86, isArabic: ar),
              const SizedBox(height: 30),
              if (_failed) ...[
                Text(ar ? 'تعذّر الاتصال. حاول مرة أخرى.' : 'Unable to connect. Please try again.',
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                FilledButton(onPressed: _restoreSession,
                  child: Text(ar ? 'إعادة المحاولة' : 'Try again')),
              ] else
                const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: GoDesign.orange)),
            ]),
          )),
        ))),
      ),
    );
  }
}
