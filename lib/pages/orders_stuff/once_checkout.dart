import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_paystack_max/flutter_paystack_max.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/admin_controller.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/paystack_controller.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/aux_models.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/pages/orders_stuff/payment_successful_page.dart';
import 'package:hair_main_street/pages/profile/add_delivery_address.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:material_symbols_icons/symbols.dart';
// import 'package:paystack_flutter_sdk/paystack_flutter_sdk.dart';
// import 'package:monnify_payment_sdk/monnify_payment_sdk.dart';

class OnceCheckoutPage extends StatefulWidget {
  final List<CheckOutTickBoxModel> products;
  const OnceCheckoutPage({required this.products, super.key});

  @override
  State<OnceCheckoutPage> createState() => _OnceCheckoutPageState();
}

class _OnceCheckoutPageState extends State<OnceCheckoutPage> {
  UserController userController = Get.find<UserController>();
  ProductController productController = Get.find<ProductController>();
  CheckOutController checkOutController = Get.find<CheckOutController>();
  PaystackController paystackController = Get.find<PaystackController>();
  AdminController adminController = Get.find<AdminController>();
  String? publicKey = dotenv.env["PAYSTACK_PUBLIC_KEY"];
  String? livePublicKey = dotenv.env["PAYSTACK_LIVE_PUBLIC_KEY"];
  // String? monnifyAPIKey = dotenv.env["MONNIFY_API_KEY"];
  // String? monnifyContractCode = dotenv.env["MONNIFY_CONTRACT_CODE"];
  String? callbackUrl = dotenv.env["CALLBACK_URL"];
  // final plugin = PaystackPlugin();
  // late Monnify? monnify;
  Address? selectedAddress;
  num totalPrice = 0.0;
  Stream? myStream;
  Map<String, dynamic> valueReturned = {};

  //calculate total Price
  calculateTotal() {
    for (var product in widget.products) {
      totalPrice += product.price!;
    }
  }

  String? determinePublicKey() {
    debugPrint(
        "publickey: ${adminController.adminSettings.value!.isLive == true ? livePublicKey : publicKey}");
    return adminController.adminSettings.value!.isLive == true
        ? livePublicKey
        : publicKey;
  }

  // initializeMonnify() async {
  //   ApplicationMode applicationMode =
  //       kDebugMode ? ApplicationMode.TEST : ApplicationMode.LIVE;
  //   try {
  //     monnify = await Monnify.initialize(
  //       applicationMode: ApplicationMode.TEST,
  //       apiKey: monnifyAPIKey!,
  //       contractCode: monnifyContractCode!,
  //     );
  //   } on PlatformException catch (e) {
  //     userController.showMyToast(
  //         "There was a problem initializing the payment gateway ${e.message}");
  //   }
  // }

  @override
  void initState() {
    // plugin.initialize(publicKey: publicKey!);
    //  initializeMonnify();
    myStream = DataBaseService()
        .getDeliveryAddresses(userController.userState.value!.uid!)
        .handleError((error) {
      Get.snackbar(
        "Error",
        "There was a problem fetching delivery addresses",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.red[200],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: Get.height * 0.08,
        ),
      );
    });
    userController.getDeliveryAddresses(userController.userState.value!.uid!);
    calculateTotal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Product? product;
    for (var item in widget.products) {
      product = productController.getSingleProduct(item.productID!);
    }

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

    // //error dialog handler
    // void showErrorDialog(String message) {
    //   Get.dialog(
    //     AlertDialog(
    //       contentPadding: const EdgeInsets.all(16),
    //       elevation: 0,
    //       backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
    //       content: Text(
    //         message,
    //         style: const TextStyle(
    //           decoration: TextDecoration.none,
    //           color: Colors.black,
    //           fontSize: 16,
    //           fontWeight: FontWeight.w700,
    //         ),
    //         textAlign: TextAlign.center,
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Get.close(2),
    //           style: TextButton.styleFrom(
    //             backgroundColor: Colors.red.shade300,
    //           ),
    //           child: const Text(
    //             'Close',
    //             style: TextStyle(
    //               fontSize: 16,
    //               color: Colors.white,
    //             ),
    //           ),
    //         ),
    //       ],
    //       actionsAlignment: MainAxisAlignment.center,
    //     ),
    //   );
    // }

