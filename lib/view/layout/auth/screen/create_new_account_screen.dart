import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/custom_select/custom_select_item.dart';
import '../../../custom_widgets/custom_select/custom_single_select.dart';
import '../../../custom_widgets/go_master_ui.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../controller/auth_controller.dart';
import 'share_location_screen.dart';

class CreateNewAccountScreen extends StatefulWidget {
  static const routeName = 'CreateNewAccountScreen';
  const CreateNewAccountScreen({super.key});
  @override
  State<CreateNewAccountScreen> createState() => _CreateNewAccountScreenState();
}

class _CreateNewAccountScreenState extends State<CreateNewAccountScreen> with ValidationMixin {
  int? _country;
  final _formKey = GlobalKey<FormState>();
  final _nameEc = TextEditingController();
  final _emailEc = TextEditingController();
  final nameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();

  @override
  void dispose() {
    _nameEc.dispose();
    _emailEc.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AuthController()..initialArea()..getArea(),
    child: Consumer<AuthController>(builder: (context, authController, _) {
      final ar = context.languageCode == 'ar';
      return Scaffold(backgroundColor: GoDesign.paper,
        body: Form(key: _formKey, child: ApiResponseWidget(
          apiResponse: authController.areaResponse,
          onReload: () => authController.getArea(),
          isEmpty: authController.area.isEmpty,
          child: GoAuthBody(isArabic: ar, children: [
            Text(ar ? 'أكمل بيانات حسابك' : 'Complete your profile',
              textAlign: TextAlign.center,
              style: const TextStyle(color: GoDesign.ink, fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            CustomFormField(validator: validateEmptyField, controller: _nameEc,
              hintText: ar ? 'الاسم الكامل' : 'Full name', focusNode: nameFocusNode,
              prefixIcon: const Icon(Icons.person_outline, size: 21),
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(emailFocusNode)),
            const SizedBox(height: 14),
            CustomFormField(controller: _emailEc, validator: validateEmptyField,
              keyboardType: TextInputType.emailAddress,
              hintText: ar ? 'البريد الإلكتروني' : 'Email address', focusNode: emailFocusNode,
              prefixIcon: const Icon(Icons.mail_outline, size: 21),
              onFieldSubmitted: (_) => emailFocusNode.unfocus()),
            const SizedBox(height: 14),
            CustomSingleSelect(
              validator: validateEmptyDropDown, apiResponse: authController.areaResponse,
              onReload: () => authController.getArea(),
              value: _country ?? (authController.area.isNotEmpty ? authController.area[0].id ?? 0 : 0),
              onChanged: (value) => setState(() => _country = value),
              title: 'country'.tr,
              items: authController.area.map((e) => CustomSelectItem(value: e.id, name: e.title ?? '')).toList()),
            const SizedBox(height: 24),
            CustomButton(text: ar ? 'إنشاء حساب' : 'Create account', onPressed: () {
              if (!_formKey.currentState!.validate() || authController.area.isEmpty) return;
              context.read<AuthController>().updateUserInfo(
                name: _nameEc.text, email: _emailEc.text,
                id: _country ?? authController.area.first.id ?? 0,
                onSuccess: () => NamedNavigatorImpl.push(ShareLocationScreen.routeName),
                onHaveIdANDToken: (id, token) {
                  context.read<PusherController>().initPusher(
                    channelName: 'private-user.$id', userId: id, token: token);
                },
              );
            }),
            const SizedBox(height: 16),
            Text(ar ? 'الخطوة التالية: تحديد موقع الخدمة' : 'Next: choose your service location',
              textAlign: TextAlign.center, style: const TextStyle(color: GoDesign.muted, fontSize: 13)),
          ]),
        )),
      );
    }),
  );
}
