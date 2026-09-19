# Go Drive Customer

Standalone Flutter customer app for courier requests, pickup and drop-off locations, delivery orders, tracking, wallet, and account management. Arabic and English are supported.

This repository shares the existing Fasakhansta customer API and accounts. The Go Drive feature continues to exist in the original Fasakhansta app. This is the customer app, not the courier/Delegate app.

## Run and preview

Use Flutter 3.47.0 (the version pinned in CI):

```sh
flutter pub get
dart run tool/check_standalone.dart
python3 tool/configure_web.py
flutter run -d chrome
```

Pushes to `main` build the web application and upload `go-drive-web` in GitHub Actions. The deploy job publishes the same build through GitHub Pages. Set **Settings → Pages → Source → GitHub Actions** once before the first deployment.

The preview path is `/go-drive-customer/`. Browser assets and the CanvasKit renderer are included in the build. The manifest uses relative URLs so the application stays under its own path.

Optional repository variables:

| Variable | Purpose |
| --- | --- |
| `MAPS_WEB_API_KEY` | A Maps JavaScript key restricted to the preview origin. By default the existing public Maps client key is used. |
| `GOOGLE_WEB_CLIENT_ID` | Enables Google sign-in after the preview origin is authorized and the shared backend accepts its audience. |
| `FACEBOOK_APP_ID` | Enables Facebook sign-in after the preview domain is authorized. |

Phone/password authentication uses the existing API. OAuth buttons stay hidden until configured. The browser does not initialize mobile Firebase notifications; chat currently displays an availability message instead of trying to access an unconfigured Firestore app. Map search/routes also depend on the existing Google service endpoints being usable from the browser. Verify their CORS/key restrictions on the published origin.

## Standalone identities

- Android application ID and namespace: `com.fasakhansta.godrive.customer`
- iOS bundle ID: `com.fasakhansta.godrive.customer`
- iOS extension: `com.fasakhansta.godrive.customer.extension-example`
- iOS App Group: `group.com.fasakhansta.godrive.customer.liveactivities`
- Display name: **Go Drive**

Restaurant storefront, cart, product and restaurant-order routes resolve to Go Drive home. Courier booking, shipping history/tracking, wallet, addresses, account and support stay within this app. Guests can browse the introduction and sign in; protected routes require an account. Deleting an account also affects Fasakhansta because accounts are shared.

## Before a mobile release

1. Register the new Android/iOS identities in the existing Firebase project if retaining shared Firestore chat. Download the matching `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`; do not relabel the old Firebase files. They are ignored in git.
2. Provision Android signing and iOS bundle/extension/App Group profiles for the new identities. Complete the native launcher/splash artwork for Go Drive before store submission.
3. Configure native OAuth and matching URL schemes, then enable the corresponding providers. Apple sign-in additionally uses `--dart-define=ENABLE_APPLE_SIGN_IN=true`.
4. Verify that the backend stores notification tokens per app/device so using Go Drive does not replace the Fasakhansta installation token.
5. Verify an authenticated pickup/drop-off booking, fare, payment, courier assignment, tracking, cancellation and notification flow on a test account/device. No live order or payment is created by CI.

The old baseline contained a Google service-account private key and an unused Pusher server secret in client Dart code. They have been removed from this working tree. Rotate/revoke the exposed credentials in their provider consoles, because earlier history and the original repository still contain them. Direct client FCM sending is disabled; server-side delivery of chat push notifications must be provided before releasing chat push support. Message persistence and inbound notification handling remain separate.

The one-time baseline import workflow has been removed to prevent re-importing the original app over the standalone implementation.