    createOrder({
      required int? paymentPrice,
      required String? email,
      required String? paymentMethod,
      required String? orderQuantity,
      required MyUser? user,
      required String? vendorID,
      required Product? product,
      required int? installmentNumber,
      required String? reference,
    }) async {
      int installmentPaid;
      if (installmentNumber != 0) {
        installmentPaid = 1;
      } else {
        installmentPaid = 0;
      }
      var productPrice = (totalPrice) / int.parse(orderQuantity!);
      var result = await checkOutController.createOrder(
        deliveryAddress: userController.selectedAddress.value ?? user!.address!,
        totalPrice: totalPrice,
        orderQuantity: orderQuantity,
        installmentPaid: installmentPaid,
        productID: product!.productID,
        productPrice: productPrice.toString(),
        paymentMethod: paymentMethod,
        paymentPrice: paymentPrice,
        transactionID: reference,
        user: user,
        vendorID: vendorID,
        installmentNumber: installmentNumber,
        optionName: widget.products[0].optionName,
      );
      if (result == 'success') {
        paystackController.isLoading.value = false;
        if (Get.isDialogOpen!) Get.back();
        Get.to(
          () => const PaymentSuccessfulPage(),
        );
      }
    }

    // //payment for paystack
    // initializePaymentPaystack({
    //   int? paymentPrice,
    //   String? email,
    //   String? paymentMethod,
    //   String? orderQuantity,
    //   MyUser? user,
    //   String? vendorID,
    //   Product? product,
    //   int? installmentNumber,
    // }) async {
    //   String reference = _getReference();
    //   final request = PaystackTransactionRequest(
    //     reference: reference,
    //     secretKey: secretKey!,
    //     email: email!,
    //     amount: (paymentPrice! * 100).toDouble(),
    //     currency: PaystackCurrency.ngn,
    //     channel: [
    //       PaystackPaymentChannel.mobileMoney,
    //       PaystackPaymentChannel.card,
    //       PaystackPaymentChannel.ussd,
    //       PaystackPaymentChannel.bankTransfer,
    //       PaystackPaymentChannel.bank,
    //       PaystackPaymentChannel.qr,
    //       PaystackPaymentChannel.eft,
    //     ],
    //   );

    //   final initializedTransaction =
    //       await PaymentService.initializeTransaction(request);

    //   if (!initializedTransaction.status) {
    //     Get.snackbar(
    //       "Error",
    //       initializedTransaction.message,
    //       backgroundColor: Colors.red.shade200,
    //       colorText: Colors.black,
    //       snackPosition: SnackPosition.BOTTOM,
    //       duration: Duration(
    //         milliseconds: 400,
    //       ),
    //     );
    //     return;
    //   }

    //   if (!mounted) return null;
    //   final response = await PaymentService.showPaymentModal(
    //     _paymentContext,
    //     transaction: initializedTransaction,
    //     callbackUrl: callbackUrl!,
    //   ).then((_) async {
    //     if (!mounted) return null;
    //     return await PaymentService.verifyTransaction(
    //       paystackSecretKey: secretKey!,
    //       initializedTransaction.data?.reference ?? request.reference,
    //     );
    //   });

    //   //print(response);
    //   switch (response?.data.status) {
    //     case PaystackTransactionStatus.success:
    //       int installmentPaid;
    //       if (installmentNumber != 0) {
    //         installmentPaid = 1;
    //       } else {
    //         installmentPaid = 0;
    //       }
    //       var totalPrice = product!.price!;
    //       var productPrice = (product.price!) / int.parse(orderQuantity!);
    //       var result = await checkOutController.createOrder(
    //         deliveryAddress:
    //             userController.selectedAddress.value ?? user!.address!,
    //         totalPrice: totalPrice,
    //         orderQuantity: orderQuantity,
    //         installmentPaid: installmentPaid,
    //         productID: product.productID,
    //         productPrice: productPrice.toString(),
    //         paymentMethod: paymentMethod,
    //         paymentPrice: paymentPrice,
    //         transactionID: reference,
    //         user: user,
    //         vendorID: vendorID,
    //         installmentNumber: installmentNumber,
    //         optionName: widget.products[0].optionName,
    //       );
    //       if (result == 'success') {
    //         checkOutController.isLoading.value = false;
    //         Get.to(
    //           () => const PaymentSuccessfulPage(),
    //         );
    //       }
    //       break;

