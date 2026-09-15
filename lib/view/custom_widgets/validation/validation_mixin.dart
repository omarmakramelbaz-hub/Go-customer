import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import '../../../helpers/translation/all_translation.dart';

mixin ValidationMixin<T extends StatefulWidget> on State<T> {
  String? validateName(String? value) {
    if (value!.trim().isEmpty) {
      return 'validateName'.tr;
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value!.trim().isEmpty) {
      return 'validateEmail'.tr;
    } else if (!_emailValidationStructure(value.trim())) {
      return 'validateEmailStructure'.tr;
    }
    return null;
  }

  bool _emailValidationStructure(String email) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  String? validatePhone(String? value, {Country? country}) {
    if (value == null || value.trim().isEmpty) {
      return 'validatePhone'.tr;
    }

    // Remove leading 0 for length comparison, if it exists
    String trimmedValue = value.trim();
    if (trimmedValue.startsWith('0')) {
      trimmedValue = trimmedValue.substring(1);
    }

    if (country != null && trimmedValue.length != country.example.trim().length) {
      return 'validatePhoneContainTenNumbers'.translate(args: [country.example.trim().length.toString()]);
    }

    return null;
  }

  String? validateVCash(String? value, {Country? country}) {
    if (value!.trim().isEmpty) {
      return 'validatePhone'.tr;
    } else if (value.startsWith('0')) {
      return 'validatePhoneStartWithZero'.tr;
    } else if (!value.startsWith('10')) {
      return 'validateVCash'.tr;
    } else if (country != null && (value.trim().length != country.example.trim().length)) {
      return 'validatePhoneContainTenNumbers'.translate(args: [country.example.trim().length.toString()]);
    } else {
      return null;
    }
  }

  String? validatePassword(String? value) {
    if (value!.trim().length < 6) {
      return 'validatePassword6'.tr;
    }
    return null;
  }

  static String? validateNewPassword(String? value) {
    if (value == null || value.trim().length < 6) {
      return 'validatePassword'.tr;
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().length < 6) {
      return 'validatePassword'.tr;
    } else if (password != value) {
      return 'validateConfirmPassword'.tr;
    }
    return null;
  }

  String? validateEmptyField(String? value) {
    if (value!.trim().isEmpty) {
      return 'validateEmpty'.tr;
    }
    return null;
  }

  String? validateEmptyDropDown(dynamic value) {
    if (value == null) {
      return 'validateEmpty'.tr;
    }
    return null;
  }

  String? validateEmptyMultiSelect(List<dynamic>? value) {
    if (value == null) {
      return 'validateEmpty'.tr;
    } else if (value.isEmpty) {
      return 'validateEmpty'.tr;
    }
    return null;
  }

  String? validateNationalId(String? value) {
    if (value == null) {
      return 'validateEmpty'.tr;
    } else if (value.isEmpty) {
      return 'validateEmpty'.tr;
    } else if (value.length != 14) {
      return 'validateNationalId'.tr;
    }
    return null;
  }

  String? validateDrivingLicense(String? value) {
    if (value == null) {
      return 'validateEmpty'.tr;
    } else if (value.isEmpty) {
      return 'validateEmpty'.tr;
    } else if (value.length != 14) {
      return 'validateDrivingLicense'.tr;
    }
    return null;
  }

  String? validateTaxNumber(String? value) {
    if (value == null) {
      return 'validateEmpty'.tr;
    } else if (value.isEmpty) {
      return 'validateEmpty'.tr;
    } else if (value.length != 14) {
      return 'validateTaxNumber'.tr;
    }
    return null;
  }

  String? validateCommercialRegistrationNumber(String? value) {
    if (value == null) {
      return 'validateEmpty'.tr;
    } else if (value.isEmpty) {
      return 'validateEmpty'.tr;
    } else if (value.length != 14) {
      return 'validateCommercialRegistrationNumber'.tr;
    }
    return null;
  }

  String? validateNameFourthly(String? value) {
    if (value == null || value.isEmpty) {
      return 'validateName'.tr;
    }

    List<String> words = value.trim().split(RegExp(r'\s+'));

    if (words.length != 4) {
      return 'validateNameFourthly'.tr;
    }

    return null;
  }

  String? validateFeeInShowDelegate({
    String? value,
    num kmPrice = 0,
    num percentage = 0,
    num distance = 0,
    num userBalance = 0,
    num actualPrice = 0,
    String? paymentType,
  }) {
    final double minAmount = distance - (distance * (percentage / 100));
    log(minAmount.toString());

    final double? inputValue = double.tryParse(value ?? '0');

    if (inputValue == null) {
      return 'enterAmount'.tr;
    }

    if (inputValue < minAmount) {
      return 'minimumAmountToDeliver'.tr.replaceAll('{}', minAmount.toStringAsFixed(0).toString());
    }
    if (inputValue - actualPrice > userBalance && paymentType == 'wallet') {
      return 'notEnoughBalance'.tr;
    }

    return null;
  }

  String? validateFee({String? value, num kmPrice = 0, num percentage = 0, num distance = 0}) {
    final double minAmount = distance - (distance * (percentage / 100));
    log(minAmount.toString());

    final double? inputValue = double.tryParse(value ?? '0');

    if (inputValue == null) {
      return 'enterAmount'.tr;
    }

    if (inputValue < minAmount) {
      return 'minimumAmountToDeliver'.tr.replaceAll('{}', minAmount.toStringAsFixed(0).toString());
    }

    return null;
  }
}
