import 'dart:io';

import '../lib/helpers/routes/go_drive_route_policy.dart';

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

void main() {
  for (final route in [
    'RestaurantDetailsScreen',
    'CartScreen',
    'TrackingYourOrderScreen',
    'FavoriteScreen',
    '/unknown',
  ]) {
    for (final signedIn in [false, true]) {
      check(
        GoDriveRoutePolicy.resolve(route, signedIn: signedIn) ==
            GoDriveRoutePolicy.home,
        'Restaurant and unknown routes must stay inside Go Drive: $route',
      );
    }
  }
  for (final route in [
    'RequestDelegateScreen',
    'DelegateOrdersScreen',
    'TrackingDelegateOrderScreen',
    'WalletScreen',
    'AddressScreen',
    'ChatScreen',
  ]) {
    check(
      GoDriveRoutePolicy.resolve(route, signedIn: false) ==
          GoDriveRoutePolicy.login,
      'Guest must sign in before opening $route',
    );
    check(
      GoDriveRoutePolicy.resolve(route, signedIn: true) == route,
      'Signed-in customers must reach $route',
    );
  }
  for (final route in [
    'LoginScreen',
    'RegisterScreen',
    'VerificationCodeScreen',
    'CreateNewAccountScreen',
    'ResetPasswordScreen',
  ]) {
    check(
      GoDriveRoutePolicy.resolve(route, signedIn: false) == route,
      'Account creation/recovery must remain reachable: $route',
    );
  }
  for (final directory in ['lib', 'assets', 'web']) {
    for (final file in Directory(
      directory,
    ).listSync(recursive: true).whereType<File>()) {
      if (!RegExp(r'\.(dart|json|html|yaml)$').hasMatch(file.path)) continue;
      check(
        !file.readAsStringSync().contains('-----BEGIN PRIVATE KEY-----'),
        'Server credential must not ship in ${file.path}',
      );
    }
  }
  stdout.writeln('Go Drive navigation and client credential checks passed.');
}
