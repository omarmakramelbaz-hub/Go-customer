# GO Customer legal documents — 26 September 2026

## Requested change
Replace the restaurant-oriented terms and privacy notice shown in the owner's screenshots with documents covering GO Customer courier and professional-service requests.

## Root cause and implementation
`PrivacyPolicyScreen` and `TermsAndConditionsScreen` previously rendered `MyAccountController.setting.privacy` and `.terms` from the shared settings endpoint. They now use versioned customer-only text in `lib/helpers/legal/go_customer_legal.dart`. No shared settings, other applications or backend data is changed.

The documents contain 14 terms sections and 15 privacy sections, each in Arabic and English. Existing route names are preserved so account, drawer and registration links continue to reach the same destinations. Both pages use a dark GO header, selectable text, responsive spacing, a visible update date, links to each other and the existing support route. They do not require authentication or a settings request to render. This change does not add consent gates or record acceptance on behalf of a user.

## Product facts and constraints used
- Courier requests and 19 existing service categories remain unchanged.
- The owner requires mutual customer/partner acceptance before commission is due, a final agreed price and no duplicate commission. Price revisions require fresh agreement.
- Existing customer source uses shared backend account/payment services. The notice does not falsely claim complete backend/account isolation.
- Provider requests submit the description, contact phone, coordinates, address and selected photos. The notice does not falsely promise that no personal details are shared until acceptance.
- Wallet balance/history and payment flows remain supplied by existing controllers. No new withdrawal, refund automation, payment method or refund deadline is represented as implemented.
- Local storage, optional social sign-in, map access, notifications and configured chat are disclosed according to the functions actually used. No end-to-end-encryption, PCI, data-residency or zero-risk claim is made.
- Policies link to the existing support screen rather than inventing an operator email or assigning a personal phone number as a privacy contact.

## Legal reference checks
Consulted on 26 September 2026:

- DLA Piper, Data Protection Laws of the World: Egypt, last modified 13 February 2026. Used as a secondary cross-check for stated purposes, lawful processing, data-subject rights, retention, marketing consent and cross-border constraints. https://www.dlapiperdataprotection.com/index.html?c=EG&t=law
- Egyptian Consumer Protection Agency, official legislation index linking Consumer Protection Law 181/2018. https://cpa.gov.eg/ar-eg/تشريعات
- Egyptian Consumer Protection Agency, official complaint information. https://cpa.gov.eg/ar-eg/كيف-تتقدم-بشكوى

No legal-compliance certification is implied. Public text preserves mandatory consumer/data rights and does not invent article-specific deadlines or claim that required licences or transfer permissions have been obtained.

## Owner / legal review still needed
1. Supply and verify the legal operator name, service address, registration details where applicable and designated privacy contact. These were not established from the supplied screenshots or inspected client source and have not been invented.
2. Confirm server-side retention periods, hosting/processing regions, processor agreements and any required authorisations. Client-source review cannot establish those facts.
3. Verify how account deletion affects shared services, wallet settlement, Firestore records and backups. Policy text is not an implementation of deletion or data export.
4. Align operational cancellation/refund handling with the published terms, actual payment-provider processes and applicable law. No new fee or arbitrary blanket non-refund rule is introduced.
5. Before public store release or reliance as final legal documentation, obtain review from qualified Egyptian counsel and add any missing operator disclosures. Material updates that need notice/consent require an actual notice/consent process; this patch does not silently create one.

## Tests
The existing web workflow retains its permissions, triggers, build and deployment behavior. Only the test command is expanded to run `test/go_customer_legal_test.dart` alongside the identity suite.

Tests cover version and bilingual completeness, removal of restaurant legal copy, mutual-agreement pricing, sharing transparency, stable route names, absence of shared-settings loading, guest/no-provider rendering at 320/390/768 logical pixels, enlarged text, RTL/LTR, footer access and support/cross-link callbacks.

Use the latest Actions result to establish compilation and test status. These tests do not establish server-side or legal compliance.
