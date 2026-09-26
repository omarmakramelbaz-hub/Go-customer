import 'package:dio/dio.dart';
import '../helpers/hive/hive_methods.dart';
import '../helpers/networking/urls.dart';

/// Isolated transport: no legacy checkout settings or wallet mutations.
/// All prices, eligibility, acceptance and payment status are server-owned.
class ServiceFailure implements Exception {
  const ServiceFailure(this.message, [this.status]);
  final String message;
  final int? status;
  @override
  String toString() => message;
}

class ServiceCapabilities {
  const ServiceCapabilities({required this.ready, required this.enabled, this.methods = const []});
  final bool ready;
  final bool enabled;
  final List<String> methods;
  factory ServiceCapabilities.fromMap(Map<String, dynamic> data) => ServiceCapabilities(
    ready: data['schema_ready'] == true && data['version'] == 1,
    enabled: data['enabled'] == true,
    methods: (data['payment_methods'] as List? ?? const []).whereType<String>().where(paymentLabels.containsKey).toList(),
  );
}

const paymentLabels = <String, List<String>>{
  'cash': ['كاش للصنايعي', 'Cash to professional'],
  'wallet': ['محفظة التطبيق', 'App wallet'],
  'card': ['كارت بنكي', 'Bank card'],
  'mobile_wallet': ['محفظة إلكترونية', 'Mobile wallet'],
  'apple_pay': ['Apple Pay', 'Apple Pay'],
  'google_pay': ['Google Pay', 'Google Pay'],
};
String paymentLabel(String? method, bool ar) => paymentLabels[method]?[ar ? 0 : 1] ?? (ar ? 'غير محدد' : 'Not selected');

class ServiceApi {
  ServiceApi({required this.partner, Dio? dio, String? baseUrl, String? Function()? token})
      : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 30), sendTimeout: const Duration(seconds: 30))),
        _base = (baseUrl ?? Urls.baseUrl).replaceAll(RegExp(r'/+$'), ''),
        _token = token ?? HiveMethods.getToken;
  final bool partner;
  final Dio _dio;
  final String _base;
  final String? Function() _token;

  Future<Map<String, dynamic>> request(String path, {Object? body, Map<String, dynamic>? query, bool public = false}) async {
    final token = _token();
    if (!public && (token == null || token.isEmpty)) throw const ServiceFailure('سجل الدخول للمتابعة / Please sign in.', 401);
    try {
      final response = await _dio.request<dynamic>('$_base/go-services/$path',
        data: body, queryParameters: query,
        options: Options(method: body == null ? 'GET' : 'POST', followRedirects: false,
          validateStatus: (_) => true,
          contentType: body is FormData ? 'multipart/form-data' : 'application/json',
          headers: {'Accept': 'application/json', 'X-App-Scope': partner ? 'go_partner' : 'go',
            if (!public) 'Authorization': 'Bearer $token'}));
      final raw = response.data;
      if (response.statusCode != 200 && response.statusCode != 201) {
        // Never treat network/auth failures as an empty marketplace.
        final message = raw is Map ? raw['message']?.toString() : null;
        throw ServiceFailure(message ?? 'تعذر تنفيذ الطلب / Request failed.', response.statusCode);
      }
      if (raw is! Map || raw['data'] is! Map || raw['status'] != 'Success') {
        throw const ServiceFailure('استجابة غير متوقعة من الخادم / Invalid server response.');
      }
      return Map<String, dynamic>.from(raw['data'] as Map);
    } on DioException {
      throw const ServiceFailure('تعذر الاتصال. راجع حالة الطلب قبل إعادة المحاولة / Connection failed. Check the job before retrying.');
    }
  }

  Future<ServiceCapabilities> capabilities() async {
    try { return ServiceCapabilities.fromMap(await request('capabilities', public: true)); }
    on ServiceFailure catch (error) {
      if (error.status == 404) return const ServiceCapabilities(ready: false, enabled: false);
      rethrow;
    }
  }
  Future<Map<String, dynamic>> jobs({String scope = 'open', int page = 1}) => request('jobs', query: {'scope': scope, 'page': page});
  Future<Map<String, dynamic>> job(int id) => request('jobs/$id');
  Future<Map<String, dynamic>> create(FormData data) => request('jobs', body: data);
  Future<Map<String, dynamic>> quote(int id, Map<String, dynamic> data) => request('jobs/$id/offers', body: data);
  Future<Map<String, dynamic>> accept(int id, int offer, String method) => request('jobs/$id/offers/$offer/accept', body: {'payment_method': method});
  Future<Map<String, dynamic>> reject(int id, int offer) => request('jobs/$id/offers/$offer/reject', body: <String, dynamic>{});
  Future<Map<String, dynamic>> skip(int id) => request('jobs/$id/skip', body: <String, dynamic>{});
  Future<Map<String, dynamic>> status(int id, String state, {String? reason, bool cashPaid = false}) => request('jobs/$id/status', body: {'status': state, if (reason != null) 'reason': reason, 'cash_paid': cashPaid});
  Future<Map<String, dynamic>> checkout(int id) => request('jobs/$id/checkout', body: <String, dynamic>{});
  void close() => _dio.close();
}

