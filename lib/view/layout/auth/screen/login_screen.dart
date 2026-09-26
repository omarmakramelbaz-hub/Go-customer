import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extension/string_extension.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/translation/main_app_bloc.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/go_master_ui.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../../bottom_navigation/bottom_navigation_bar_screen.dart';
import '../../on_boarding/screen/go_guest_welcome_screen.dart';
import '../controller/auth_controller.dart';
import 'check_mobile_has_account.dart';
import 'create_new_account_screen.dart';
import 'register_screen.dart';
import 'social_login_row_widget.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'LoginScreen';
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _mobileEC = TextEditingController();
  final _passwordEC = TextEditingController();
  Country? _country;

  @override
  void initState() {
    _country = CountryParser.parsePhoneCode('20');
    super.initState();
  }

  @override
  void dispose() {
    _mobileEC.dispose();
    _passwordEC.dispose();
    super.dispose();
  }

  void _openGuest(bool ar) => Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (guestContext) => GoGuestWelcomeScreen(
      isArabic: ar,
      onLogin: () => Navigator.of(guestContext).pop(),
      onRegister: () => NamedNavigatorImpl.push(RegisterScreen.routeName),
      onContinue: () {
        HiveMethods.deleteToken();
        HiveMethods.updateIsVisitor(true);
        NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName, clean: true);
      },
    ),
  ));

  @override
  Widget build(BuildContext context) => StreamBuilder<String>(
    stream: mainAppBloc.langStream,
    builder: (context, language) {
      final ar = context.languageCode == 'ar';
      return Scaffold(
        backgroundColor: GoDesign.paper,
        body: Form(key: _formKey, child: GoAuthBody(isArabic: ar, children: [
          GoAuthTabs(register: false, isArabic: ar, onLogin: () {},
            onRegister: () => NamedNavigatorImpl.push(RegisterScreen.routeName)),
          const SizedBox(height: 28),
          CustomFormField(
            validator: (value) => validatePhone(value, country: _country),
            controller: _mobileEC, keyboardType: TextInputType.phone,
            country: _country, hintText: ar ? 'رقم الموبايل' : 'Mobile number',
            prefixIcon: const Icon(Icons.phone_outlined, size: 21)),
          const SizedBox(height: 14),
          CustomFormField(validator: validatePassword, controller: _passwordEC,
            hintText: ar ? 'كلمة المرور' : 'Password', isPassword: true,
            prefixIcon: const Icon(Icons.lock_outline, size: 21),
            onFieldSubmitted: (_) => _submitLogin(context)),
          Align(alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => NamedNavigatorImpl.push(CheckMobileHasAccount.routeName),
              style: TextButton.styleFrom(foregroundColor: GoDesign.ink),
              child: Text(ar ? 'نسيت كلمة المرور؟' : 'Forgot password?'))),
          const SizedBox(height: 4),
          CustomButton(text: ar ? 'تسجيل الدخول' : 'Sign in',
            onPressed: () => _submitLogin(context)),
          if (SocialLoginRowWidget.isAvailable) ...[
            const SizedBox(height: 20),
            const SocialLoginRowWidget(),
          ],
          const SizedBox(height: 24),
          GoOrDivider(isArabic: ar),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => _openGuest(ar),
            style: OutlinedButton.styleFrom(foregroundColor: GoDesign.ink,
              side: const BorderSide(color: GoDesign.border)),
            icon: const Icon(Icons.visibility_outlined, size: 21),
            label: Text(ar ? 'دخول كزائر' : 'Continue as guest')),
          const SizedBox(height: 12),
          Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(ar ? 'معندكش حساب؟' : 'New here?', style: const TextStyle(color: GoDesign.muted)),
              TextButton(onPressed: () => NamedNavigatorImpl.push(RegisterScreen.routeName),
                child: Text(ar ? 'أنشئ حساب الآن' : 'Create an account')),
            ]),
        ])),
      );
    },
  );

  // Keep the existing session, first-time account and realtime callbacks intact.
  void _submitLogin(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthController>().login(
      onHaveIdANDToken: (id, token) {
        context.read<PusherController>().initPusher(
          channelName: 'private-user.$id', userId: id, token: token);
      },
      onFirstTime: () => NamedNavigatorImpl.push(CreateNewAccountScreen.routeName),
      mobile: _mobileEC.text.removeZero(),
      password: _passwordEC.text,
      onSuccess: (register, mobileVerifiedAt) {
        HiveMethods.updateIsVisitor(false);
        if (register == 0 && mobileVerifiedAt != null) {
          NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName, replace: true);
        } else {
          NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName, clean: true);
        }
      },
    );
  }
}
