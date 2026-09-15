// import 'package:flutter/services.dart';
//
// class PaymobHelper {
//   static const MethodChannel _channel = MethodChannel('com.faskhaninja.payment');
//
//   /// Initiates an Apple Pay payment via native Paymob integration.
//   ///
//   /// [paymentKey]: The payment key obtained from Paymob API.
//   /// [amount]: The transaction amount.
//   /// [countryCode]: e.g., 'EG' or 'US'.
//   /// [currencyCode]: e.g., 'EGP' or 'USD'.
//   /// [merchantIdentifier]: Your Apple Pay Merchant ID from Developer Portal (e.g., merchant.com.yourapp).
//   static Future<Map<String, dynamic>?> payWithApplePay({
//     required String paymentKey,
//     required double amount,
//     required String countryCode,
//     required String currencyCode,
//     required String merchantIdentifier,
//   }) async {
//     try {
//       final result = await _channel.invokeMethod(
//         'payWithApplePay',
//         {
//           'paymentKey': paymentKey,
//           'amount': amount,
//           'countryCode': countryCode,
//           'currencyCode': currencyCode,
//           'merchantIdentifier': merchantIdentifier,
//         },
//       );
//       return Map<String, dynamic>.from(result);
//     } on PlatformException catch (e) {
//       throw Exception('Apple Pay failed: ${e.message}');
//     }
//   }
// }
