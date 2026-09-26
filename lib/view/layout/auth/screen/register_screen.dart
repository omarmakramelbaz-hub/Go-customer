import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extension/string_extension.dart';
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
import '../controller/auth_controller.dart';
import 'create_new_account_screen.dart';
import 'login_screen.dart';
import 'social_login_row_widget.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = 'RegisterScreen';
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _mobileEC = TextEditingController();
  final _passwordEC = TextEditingController();
  final _confirmationEC = TextEditingController();
  final _focusNode = FocusNode();
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
    _confirmationEC.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<String>(
    stream: mainAppBloc.langStream,
    builder: (context, _) {
      final ar = context.languageCode == 'ar';
      return Scaffold(backgroundColor: GoDesign.paper,
        body: Form(key: _formKey, child: GoAuthBody(isArabic: ar, children: [
          GoAuthTabs(register: true, isArabic: ar,
            onLogin: () => NamedNavigatorImpl.push(LoginScreen.routeName), onRegister: () {}),
          const SizedBox(height: 22),
          Text(ar ? 'ابدأ برقم الموبايل وكلمة المرور، ثم أكمل بيانات حسابك.'
            : 'Start with your mobile number and password, then complete your profile.',
            textAlign: TextAlign.center, style: const TextStyle(color: GoDesign.muted, height: 1.5)),
          const SizedBox(height: 22),
          CustomFormField(validator: (value) => validatePhone(value, country: _country),
            controller: _mobileEC, keyboardType: TextInputType.phone, country: _country,
            hintText: ar ? 'رقم الموبايل' : 'Mobile number',
            prefixIcon: const Icon(Icons.phone_outlined, size: 21)),
          const SizedBox(height: 14),
          CustomFormField(validator: validatePassword, controller: _passwordEC,
            hintText: ar ? 'كلمة المرور' : 'Password', isPassword: true, focusNode: _focusNode,
            prefixIcon: const Icon(Icons.lock_outline, size: 21),
            onFieldSubmitted: (_) => _focusNode.unfocus()),
          const SizedBox(height: 14),
          CustomFormField(controller: _confirmationEC, isPassword: true,
            hintText: ar ? 'تأكيد كلمة المرور' : 'Confirm password',
            prefixIcon: const Icon(Icons.lock_outline, size: 21),
            validator: (value) => value == _passwordEC.text && (value?.isNotEmpty ?? false)
              ? null : (ar ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match')),
          const SizedBox(height: 22),
          CustomButton(onPressed: () => _submit(context), text: ar ? 'متابعة إنشاء الحساب' : 'Continue registration'),
          const SizedBox(height: 14),
          Text(ar ? 'بإنشاء حسابك، أنت توافق على' : 'By creating an account, you agree to our',
            textAlign: TextAlign.center, style: const TextStyle(color: GoDesign.muted, fontSize: 12)),
          Wrap(alignment: WrapAlignment.center, children: [
            TextButton(onPressed: () => NamedNavigatorImpl.push('TermsAndConditionsScreen'),
              child: Text(ar ? 'الشروط والأحكام' : 'Terms and conditions')),
            TextButton(onPressed: () => NamedNavigatorImpl.push('PrivacyPolicyScreen'),
              child: Text(ar ? 'سياسة الخصوصية' : 'Privacy policy')),
          ]),
          if (SocialLoginRowWidget.isAvailable) ...[
            const SizedBox(height: 10), GoOrDivider(isArabic: ar),
            const SizedBox(height: 12), const SocialLoginRowWidget(),
          ],
        ])),
      );
    },
  );

  void _submit(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthController>().login(
      onHaveIdANDToken: (id, token) {
        context.read<PusherController>().initPusher(
          channelName: 'private-user.$id', userId: id, token: token);
      },
      onFirstTime: () => NamedNavigatorImpl.push(CreateNewAccountScreen.routeName),
      mobile: _mobileEC.text.removeZero(), password: _passwordEC.text,
      onSuccess: (register, mobileVerifiedAt) {
        NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName);
      },
    );
  }
}
