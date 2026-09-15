// import 'package:faskhaninja/helpers/paymob/saved_bank_card.dart';
// import 'package:flutter/material.dart';

// class PaymentScreen extends StatelessWidget {
//   static const routeName = 'PaymentScreen';

//   const PaymentScreen({super.key});
//   void initiatePayment() async {
//     final card = SavedBankCard(
//       token: 'your-card-token',
//       maskedPanNumber: '**** **** **** 1234',
//       cardType: 'Visa', // Example card type
//     );

//     await card.payWithPaymob(
//       savedCard: card,
//       appName: 'YourAppName',
//       buttonBackgroundColor: Colors.blue,
//       buttonTextColor: Colors.white,
//       saveCardDefault: true,
//       showSaveCard: true,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: ElevatedButton(
//         onPressed: initiatePayment,
//         child: Text('Pay with Paymob'),
//       ),
//     );
//   }
// }
