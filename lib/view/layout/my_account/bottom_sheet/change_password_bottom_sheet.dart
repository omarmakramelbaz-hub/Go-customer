import '../../../custom_widgets/popups/go_popups.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../../auth/controller/auth_controller.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  State<ChangePasswordBottomSheet> createState() => _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet>
    with ValidationMixin {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordEC = TextEditingController();
  final _newPasswordEC = TextEditingController();
  final _passwordConfirmationEC = TextEditingController();

  final _currentPasswordFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();
  final _passwordConfirmationFocusNode = FocusNode();

  @override
  void dispose() {
    _currentPasswordEC.dispose();
    _newPasswordEC.dispose();
    _passwordConfirmationEC.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _passwordConfirmationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return GoSheet(title: 'changePassword'.tr, subtitle: isArabic ? 'أنشئ كلمة مرور قوية لحماية حسابك' : 'Create a strong password to protect your account', icon: Icons.lock_reset_rounded, includeKeyboardInset: true,
      child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    _SecurityHint(
                      text: isArabic
                          ? 'استخدم 6 أحرف أو أرقام على الأقل وتجنب كلمات المرور سهلة التخمين.'
                          : 'Use at least 6 characters or numbers and avoid easy-to-guess passwords.',
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      validator: validateEmptyField,
                      controller: _currentPasswordEC,
                      title: isArabic ? 'كلمة المرور الحالية' : 'Current password',
                      hintText: isArabic ? 'أدخل كلمة المرور الحالية' : 'Enter current password',
                      isPassword: true,
                      focusNode: _currentPasswordFocusNode,
                      radius: 16,
                      fillColor: const Color(0xFFFAFAFB),
                      titleStyle: AppTextStyle.text13BS(),
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: AppColors.mainAppColor,
                      ),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_newPasswordFocusNode);
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomFormField(
                      validator: validatePassword,
                      controller: _newPasswordEC,
                      title: 'newPassword'.tr,
                      hintText: isArabic ? 'أدخل كلمة المرور الجديدة' : 'Enter new password',
                      isPassword: true,
                      focusNode: _newPasswordFocusNode,
                      radius: 16,
                      fillColor: const Color(0xFFFAFAFB),
                      titleStyle: AppTextStyle.text13BS(),
                      prefixIcon: Icon(
                        Icons.key_rounded,
                        size: 20,
                        color: AppColors.mainAppColor,
                      ),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_passwordConfirmationFocusNode);
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomFormField(
                      validator: (value) =>
                          validateConfirmPassword(value, _newPasswordEC.text),
                      controller: _passwordConfirmationEC,
                      title: 'confirmNewPassword'.tr,
                      hintText: isArabic
                          ? 'أعد كتابة كلمة المرور الجديدة'
                          : 'Re-enter new password',
                      isPassword: true,
                      focusNode: _passwordConfirmationFocusNode,
                      radius: 16,
                      fillColor: const Color(0xFFFAFAFB),
                      titleStyle: AppTextStyle.text13BS(),
                      prefixIcon: Icon(
                        Icons.verified_user_outlined,
                        size: 20,
                        color: AppColors.mainAppColor,
                      ),
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    ),
                    const SizedBox(height: 18),
                    ChangeNotifierProvider(
                      create: (_) => AuthController(),
                      child: Consumer<AuthController>(
                        builder: (context, authController, _) {
                          return CustomButton(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.gridOneButtonColor,
                                AppColors.gridTwoButtonColor,
                              ],
                            ),
                            text: isArabic ? 'حفظ كلمة المرور' : 'Save password',
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState!.validate()) {
                                authController.changePassword(
                                  currentPassword: _currentPasswordEC.text,
                                  newPassword: _newPasswordEC.text,
                                  confirmPassword: _passwordConfirmationEC.text,
                                  onSuccess: () => Navigator.pop(context),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                  
      ])),
    );
  }
}



class _SecurityHint extends StatelessWidget {
  const _SecurityHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE5CF)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 19, color: AppColors.mainAppColor),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.text11RG().copyWith(
                color: const Color(0xFF6E737B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
