# GO service marketplace client

Feature branch integration for F-Backend PR #8. No deployment, payment credential change, gateway activation or live financial operation is performed by this change.

The existing profession route now probes `/go-services/capabilities`. An old-backend 404 or missing schema retains the original direct-choice screen byte-for-byte in `legacy_profession_partners_screen.dart`. Network/auth/server errors are visible, not treated as an empty result. When the schema exists but creation is disabled, existing jobs remain accessible. The Orders route retains delivery history and adds service job access after restarting the app.

Customers pin the actual work location (not necessarily the device location), describe work, attach up to five photos, optionally schedule it, review quotes, select an advertised payment method, and explicitly accept/reject. Creation retries preserve the same key and payload within the form; after closing an uncertain submission, check My jobs before creating another. Pending form recovery across process termination is not yet implemented.

No client computes or transfers the final commission. The backend remains authoritative for eligibility, exclusivity, payment capture, commission, refunds and settlement. Native checkout uses a WebView; web checkout opens a browser tab. Redirects never mark jobs paid. Payment methods remain hidden unless advertised by the backend. Cash completion requires explicit confirmation of cash payment. Disputes/refund-pending states are surfaced for support, not automatically resolved.

Foreground lists refresh every 15 seconds and job details every 10 seconds, pause for app lifecycle changes, and reload after actions. This is polling, not a claim of new push/deep-link integration. Existing backend push still requires device navigation testing. Signed photo URLs refresh with job reads.

CI: isolated transport/contract, exact-decimal and widget tests plus Flutter analysis and a web compilation. CI does not call live service APIs or gateways. Before rollout, run staging tests with real customer/partner accounts, old-backend fallback, real map keys, simultaneous acceptance, insufficient balances, cancellation and electronic payment confirmation/refunds. Existing backend service enablement remains OFF until explicitly enabled by the operator.
