import 'package:dio/dio.dart';
import '../helpers/hive/hive_methods.dart';
import '../helpers/networking/urls.dart';
import '../go_services/service_api.dart';

class StoreOrderApi {
  StoreOrderApi({Dio? dio, String? baseUrl, String? Function()? token})
      : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 40))),
        _base = (baseUrl ?? Urls.baseUrl).replaceAll(RegExp(r'/+$'), ''), _token = token ?? HiveMethods.getToken;
  final Dio _dio;
  final String _base;
  final String? Function() _token;
  Future<Map<String, dynamic>> request(String path, {Map<String, dynamic>? body, Map<String, dynamic>? query}) async {
    final token = _token();
    if (token == null || token.isEmpty) throw const ServiceFailure('سجل الدخول للمتابعة / Please sign in.', 401);
    try {
      final response = await _dio.request<dynamic>('$_base/go-stores/$path', data: body, queryParameters: query,
        options: Options(method: body == null ? 'GET' : 'POST', followRedirects: false, validateStatus: (_) => true,
          headers: {'Accept': 'application/json', 'X-App-Scope': 'go', 'Authorization': 'Bearer $token'}));
      final raw = response.data;
      if (response.statusCode != 200 || raw is! Map || raw['status'] != 'Success' || raw['data'] is! Map) {
        throw ServiceFailure(raw is Map ? raw['message']?.toString() ?? 'تعذر تنفيذ الطلب / Could not complete request.' : 'تعذر الاتصال / Connection failed.', response.statusCode);
      }
      return Map<String, dynamic>.from(raw['data']);
    } on DioException {
      throw const ServiceFailure('تعذر تأكيد الاتصال. أعد المحاولة لمتابعة نفس الطلب / Connection interrupted. Retry to recover the same order.');
    }
  }
  Future<Map<String, dynamic>> quote(Map<String, dynamic> body) => request('quote', body: body);
  Future<Map<String, dynamic>> submit(Map<String, dynamic> body) => request('orders', body: body);
  Future<Map<String, dynamic>> orders({bool history = false, int page = 1}) => request('orders', query: {'history': history ? 1 : 0, 'page': page});
  Future<Map<String, dynamic>> order(int id) => request('orders/$id');
  Future<Map<String, dynamic>> action(int id, String action, int revision) => request('orders/$id/action', body: {'action': action, 'revision': revision});
  Future<Map<String, dynamic>> checkout(int id) => request('orders/$id/checkout', body: {});
  void close() => _dio.close();
}
