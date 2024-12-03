import 'dart:async';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/chatController.dart';
import 'package:hair_main_street/controllers/notificationController.dart';
import 'package:hair_main_street/controllers/userController.dart';
import 'package:hair_main_street/firebase_options.dart';
import 'package:hair_main_street/pages/authentication/authentication.dart';
import 'package:hair_main_street/pages/client_shop_page.dart';
import 'package:hair_main_street/pages/homePage.dart';
import 'package:hair_main_street/pages/menu/orders.dart';
import 'package:hair_main_street/pages/onboarding_page.dart';
import 'package:hair_main_street/pages/product_page.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/services/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

// ...

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Future.delayed(const Duration(milliseconds: 1000));
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool("showHome") ?? false;
  NotificationService().init();
  //await FirebaseMessaging.instance.getInitialMessage();
  Get.put(UserController());
  Get.lazyPut<NotificationController>(() => NotificationController());
  Get.put<ChatController>(ChatController());
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

  handleAppLinks() async {
    _appLinks = AppLinks();

    if (!Foundation.kDebugMode) {
      // Check initial link if app was in cold state (terminated)
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        // print('getInitialAppLink: $appLink');
        // print(appLink.queryParameters);

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
            var vendor = await DataBaseService().getVendorFromShopName(val);
            vendorID = vendor!.userID;
          });
          Get.toNamed("/shops", arguments: {"vendorID": vendorID});
        }
        if (appLink.path.contains('/products')) {
          String? productID;
          var val =
              appLink.pathSegments.length > 1 ? appLink.pathSegments[1] : "";
          productID = val;
          Get.toNamed("/products", arguments: {"id": productID});
        }
      }
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      // print('onAppLink: $uri');
      // print(uri.queryParameters);

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
          var vendor = await DataBaseService().getVendorFromShopName(val);
          vendorID = vendor!.userID;
        });
        Get.toNamed("/shops", arguments: {"vendorID": vendorID});
      }
      if (uri.path.contains('/products')) {
        String? productID;
        var val = uri.pathSegments.length > 1 ? uri.pathSegments[1] : "";
        productID = val;
        Get.toNamed("/products", arguments: {"id": productID});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: "/",
      defaultTransition: Transition.fadeIn,
      getPages: [
        GetPage(
            name: '/',
            page: () =>
                widget.showHome ? const HomePage() : const OnboardingScreen()),
        GetPage(name: "/orders", page: () => const OrdersPage()),
        GetPage(name: '/shops', page: () => const ClientShopPage()),
        GetPage(name: '/products', page: () => const ProductPage()),
        GetPage(
          name: '/register',
          parameters: {"referralCode": referralCode},
          page: () => SignInUpPage(
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
        splashColor: const Color(0xFF673AB7).withOpacity(0.30),
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