List<Map<String, dynamic>> serviceMaps(dynamic data) => data is List
    ? data.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList()
    : <Map<String, dynamic>>[];
int serviceId(dynamic value) => int.tryParse('$value') ?? 0;

/// Decimal strings stay exact; never send binary floating-point prices.
String? normalizeServicePrice(String value) {
  var input = value.trim().replaceAll('٫', '.');
  for (var i = 0; i < 10; i++) { input = input.replaceAll('٠١٢٣٤٥٦٧٨٩'[i], '$i').replaceAll('۰۱۲۳۴۵۶۷۸۹'[i], '$i'); }
  if (!RegExp(r'^\d{1,7}(\.\d{1,2})?$').hasMatch(input)) return null;
  final parts = input.split('.');
  final cents = int.parse(parts[0]) * 100 + int.parse(parts.length == 1 ? '0' : parts[1].padRight(2, '0'));
  if (cents < 100 || cents > 100000000) return null;
  return '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';
}
bool serviceOfferLive(Map<String, dynamic> job, Map<String, dynamic> offer, {DateTime? now}) {
  final time = now ?? DateTime.now();
  final search = DateTime.tryParse('${job['search_until']}');
  final expiry = DateTime.tryParse('${offer['expires_at']}');
  return job['status'] == 'searching' && offer['status'] == 'offered' && search != null && expiry != null && search.isAfter(time) && expiry.isAfter(time);
}
bool serviceCanQuote(Map<String, dynamic> job) => job['status'] == 'searching' && job['recipient_status'] == 'invited' && serviceMaps(job['offers']).isEmpty && (DateTime.tryParse('${job['search_until']}')?.isAfter(DateTime.now()) ?? false);
bool serviceSelected(Map<String, dynamic> job) => serviceMaps(job['offers']).any((offer) => offer['status'] == 'accepted' && serviceId(offer['id']) == serviceId(job['accepted_offer_id']));
String serviceState(String? value, bool ar) {
  const labels = <String, List<String>>{
    'searching': ['جاري استقبال عروض المصنعية', 'Receiving quotations'],
    'booked': ['تم الاتفاق', 'Booked'], 'in_progress': ['جاري التنفيذ', 'In progress'],
    'awaiting_confirmation': ['بانتظار تأكيد العميل للإتمام', 'Awaiting customer completion'],
    'completed': ['مكتمل', 'Completed'], 'cancelled': ['ملغي', 'Cancelled'],
    'expired': ['انتهت الصلاحية', 'Expired'], 'disputed': ['اعتراض قيد المراجعة', 'Dispute under review'],
    'offered': ['عرض متاح', 'Available quote'], 'accepted': ['العرض المختار', 'Selected quote'],
    'rejected': ['مرفوض', 'Rejected'], 'closed': ['مغلق', 'Closed'],
    'unpaid': ['لم يتم تأكيد الدفع', 'Payment not confirmed'], 'held': ['تم تأكيد الدفع وحجز المبلغ', 'Payment verified; funds held'],
    'cash_due': ['كاش عند إتمام العمل', 'Cash due on completion'], 'paid': ['تمت التسوية', 'Settled'],
    'refund_pending': ['استرداد قيد المعالجة', 'Refund pending'], 'refunded': ['تم رد المبلغ', 'Refunded'],
    'review': ['الدفع قيد المراجعة', 'Payment under review'],
  };
  return labels[value]?[ar ? 0 : 1] ?? (ar ? 'حالة قيد التحقق' : 'Status pending verification');
}