    //     case PaystackTransactionStatus.failed:
    //       showErrorDialog("Payment Failed");
    //       break;
    //     case PaystackTransactionStatus.abandoned:
    //       showErrorDialog("Payment Abandoned");
    //       break;
    //     case null:
    //       showErrorDialog("Payment Failed");
    //       break;
    //     default:
    //       showErrorDialog("Payment Failed");
    //       break;
    //   }
    // }

    // //initiate payment with monnify
    // initiatePaymentMonnify({
    //   int? paymentPrice,
    //   String? email,
    //   String? paymentMethod,
    //   String? orderQuantity,
    //   MyUser? user,
    //   String? vendorID,
    //   Product? product,
    //   int? installmentNumber,
    // }) async {
    //   String reference = _getReference();
    //   TransactionDetails transactionDetails = TransactionDetails().copyWith(
    //     currencyCode: "NGN",
    //     customerEmail: email!,
    //     amount: paymentPrice!.toDouble(),
    //     paymentMethods: [
    //       PaymentMethod.CARD,
    //       PaymentMethod.USSD,
    //       PaymentMethod.ACCOUNT_TRANSFER,
    //       PaymentMethod.DIRECT_DEBIT,
    //     ],
    //     paymentReference: reference,
    //   );
    //   try {
    //     final response =
    //         await monnify?.initializePayment(transaction: transactionDetails);

    //     switch (response?.transactionStatus) {
    //       case "PAID":
    //         int installmentPaid;
    //         if (installmentNumber != 0) {
    //           installmentPaid = 1;
    //         } else {
    //           installmentPaid = 0;
    //         }
    //         var totalPrice = product!.price!;
    //         var productPrice = (product.price!) / int.parse(orderQuantity!);
    //         var result = await checkOutController.createOrder(
    //           deliveryAddress:
    //               userController.selectedAddress.value ?? user!.address!,
    //           totalPrice: totalPrice,
    //           orderQuantity: orderQuantity,
    //           installmentPaid: installmentPaid,
    //           productID: product.productID,
    //           productPrice: productPrice.toString(),
    //           paymentMethod: paymentMethod,
    //           paymentPrice: paymentPrice,
    //           transactionID: reference,
    //           user: user,
    //           vendorID: vendorID,
    //           installmentNumber: installmentNumber,
    //           optionName: widget.products[0].optionName,
    //         );
    //         if (result == 'success') {
    //           checkOutController.isLoading.value = false;
    //           Get.to(
    //             () => const PaymentSuccessfulPage(),
    //           );
    //         }
    //         break;

    //       case "FAILED":
    //         showErrorDialog("Payment Failed");
    //         break;
    //       case "CANCELLED":
    //         showErrorDialog("Payment Cancelled");
    //         break;
    //       case null:
    //         showErrorDialog("Payment Failed");
    //         break;
    //       default:
    //         showErrorDialog("Payment Failed");
    //         break;
    //     }
    //   } on PlatformException catch (e) {
    //     // handle exceptions in here.
    //     userController
    //         .showMyToast("There was an error initiating payment ${e.message}");
    //   }
    // }

