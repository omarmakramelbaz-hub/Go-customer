import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_drive_customer/go_stores/store_browse_view.dart';

void main() {
  const fixture = String.fromEnvironment('GO_STORE_IMAGE_TEST_URL');
  testWidgets('store image loads from a different origin without CORS headers', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GestureDetector(
              onTap: () => tapped = true,
              child: const StoreImage(imageUrl: fixture, height: 180, width: 240),
            ),
          ),
        ),
      ),
    );

    // The fixture server has no Access-Control-Allow-Origin header. Canvas
    // loading must fail, and the real browser must load the HTML image instead.
    for (var attempt = 0; attempt < 50 && find.byType(HtmlElementView).evaluate().isEmpty; attempt++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
    }
    expect(find.byType(HtmlElementView), findsOneWidget);
    expect(find.byIcon(Icons.storefront_rounded), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(StoreImage));
    expect(tapped, isTrue);
  }, skip: !kIsWeb || fixture.isEmpty);
}
