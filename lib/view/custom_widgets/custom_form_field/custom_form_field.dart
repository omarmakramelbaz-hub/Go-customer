import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../helpers/extensions/extensions.dart';
import '../../../helpers/theme/app_colors.dart';
import '../../../helpers/theme/app_text_style.dart';
import '../../../helpers/theme/go_design_tokens.dart';
import '../../../helpers/translation/all_translation.dart';

enum FormFieldBorder { underLine, outLine, none }

class CustomFormField extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isPassword;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final void Function()? onTap;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double radius;
  final Color? fillColor;
  final Color? focusColor;
  final Color? unFocusColor;
  final Color? passwordColor;
  final String? title;
  final String? otherSideTitle;
  final TextDirection? textDirection;
  final Country? country;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(Country)? onCountrySelect;
  final Function(String)? onFieldSubmitted;
  final FormFieldBorder formFieldBorder;
  final TextStyle? titleStyle;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final int? maxLength;
  final String? initialValue;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;

  const CustomFormField({
    super.key, this.controller, this.onChanged, this.validator, this.keyboardType,
    this.isPassword = false, this.hintText, this.maxLines = 1, this.minLines = 1,
    this.onTap, this.readOnly = false, this.prefixIcon, this.suffixIcon,
    this.radius = GoDesign.radius, this.fillColor, this.focusColor, this.unFocusColor,
    this.title, this.textDirection, this.otherSideTitle, this.country, this.passwordColor,
    this.formFieldBorder = FormFieldBorder.outLine, this.inputFormatters,
    this.onCountrySelect, this.onFieldSubmitted, this.titleStyle, this.textStyle,
    this.hintStyle, this.maxLength, this.autovalidateMode, this.initialValue, this.focusNode,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    Widget countryCode() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text('${widget.country?.flagEmoji} +${widget.country?.phoneCode}',
        style: widget.textStyle ?? AppTextStyle.textFormStyle,
        textDirection: TextDirection.ltr),
    );
    return SizedBox(
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.title != null || widget.otherSideTitle != null) ...[
          Row(children: [
            if (widget.title != null)
              Expanded(child: Text(widget.title!, style: widget.titleStyle ??
                AppTextStyle.formTitleStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600))),
            if (widget.otherSideTitle != null)
              Text(widget.otherSideTitle!, style: widget.titleStyle ?? AppTextStyle.formTitleStyle),
          ]),
          const SizedBox(height: 8),
        ],
        Directionality(
          textDirection: widget.textDirection ?? (context.isRtl ? TextDirection.rtl : TextDirection.ltr),
          child: TextFormField(
            onFieldSubmitted: widget.onFieldSubmitted,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            controller: widget.controller, onChanged: widget.onChanged,
            validator: widget.validator, onTap: widget.onTap, readOnly: widget.readOnly,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword && _obscureText,
            enableSuggestions: !widget.isPassword,
            autocorrect: !widget.isPassword,
            style: widget.textStyle ?? AppTextStyle.textFormStyle,
            autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            minLines: widget.isPassword ? 1 : widget.minLines,
            cursorColor: widget.focusColor ?? GoDesign.orange,
            inputFormatters: widget.inputFormatters, maxLength: widget.maxLength,
            decoration: InputDecoration(
              hintMaxLines: 2, hintText: widget.hintText,
              hintStyle: widget.hintStyle ?? const TextStyle(color: GoDesign.muted, fontSize: 14),
              fillColor: widget.fillColor ??
                (widget.formFieldBorder == FormFieldBorder.underLine ? Colors.transparent : GoDesign.paper),
              filled: true,
              border: _border(widget.unFocusColor ?? GoDesign.border),
              enabledBorder: _border(widget.unFocusColor ?? GoDesign.border),
              disabledBorder: _border(widget.unFocusColor ?? GoDesign.border),
              focusedBorder: _border(widget.focusColor ?? GoDesign.orange, width: 1.5),
              errorBorder: _border(GoDesign.danger),
              focusedErrorBorder: _border(GoDesign.danger, width: 1.5),
              errorMaxLines: 3,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              prefixIconColor: GoDesign.muted, suffixIconColor: GoDesign.muted,
              prefixIcon: widget.country != null && !ar
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    if (widget.prefixIcon != null) widget.prefixIcon!, countryCode()])
                : widget.prefixIcon,
              suffixIcon: widget.country != null && ar
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    countryCode(), if (widget.suffixIcon != null) widget.suffixIcon!])
                : widget.isPassword
                  ? IconButton(
                      tooltip: _obscureText ? (ar ? 'إظهار كلمة المرور' : 'Show password')
                        : (ar ? 'إخفاء كلمة المرور' : 'Hide password'),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                      icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 21, color: widget.passwordColor ?? AppColors.hintColor))
                  : widget.suffixIcon,
            ),
            initialValue: widget.initialValue,
            // Let TextFormField own its internal focus node when none is supplied.
            focusNode: widget.focusNode,
          ),
        ),
      ]),
    );
  }

  InputBorder _border(Color color, {double width = 1}) {
    switch (widget.formFieldBorder) {
      case FormFieldBorder.outLine:
        return OutlineInputBorder(borderRadius: BorderRadius.circular(widget.radius),
          borderSide: BorderSide(color: color, width: width));
      case FormFieldBorder.underLine:
        return UnderlineInputBorder(borderSide: BorderSide(color: color, width: width));
      case FormFieldBorder.none:
        return InputBorder.none;
    }
  }
}
