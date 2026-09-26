# GO Customer — approved master UI review

Reference: the 15-screen GO Customer flowboard supplied by the owner on 26 September 2026 (orange GO map-pin logo, dark ink headers, white surfaces, Arabic RTL).

Branch: `design/customer-master-ui-20260926`  
Base: `b9b38a4133b3f287263f3b65b4f30ac91c5dca75`  
Review: PR #5. This is an isolated review implementation, not a production deployment.

## Screen mapping

| Reference | Existing implementation / adapter |
| --- | --- |
| Splash | `lib/view/layout/on_boarding/screen/splash_screen.dart`, original logo and `GoSplashBackdrop` |
| Login | `lib/view/layout/auth/screen/login_screen.dart` |
| Registration | `register_screen.dart` and `create_new_account_screen.dart` under auth/screen |
| Home | `lib/view/layout/home/widgets/go_customer_home_view.dart` |
| Side menu | `lib/view/layout/home/screen/go_services_home_screen.dart` |
| Service details | `lib/view/layout/partner_search/screen/go_partner_detail_screen.dart` |
| Confirm service request | `_CreatePartnerRequestSheet` in `profession_partners_screen.dart` |
| Track request | `tracking_delegate_order_screen.dart` and `tracking_delegate_order_widget.dart` under request_delegate |
| Wallet | `lib/view/layout/wallet/screen/wallet_screen.dart` and balance/history widgets |
| My account | `lib/view/layout/my_account/screen/my_account_screen.dart` |
| Search and filters | Home service search and provider name/distance filters in `profession_partners_screen.dart` |
| Notifications | `lib/view/layout/notifications/screen/notifications_screen.dart` and `notification_widget.dart` |
| Chat | `lib/view/layout/chat/screen/chat_screen.dart` and `orders/widgets/messages_widget.dart` |
| Choose location | `lib/view/layout/address/screen/map_screen.dart` |
| Guest entry | `lib/view/layout/on_boarding/screen/go_guest_welcome_screen.dart` |

The orders list, five-tab navigation, shared action buttons, fields, headers, sheets, dialogs and theme were also restyled. Ancillary legacy routes inherit the shared theme, but this does not establish a pixel-perfect audit of every legacy route.

## Shared presentation layer

- `go_design_tokens.dart`: orange, ink, paper, border, spacing, radius and gradients.
- `go_master_ui.dart`: original-logo brand header, auth tabs/body, surfaces, divider and decorative splash.
- Existing original `go_logo.svg` / `go_logo_light.svg` artwork is retained, not regenerated.
- Guest artwork is an embedded crop of the owner's reference, not a new remote image dependency.
- Existing service-photo sprite is reused; the home hero uses an existing service photo rather than a pixel-identical extraction of the reference's hero artwork.

## Existing contracts retained

No backend endpoint, payment provider configuration, credentials, commission rule, server configuration or deployment workflow is changed by this UI work. All 19 profession keys are preserved and enumerated in the regression test.

Authentication retains the existing phone/password and profile-completion stages, token/visitor transitions and realtime initialization. Wallet charge/transfer sheets retain their controllers and settings checks. Service request FormData fields and multipart photo uploads are unchanged. Chat retains the Firestore stream and send arguments. Tracking retains five-second refresh, revised-quote acceptance/decline, cancellation availability, phone and chat actions.

Presentation lifecycle guards and layout handling were improved in touched routes. These changes still require end-to-end verification against a test account; compilation alone cannot prove every live integration.

## Deliberate differences from illustrative data

- Registration remains two-stage because that is the current account API flow.
- The reference's example names, amounts, ratings, appointments and timestamps are not hard-coded into customer data.
- Service price and timing remain subject to agreement with the provider; the request is not silently converted to a fixed-price booking.
- Filters use available provider name/distance fields. Unavailable price/rating rankings are not simulated.
- Wallet actions expose implemented top-up, transfer and history behavior; no dummy withdrawal action is added.
- Chat does not add nonfunctional attachment or calling controls where the existing arguments do not support them.
- Notification read-state is not fabricated; the old inert mark-all-read control is removed.
- The existing orders feed remains the existing backend feed. This UI change does not invent a unified service-order endpoint.

## Validation

The existing PR workflow runs:

```sh
flutter pub get
python3 tool/verify_approved_identity.py
flutter test test/go_customer_identity_test.dart
dart run tool/check_standalone.dart
flutter build web --release --no-web-resources-cdn --base-href /Go-customer/
```

The identity guard checks the original logo raster hash and active home route. Expanded widget tests cover the exact profession keys, reference artwork decoding, Arabic/English home at 320/390/768 logical pixels, enlarged text, service callbacks, auth fields, password visibility, secondary/loading action behavior, contrasting headers, guest entry and status timeline.

Use the latest GitHub Actions run for the actual validation result. A successful earlier commit must not be reported as validation of a later commit.

## Review before merge

1. Inspect the latest build and compare the real routes against the supplied reference, particularly image treatment, spacing, Arabic typography and large text.
2. Exercise existing account creation/login/guest transitions, request submission, quote acceptance/decline, calls/chat and realtime updates using a test account.
3. Verify wallet balance/history and existing charge/transfer flows without initiating an unintended live financial transaction.
4. Check device/browser behavior for maps, keyboard, safe areas and navigation. No iOS/Android device build or store upload is implied by the web workflow.

The PR stays unmerged pending review. The existing workflow deploys Pages only from main; a pull-request build does not update the saved public preview or the production server.
