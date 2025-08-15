import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/blank_page.dart';
import 'package:hair_main_street/controllers/cart_controller.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/pages/orders_stuff/cart_checkout.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/mdi.dart';
import 'package:iconify_flutter_plus/icons/raphael.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // GlobalKey<FormState> formKey = GlobalKey();
    CartController cartController = Get.find<CartController>();
    UserController userController = Get.find<UserController>();
    CheckOutController checkOutController = Get.find<CheckOutController>();
    // if (userController.userState.value != null) {
    //   cartController.fetchCart();
    // }
    String formatCurrency(String numberString) {
      final number =
          double.tryParse(numberString) ?? 0.0; // Handle non-numeric input
      final formattedNumber =
          number.toStringAsFixed(2); // Format with 2 decimals

      // Split the number into integer and decimal parts
      final parts = formattedNumber.split('.');
      final intPart = parts[0];
      final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

      // Format the integer part with commas for every 3 digits
      final formattedIntPart = intPart.replaceAllMapped(
        RegExp(r'\d{1,3}(?=(\d{3})+(?!\d))'),
        (match) => '${match.group(0)},',
      );

      // Combine the formatted integer and decimal parts
      final formattedResult = formattedIntPart + decimalPart;

      return formattedResult;
    }

    return Obx(() {
      debugPrint("cart items: ${cartController.cartItems.length}");
      if (userController.authStreamDone.isFalse) {
        return Center(
          child: LoadingWidget(),
        );
      } else if (userController.userState.value == null) {
        return BlankPage(
          text: "You are not logged In",
          pageIcon: const Icon(
            Icons.person_off_outlined,
            size: 48,
          ),
        );
      } else {
        return Obx(
          () {
            if (cartController.isLoading.value) {
              return const LoadingWidget();
            } else {
              return Scaffold(
                appBar: AppBar(
                  scrolledUnderElevation: 0,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  // leading: IconButton(
                  //   onPressed: () => Get.back(),
                  //   icon: const Icon(
                  //       Symbols.arrow_back_ios_new_rounded,
                  //       size: 24,
                  //       color: Colors.black),
                  // ),
                  title: SafeArea(
                    child: Row(
                      children: [
                        const Text(
                          'Cart ',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        Obx(
                          () => cartController.cartItems.isEmpty
                              ? const SizedBox.shrink()
                              : Text(
                                  '(${cartController.cartItems.length})',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                      ),
                      child: InkWell(
                        onTap: () {
                          if (checkOutController.deletableCartItems.isEmpty) {
                            cartController.showMyToast("Select an Item");
                          } else {
                            Get.dialog(
                              AlertDialog(
                                elevation: 0,
                                backgroundColor: Colors.white,
                                titlePadding:
                                    const EdgeInsets.fromLTRB(16, 10, 16, 4),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(16, 2, 16, 10),
                                title: const Text(
                                  "Delete Item(s)?",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                content: Text(
                                  "Are you sure you want to remove this item(s) from your cart?",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black.withValues(alpha: 0.65),
                                  ),
                                ),
                                actionsAlignment: MainAxisAlignment.spaceEvenly,
                                actionsPadding:
                                    const EdgeInsets.fromLTRB(16, 4, 16, 10),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 32),
                                      //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF673AB7),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 32),
                                      //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFF673AB7),
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () async {
                                      cartController.isLoading.value = true;
                                      if (cartController.isLoading.value ==
                                          true) {
                                        Get.dialog(
                                          const LoadingWidget(),
                                          barrierDismissible: false,
                                        );
                                      }
                                      if (checkOutController
                                          .deletableCartItems.isEmpty) {
                                        cartController
                                            .showMyToast("Select an Item");
                                      } else {
                                        var value = await checkOutController
                                            .removeFromCart();
                                        if (value == "success") {
                                          Get.close(2);
                                        }
                                      }
                                    },
                                    child: const Text(
                                      "Confirm",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              barrierDismissible: true,
                            );
                          }
                        },
                        child: const Iconify(
                          Mdi.delete,
                          size: 25,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
                extendBody: false,
                extendBodyBehindAppBar: false,
                body: cartController.cartItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: Get.height * 0.12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Iconify(
                                Raphael.cart,
                                size: 156,
                                color: const Color(0xFF673AB7)
                                    .withValues(alpha: 0.30),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                "Oops Nothing here yet\nLet's Go Shopping",
                                style: TextStyle(
                                  color: const Color(0xFF673AB7)
                                      .withValues(alpha: 0.70),
                                  fontSize: 30,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Obx(
                        () => Container(
                          //decoration: BoxDecoration(gradient: myGradient),
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          //padding: EdgeInsets.all(8),
                          child: ListView.builder(
                            //physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return CartCard(
                                cartItem: cartController.cartItems[index],
                                cartId:
                                    cartController.cartItems[index].cartItemID,
                                id: cartController.cartItems[index].productID,
                                optionName:
                                    cartController.cartItems[index].optionName,
                              );
                            },
                            itemCount: cartController.cartItems.length,
                            // shrinkWrap: true,
                          ),
                        ),
                      ),
                bottomNavigationBar: Visibility(
                  visible: userController.userState.value != null &&
                      cartController.cartItems.isNotEmpty,
                  child: BottomAppBar(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    height: kToolbarHeight,
                    color: Colors.white,
                    elevation: 0,
                    //padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                splashRadius: 2,
                                // controlAffinity:
                                //     ListTileControlAffinity.leading,
                                // contentPadding:
                                //     const EdgeInsets.symmetric(
                                //         horizontal: 0, vertical: 1),
                                side: const BorderSide(
                                    width: 2, color: Colors.black),
                                shape: const CircleBorder(),
                                // title: const Text(
                                //   "All",
                                //   style: TextStyle(
                                //     fontSize: 18,
                                //     fontWeight: FontWeight.w600,
                                //     color: Color(0xFF673AB7),
                                //     fontFamily: 'Lato',
                                //   ),
                                // ),
                                value: checkOutController
                                    .isMasterCheckboxChecked.value,
                                onChanged: (val) {
                                  checkOutController.toggleMasterCheckbox();
                                  // for (var item
                                  //     in checkOutController.checkoutList) {
                                  //   //print(item.price);
                                  //   print(item.quantity);
                                  // }
                                  checkOutController
                                      .getTotalPriceAndTotalQuantity();
                                  // Future.delayed(Duration(seconds: 2), () {
                                  //   checkOutController
                                  //       .getTotalPriceAndTotalQuantity();
                                  // });
                                },
                              ),
                              const Text(
                                "All",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF673AB7),
                                  fontFamily: 'Lato',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          "NGN${formatCurrency(checkOutController.totalPriceAndQuantity["totalPrice"].toString())}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF673AB7),
                            fontFamily: 'Lato',
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7),
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 8),
                            //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                            shape: RoundedRectangleBorder(
                              // side: const BorderSide(
                              //   width: 1,
                              //   color: Color(0xFF673AB7),
                              // ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (checkOutController.checkoutList.isEmpty) {
                              cartController.showMyToast(
                                  "Please Select at least 1 Product");
                              cartController.isVerified.value = false;
                            } else {
                              cartController.verifyCartItems(
                                  checkOutController.checkoutList);
                              if (cartController.verificationList
                                  .any((item) => item.isVerified != true)) {
                                debugPrint("check out list not verified");
                              } else {
                                Get.to(
                                  () => CartCheckoutPage(
                                      products:
                                          checkOutController.checkoutList),
                                );
                              }
                            }
                            // DataBaseService().addProduct();
                          },
                          child: GetX<CheckOutController>(
                            builder: (_) {
                              return Text(
                                "Check Out (${checkOutController.totalPriceAndQuantity["totalQuantity"] ?? 0})",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        );
      }
    });
  }
}
