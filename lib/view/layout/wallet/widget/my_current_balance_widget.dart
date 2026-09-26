import 'package:flutter/material.dart';

import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/custom_loading/custom_shimmer.dart';
import '../model/wallet_model.dart';

class MyCurrentBalanceWidget extends StatefulWidget {
  final WalletResponse? wallet;
  final String? pusherWalletAmount;
  const MyCurrentBalanceWidget({super.key, required this.wallet, this.pusherWalletAmount});
  @override
  State<MyCurrentBalanceWidget> createState() => _MyCurrentBalanceWidgetState();
}

class _MyCurrentBalanceWidgetState extends State<MyCurrentBalanceWidget> {
  bool _visible = true;
  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    final balance = widget.pusherWalletAmount ?? widget.wallet?.balance?.toStringAsFixed(2);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: GoDesign.actionGradient,
        borderRadius: BorderRadius.circular(GoDesign.cardRadius)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ar ? 'الرصيد الحالي' : 'Current balance',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (balance == null)
            const CustomShimmer(height: 36, width: 130, radius: 8)
          else
            Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(_visible ? balance : '••••••', textDirection: TextDirection.ltr,
                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
              Text(ar ? 'جنيه' : 'EGP', style: const TextStyle(color: Colors.white, fontSize: 14)),
            ]),
        ])),
        const SizedBox(width: 8),
        Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 42),
          IconButton(
            tooltip: _visible ? (ar ? 'إخفاء الرصيد' : 'Hide balance') : (ar ? 'إظهار الرصيد' : 'Show balance'),
            onPressed: () => setState(() => _visible = !_visible),
            icon: Icon(_visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.white, size: 20)),
        ]),
      ]),
    );
  }
}
