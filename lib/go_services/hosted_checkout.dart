import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opening or closing checkout never means a payment succeeded. Callers refresh
/// the authenticated order status returned by the server.
Future<void> openGoCheckout(
  BuildContext context,
  String url, {
  required bool ar,
}) async {
  final uri = Uri.tryParse(url);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host != 'accept.paymob.com' ||
      uri.userInfo.isNotEmpty ||
      !uri.path.startsWith('/unifiedcheckout/')) {
    throw StateError(ar ? 'رابط دفع غير صالح' : 'Invalid checkout URL');
  }
  if (kIsWeb) {
    if (!await launchUrl(uri, webOnlyWindowName: '_blank')) {
      throw StateError(ar ? 'تعذر فتح صفحة الدفع' : 'Could not open checkout');
    }
  } else if (context.mounted) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(ar ? 'الدفع الآمن' : 'Secure checkout')),
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
            ),
            shouldOverrideUrlLoading: (controller, action) async {
              final next = Uri.tryParse('${action.request.url}');
              return next != null && ['https', 'about'].contains(next.scheme)
                  ? NavigationActionPolicy.ALLOW
                  : NavigationActionPolicy.CANCEL;
            },
          ),
        ),
      ),
    );
  }
}
