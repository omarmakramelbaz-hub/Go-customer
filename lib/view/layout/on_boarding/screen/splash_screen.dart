import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/identity/go_customer_identity.dart';
import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/go_drive_brand.dart';
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
    // GitHub Pages is a public UI preview. Do not let stale browser auth
    // state/API availability trap the preview on the splash screen.
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
    if (auth.profileResponse.state != ResponseState.complete ||
        auth.profile == null) {
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
        channelName: 'private-user.${profile.id}',
        userId: profile.id!,
        token: profile.token ?? HiveMethods.getToken()!,
      );
    }
    _open(
      profile.email == null
          ? CreateNewAccountScreen.routeName
          : BottomNavigationBarScreen.routeName,
    );
  }

  void _open(String route) {
    if (mounted) NamedNavigatorImpl.push(route, clean: true);
  }

  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    return Scaffold(
      backgroundColor: const Color(0xff171A1F),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(GoCustomerIdentity.lightLogoAsset, width: 210, height: 150),
                const SizedBox(height: 12),
                Text(
                  ar ? 'كل خدماتك عندك' : 'All your services, in one place',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 36),
                if (_failed) ...[
                  Text(ar ? 'تعذّر الاتصال. حاول مرة أخرى.' : 'Unable to connect. Please try again.',
                    style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _restoreSession,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xffFD7201)),
                    child: Text(ar ? 'إعادة المحاولة' : 'Try again'),
                  ),
                  TextButton(
                    onPressed: () => _open(LoginScreen.routeName),
                    child: Text(ar ? 'تسجيل الدخول' : 'Sign in', style: const TextStyle(color: Colors.white)),
                  ),
                ] else
                  const CircularProgressIndicator(color: Color(0xffFD7201)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
