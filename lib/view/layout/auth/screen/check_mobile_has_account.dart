import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extension/string_extension.dart';
import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../custom_widgets/go_master_ui.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../controller/auth_controller.dart';
import 'change_password_check_code.dart';

class CheckMobileHasAccount extends StatefulWidget {
  static const routeName = 'CheckMobileHasAccount';

  const CheckMobileHasAccount({super.key});

  @override
  State<CheckMobileHasAccount> createState() => _CheckMobileHasAccountState();
}

class _CheckMobileHasAccountState extends State<CheckMobileHasAccount>
    with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _mobileEC = TextEditingController();
  Country? _country;

  @override
  void initState() {
    _country = CountryParser.parsePhoneCode('20');
    super.initState();
  }

  @override
  void dispose() {
    _mobileEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    return Scaffold(
      backgroundColor: GoDesign.paper,
      appBar: CustomAppBar(
        title: Text(ar ? 'استعادة كلمة المرور' : 'Reset password'),
      ),
      body: Form(
        key: _formKey,
        child: GoAuthBody(
          isArabic: ar,
          children: [
            Text(
              ar ? 'نسيت كلمة المرور؟' : 'Forgot password?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GoDesign.ink,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              ar
                  ? 'اكتب رقم الهاتف المسجل بحسابك. هنرسل كود الاستعادة على بريدك الإلكتروني.'
                  : 'Enter your registered phone number. We will send a recovery code to your email.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GoDesign.muted,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            GoAuthPhoneField(
              controller: _mobileEC,
              isArabic: ar,
              countryCode: _country!.phoneCode,
              validator: (value) => validatePhone(value, country: _country),
            ),
            const SizedBox(height: 26),
            CustomButton(onPressed: _submit, text: ar ? 'متابعة' : 'Continue'),
          ],
        ),
      ),
    );
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    final mobile = _mobileEC.text.removeZero();

    context.read<AuthController>().checkMobileHasAccount(
      mobile: mobile,
      countryCode: _country!.phoneCode,
      onSuccess: (email) {
        CommonMethods.showChooseDialog(
          context,
          message: 'weWillSendCodeToThisEmail'.translate(args: [email]),
          onPressed: () {
            context.read<AuthController>().forgetPassword(
              email: email,
              mobile: mobile,
              onSuccess: () {
                NamedNavigatorImpl.pop();
                NamedNavigatorImpl.push(
                  ChangePasswordCheckCodeScreen.routeName,
                  arguments: ChangePasswordCheckCodeArguments(
                    email: email,
                    mobile: mobile,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
