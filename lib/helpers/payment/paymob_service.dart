// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:dio/dio.dart';
//
// import '../utils/logger.dart';
// import 'payment_constants.dart';
//
// class PaymobService {
//   static final PaymobService _instance = PaymobService._internal();
//
//   factory PaymobService() {
//     return _instance;
//   }
//
//   PaymobService._internal();
//
//   final Dio _dio = Dio();
//   final String _baseUrl = 'https://accept.paymob.com/api';
//
//   Future<String?> _getAuthToken() async {
//     try {
//       final response = await _dio.post(
//         '$_baseUrl/auth/tokens',
//         data: {'api_key': PaymentConstants.paymobApiKey},
//       );
//       return response.data['token'];
//     } catch (e) {
//       log('Paymob Auth Error: $e');
//       return null;
//     }
//   }
//
//   Future<int?> _createOrder({
//     required String authToken,
//     required double amount,
//     List<Map<String, dynamic>>? items,
//   }) async {
//     try {
//       final amountCents = (amount * 100).round();
//
//       final response = await _dio.post(
//         '$_baseUrl/ecommerce/orders',
//         data: {
//           'auth_token': authToken,
//           'delivery_needed': 'false',
//           'amount_cents': amountCents.toString(),
//           'currency': 'EGP',
//           'items': items ?? [],
//         },
//       );
//       return response.data['id'];
//     } catch (e) {
//       log('Paymob Create Order Error: $e');
//       return null;
//     }
//   }
//
//   Future<String?> _getPaymentKey({
//     required String authToken,
//     required int orderId,
//     required double amount,
//     required String integrationId,
//     required Map<String, dynamic> billingData,
//   }) async {
//     try {
//       final amountCents = (amount * 100).round();
//
//       final response = await _dio.post(
//         '$_baseUrl/acceptance/payment_keys',
//         data: {
//           'auth_token': authToken,
//           'amount_cents': amountCents.toString(),
//           'expiration': 3600,
//           'order_id': orderId.toString(),
//           'billing_data': billingData,
//           'currency': 'EGP',
//           'integration_id': integrationId,
//           'lock_order_when_paid': 'false'
//         },
//       );
//       return response.data['token'];
//     } catch (e) {
//       log('Paymob Get Payment Key Error: $e');
//       return null;
//     }
//   }
//
//   Future<Map<String, dynamic>> processApplePay({
//     required double amount,
//     required Map<String, dynamic> applePayResult,
//     required Map<String, dynamic> billingData,
//   }) async {
//     try {
//       final authToken = await _getAuthToken();
//       if (authToken == null) throw Exception('Failed to authenticate with Paymob');
//
//       final orderId = await _createOrder(authToken: authToken, amount: amount);
//       if (orderId == null) throw Exception('Failed to create order');
//
//       final paymentKey = await _getPaymentKey(
//         authToken: authToken,
//         orderId: orderId,
//         amount: amount,
//         integrationId: PaymentConstants.paymobCardIntegrationId,
//         billingData: billingData,
//       );
//
//       if (paymentKey == null) throw Exception('Failed to get payment key');
//
//       String tokenData = applePayResult['token'] ?? '';
//       if (tokenData.isEmpty && applePayResult['paymentData'] != null) {
//         if (applePayResult['paymentData'] is Map) {
//           tokenData = jsonEncode(applePayResult['paymentData']);
//         } else {
//           tokenData = applePayResult['paymentData'].toString();
//         }
//       }
//
//       final payResponse = await _dio.post(
//         '$_baseUrl/acceptance/payments/pay',
//         data: {
//           'source': {'identifier': tokenData, 'subtype': 'APPLE_PAY'},
//           'payment_token': paymentKey
//         },
//       );
//
//       return payResponse.data;
//     } on DioException catch (e) {
//       log('==============> Paymob Process Apple Pay Error');
//       log('Status Code: ${e.response?.statusCode}');
//       log('Data: ${e.response?.data}');
//       PrintLog.e(e);
//       rethrow;
//     } catch (e) {
//       log('==============> Paymob Process Apple Pay Error');
//       PrintLog.e(e);
//       rethrow;
//     }
//   }
// }
