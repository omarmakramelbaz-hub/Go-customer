part of 'app_routers_import.dart';

class NamedNavigatorImpl {
  static GlobalKey<NavigatorState> navigatorState = GlobalKey<NavigatorState>();

  static final BuildContext context = navigatorState.currentContext!;
  static final NavigatorState currentState = navigatorState.currentState!;

  static bool _isGuestProtectedRoute(String screen) {
    return screen == RestaurantDetailsScreen.routeName ||
        screen == RequestDelegateScreen.routeName ||
        screen == PersonalInformationScreen.routeName ||
        screen == WalletScreen.routeName;
  }

  static Future push(String screen, {bool replace = false, bool clean = false, Object? arguments}) {
    log('screen ======> $screen');

    if (GuestAccessGuard.isGuest && _isGuestProtectedRoute(screen)) {
      GuestAccessGuard.showLoginRequired(context);
      return Future.value();
    }

    if (clean) {
      return currentState.pushNamedAndRemoveUntil(screen, (route) => false, arguments: arguments);
    } else if (replace) {
      return currentState.pushReplacementNamed(screen, arguments: arguments);
    } else {
      return currentState.pushNamed(screen, arguments: arguments);
    }
  }

  static void pop() {
    if (Navigator.of(context).canPop()) {
      currentState.pop(context);
    } else {
      push(BottomNavigationBarScreen.routeName, clean: true);
    }
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    dynamic args;
    if (settings.arguments != null) args = settings.arguments;
    switch (settings.name) {
      case ZoomImageScreen.routeName:
        return MaterialPageRoute(builder: (_) => ZoomImageScreen(args: args));
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case BottomNavigationBarScreen.routeName:
        return MaterialPageRoute(builder: (_) => const BottomNavigationBarScreen());
      case OnBoardingScreen.routeName:
        return MaterialPageRoute(builder: (_) => const OnBoardingScreen());
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RegisterScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case VerificationCodeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const VerificationCodeScreen());
      case SocialAuthPhoneScreen.routeName:
        return MaterialPageRoute(builder: (_) => SocialAuthPhoneScreen(socialAuthData: args));
      case CreateNewAccountScreen.routeName:
        return MaterialPageRoute(builder: (_) => const CreateNewAccountScreen());
      case ShareLocationScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ShareLocationScreen());
      case RestaurantsScreen.routeName:
        return MaterialPageRoute(
          builder: (_) =>
              ChangeNotifierProvider(create: (_) => RestaurantsController(), child: const RestaurantsScreen()),
        );
      case RestaurantDetailsScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => RestaurantsController(),
            child: RestaurantDetailsScreen(args: args),
          ),
        );
      case ProductDetailsScreen.routeName:
        return MaterialPageRoute(builder: (_) => ProductDetailsScreen(args: args));
      case AccountInformationScreen.routeName:
        return MaterialPageRoute(builder: (_) => AccountInformationScreen(args: args));
      case PersonalInformationScreen.routeName:
        return MaterialPageRoute(builder: (_) => const PersonalInformationScreen());
      case RequestAgainScreen.routeName:
        return MaterialPageRoute(builder: (_) => RequestAgainScreen(args: args));
      case TrackingYourOrderScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => OrdersController()),
              ChangeNotifierProvider(create: (_) => MyAccountController()),
            ],
            child: TrackingYourOrderScreen(args: args),
          ),
        );
      case ChatScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ChatController(),
            child: ChatScreen(args: args),
          ),
        );
      case ServiceRatingScreen.routeName:
        return MaterialPageRoute(builder: (_) => ServiceRatingScreen(args: args));
      case CartScreen.routeName:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      // case PaymentScreen.routeName:
      //   return MaterialPageRoute(
      //     builder: (_) => const PaymentScreen(),
      //   );
      case FavoriteScreen.routeName:
        return MaterialPageRoute(builder: (_) => const FavoriteScreen());
      case AddressScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AddressScreen());
      case HelpScreen.routeName:
        return MaterialPageRoute(builder: (_) => const HelpScreen());
      case TermsAndConditionsScreen.routeName:
        return MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen());
      case PrivacyPolicyScreen.routeName:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      case ContactUsScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ContactUsScreen());
      // case ConfirmAddressScreen.routeName:
      //   return MaterialPageRoute(builder: (_) => const ConfirmAddressScreen());
      case AddAddressScreen.routeName:
        return MaterialPageRoute(builder: (_) => AddAddressScreen(args: args));
      case UpdateAddressScreen.routeName:
        return MaterialPageRoute(builder: (_) => UpdateAddressScreen(args: args));
      case SearchScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => SearchRestaurantController()
                  ..initialLastSearch()
                  ..getLastSearch(),
              ),
              ChangeNotifierProvider(create: (context) => RestaurantsController()),
            ],
            child: const SearchScreen(),
          ),
        );
      case ChooseAddressFromMapScreen.routeName:
        return MaterialPageRoute(builder: (_) => ChooseAddressFromMapScreen(args: args));
      case AddAddressFromCartScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AddAddressFromCartScreen());
      case ExecuteTheOrderScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => MyAccountController(),
            child: ExecuteTheOrderScreen(args: args),
          ),
        );

      case WalletScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => WalletController()
                  ..initialWallet()
                  ..getWallet(),
              ),
              ChangeNotifierProvider(
                create: (_) => MyAccountController()
                  ..initialSetting()
                  ..getSetting(),
              ),
            ],
            child: const WalletScreen(),
          ),
        );
      case OrderOTPScreen.routeName:
        return MaterialPageRoute(builder: (_) => const OrderOTPScreen());
      case YourOrderSuccessfullyCompletedScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => OrdersController(),
            child: YourOrderSuccessfullyCompletedScreen(args: args),
          ),
        );
      case RegisterAsVendorScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RegisterAsVendorScreen());
      case RegisterAsDeliveryScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RegisterAsDeliveryScreen());
      case ContractDeliveryScreen.routeName:
        return MaterialPageRoute(builder: (_) => ContractDeliveryScreen(args: args));
      case ContractVendorScreen.routeName:
        return MaterialPageRoute(builder: (_) => ContractVendorScreen(args: args));
      case CustomPaymentWebViewScreen.routeName:
        return MaterialPageRoute(builder: (_) => CustomPaymentWebViewScreen(args: args));
      case RequestDelegateScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RequestDelegateScreen());
      case ChooseDeliveryDelegateScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ChooseDeliveryDelegateScreen());
      case DelegateOrdersScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => RequestDelegateController(),
            child: const DelegateOrdersScreen(),
          ),
        );
      case AdminChatScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AdminChatController(),
            child: AdminChatScreen(args: args),
          ),
        );
      case TrackingDelegateOrderScreen.routeName:
        return MaterialPageRoute(builder: (_) => TrackingDelegateOrderScreen(args: args));
      case SelectLocationFromMapScreen.routeName:
        return MaterialPageRoute(builder: (_) => SelectLocationFromMapScreen(args: args));
      case SearchPlaceScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SearchPlaceScreen());
      case ShowDelegateOnMapScreen.routeName:
        return MaterialPageRoute(builder: (_) => ShowDelegateOnMapScreen(args: args));
      case ProductInCartDetailsScreen.routeName:
        return MaterialPageRoute(builder: (_) => ProductInCartDetailsScreen(args: args));
      case MapScreen.routeName:
        return MaterialPageRoute(builder: (_) => MapScreen(args: args));
      case ChangePasswordCheckCodeScreen.routeName:
        return MaterialPageRoute(builder: (_) => ChangePasswordCheckCodeScreen(args: args));
      case ResetPasswordScreen.routeName:
        return MaterialPageRoute(builder: (_) => ResetPasswordScreen(args: args));
      case CheckMobileHasAccount.routeName:
        return MaterialPageRoute(builder: (_) => const CheckMobileHasAccount());
      case DrawRestaurantScreen.routeName:
        return MaterialPageRoute(
          builder: (_) =>
              ChangeNotifierProvider(create: (context) => HomeController(), child: const DrawRestaurantScreen()),
        );
      default:
        return MaterialPageRoute(builder: (_) => const BottomNavigationBarScreen());
    }
  }
}
