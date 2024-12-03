//import 'package:dot_navigation_bar/dot_navigation_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/cartController.dart';
import 'package:hair_main_street/controllers/notificationController.dart';
import 'package:hair_main_street/controllers/order_checkoutController.dart';
import 'package:hair_main_street/controllers/productController.dart';
import 'package:hair_main_street/controllers/refund_cancellation_Controller.dart';
import 'package:hair_main_street/controllers/userController.dart';
import 'package:hair_main_street/controllers/vendorController.dart';
import 'package:hair_main_street/pages/cart.dart';
import 'package:hair_main_street/pages/menu.dart';
import 'package:hair_main_street/pages/new_feed.dart';
import 'package:hair_main_street/pages/vendors.dart';
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

  @override
  void initState() {
    Get.put(VendorController());
    Get.put(RefundCancellationController());
    Get.put(WishListController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = Get.height;
    double screenWidth = Get.width;
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
            // String userType =
            //     userController.userState.value!.isVendor! == true
            //         ? "vendor"
            //         : "buyer";
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
          return NavigationBar(
            height: kToolbarHeight,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            // iconSize: 25,
            // selectedLabelStyle: const TextStyle(
            //     fontSize: 15,
            //     fontFamily: 'Raleway',
            //     fontWeight: FontWeight.w500,
            //     color: Color(0xFF673AB7)),
            // unselectedLabelStyle: const TextStyle(
            //     fontSize: 15,
            //     fontFamily: 'Raleway',
            //     fontWeight: FontWeight.w500,
            //     color: Colors.black),
            // pad: 1,
            // boxShadow: const [
            //   BoxShadow(
            //     color: Colors.black,
            //     blurStyle: BlurStyle.outer,
            //     offset: Offset.zero,
            //     blurRadius: 1,
            //   ),
            // ],
            // top: 2,
            // paddingVertical: 8,
            // bottom: 1,
            // borderRadius: BorderRadius.all(
            //   Radius.circular(16),
            // ),
            backgroundColor: Colors.white,
            //blur: 1,
            //unselectedItemColor: Colors.black,
            //countStyle: const CountStyle(color: Colors.black),
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
                  icon: Iconify(MaterialSymbols.shopping_cart_outline_rounded),
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
                  selectedIcon: Iconify(
                    Ci.user,
                    color: Color(0xFF673AB7),
                  ),
                ),
              ),
            ],
            selectedIndex: bottomNavController.tabIndex.value,
            onDestinationSelected: bottomNavController.changeTabIndex,
          );
        }),
        // bottomNavigationBar: Container(
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.vertical(
        //       top: Radius.circular(16),
        //       bottom: Radius.circular(16),
        //     ),
        //     border: Border.all(color: Colors.black, width: 1.6),
        //   ),
        //   margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        //   padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        //   child: SafeArea(
        //     child: GNav(
        //       style: GnavStyle.google,
        //       //color: Colors.green,
        //       tabBackgroundColor: Color(0xFF0E4D92),
        //       tabBorderRadius: 12,
        //       tabActiveBorder: Border.all(color: Colors.black, width: 1.2),
        //       tabBorder: Border.all(color: Colors.white, width: 1),
        //       //tabMargin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        //       padding: EdgeInsets.all(6),
        //       gap: 4,
        //       selectedIndex: _selectedTab,
        //       onTabChange: (value) {
        //         setState(() {
        //           _selectedTab = value;
        //         });
        //       },
        //       //color: Colors.white,
        //       textStyle: TextStyle(fontSize: 16, color: Colors.white),
        //       tabs: [
        //         /// Home
        //         GButton(
        //           iconActiveColor: Colors.white,
        //           icon: Icons.home_outlined,
        //           iconSize: 28,
        //           text: "Home",
        //         ),

        //         /// Likes
        //         GButton(
        //           iconActiveColor: Colors.white,
        //           icon: Icons.shopping_cart_outlined,
        //           iconSize: 28,
        //           text: "Cart",
        //         ),

        //         /// Profile
        //         GButton(
        //           iconActiveColor: Colors.white,
        //           icon: Icons.menu,
        //           iconSize: 28,
        //           text: "Menu",
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
