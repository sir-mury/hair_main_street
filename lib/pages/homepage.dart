//import 'package:dot_navigation_bar/dot_navigation_bar.dart';

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/cart_controller.dart';
import 'package:hair_main_street/controllers/connectivity_controller.dart';
import 'package:hair_main_street/controllers/notification_controller.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/paystack_controller.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/controllers/refund_cancellation_Controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/controllers/vendor_controller.dart';
import 'package:hair_main_street/pages/cart.dart';
import 'package:hair_main_street/pages/menu.dart';
import 'package:hair_main_street/pages/new_feed.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/teenyicons.dart';
import 'package:iconify_flutter_plus/icons/material_symbols.dart';
import 'package:iconify_flutter_plus/icons/ci.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'dart:math' as math;

//import 'package:hair_main_street/widgets/cards.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProductController productController = Get.put(ProductController());
  BottomNavController bottomNavController = Get.put(BottomNavController());

  UserController userController = Get.find<UserController>();

  //var anotherController = Get.put(VendorController());
  List<Widget> tabs = [
    const NewFeedPage(),
    // const VendorsPage(),
    const CartPage(),
    const MenuPageSubstitute()
  ];
  //final _selectedTab = 0;

  CartController cartController = Get.put(CartController());
  CheckOutController checkOutController = Get.put(CheckOutController());
  NotificationController notificationController =
      Get.put(NotificationController());
  ConnectivityController connectivityController =
      Get.find<ConnectivityController>();

  @override
  void initState() {
    super.initState();
    Get.put(VendorController());
    Get.put(RefundCancellationController());
    Get.put(WishListController());
    Get.put(PaystackController());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double screenHeight = Get.height;
    // double screenWidth = Get.width;
    checkOutController.userUID.value =
        userController.userState.value?.uid == null
            ? ""
            : userController.userState.value!.uid!;
    return Scaffold(
      //extendBodyBehindAppBar: true,
      //extendBody: true,
      body: Obx(() => IndexedStack(
            index: bottomNavController.tabIndex.value,
            children: tabs,
          )),
      bottomNavigationBar: SafeArea(
        child: Obx(() {
          if (userController.userState.value != null) {
            if (userController.userState.value!.isVendor == true) {
              notificationController.subscribeToTopics(
                  "vendor", userController.userState.value!.uid!);
              notificationController.subscribeToTopics(
                  "buyer", userController.userState.value!.uid!);
            } else {
              notificationController.subscribeToTopics(
                  "buyer", userController.userState.value!.uid!);
            }
          }
          return AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            height: connectivityController.isConnected.value
                ? kToolbarHeight
                : kToolbarHeight * 1.5,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  NavigationBar(
                    height: kToolbarHeight,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    backgroundColor: Colors.white,
                    indicatorColor: Colors.transparent,
                    destinations: [
                      GestureDetector(
                        onDoubleTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setBool("showHome", false);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: NavigationDestination(
                            icon: Iconify(
                              Teenyicons.home_alt_outline,
                              size: 24,
                              // color: Color(0xFF673AB7),
                            ),
                            label: "Home",
                            selectedIcon: Iconify(
                              Teenyicons.home_alt_solid,
                              color: Color(0xFF673AB7),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 8.0),
                      //   child: NavigationDestination(
                      //     icon: Iconify(Ion.md_notifications_outline),
                      //     label: "Notifications",
                      //     selectedIcon: Iconify(
                      //       Ion.md_notifications,
                      //       color: Color(0xFF673AB7),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                      //   child: NavigationDestination(
                      //     icon: SvgPicture.asset(
                      //       'assets/Icons/shop.svg',
                      //       color: Colors.black,
                      //       height: 24,
                      //       width: 24,
                      //     ),
                      //     label: "Vendors",
                      //     selectedIcon: SvgPicture.asset(
                      //       'assets/Icons/shop.svg',
                      //       color: const Color(0xFF673AB7),
                      //       height: 24,
                      //       width: 24,
                      //     ),
                      //   ),
                      // ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: NavigationDestination(
                          icon: Iconify(
                              MaterialSymbols.shopping_cart_outline_rounded),
                          label: "Cart",
                          selectedIcon: Iconify(
                            MaterialSymbols.shopping_cart_rounded,
                            color: Color(0xFF673AB7),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: NavigationDestination(
                          icon: Iconify(Ci.user),
                          label: "Account",
                          selectedIcon: Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: Color(0xFF673AB7),
                          ),
                        ),
                      ),
                    ],
                    selectedIndex: bottomNavController.tabIndex.value,
                    onDestinationSelected: bottomNavController.changeTabIndex,
                  ),
                  connectivityController.isConnected.value == false
                      ? SafeArea(
                          child: SizedBox(
                            width: double.maxFinite,
                            child: ColoredBox(
                              color: AppColors.shade4,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  "You are currently offline",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: "Raleway",
                                    fontSize: 16,
                                    color: AppColors.shade1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink()
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
