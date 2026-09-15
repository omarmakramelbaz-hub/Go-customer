# Go Drive Customer

Standalone Go Drive customer application, separated from Fasakhansta Customer for independent development and deployment.

## Source baseline

The Go Drive customer feature is centered around the delegate-request flow (`lib/view/layout/request_delegate`) and its map/location dependencies. The original feature in `fasakhansta-customer` remains unchanged.

## Standalone app identity

- App name: Go Drive
- Android/iOS application id: `com.fasakhansta.godrive.customer`

## Extraction status

Repository initialized. Next: import the Flutter baseline required by Go Drive, switch the standalone entry point to the Go Drive flow, and configure independent web/mobile deployment.