    // showPaymentDialog({
    //   String? orderQuantity,
    //   Product? product,
    //   String? vendorID,
    //   String? paymentMethod,
    //   MyUser? user,
    //   int? paymentPrice,
    //   int? installmentNumber,
    //   String? email,
    // }) {
    //   return Get.dialog(
    //     AlertDialog(
    //       backgroundColor: Colors.white,
    //       alignment: Alignment.center,
    //       shape:
    //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    //       contentPadding: const EdgeInsets.all(8),
    //       elevation: 0,
    //       content: Column(
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.end,
    //             children: [
    //               InkWell(
    //                 radius: 40,
    //                 onTap: () {
    //                   !Get.isDialogOpen! ? Get.back() : Get.close(2);
    //                 },
    //                 child: const Padding(
    //                   padding: EdgeInsets.all(8.0),
    //                   child: Icon(
    //                     Icons.clear,
    //                     color: Colors.black,
    //                     size: 20,
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //           const SizedBox(
    //             height: 2,
    //           ),
    //           Align(
    //             alignment: Alignment.center,
    //             child: const Text(
    //               "Choose your payment gateway",
    //               style: TextStyle(
    //                 fontFamily: 'Lato',
    //                 fontSize: 16,
    //                 fontWeight: FontWeight.bold,
    //               ),
    //             ),
    //           ),
    //           const SizedBox(
    //             height: 8,
    //           ),
    //           const Text(
    //             "Choose between the various payment gateways we have available",
    //             style: TextStyle(
    //               fontFamily: 'Lato',
    //               fontSize: 13,
    //               fontWeight: FontWeight.w400,
    //             ),
    //             maxLines: 3,
    //             textAlign: TextAlign.center,
    //           ),
    //           const Divider(
    //             height: 12,
    //             color: Colors.grey,
    //             thickness: 1,
    //           ),
    //           InkWell(
    //             child: const SizedBox(
    //               width: double.infinity,
    //               child: Padding(
    //                 padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    //                 child: Text(
    //                   "Pay with Paystack",
    //                   textAlign: TextAlign.left,
    //                   style: TextStyle(
    //                     fontSize: 15,
    //                     color: Colors.black,
    //                     fontFamily: 'Lato',
    //                     fontWeight: FontWeight.w700,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             onTap: () async {
    //               Get.close(1);
    //               await initializePaymentPaystack(
    //                 orderQuantity: widget.products.first.quantity.toString(),
    //                 product: product,
    //                 vendorID: product!.vendorId,
    //                 paymentMethod: "once",
    //                 user: userController.userState.value,
    //                 paymentPrice: widget.products.first.price!.toInt(),
    //                 installmentNumber: 0,
    //                 email: userController.userState.value!.email!,
    //               );
    //             },
    //           ),
    //           const Divider(
    //             height: 4,
    //             color: Colors.grey,
    //             thickness: 1,
    //           ),
    //           InkWell(
    //             onTap: () async {
    //               Get.close(1);
    //               // await initiatePaymentMonnify(
    //               //   orderQuantity: widget.products.first.quantity.toString(),
    //               //   product: product,
    //               //   vendorID: product!.vendorId,
    //               //   paymentMethod: "once",
    //               //   user: userController.userState.value,
    //               //   paymentPrice: widget.products.first.price!.toInt(),
    //               //   installmentNumber: 0,
    //               //   email: userController.userState.value!.email!,
    //               // );
    //             },
    //             child: const SizedBox(
    //               width: double.infinity,
    //               child: Padding(
    //                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    //                 child: Text(
    //                   "Pay with Monnify",
    //                   textAlign: TextAlign.left,
    //                   style: TextStyle(
    //                     fontSize: 15,
    //                     color: Colors.black,
    //                     fontFamily: 'Lato',
    //                     fontWeight: FontWeight.w700,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //           // const SizedBox(
    //           //   width: 4,
    //           // ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        userController.selectedAddress.value = null;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              userController.selectedAddress.value = null;
              Get.back();
            },
            icon: const Icon(Symbols.arrow_back_ios_new_rounded,
                size: 20, color: Colors.black),
          ),
          title: const Text(
            'One Time Payment',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lato',
              color: Colors.black,
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: StreamBuilder(
              stream: myStream ?? Stream.empty(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Error loading data',
                          style: TextStyle(color: Colors.red),
                        ),
                        if (kDebugMode) // Only show error details in debug mode
                          Text(
                            snapshot.error.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                } else {
                  if (userController.deliveryAddresses.isNotEmpty &&
                      userController.selectedAddress.value == null) {
                    userController.selectedAddress.value =
                        userController.deliveryAddresses.firstWhereOrNull(
                                (value) => value!.isDefault == true) ??
                            userController.deliveryAddresses.firstOrNull;
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Summary",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF673AB7)
                                  .withValues(alpha: 0.75),
                              fontFamily: 'Lato'),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Column(
                          children:
                              List.generate(widget.products.length, (index) {
                            return summaryCard(product, index, formatCurrency);
                          }),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        Text(
                          "Delivery Address",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color:
                                const Color(0xFF673AB7).withValues(alpha: 0.75),
                            fontFamily: 'Lato',
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            // Add Address Button
                            InkWell(
                              onTap: () {
                                Get.to(() => const AddDeliveryAddressPage());
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xFF673AB7)
                                        .withValues(alpha: 0.65),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 130,
                                width: 120,
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 35,
                                      color: Color(0xFF673AB7),
                                    ),
                                    Text(
                                      "Add new\naddress",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 8), // Increased spacing

                            // Addresses List
                            Obx(() {
                              if (userController.deliveryAddresses.isEmpty) {
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.red[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    height: 130,
                                    width: 250,
                                    child: Center(
                                      child: Text(
                                        "You need to\nadd a\nDelivery Address",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Lato',
                                          color: Colors.red[300],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                // if (userController.deliveryAddresses.isNotEmpty &&
                                //     userController.selectedAddress.value ==
                                //         null) {
                                //   userController.selectedAddress.value =
                                //       userController.deliveryAddresses[0];
                                // }
                                // print(
                                //     "selectedAddress: ${userController.selectedAddress.value!}");
                                return addressCard();
                              }
                            }),
                          ],
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        Text(
                          "Payment",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color:
                                const Color(0xFF673AB7).withValues(alpha: 0.75),
                            fontFamily: 'Lato',
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          //margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: Colors.grey[200],
                            // border: Border.all(
                            //     width: 0.5, color: Colors.black.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Amount:",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Lato',
                                ),
                              ),
                              Text(
                                "NGN ${formatCurrency(totalPrice.toString())}",
                                style: const TextStyle(
                                  color: Color(0xFF673AB7),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Lato',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  );
                }
              }),
        ),
        bottomNavigationBar: SafeArea(
          child: BottomAppBar(
            elevation: 0,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: NGN${formatCurrency(totalPrice.toString())}",
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                    //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                    shape: RoundedRectangleBorder(
                      // side: const BorderSide(
                      //   width: 1.2,
                      //   color: Colors.black,
                      // ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (userController.selectedAddress.value == null) {
                      userController
                          .showMyToast("Please Enter Your Delivery Address");
                    } else {
                      paystackController.isLoading.value = true;
                      if (paystackController.isLoading.isTrue) {
                        Get.dialog(
                          const Center(child: LoadingWidget()),
                        );
                      }
                      // showPaymentDialog(
                      //   orderQuantity: widget.products.first.quantity.toString(),
                      //   product: product,
                      //   vendorID: product!.vendorId,
                      //   paymentMethod: "once",
                      //   user: userController.userState.value,
                      //   paymentPrice: widget.products.first.price!.toInt(),
                      //   installmentNumber: 0,
                      //   email: userController.userState.value!.email!,
                      // ),
                      //FOR NOW MONNIFY DOES NOT WORK
                      // !Platform.isIOS
                      //     ? await showPaymentDialog(
                      //         orderQuantity:
                      //             widget.products.first.quantity.toString(),
                      //         product: product,
                      //         vendorID: product!.vendorId,
                      //         paymentMethod: "once",
                      //         user: userController.userState.value,
                      //         paymentPrice:
                      //             widget.products.first.price!.toInt(),
                      //         installmentNumber: 0,
                      //         email: userController.userState.value!.email!,
                      //       )
                      // await initializePaymentPaystack(
                      //   orderQuantity:
                      //       widget.products.first.quantity.toString(),
                      //   product: product,
                      //   vendorID: product!.vendorId,
                      //   paymentMethod: "once",
                      //   user: userController.userState.value,
                      //   paymentPrice: widget.products.first.price!.toInt(),
                      //   installmentNumber: 0,
                      //   email: userController.userState.value!.email!,
                      // );

                      var sdkStatus = await paystackController.initializeSDK(
                        publicKey: determinePublicKey() ?? publicKey!,
                        enableLogging: true,
                      );

                      if (sdkStatus != null &&
                          sdkStatus.contains("Initialized Sdk")) {
                        await paystackController.initializePayment(
                          amount: widget.products.first.price!,
                          email: userController.userState.value!.email!,
                          reference: _getReference(),
                        );
                        if (paystackController.accessCode.value.isNotEmpty) {
                          var result = await paystackController.launchSdkUi(
                              accessCode: paystackController.accessCode.value);
                          if (result != null) {
                            String reference =
                                paystackController.responseReference.value;
                            await createOrder(
                              reference: reference,
                              product: product,
                              vendorID: product!.vendorId,
                              user: userController.userState.value!,
                              paymentMethod: "once",
                              paymentPrice:
                                  widget.products.first.price!.toInt(),
                              installmentNumber: 0,
                              email: userController.userState.value!.email!,
                              orderQuantity:
                                  widget.products.first.quantity.toString(),
                            );
                          }
                        }
                      } else {
                        Get.close(1);
                        paystackController.isLoading.value = false;
                        paystackController.mySnackBar(
                          title: "Error",
                          message: "Failed to initialize SDK",
                          color: Colors.red[400],
                          textColor: Colors.white,
                        );
                      }
                    }
                  },
                  child: const Text(
                    "Pay Now",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container summaryCard(Product? product, int index,
      String Function(String numberString) formatCurrency) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1,
          color: const Color(0xFF673AB7).withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: product?.image?.isNotEmpty == true &&
                      product!.image!.isNotEmpty
                  ? product.image!.first
                  : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
              errorWidget: ((context, url, error) =>
                  const Text("Failed to Load Image")),
              placeholder: ((context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )),
              imageBuilder: (context, imageProvider) => Container(
                height: 140,
                width: 130,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 6,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${product!.name}',
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontFamily: 'Lato',
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Visibility(
                  visible: widget.products[index].optionName != null &&
                      widget.products[index].optionName!.isNotEmpty,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '${widget.products[index].optionName}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato',
                        color: Colors.black.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  'Qty:${widget.products[index].quantity}pcs',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lato',
                    color: Colors.black.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "NGN ${formatCurrency(widget.products[index].price.toString())}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lato',
                    color: Color(0xFF673AB7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> getAccessCode(
      String reference, String email, num amount) async {
    String? accessCode =
        await DataBaseService().initiateTransaction(amount, email, reference);
    return accessCode ?? "";
  }

  Widget addressCard() {
    return Expanded(
      child: SizedBox(
        height: 130,
        // width: 250,
        child: ListView.builder(
          itemBuilder: (context, index) {
            final address = userController.deliveryAddresses[index];
            var isSelected = userController.selectedAddress.value == address;
            return GestureDetector(
              onTap: () {
                setState(() {
                  userController.selectedAddress.value = address;
                });
              },
              child: Container(
                margin: EdgeInsets.only(
                  left: index == 0 ? 4 : 8,
                  right: index == userController.deliveryAddresses.length - 1
                      ? 4
                      : 0,
                ),
                width: 250, // Fixed width for address cards
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.shade2.withValues(alpha: 0.5)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.main : Colors.black,
                    width: isSelected ? 2 : 0.5,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${address!.landmark ?? ""},${address.streetAddress ?? "No Street Address"},${address.lGA ?? "No LGA"},${address.state ?? "No State"}.${address.zipCode ?? ""}",
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      "${address.contactName ?? ""},${address.contactPhoneNumber ?? ""}",
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: userController.deliveryAddresses.length,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
        ),
      ),
    );
  }
}
