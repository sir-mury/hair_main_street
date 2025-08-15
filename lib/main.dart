import 'dart:async';
import 'package:flutter/foundation.dart' as foundation;
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/blank_page.dart';
import 'package:hair_main_street/controllers/admin_controller.dart';
import 'package:hair_main_street/controllers/chat_controller.dart';
import 'package:hair_main_street/controllers/connectivity_controller.dart';
import 'package:hair_main_street/controllers/notification_controller.dart';
import 'package:hair_main_street/controllers/updates_service_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/firebase_options.dart';
import 'package:hair_main_street/pages/authentication/authentication.dart';
import 'package:hair_main_street/pages/authentication/create_account.dart';
import 'package:hair_main_street/pages/authentication/reset_password.dart';
import 'package:hair_main_street/pages/client_shop_page.dart';
import 'package:hair_main_street/pages/homepage.dart';
import 'package:hair_main_street/pages/menu/orders.dart';
import 'package:hair_main_street/pages/onboarding_page.dart';
import 'package:hair_main_street/pages/product_page.dart';
import 'package:hair_main_street/services/auth.dart';
import 'package:hair_main_street/services/notification.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

// ...

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
  Get.put(ConnectivityController());
  final prefs = SharedPreferencesAsync();
  final showHome = await prefs.getBool("showHome") ?? false;
  await prefs.setBool("hasShownUpdateDialog", false);
  //await FirebaseMessaging.instance.getInitialMessage();
  Get.put(NotificationController());
  Get.put(UserController());
  Get.put(AdminController());
  Get.put(UpdatesServiceController());
  Get.put<ChatController>(ChatController());
  NotificationService().init();
  FlutterNativeSplash.remove();

  runApp(MyApp(showHome: showHome));
}

class MyApp extends StatefulWidget {
  final bool showHome;
  const MyApp({required this.showHome, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  String referralCode = "";
  // late StreamSubscription<List<ConnectivityResult>> connectivitySubcription;

  @override
  void initState() {
    handleAppLinks();
    super.initState();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();

    super.dispose();
  }

  void showMyToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT, // 3 seconds by default, adjust if needed
      gravity: ToastGravity.CENTER, // Position at the bottom of the screen
      //timeInSec: 0.3, // Display for 0.3 seconds (300 milliseconds)
      backgroundColor: AppColors.shade2, // Optional: Set background color
      textColor: Colors.black, // Optional: Set text color
      fontSize: 14.0, // Optional: Set font size
    );
  }

  handleAppLinks() async {
    _appLinks = AppLinks();

    if (!foundation.kDebugMode) {
      // Check initial link if app was in cold state (terminated)
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        // print('getInitialAppLink: $appLink');
        // print(appLink.queryParameters);

        // print(appLink.path);
        if (appLink.path == '/__/auth/action') {
          var result = await AuthService().handlePasswordResetLink(appLink);
          if (result["success"] == true) {
            Get.off(
              () => ResetPasswordPage(
                code: result["oobCode"],
              ),
            );
          }
          return;
        }

        if (appLink.path.contains('/register')) {
          setState(() {
            var val = appLink.queryParameters["referralCode"] ?? "";
            referralCode = val.toString();
          });
          Get.toNamed("/register");
        }
        if (appLink.path.contains('/shops')) {
          String? vendorID;
          setState(() async {
            var val =
                appLink.pathSegments.length > 1 ? appLink.pathSegments[1] : "";
            vendorID = val;
          });
          Get.toNamed("/shops", arguments: {"vendorID": vendorID});
        }
        if (appLink.path.contains('/products')) {
          String? productID;
          var val =
              appLink.pathSegments.length > 1 ? appLink.pathSegments[1] : "";
          productID = val;
          Get.toNamed("/products/$productID");
        }
      }
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      // print('onAppLink: $uri');
      // print(uri.queryParameters);

      if (uri.path == '/__/auth/action') {
        var result = await AuthService().handlePasswordResetLink(uri);
        if (result["success"] == true) {
          Get.off(() => ResetPasswordPage(
                code: result["oobCode"],
              ));
        }
        return;
      }

      if (uri.path.contains('/register')) {
        setState(() {
          var val = uri.queryParameters["referralCode"] ?? "";
          referralCode = val.toString();
          //print("referral code: $referralCode");
        });
        Get.toNamed("/register");
      }
      if (uri.path.contains('/shops')) {
        String? vendorID;
        setState(() async {
          var val = uri.pathSegments.length > 1 ? uri.pathSegments[1] : "";
          vendorID = val;
        });
        Get.toNamed("/shops/$vendorID");
      }
      if (uri.path.contains('/products')) {
        String? productID;
        var val = uri.pathSegments.length > 1 ? uri.pathSegments[1] : "";
        productID = val;
        Get.toNamed("/products/$productID");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      smartManagement: SmartManagement.onlyBuilder,
      initialRoute: "/",
      defaultTransition: Transition.fadeIn,
      unknownRoute: GetPage(name: '/notfound', page: () => const HomePage()),
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? "");

        if (uri.path == "/__/auth/action") {
          debugPrint(
              '[onGenerateRoute] Intercepted and blocked GetX auto-nav for: ${settings.name}');
          return GetPageRoute(
              settings: settings,
              page: () => BlankPage(
                    interactionIcon: LoadingWidget(),
                  ));
        }
        return null;
      },
      getPages: [
        GetPage(name: '/', page: () => const HomePage()),
        GetPage(name: "/orders", page: () => const OrdersPage()),
        GetPage(
            name: '/shops/:id',
            page: () {
              final String vendorID = Get.parameters['id'] ?? '';
              return ClientShopPage(
                vendorID: vendorID,
              );
            }),
        GetPage(name: "/reset-password", page: () => ResetPasswordPage()),
        GetPage(
            name: '/products/:id',
            page: () {
              final String productId = Get.parameters['id'] ?? '';
              return ProductPage(id: productId);
            }),
        GetPage(
          name: '/register',
          parameters: {"referralCode": referralCode},
          page: () => CreateAccountPage(
            referralCode: referralCode,
          ),
        ),
      ],
      debugShowCheckedModeBanner: false,
      title: 'Hair Main Street',
      theme: ThemeData(
        popupMenuTheme: PopupMenuThemeData(
          enableFeedback: true,
        ),
        extensions: const [
          WoltModalSheetThemeData(
            topBarElevation: 0,
            topBarShadowColor: Colors.white,
            modalElevation: 0,
            dragHandleColor: Colors.black,
          )
        ],
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 11.2,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7),
            padding: const EdgeInsets.symmetric(vertical: 10),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            textStyle: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF673AB7),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
          backgroundColor: Colors.white,
          actionsIconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Raleway',
        //primaryColor: Colors.white,
        splashColor: const Color(0xFF673AB7).withValues(alpha: 0.30),
        //primarySwatch: primary,
        useMaterial3: true,
      ),
      home: widget.showHome ? const HomePage() : const OnboardingScreen(),
    );
  }
}

// final router = GoRouter(routes: [
//   GoRoute(
//     path: "/",
//     name: "home",
//     builder: ((context, state) => const SplashScreen()),
//   ),
//   GoRoute(
//     path: "/register/:referralcode",
//     name: "sign up",
//     builder: ((context, state) => const SignInUpPage()),
//   ),
// ]);
