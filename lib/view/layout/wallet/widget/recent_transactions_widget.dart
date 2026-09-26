import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/date_methods.dart';
import '../../auth/controller/auth_controller.dart';
import '../model/wallet_model.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<WalletModel>? wallet;
  const RecentTransactionsWidget({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final items = wallet ?? const <WalletModel>[];
    final ar = context.languageCode == 'ar';
    final authId = context.read<AuthController>().profile?.id;
    return Column(children: items.map((transaction) {
      final isFromMe = authId == transaction.fromUser;
      final isCredit = transaction.type == 'charging' || (transaction.toUser == authId && !isFromMe);
      final amount = transaction.amount ?? 0;
      final color = isCredit ? GoDesign.success : GoDesign.orange;
      final icon = transaction.type == 'charging' ? Icons.add_card_outlined
        : transaction.type == 'transfer' ? Icons.swap_horiz_rounded
        : transaction.type == 'shipping' ? Icons.receipt_long_outlined
        : Icons.account_balance_wallet_outlined;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: GoDesign.canvas,
          borderRadius: BorderRadius.circular(GoDesign.radius)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: .1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 21)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(alignment: WrapAlignment.spaceBetween, spacing: 12, runSpacing: 6, children: [
              Text(_label(transaction.type ?? '', ar),
                style: const TextStyle(color: GoDesign.ink, fontSize: 15, fontWeight: FontWeight.w600)),
              Text('${isCredit ? '+' : '-'} ${amount.toStringAsFixed(2)} ${ar ? 'جنيه' : 'EGP'}',
                textDirection: TextDirection.ltr,
                style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
            ]),
            if (transaction.orderNo != null) ...[
              const SizedBox(height: 4),
              Text(transaction.orderNo!, style: const TextStyle(color: GoDesign.muted, fontSize: 12)),
            ],
            if (transaction.fromUserName != null && transaction.toUserName != null) ...[
              const SizedBox(height: 4),
              Text('${isFromMe ? (ar ? 'من محفظتك' : 'Your wallet') : transaction.fromUserName} ← ${transaction.toUser == authId ? (ar ? 'محفظتك' : 'Your wallet') : transaction.toUserName}',
                style: const TextStyle(color: GoDesign.muted, fontSize: 12)),
            ],
            const SizedBox(height: 5),
            Text(DateMethods.formatToDate(transaction.createdAt ?? ''),
              style: const TextStyle(color: GoDesign.muted, fontSize: 12)),
          ])),
        ]),
      );
    }).toList());
  }

  String _label(String type, bool ar) {
    switch (type) {
      case 'transfer': return ar ? 'تحويل أموال' : 'Transfer';
      case 'charging': return ar ? 'شحن رصيد' : 'Top up';
      case 'withdraw': return ar ? 'سحب من المحفظة' : 'Withdrawal';
      case 'shipping': return ar ? 'دفع طلب' : 'Order payment';
      default: return type.isEmpty ? (ar ? 'عملية محفظة' : 'Wallet transaction') : type;
    }
  }

  // Retained for callers that use the original label helper.
  String buildTransaction(String transaction) => _label(transaction, true);
}
