import '../../../custom_widgets/popups/go_popups.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../controller/wallet_controller.dart';
import '../widget/recent_transactions_widget.dart';

class WalletHistoryBottomSheet extends StatelessWidget {
  const WalletHistoryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ar = context.languageCode == 'ar';
    return DraggableScrollableSheet(
      initialChildSize: .72,
      minChildSize: .4,
      maxChildSize: .92,
      expand: false,
      builder: (context, scroll) => Material(
        color: GoDesign.paper,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: GoPopupHeader(title: ar ? 'العمليات' : 'Transactions', icon: Icons.receipt_long_outlined, onClose: () => Navigator.pop(context)),
              ),
              Expanded(
                child: Consumer<WalletController>(
                  builder: (context, wallet, _) => RefreshIndicator(
                    onRefresh: wallet.getWallet,
                    child: ListView(
                      controller: scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      children: [
                        ApiResponseWidget(
                          apiResponse: wallet.walletResponse,
                          onReload: wallet.getWallet,
                          isEmpty: wallet.wallet?.wallet?.isEmpty ?? true,
                          child: RecentTransactionsWidget(
                            wallet: wallet.wallet?.wallet,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
