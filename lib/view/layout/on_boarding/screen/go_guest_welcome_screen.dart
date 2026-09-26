import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/go_master_ui.dart';

/// Guest entry is presentation only. The caller retains the existing session
/// cleanup, registration and browsing actions.
class GoGuestWelcomeScreen extends StatelessWidget {
  const GoGuestWelcomeScreen({super.key, required this.isArabic,
    required this.onContinue, required this.onLogin, required this.onRegister});
  final bool isArabic;
  final VoidCallback onContinue;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GoDesign.paper,
    appBar: AppBar(backgroundColor: GoDesign.paper, foregroundColor: GoDesign.ink,
      elevation: 0, title: const SizedBox.shrink()),
    body: SafeArea(child: LayoutBuilder(builder: (context, constraints) =>
      SingleChildScrollView(child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(child: Padding(padding: const EdgeInsets.all(24),
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SvgPicture.asset('assets/svg/go_guest_illustration.svg',
                width: 235, height: 196, excludeFromSemantics: true),
              const SizedBox(height: 22),
              Text(isArabic ? 'استكشف خدماتنا' : 'Explore our services',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: GoDesign.ink)),
              const SizedBox(height: 12),
              Text(isArabic ? 'تصفح خدماتنا كزائر، وسجّل دخولك عندما تكون مستعدًا لطلب الخدمة.'
                : 'Browse as a guest and sign in when you are ready to book a service.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: GoDesign.muted, fontSize: 15, height: 1.6)),
              const SizedBox(height: 28),
              CustomButton(text: isArabic ? 'متابعة كزائر' : 'Continue as guest', onPressed: onContinue),
              const SizedBox(height: 18),
              GoOrDivider(isArabic: isArabic),
              const SizedBox(height: 8),
              Wrap(alignment: WrapAlignment.center, children: [
                TextButton(onPressed: onLogin, child: Text(isArabic ? 'تسجيل الدخول' : 'Sign in')),
                TextButton(onPressed: onRegister, child: Text(isArabic ? 'إنشاء حساب' : 'Create account')),
              ]),
            ]),
          ),
        )),
      )),
    )),
  );
}
