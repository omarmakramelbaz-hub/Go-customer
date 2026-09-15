import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/global_widgets/dark_app_bottom_sheet.dart';
import '../controller/request_delegate_controller.dart';

class RDDetailsBottomSheet extends StatefulWidget {
  const RDDetailsBottomSheet({super.key, required this.requestDelegateController});
  final RequestDelegateController requestDelegateController;

  @override
  State<RDDetailsBottomSheet> createState() => _RDDetailsBottomSheetState();
}

class _RDDetailsBottomSheetState extends State<RDDetailsBottomSheet> {
  final FocusNode focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: DarkAppBottomSheet(
          title: 'packageDescription'.tr,
          isDark: true,
          showBorder: true,
          children: [
            15.sbH,
            CustomFormField(
              controller: widget.requestDelegateController.descriptionEC,
              hintText: 'packageDescription'.tr,
              maxLines: 7,
              minLines: 5,
              radius: 15,
              fillColor: AppColors.lightDarkColor,
              unFocusColor: AppColors.lightDarkColor,
              textStyle: AppTextStyle.text14MW(),
              validator: (p0) {
                if (p0 == null || p0.isEmpty) {
                  return 'validateEmpty'.tr;
                } else if (p0.length < 3) {
                  return 'validateDisc'.tr;
                }
                return null;
              },
              onFieldSubmitted: (p0) {
                focusNode.unfocus();
              },
            ),
            15.sbH,
            CustomButton(
              text: 'save'.tr,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.requestDelegateController.setDescriptionEC(
                    widget.requestDelegateController.descriptionEC.text,
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
