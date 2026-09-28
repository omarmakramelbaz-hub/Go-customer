import '../../../custom_widgets/popups/go_popups.dart';
import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/translation/all_translation.dart';

class ChangeLangBottomSheet extends StatefulWidget {
  const ChangeLangBottomSheet({super.key});

  @override
  State<ChangeLangBottomSheet> createState() =>
      _ChangeLangBottomSheetState();
}

class _ChangeLangBottomSheetState extends State<ChangeLangBottomSheet> {
  bool _isChangingLanguage = false;


  @override
  Widget build(BuildContext context) => GoSheet(title: 'changeLanguage'.tr,
    icon: Icons.language_rounded, busy: _isChangingLanguage,
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      GoPopupChoice(label: 'العربية', subtitle: 'Arabic', selected: context.languageCode == 'ar',
        leading: const Text('AR'), onTap: _isChangingLanguage ? null : () => _selectLanguage('ar')),
      const SizedBox(height: 10),
      GoPopupChoice(label: 'English', subtitle: 'الإنجليزية', selected: context.languageCode == 'en',
        leading: const Text('EN'), onTap: _isChangingLanguage ? null : () => _selectLanguage('en')),
    ]));

  Future<void> _selectLanguage(String language) async {
    if (_isChangingLanguage) return;

    if (context.languageCode == language) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isChangingLanguage = true);
    await changeLanguage(language);

    if (!mounted) return;
    Navigator.pop(context);
  }
}
