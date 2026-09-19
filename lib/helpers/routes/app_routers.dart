part of 'app_routers_import.dart';

class NamedNavigatorImpl {
  static GlobalKey<NavigatorState> navigatorState = GlobalKey<NavigatorState>();

  static BuildContext get context => navigatorState.currentContext!;
  static NavigatorState get currentState => navigatorState.currentState!;

  static bool _isGuestProtectedRoute(String screen) {
    return screen == RestaurantDetailsScreen.routeName ||
        screen == RequestDelegateScreen.routeName ||
        screen == PersonalInformationScreen.routeName ||
        screen == WalletScreen.routeName;
  }

  static Future push(
    String screen, {
    bool replace = false,
    bool clean = false,
    Object? arguments,
  }) {
    log('screen ======> $screen');

    if (GuestAccessGuard.isGuest && _isGuestProtectedRoute(screen)) {
      GuestAccessGuard.showLoginRequired(context);
      return Future.value();
    }

    if (clean) {
      return currentState.pushNamedAndRemoveUntil(
        screen,
        (route) => false,
        arguments: arguments,
      );
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
    final resolved = GoDriveRoutePolicy.resolve(
      settings.name,
      signedIn: HiveMethods.getToken() != null,
    );
    settings = RouteSettings(
      name: resolved,
      arguments: resolved == settings.name ? settings.arguments : null,
    );
    if (kIsWeb &&
        Firebase.apps.isEmpty &&
        (resolved == ChatScreen.routeName ||
            resolved == AdminChatScreen.routeName)) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(context.languageCode == 'ar' ? 'المحادثة' : 'Chat'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                context.languageCode == 'ar'
                    ? 'المحادثة غير متاحة حاليًا في نسخة المعاينة. يمكنك الاتصال بالمندوب من تفاصيل الطلب.'
                    : 'Chat is unavailable in this preview. You can call your courier from the order details.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }
    dynamic args;
    if (settings.arguments != null) args = settings.arguments;
    switch (settings.name) {
      case ZoomImageScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ZoomImageScreen(args: args),
        );
      case SplashScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case BottomNavigationBarScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const BottomNavigationBarScreen(),
        );
      case OnBoardingScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case LoginScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case RegisterScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case VerificationCodeScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const VerificationCodeScreen(),
        );
      case SocialAuthPhoneScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SocialAuthPhoneScreen(socialAuthData: args),
        );
      case CreateNewAccountScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CreateNewAccountScreen(),
        );
      case ShareLocationScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ShareLocationScreen(),
        );
      case RestaurantsScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangeNotifierProvider(
            create: (_) => RestaurantsController(),
            child: const RestaurantsScreen(),
          ),
        );
      case RestaurantDetailsScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangeNotifierProvider(
            create: (_) => RestaurantsController(),
            child: RestaurantDetailsScreen(args: args),
          ),
        );
      case ProductDetailsScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductDetailsScreen(args: args),
        );
      case AccountInformationScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AccountInformationScreen(args: args),
        );
      case PersonalInformationScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PersonalInformationScreen(),
        );
      case RequestAgainScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RequestAgainScreen(args: args),
        );
      case TrackingYourOrderScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
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
          settings: settings,
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ChatController(),
            child: ChatScreen(args: args),
          ),
        );
      case ServiceRatingScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ServiceRatingScreen(args: args),
        );
      case CartScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CartScreen(),
        );
      // case PaymentScreen.routeName:
      //   return MaterialPageRoute(settings: settings,
      //     builder: (_) => const PaymentScreen(),
      //   );
      case FavoriteScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FavoriteScreen(),
        );
      case AddressScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddressScreen(),
        );
      case HelpScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HelpScreen(),
        );
      case TermsAndConditionsScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TermsAndConditionsScreen(),
        );
      case PrivacyPolicyScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PrivacyPolicyScreen(),
        );
      case ContactUsScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ContactUsScreen(),
        );
      // case ConfirmAddressScreen.routeName:
      //   return MaterialPageRoute(settings: settings, builder: (_) => const ConfirmAddressScreen());
      case AddAddressScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AddAddressScreen(args: args),
        );
      case UpdateAddressScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => UpdateAddressScreen(args: args),
        );
      case SearchScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => SearchRestaurantController()
                  ..initialLastSearch()
                  ..getLastSearch(),
              ),
              ChangeNotifierProvider(
                create: (context) => RestaurantsController(),
              ),
            ],
            child: const SearchScreen(),
          ),
        );
      case ChooseAddressFromMapScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChooseAddressFromMapScreen(args: args),
        );
      case AddAddressFromCartScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddAddressFromCartScreen(),
        );
      case ExecuteTheOrderScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangeNotifierProvider(
            create: (context) => MyAccountController(),
            child: ExecuteTheOrderScreen(args: args),
          ),
        );

      case WalletScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
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
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OrderOTPScreen(),
        );
      case YourOrderSuccessfullyCompletedScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangeNotifierProvider(
            create: (context) => OrdersController(),
            child: YourOrderSuccessfullyCompletedScreen(args: args),
          ),
        );
      case RegisterAsVendorScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterAsVendorScreen(),
        );
      case RegisterAsDeliveryScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterAsDeliveryScreen(),
        );
      case ContractDeliveryScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ContractDeliveryScreen(args: args),
        );
      case ContractVendorScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ContractVendorScreen(args: args),
        );
      case CustomPaymentWebViewScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CustomPaymentWebViewScreen(args: args),
        );
      case RequestDelegateScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RequestDelegateScreen(),
        );
      case ChooseDeliveryDelegateScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ChooseDeliveryDelegateScreen(),
        );
      case DelegateOrdersScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangeNotifierProvider(
            create: (context) => RequestDelegateController(),
            child: const DelegateOrdersScreen(),
          ),
        );
      case AdminChatScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AdminChatController(),
            child: AdminChatScreen(args: args),
          ),
        );
      case TrackingDelegateOrderScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => TrackingDelegateOrderScreen(args: args),
        );
      case SelectLocationFromMapScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SelectLocationFromMapScreen(args: args),
        );
      case SearchPlaceScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SearchPlaceScreen(),
        );
      case ShowDelegateOnMapScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ShowDelegateOnMapScreen(args: args),
        );
      case ProductInCartDetailsScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductInCartDetailsScreen(args: args),
        );
      case MapScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MapScreen(args: args),
        );
      case ChangePasswordCheckCodeScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangePasswordCheckCodeScreen(args: args),
        );
      case ResetPasswordScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResetPasswordScreen(args: args),
        );
      case CheckMobileHasAccount.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CheckMobileHasAccount(),
        );
      case DrawRestaurantScreen.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangeNotifierProvider(
            create: (context) => HomeController(),
            child: const DrawRestaurantScreen(),
          ),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const BottomNavigationBarScreen(),
        );
    }
  }
}
