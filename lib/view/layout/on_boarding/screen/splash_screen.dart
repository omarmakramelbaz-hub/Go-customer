import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
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
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GoDriveBrand(size: 54),
                const SizedBox(height: 18),
                Text(
                  ar
                      ? 'مندوبك في أي وقت'
                      : 'Your courier, whenever you need one',
                ),
                const SizedBox(height: 36),
                if (_failed) ...[
                  Text(
                    ar
                        ? 'تعذّر الاتصال. حاول مرة أخرى.'
                        : 'Unable to connect. Please try again.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _restoreSession,
                    child: Text(ar ? 'إعادة المحاولة' : 'Try again'),
                  ),
                  TextButton(
                    onPressed: () => _open(LoginScreen.routeName),
                    child: Text(ar ? 'تسجيل الدخول' : 'Sign in'),
                  ),
                ] else
                  CircularProgressIndicator(color: AppColors.mainAppColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
