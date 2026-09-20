import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../view/layout/auth/screen/login_screen.dart';
import '../hive/hive_methods.dart';
import '../routes/app_routers_import.dart';
import '../translation/all_translation.dart';
import '../utils/common_methods.dart';

enum ResponseState {
  sleep,
  offline,
  loading,
  pagination,
  complete,
  error,
  unauthorized,
}

class ApiResponse {
  ResponseState state;

  dynamic data;

  ApiResponse({required this.state, required this.data});
}

class ApiHelper {
  static ApiHelper? _instance;

  ApiHelper._();

  static ApiHelper get instance {
    _instance ??= ApiHelper._();

    return _instance!;
  }

  final Dio _dio = Dio()
    ..interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
        filter: (options, args) {
          if (options.path.contains('/posts')) return false;
          return !args.isResponse || !args.hasUint8ListData;
        },
      ),
    );

  Options _options(Map<String, String>? headers, bool hasToken) {
    return Options(
      contentType: 'application/json',
      followRedirects: false,
      validateStatus: (status) => true,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Lang': HiveMethods.getLang(),
        'X-App-Scope': 'go',
        if (HiveMethods.getToken() != null && hasToken) ...{
          'Authorization': 'Bearer ${HiveMethods.getToken()}',
        },
        ...?headers,
      },
    );
  }

  Map<String, String> _offlineMessage() {
    return {'message': 'Make sure you are connected to the internet'.tr};
  }

  Map<String, String> _errorMessage() {
    return {'message': 'An error occurred'.tr};
  }

  Future<ApiResponse> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    void Function()? onFinish,
    void Function(int, int)? onReceiveProgress,
    bool hasToken = true,
  }) async {
    ApiResponse responseJson;
    if (await CommonMethods.hasConnection() == false) {
      responseJson = ApiResponse(
        state: ResponseState.offline,
        data: _offlineMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
      return responseJson;
    }

    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: _options(headers, hasToken),
        onReceiveProgress: onReceiveProgress,
      );
      responseJson = _buildResponse(response);
      Future.delayed(Duration.zero, onFinish);
    } on DioException {
      responseJson = ApiResponse(
        state: ResponseState.error,
        data: _errorMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
    } on SocketException {
      responseJson = ApiResponse(
        state: ResponseState.offline,
        data: _offlineMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
      return responseJson;
    }
    return responseJson;
  }

  Future<ApiResponse> post(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Map<String, String>? headers,
    void Function()? onFinish,
    void Function(int, int)? onReceiveProgress,
    void Function(int, int)? onSendProgress,
    bool hasToken = true,
  }) async {
    ApiResponse responseJson;

    if (await CommonMethods.hasConnection() == false) {
      responseJson = ApiResponse(
        state: ResponseState.offline,
        data: _offlineMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
      return responseJson;
    }
    try {
      final response = await _dio.post(
        url,
        queryParameters: queryParameters,
        data: body,
        options: _options(headers, hasToken),
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
      );
      responseJson = _buildResponse(response);
      Future.delayed(Duration.zero, onFinish);
    } on DioException {
      responseJson = ApiResponse(
        state: ResponseState.error,
        data: _errorMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
      return responseJson;
    } on SocketException {
      responseJson = ApiResponse(
        state: ResponseState.offline,
        data: _offlineMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
      return responseJson;
    }
    return responseJson;
  }

  Future<ApiResponse> put(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Map<String, String>? headers,
    void Function()? onFinish,
    void Function(int, int)? onReceiveProgress,
    void Function(int, int)? onSendProgress,
    bool hasToken = true,
  }) async {
    ApiResponse responseJson;

    if (await CommonMethods.hasConnection() == false) {
      responseJson = ApiResponse(
        state: ResponseState.offline,
        data: _offlineMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
      return responseJson;
    }
    try {
      final response = await _dio.put(
        url,
        queryParameters: queryParameters,
        data: body,
        options: _options(headers, hasToken),
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
      );
      responseJson = _buildResponse(response);
      Future.delayed(Duration.zero, onFinish);
    } on DioException {
      responseJson = ApiResponse(
        state: ResponseState.error,
        data: _errorMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
    } on SocketException {
      responseJson = ApiResponse(
        state: ResponseState.offline,
        data: _offlineMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
      return responseJson;
    }
    return responseJson;
  }

  Future<ApiResponse> patch(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Map<String, String>? headers,
    void Function()? onFinish,
    void Function(int, int)? onReceiveProgress,
    void Function(int, int)? onSendProgress,
    bool hasToken = true,
  }) async {
    ApiResponse responseJson;

    if (await CommonMethods.hasConnection() == false) {
      responseJson = ApiResponse(
        state: ResponseState.offline,
        data: _offlineMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
      return responseJson;
    }
    try {
      final response = await _dio.patch(
        url,
        queryParameters: queryParameters,
        data: body,
        options: _options(headers, hasToken),
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
      );
      responseJson = _buildResponse(response);
      Future.delayed(Duration.zero, onFinish);
    } on DioException {
      responseJson = ApiResponse(
        state: ResponseState.error,
        data: _errorMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
    } on SocketException {
      responseJson = ApiResponse(
        state: ResponseState.offline,
        data: _offlineMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
      return responseJson;
    }
    return responseJson;
  }

  Future<ApiResponse> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Map<String, String>? headers,
    void Function()? onFinish,
    bool hasToken = true,
  }) async {
    ApiResponse responseJson;

    if (await CommonMethods.hasConnection() == false) {
      responseJson = ApiResponse(
        state: ResponseState.offline,
        data: _offlineMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
      return responseJson;
    }
    try {
      final response = await _dio.delete(
        url,
        queryParameters: queryParameters,
        data: body,
        options: _options(headers, hasToken),
      );
      responseJson = _buildResponse(response);
      Future.delayed(Duration.zero, onFinish);
    } on DioException {
      responseJson = ApiResponse(
        state: ResponseState.error,
        data: _errorMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
    } on SocketException {
      responseJson = ApiResponse(
        state: ResponseState.offline,
        data: _offlineMessage(),
      );
      Future.delayed(Duration.zero, onFinish);
      return responseJson;
    }
    return responseJson;
  }

  ApiResponse _buildResponse(Response<dynamic> response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = response.data;
        return ApiResponse(state: ResponseState.complete, data: responseJson);
      case 201:
        var responseJson = response.data;
        return ApiResponse(state: ResponseState.complete, data: responseJson);
      case 400:
        var responseJson = response.data;
        return ApiResponse(state: ResponseState.error, data: responseJson);
      case 401:
        var responseJson = response.data;
        Future.delayed(Duration.zero, () {
          if (HiveMethods.isVisitor() == false) {
            NamedNavigatorImpl.push(LoginScreen.routeName, clean: true);
          }
        });
        return ApiResponse(
          state: ResponseState.unauthorized,
          data: responseJson,
        );
      case 422:
        var responseJson = response.data;
        return ApiResponse(state: ResponseState.error, data: responseJson);
      case 403:
        var responseJson = response.data;
        return ApiResponse(state: ResponseState.error, data: responseJson);
      case 500:
      default:
        var responseJson = response.data;
        return ApiResponse(state: ResponseState.error, data: responseJson);
    }
  }

  // FCM sends require a server credential and belong in the backend.
  // Chat messages are still persisted by the existing chat controllers.
  Future<void> sendNotification({
    String? titleName,
    String? body,
    String? deviceToken,
    Map<String, dynamic>? data,
  }) async {
    log(
      'Direct client push is disabled; delivery must be handled by the server.',
    );
  }
}
