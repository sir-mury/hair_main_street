//ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/admin_controller.dart';
import 'package:hair_main_street/controllers/notification_controller.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/pages/authentication/sign_in.dart';
import 'package:hair_main_street/pages/chats_page.dart';
import 'package:hair_main_street/pages/menu/settings/settings.dart';
import 'package:hair_main_street/blank_page.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
//import 'package:hair_main_street/Shop_page.dart';
import 'package:hair_main_street/pages/menu/orders.dart';
import 'package:hair_main_street/pages/menu/profile.dart';
import 'package:hair_main_street/pages/notifcation.dart';
import 'package:hair_main_street/pages/vendor_dashboard/become_vendor.dart';
import 'package:hair_main_street/pages/vendor_dashboard/vendor.dart';
import 'package:hair_main_street/pages/menu/wishlist.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ion.dart';
import 'package:iconify_flutter_plus/icons/material_symbols.dart';
import 'package:material_symbols_icons/symbols.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    UserController userController = Get.find<UserController>();
    CheckOutController checkOutController = Get.find<CheckOutController>();
    num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;

    return Obx(
      () => userController.userState.value == null
          ? BlankPage(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              buttonStyle: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                shape: RoundedRectangleBorder(
                  // side: const BorderSide(
                  //   width: 1.2,
                  //   color: Colors.black,
                  // ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              pageIcon: const Icon(
                Icons.person_off_outlined,
                size: 48,
              ),
              text: "Your are not Logged In",
              interactionText: "Sign In or Register",
              interactionIcon: const Icon(
                Icons.person_2_outlined,
                size: 24,
                color: Colors.white,
              ),
              interactionFunction: () => Get.to(() => const SignIn()),
            )
          : Builder(builder: (context) {
              userController.profileComplete();
              return Scaffold(
                // appBar: AppBar(
                //   title: const Text(
                //     '${userController.userState.value.fullname ?? "Set your Full Name"}',
                //     style: TextStyle(
                //       fontSize: 32,
                //       fontWeight: FontWeight.w900,
                //       color: Colors.black,
                //     ),
                //   ),
                //   centerTitle: true,
                //   actions: [
                //     Transform.rotate(
                //       angle: 0.3490659,
                //       child: Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 4.0),
                //         child: IconButton(
                //           onPressed: () {
                //             Get.to(() => NotificationsPage());
                //           },
                //           icon: const Icon(
                //             Icons.notifications_active_rounded,
                //             size: 32,
                //             color: Colors.black,
                //           ),
                //         ),
                //       ),
                //     )
                //   ],
                //   //backgroundColor: Color(0xFF0E4D92),
                //   // flexibleSpace: Container(
                //   //   decoration: BoxDecoration(gradient: appBarGradient),
                //   // ),
                //   //backgroundColor: Colors.transparent,
                // ),
                backgroundColor: Colors.white,
                extendBodyBehindAppBar: false,
                body: SafeArea(
                  child: Container(
                    color: Colors.white,
                    //decoration: BoxDecoration(gradient: myGradient),
                    child: ListView(
                      padding:
                          EdgeInsets.fromLTRB(12, screenHeight * 0.02, 12, 0),
                      children: [
                        userController.isProfileComplete.value
                            ? const SizedBox.shrink()
                            : Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                height: 30,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.red, width: 0.5),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/Icons/notice.svg",
                                      height: 14,
                                      width: 14,
                                      colorFilter: ColorFilter.mode(
                                        Colors.red,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    const Text(
                                      "Profile Incomplete: Kindly complete your profile",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: "Raleway",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => Get.to(() => ProfilePage()),
                                child: userController
                                            .userState.value!.profilePhoto ==
                                        null
                                    ? CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.brown[300],
                                        child: SvgPicture.asset(
                                          "assets/Icons/user.svg",
                                          height: 35,
                                          width: 35,
                                          colorFilter: ColorFilter.mode(
                                            Colors.white,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 40,
                                        backgroundImage: NetworkImage(
                                          userController
                                              .userState.value!.profilePhoto!,
                                        ),
                                      ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  userController.userState.value!.fullname !=
                                              null ||
                                          userController
                                                  .userState.value!.fullname! !=
                                              ""
                                      ? userController
                                          .userState.value!.fullname!
                                      : "Set your Full Name",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  // style: IconButton.styleFrom(
                                  //   backgroundColor: Colors.blueGrey,
                                  // ),
                                  padding: const EdgeInsets.all(0),
                                  onPressed: () =>
                                      Get.to(() => NotificationsPage()),
                                  icon: const Iconify(
                                    Ion.md_notifications_outline,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 8,
                          thickness: 1.5,
                          color: Colors.black.withValues(alpha: 0.10),
                        ),
                        MenuButton(
                          text: "Profile",
                          onPressed: () => Get.to(() => ProfilePage()),
                        ),
                        Divider(
                          height: 8,
                          thickness: 1.5,
                          color: Colors.black.withValues(alpha: 0.10),
                        ),
                        MenuButton(
                          text: "Wish List",
                          onPressed: () => Get.to(() => const WishListPage(),
                              transition: Transition.fadeIn),
                        ),
                        Divider(
                          height: 8,
                          thickness: 1.5,
                          color: Colors.black.withValues(alpha: 0.10),
                        ),
                        MenuButton(
                          text: "Messages",
                          onPressed: () => Get.to(() => const ChatPage(),
                              transition: Transition.fadeIn),
                        ),
                        Divider(
                          height: 8,
                          thickness: 1.5,
                          color: Colors.black.withValues(alpha: 0.10),
                        ),
                        if (userController.isVendor.value == true)
                          MenuButton(
                            text: "Vendor Dashboard",
                            onPressed: () => Get.to(() => const VendorPage()),
                          )
                        else
                          MenuButton(
                            text: "Become a Vendor",
                            onPressed: () {
                              Get.to(() => const BecomeAVendorPage());
                            },
                          ),
                        Divider(
                          height: 8,
                          thickness: 1.5,
                          color: Colors.black.withValues(alpha: 0.10),
                        ),
                        MenuButton(
                          text: "My Orders",
                          onPressed: () => Get.to(() => const OrdersPage(),
                              transition: Transition.fadeIn),
                        ),
                        Divider(
                          height: 8,
                          thickness: 1.5,
                          color: Colors.black.withValues(alpha: 0.10),
                        ),
                        MenuButton(
                          text: "Settings",
                          onPressed: () => Get.to(() => const SettingsPage(),
                              transition: Transition.fadeIn),
                        ),
                        Divider(
                          height: 8,
                          thickness: 1.5,
                          color: Colors.black.withValues(alpha: 0.10),
                        ),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: InkWell(
                            onTap: () async {
                              userController.isLoading.value = true;
                              await userController.signOut();
                              if (userController.isLoading.isTrue) {
                                Get.dialog(
                                  const LoadingWidget(),
                                  barrierDismissible: false,
                                );
                              } else {
                                checkOutController.checkoutList.clear();
                                checkOutController.itemCheckboxState.clear();
                                checkOutController
                                    .isMasterCheckboxChecked.value = false;
                                checkOutController.deletableCartItems.clear();
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Iconify(
                                  MaterialSymbols.logout,
                                  size: 20,
                                  color: Color(0xFFEA4335),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.02,
                                ),
                                const Text(
                                  "Sign Out",
                                  style: TextStyle(
                                    color: Color(0xFFEA4335),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Raleway',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String? text;

  final Function? onPressed;
  const MenuButton({
    this.onPressed,
    this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: const Color(0xFF673AB7).withValues(alpha: 0.20),
        //side: BorderSide(width: 0.5),
      ),
      onPressed: onPressed == null ? () {} : () => onPressed!(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text!,
            style: const TextStyle(
              fontSize: 17,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          // SizedBox(
          //   width: screenWidth * 0.30,
          //),
          const Icon(
            Symbols.arrow_forward_ios_rounded,
            size: 20,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}

class MenuPageSubstitute extends StatelessWidget {
  const MenuPageSubstitute({super.key});

  @override
  Widget build(BuildContext context) {
    UserController userController = Get.find<UserController>();
    AdminController adminController = Get.find<AdminController>();
    NotificationController notificationController =
        Get.find<NotificationController>();
    //ReviewController reviewController = Get.find<ReviewController>();
    CheckOutController checkOutController = Get.find<CheckOutController>();
    num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;

    return Obx(
      () {
        if (userController.authStreamDone.isFalse) {
          return Center(
            child: LoadingWidget(),
          );
        } else if (userController.userState.value == null) {
          return BlankPage(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            buttonStyle: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              shape: RoundedRectangleBorder(
                // side: const BorderSide(
                //   width: 1.2,
                //   color: Colors.black,
                // ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            pageIcon: const Icon(
              Icons.person_off_outlined,
              size: 48,
            ),
            text: "Your are not Logged In",
            interactionText: "Sign In or Register",
            interactionIcon: const Icon(
              Icons.person_2_outlined,
              size: 24,
              color: Colors.white,
            ),
            interactionFunction: () => Get.to(() => const SignIn()),
          );
        } else {
          return Builder(builder: (context) {
            userController.profileComplete();
            return Scaffold(
              backgroundColor: Colors.white,
              extendBodyBehindAppBar: false,
              body: SafeArea(
                child: Container(
                  color: Colors.white,
                  //decoration: BoxDecoration(gradient: myGradient),
                  child: ListView(
                    padding:
                        EdgeInsets.fromLTRB(12, screenHeight * 0.02, 12, 0),
                    children: [
                      userController.isProfileComplete.value
                          ? const SizedBox.shrink()
                          : Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              // height: 30,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.red, width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/Icons/notice.svg",
                                    height: 14,
                                    width: 14,
                                    colorFilter: ColorFilter.mode(
                                      Colors.red,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  const Text(
                                    "Profile Incomplete: Kindly complete your profile",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontFamily: "Raleway",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: GestureDetector(
                          onTap: () => Get.to(() => ProfilePage()),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GetBuilder<UserController>(
                                builder: (_) {
                                  return userController
                                              .userState.value!.profilePhoto ==
                                          null
                                      ? CircleAvatar(
                                          radius: 40,
                                          backgroundColor: Colors.black12,
                                          child: SvgPicture.asset(
                                            "assets/Icons/user.svg",
                                            height: 35,
                                            width: 35,
                                            colorFilter: ColorFilter.mode(
                                              Colors.black,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 40,
                                          backgroundImage: NetworkImage(
                                            userController
                                                .userState.value!.profilePhoto!,
                                          ),
                                        );
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  userController.userState.value!.fullname !=
                                              null ||
                                          userController
                                                  .userState.value!.fullname! !=
                                              ""
                                      ? userController
                                          .userState.value!.fullname!
                                      : "Set your Full Name",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  // style: IconButton.styleFrom(
                                  //   backgroundColor: Colors.blueGrey,
                                  // ),
                                  padding: const EdgeInsets.all(0),
                                  onPressed: () =>
                                      Get.to(() => NotificationsPage()),
                                  icon: const Iconify(
                                    Ion.md_notifications_outline,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 8,
                        thickness: 1.5,
                        color: Colors.black.withValues(alpha: 0.10),
                      ),
                      MenuButton(
                        text: "Profile",
                        onPressed: () => Get.to(() => ProfilePage()),
                      ),
                      Divider(
                        height: 8,
                        thickness: 1.5,
                        color: Colors.black.withValues(alpha: 0.10),
                      ),
                      MenuButton(
                        text: "Wish List",
                        onPressed: () => Get.to(() => const WishListPage(),
                            transition: Transition.fadeIn),
                      ),
                      Divider(
                        height: 8,
                        thickness: 1.5,
                        color: Colors.black.withValues(alpha: 0.10),
                      ),
                      MenuButton(
                        text: "Messages",
                        onPressed: () => Get.to(() => const ChatPage(),
                            transition: Transition.fadeIn),
                      ),
                      // Divider(
                      //   height: 8,
                      //   thickness: 1.5,
                      //   color: Colors.black.withValues(alpha: 0.10),
                      // ),
                      if (userController.userState.value!.isVendor! == false)
                        Column(
                          children: [
                            Divider(
                              height: 8,
                              thickness: 1.5,
                              color: Colors.black.withValues(alpha: 0.10),
                            ),
                            MenuButton(
                              text: "Become a Vendor",
                              onPressed: () {
                                Get.to(
                                  () => adminController
                                          .adminSettings.value!.allowVendors!
                                      ? const BecomeAVendorPage()
                                      : const MakeshiftBecomeVendorPage(),
                                );
                              },
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      if (userController.userState.value!.isVendor! == true)
                        Column(
                          children: [
                            Divider(
                              height: 8,
                              thickness: 1.5,
                              color: Colors.black.withValues(alpha: 0.10),
                            ),
                            MenuButton(
                              text: "Vendor Dashboard",
                              onPressed: () => Get.to(() => const VendorPage()),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      Divider(
                        height: 8,
                        thickness: 1.5,
                        color: Colors.black.withValues(alpha: 0.10),
                      ),
                      MenuButton(
                        text: "My Orders",
                        onPressed: () => Get.to(() => const OrdersPage(),
                            transition: Transition.fadeIn),
                      ),
                      Divider(
                        height: 8,
                        thickness: 1.5,
                        color: Colors.black.withValues(alpha: 0.10),
                      ),
                      MenuButton(
                        text: "Settings",
                        onPressed: () => Get.to(() => const SettingsPage(),
                            transition: Transition.fadeIn),
                      ),
                      Divider(
                        height: 8,
                        thickness: 1.5,
                        color: Colors.black.withValues(alpha: 0.10),
                      ),
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: InkWell(
                          onTap: () async {
                            userController.isLoading.value = true;
                            if (userController.isLoading.isTrue) {
                              Get.dialog(
                                const LoadingWidget(),
                                barrierDismissible: false,
                              );
                            }

                            checkOutController.checkoutList.clear();
                            checkOutController.itemCheckboxState.clear();
                            checkOutController.isMasterCheckboxChecked.value =
                                false;
                            checkOutController.deletableCartItems.clear();
                            if (userController.userState.value!.isVendor ==
                                true) {
                              var topics = [
                                "vendor_${userController.userState.value!.uid!}",
                                "buyer_${userController.userState.value!.uid!}",
                              ];
                              notificationController
                                  .unsubscribeFromTopics(topics);
                            } else {
                              var topics = [
                                "buyer_${userController.userState.value!.uid!}",
                              ];
                              notificationController
                                  .unsubscribeFromTopics(topics);
                            }
                            await userController.signOut();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Iconify(
                                MaterialSymbols.logout,
                                size: 20,
                                color: Color(0xFFEA4335),
                              ),
                              SizedBox(
                                width: screenWidth * 0.02,
                              ),
                              const Text(
                                "Sign Out",
                                style: TextStyle(
                                  color: Color(0xFFEA4335),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Raleway',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        }
      },
    );
  }
}
