/// Navigation boundary for the standalone customer app.
/// Shared controllers can keep their existing route names, while restaurant
/// links and notifications can never open the restaurant storefront here.
class GoDriveRoutePolicy {
  static const home = 'BottomNavigationBarScreen';
  static const login = 'LoginScreen';
  static const publicRoutes = {
    'SplashScreen',
    home,
    login,
    'RegisterScreen',
    'VerificationCodeScreen',
    'SocialAuthPhoneScreen',
    'CreateNewAccountScreen',
    'CheckMobileHasAccount',
    'ChangePasswordCheckCodeScreen',
    'ResetPasswordScreen',
    'ContactUsScreen',
    'TermsAndConditionsScreen',
    'PrivacyPolicyScreen',
    'HelpScreen',
  };
  static const privateRoutes = {
    'RequestDelegateScreen',
    'ChooseDeliveryDelegateScreen',
    'DelegateOrdersScreen',
    'TrackingDelegateOrderScreen',
    'SelectLocationFromMapScreen',
    'SearchPlaceScreen',
    'ShowDelegateOnMapScreen',
    'WalletScreen',
    'AddressScreen',
    'AddAddressScreen',
    'UpdateAddressScreen',
    'MapScreen',
    'ShareLocationScreen',
    'PersonalInformationScreen',
    'AccountInformationScreen',
    'ChatScreen',
    'AdminChatScreen',
    'CustomPaymentWebViewScreen',
    'ZoomImageScreen',
  };

  static String resolve(String? requested, {required bool signedIn}) {
    if (requested == 'OnBoardingScreen') return login;
    if (publicRoutes.contains(requested)) return requested!;
    if (privateRoutes.contains(requested)) return signedIn ? requested! : login;
    return home;
  }
}
