import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../model/wallet_model.dart';
import '../model/wallet_transfer.dart';
import '../../../../helpers/translation/all_translation.dart';

class WalletController extends ChangeNotifier {
  WalletController({
    Future<ApiResponse> Function()? fetchWallet,
    String? Function()? sessionToken,
    this.requestTimeout = const Duration(seconds: 25),
  }) : _fetchWallet =
           fetchWallet ?? (() => ApiHelper.instance.get(Urls.wallet)),
       _sessionToken =
           sessionToken ??
           (() => HiveMethods.isGuestMode() ? null : HiveMethods.getToken());

  final Future<ApiResponse> Function() _fetchWallet;
  final String? Function() _sessionToken;
  final Duration requestTimeout;
  final chargeWalletFormKey = GlobalKey<FormState>();
  final chargeAmountEc = TextEditingController();
  final chargeAmountFocusNode = FocusNode();
  bool _disposed = false;
  int _loadVersion = 0;
  String? _requestSession;
  String? _walletSession;

  String? get _token {
    final token = _sessionToken();
    return token == null || token.isEmpty ? null : token;
  }

  void updateWallet({required WalletModel transaction}) => getWallet();

  void initialWallet() {
    _loadVersion++;
    _requestSession = null;
    _walletSession = null;
    _walletResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _wallet = null;
    if (!_disposed) notifyListeners();
  }

  ApiResponse _walletResponse = ApiResponse(
    state: ResponseState.sleep,
    data: null,
  );
  ApiResponse get walletResponse => _token == _requestSession
      ? _walletResponse
      : ApiResponse(state: ResponseState.sleep, data: null);
  WalletResponse? _wallet;
  WalletResponse? get wallet =>
      _token != null && _token == _walletSession ? _wallet : null;

  Future<void> getWallet() async {
    if (_disposed) return;
    final token = _token;
    if (token == null) {
      initialWallet();
      return;
    }
    if (_requestSession == token &&
        _walletResponse.state == ResponseState.loading)
      return;
    final version = ++_loadVersion;
    _requestSession = token;
    if (_walletSession != token) _wallet = null;
    _walletResponse = ApiResponse(state: ResponseState.loading, data: null);
    notifyListeners();
    try {
      final response = await _fetchWallet().timeout(requestTimeout);
      if (_disposed || version != _loadVersion || _token != token) return;
      if (response.state == ResponseState.complete) {
        final raw = response.data;
        if (raw is! Map || raw['data'] is! Map || raw['status'] == 'Error') {
          throw const FormatException('Invalid wallet response');
        }
        final parsed = WalletResponse.fromJson(
          Map<String, dynamic>.from(raw['data']),
        );
        if (parsed.balance == null || !parsed.balance!.isFinite) {
          throw const FormatException('Missing wallet balance');
        }
        _wallet = parsed;
        _walletSession = token;
      }
      _walletResponse = response;
    } catch (_) {
      if (!_disposed && version == _loadVersion && _token == token) {
        _walletResponse = ApiResponse(state: ResponseState.error, data: null);
      }
    } finally {
      if (!_disposed && version == _loadVersion) {
        // A response started by another account must never leave loading active.
        if (_token != token) {
          initialWallet();
        } else {
          notifyListeners();
        }
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _loadVersion++;
    chargeAmountEc.dispose();
    chargeAmountFocusNode.dispose();
    super.dispose();
  }

  String? _selectedPayment;
  String? get selectedPayment => _selectedPayment;
  void setSelectedPayment(String value) {
    _selectedPayment = value;
    notifyListeners();
  }

  //=============>  charging wallet  <================
  Future<void> chargingWallet({
    required dynamic amount,
    required Function(String link) onSuccess,
  }) async {
    Utils.loading();
    FormData body = FormData.fromMap({
      'amount': amount,
      'payment_method': _selectedPayment,
    });
    final response = await ApiHelper.instance.post(
      Urls.chargingWallet,
      body: body,
    );
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      // CommonMethods.showToast(message: response.data['message']);
      onSuccess.call(response.data['data']['link']);
    } else {
      CommonMethods.showError(
        message: response.data['message'],
        apiResponse: response,
      );
    }
  }

  Future<WalletTransferPreview?> checkMonyTransfer({
    required String mobile,
    required num amount,
    required TransferWallet wallet,
  }) async {
    final response = await ApiHelper.instance.post(
      Urls.checkMonyTransfer,
      body: FormData.fromMap({
        'mobile': mobile,
        'amount': amount,
        'target_wallet': wallet.value,
      }),
    );
    if (response.state == ResponseState.complete) {
      try {
        return WalletTransferPreview.fromJson(
          Map<String, dynamic>.from(response.data['data']),
          wallet: wallet,
          mobile: mobile,
          amount: amount,
        );
      } catch (_) {
        CommonMethods.showError(message: 'walletTransferUnavailable'.tr);
        return null;
      }
    }
    CommonMethods.showError(
      message: response.data is Map && response.data['message'] is String
          ? response.data['message'] as String
          : 'walletTransferFailed'.tr,
      apiResponse: response,
    );
    return null;
  }

  // null means an uncertain network result: retain the confirmation for a safe retry.
  Future<bool?> chargingMonyTransfer(WalletTransferPreview preview) async {
    final response = await ApiHelper.instance.post(
      Urls.transferWallet,
      body: FormData.fromMap(preview.payload),
    );
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
      return true;
    }
    CommonMethods.showError(
      message: response.data is Map && response.data['message'] is String
          ? response.data['message'] as String
          : 'walletTransferFailed'.tr,
      apiResponse: response,
    );
    return response.data is Map && response.data['transfer_rejected'] == true
        ? false
        : null;
  }
}
