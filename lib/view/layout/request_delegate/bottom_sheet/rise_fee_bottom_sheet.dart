import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/global_widgets/dark_app_bottom_sheet.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../controller/request_delegate_controller.dart';

class RiseYourFeeBottomSheet extends StatefulWidget {
  const RiseYourFeeBottomSheet({
    super.key,
    required this.requestDelegateController,
    required this.kmPrice,
    required this.shippingPercentage,
    required this.distance,
  });
  final RequestDelegateController requestDelegateController;
  final num kmPrice;
  final num shippingPercentage;
  final num distance;

  @override
  State<RiseYourFeeBottomSheet> createState() => _RiseYourFeeBottomSheetState();
}

class _RiseYourFeeBottomSheetState extends State<RiseYourFeeBottomSheet> with ValidationMixin {
  final TextEditingController _feeEC = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _feeEC.text = widget.requestDelegateController.priceEC.text;

    //  Provider.of<RequestDelegateController>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RequestDelegateController>();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final requestDelegateController = widget.requestDelegateController;

    return Form(
      key: _formKey,
      child: DarkAppBottomSheet(
        isDark: true,
        title: 'searchingAboutDelegate'.tr,
        showBorder: true,
        children: [
          Center(child: Text('providePrice'.tr, style: AppTextStyle.text14MW())),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    int currentValue = int.parse(_feeEC.text);
                    currentValue += 1;
                    _feeEC.text = currentValue.toString();
                  });
                },
                child: Card(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  color: AppColors.mainAppColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text('1+', style: AppTextStyle.text14MW().copyWith(fontSize: 25)),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    20.sbH,
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: CustomFormField(
                        controller: _feeEC,
                        hintText: 'egyptianPound'.tr,
                        formFieldBorder: FormFieldBorder.underLine,
                        textStyle: AppTextStyle.text14MW(),
                        keyboardType: TextInputType.number,
                        unFocusColor: Colors.transparent,
                        focusNode: focusNode,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        // onFieldSubmitted: (p0) {
                        //   focusNode.unfocus();

                        //   WidgetsBinding.instance.addPostFrameCallback((_) {
                        //     if (mounted) {
                        //       widget.requestDelegateController.setPriceEC(p0);
                        //       widget.requestDelegateController.setActualPrice(p0);
                        //       log(widget.requestDelegateController.priceEC.text);
                        //       log(p0);
                        //     }
                        //   });
                        // },
                        validator: (v) => validateFee(
                          value: _feeEC.text,
                          distance: widget.distance,
                          // num.parse(requestDelegateController.distance.toString()),
                          percentage: widget.shippingPercentage,
                          kmPrice: widget.kmPrice,
                        ),
                        suffixIcon: Text(
                          'egyptianPound'.tr,
                          style: AppTextStyle.text14MW().copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    int currentValue = int.parse(_feeEC.text);
                    currentValue -= 1;
                    _feeEC.text = currentValue.toString();
                  });
                },
                child: Card(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  color: AppColors.mainAppColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text('1-', style: AppTextStyle.text14MW().copyWith(fontSize: 25)),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: 15.sbH,
          ),
          CustomButton(
            text: 'riseUpFee'.tr,
            onPressed: () {
              // if (widget.requestDelegateController.priceEC.text.isNotEmpty &&
              //     widget.requestDelegateController.priceEC.text.trim() != '') {
              //   // requestDelegateController.dispose();
              //   NavigatorMethods.pop(context);
              // }

              if (_formKey.currentState!.validate()) {
                widget.requestDelegateController.setPriceEC(_feeEC.text);
                widget.requestDelegateController.setActualPrice(_feeEC.text);
                NamedNavigatorImpl.pop();
              }
            },
          ),
          15.sbH,
        ],
      ),
    );
  }
}
