import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_paystack_max/flutter_paystack_max.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/admin_controller.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/paystack_controller.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/aux_models.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/pages/orders_stuff/payment_successful_page.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:material_symbols_icons/symbols.dart';
// import 'package:monnify_payment_sdk/monnify_payment_sdk.dart';
import 'package:recase/recase.dart';

class CartCheckoutConfirmationPage extends StatefulWidget {
  final List<CheckOutTickBoxModel> products;
  final List<Map<String, dynamic>> productStates;
  final num? payableAmount;
  final num totalPrice;
  final Address selectedAddress;
  const CartCheckoutConfirmationPage({
    required this.payableAmount,
    required this.productStates,
    required this.totalPrice,
    required this.products,
    required this.selectedAddress,
    super.key,
  });

  @override
  State<CartCheckoutConfirmationPage> createState() =>
      _CartCheckoutConfirmationPageState();
}

class _CartCheckoutConfirmationPageState
    extends State<CartCheckoutConfirmationPage> {
  UserController userController = Get.find<UserController>();
  ProductController productController = Get.find<ProductController>();
  CheckOutController checkOutController = Get.find<CheckOutController>();
  PaystackController paystackController = Get.find<PaystackController>();
  AdminController adminController = Get.find<AdminController>();
  String? publicKey = dotenv.env["PAYSTACK_PUBLIC_KEY"];
  String? livePublicKey = dotenv.env["PAYSTACK_LIVE_PUBLIC_KEY"];

  String? monnifyAPIKey = dotenv.env["MONNIFY_API_KEY"];
  String? monnifyContractCode = dotenv.env["MONNIFY_CONTRACT_CODE"];
  // Monnify? monnify;
  String? callbackUrl = dotenv.env["CALLBACK_URL"];
  num? payableAmount;

  @override
  void initState() {
    payableAmount = widget.payableAmount;
    // initializeMonnify();
    super.initState();
  }

  bool determineIfLive() {
    return adminController.adminSettings.value!.isLive == true ? true : false;
  }

  String? determinePublicKey() {
    return adminController.adminSettings.value!.isLive == true
        ? livePublicKey
        : publicKey;
  }

  // initializeMonnify() async {
  //   monnify = await Monnify.initialize(
  //     applicationMode: ApplicationMode.TEST,
  //     apiKey: monnifyAPIKey!,
  //     contractCode: monnifyContractCode!,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // bool transactionInitialized = false;
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

    //create order
    Future createOrder({
      required List<Map<String, dynamic>> productStates,
      required String reference,
      required MyUser user,
    }) async {
      bool allSuccess = false;
      List<String> orderResults = [];
      try {
        for (var states in productStates) {
          int installmentPaid;
          var totalPrice = states["productPrice"];
          var productPrice = (totalPrice) / states["orderQuantity"];
          if (states["paymentMethod"] == "installment") {
            installmentPaid = 1;
          } else {
            installmentPaid = 0;
          }

          var result = await checkOutController.createOrder(
            deliveryAddress: widget.selectedAddress,
            installmentPaid: installmentPaid,
            totalPrice: totalPrice,
            paymentMethod: states["paymentMethod"],
            paymentPrice: states["installmentAmountPaid"],
            productID: states["productID"],
            transactionID: reference,
            vendorID: states["vendorID"],
            installmentNumber: states["numberOfInstallments"],
            orderQuantity: states["orderQuantity"].toString(),
            productPrice: productPrice.toString(),
            user: user,
          );
          orderResults.add(result);
          allSuccess = orderResults.every((result) => result == 'success');
        }
        if (allSuccess == true) {
          paystackController.isLoading.value = false;
          if (Get.isDialogOpen!) Get.back();
          Get.to(() => const PaymentSuccessfulPage());
          checkOutController.checkoutList.clear();
        }
      } catch (e) {
        debugPrint("error: $e");
      }
    }

    //error dialog handler
//     void showErrorDialog(String message) {
//       Get.dialog(
//         AlertDialog(
//           contentPadding: const EdgeInsets.all(16),
//           elevation: 0,
//           backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
//           content: Text(
//             message,
//             style: const TextStyle(
//               decoration: TextDecoration.none,
//               color: Colors.black,
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Get.close(2),
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.red.shade300,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               child: const Text(
//                 'Close',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//           actionsAlignment: MainAxisAlignment.center,
//         ),
//       );
//     }

// // Helper method to handle successful payment
//     Future<void> handleSuccessfulPayment(
//       List<Map<String, dynamic>> productStates,
//       String reference,
//       MyUser user,
//     ) async {
//       try {
//         for (var states in productStates) {
//           int installmentPaid;
//           var totalPrice = states["productPrice"];
//           var productPrice = (states["productPrice"]) / states["orderQuantity"];
//           if (states["paymentMethod"] == "installment") {
//             installmentPaid = 1;
//           } else {
//             installmentPaid = 0;
//           }

//           var result = await checkOutController.createOrder(
//             deliveryAddress: widget.selectedAddress,
//             installmentPaid: installmentPaid,
//             totalPrice: totalPrice,
//             paymentMethod: states["paymentMethod"],
//             paymentPrice: states["installmentAmountPaid"],
//             productID: states["productID"],
//             transactionID: reference,
//             vendorID: states["vendorID"],
//             installmentNumber: states["numberOfInstallments"],
//             orderQuantity: states["orderQuantity"].toString(),
//             productPrice: productPrice.toString(),
//             user: user,
//           );

//           if (result == 'success') {
//             if (mounted) {
//               Get.to(() => const PaymentSuccessfulPage());
//               checkOutController.checkoutList.clear();
//             }
//             break; // Exit loop after first success
//           }
//         }
//       } catch (e) {
//         debugPrint("error: $e");
//       }
//     }

// Helper method for error dialogs
    // void showErrorDialog2(String message) {
    //   if (mounted) {
    //     showErrorDialog(message);
    //   }
    // }

    // //initialise payment for paystack
    // initializePaymentPaystack(
    //   List<Map<String, dynamic>> productStates,
    //   String email,
    //   MyUser user,
    // ) async {
    //   String reference = _getReference();
    //   final request = PaystackTransactionRequest(
    //     reference: reference,
    //     secretKey: secretKey!,
    //     email: email,
    //     amount: (widget.payableAmount!.toDouble() * 100),
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
    //       duration: const Duration(
    //         milliseconds: 400,
    //       ),
    //     );
    //     return;
    //   }

    //   // Use a completer to handle the modal and verification separately
    //   final Completer<PaystackTransactionVerified?> completer = Completer();

    //   // Show modal in a separate function that doesn't cross async gaps
    //   WidgetsBinding.instance.addPostFrameCallback((_) async {
    //     if (!mounted) {
    //       completer.complete(null);
    //       return;
    //     }

    //     try {
    //       await PaymentService.showPaymentModal(
    //         context,
    //         transaction: initializedTransaction,
    //         callbackUrl: callbackUrl!,
    //       );

    //       if (!mounted) {
    //         completer.complete(null);
    //         return;
    //       }

    //       final verificationResponse = await PaymentService.verifyTransaction(
    //         paystackSecretKey: secretKey!,
    //         initializedTransaction.data?.reference ?? request.reference,
    //       );

    //       completer.complete(verificationResponse);
    //     } catch (e) {
    //       completer.complete(null);
    //     }
    //   });

    //   final response = await completer.future;

    //   if (!mounted) return;

    //   //print(response);
    //   switch (response?.data.status) {
    //     case PaystackTransactionStatus.success:
    //       await handleSuccessfulPayment(productStates, reference, user);
    //       break;

    //     case PaystackTransactionStatus.failed:
    //       showErrorDialog2("Payment Failed");
    //       break;
    //     case PaystackTransactionStatus.abandoned:
    //       showErrorDialog2("Payment Abandoned");
    //       break;
    //     case null:
    //       showErrorDialog2("Payment Failed");
    //       break;
    //     default:
    //       showErrorDialog2("Payment Failed");
    //       break;
    //   }
    // }

    // //initiate monnify payment for a list of products
    // initatePaymentForProducts(
    //   List<Map<String, dynamic>> productStates,
    //   String email,
    //   MyUser user,
    // ) async {
    //   String reference = _getReference();
    //   TransactionDetails transactionDetails = TransactionDetails().copyWith(
    //     currencyCode: "NGN",
    //     customerEmail: email,
    //     amount: (widget.payableAmount!.toDouble()),
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
    //         try {
    //           for (var states in productStates) {
    //             int installmentPaid;
    //             var totalPrice = states["productPrice"];
    //             var productPrice =
    //                 (states["productPrice"]) / states["orderQuantity"];
    //             if (states["paymentMethod"] == "installment") {
    //               installmentPaid = 1;
    //             } else {
    //               installmentPaid = 0;
    //             }
    //             var result = await checkOutController.createOrder(
    //               deliveryAddress: widget.selectedAddress,
    //               installmentPaid: installmentPaid,
    //               totalPrice: totalPrice,
    //               paymentMethod: states["paymentMethod"],
    //               paymentPrice: states["installmentAmountPaid"],
    //               productID: states["productID"],
    //               transactionID: reference,
    //               vendorID: states["vendorID"],
    //               installmentNumber: states["numberOfInstallments"],
    //               orderQuantity: states["orderQuantity"].toString(),
    //               productPrice: productPrice.toString(),
    //               user: user,
    //             );
    //             if (result == 'success') {
    //               Get.to(
    //                 () => const PaymentSuccessfulPage(),
    //               );
    //               checkOutController.checkoutList.clear();
    //             }
    //           }
    //         } catch (e) {
    //           print("error: $e");
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
    //   } catch (e) {
    //     // handle exceptions in here.
    //   }
    // }

    // showPaymentDialog(
    //   List<Map<String, dynamic>> productStates,
    //   String email,
    //   MyUser user,
    // ) {
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
    //                 widget.productStates,
    //                 userController.userState.value!.email!,
    //                 userController.userState.value!,
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
    //               // await initatePaymentForProducts(
    //               //   widget.productStates,
    //               //   userController.userState.value!.email!,
    //               //   userController.userState.value!,
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
      onPopInvokedWithResult: (bool didPop, value) async {
        if (didPop) {
          payableAmount = 0.0;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Symbols.arrow_back_ios_new_rounded,
                size: 20, color: Colors.black),
          ),
          title: const Text(
            'Check Out Confirmation',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lato',
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          // flexibleSpace: Container(
          //   decoration: BoxDecoration(gradient: appBarGradient),
          // ),
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order Finalization",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF673AB7).withValues(alpha: 0.75),
                    fontFamily: 'Lato',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                ...List.generate(widget.products.length, (index) {
                  var theProduct = productController
                      .getSingleProduct(widget.products[index].productID!);
                  widget.productStates[index]["vendorID"] =
                      theProduct!.vendorId;
                  widget.productStates[index]["productID"] =
                      theProduct.productID;
                  widget.productStates[index]["orderQuantity"] =
                      widget.products[index].quantity!;
                  widget.productStates[index]["productPrice"] =
                      widget.products[index].price!;
                  // if (productStates[index]["paymentMethod"] == "once") {
                  //   productStates[index]["numberOfInstallments"] = 0;
                  // } else {
                  //   productStates[index]["numberOfInstallments"] = 3;
                  // }
                  // totalPayableAmount +=
                  //     productStates[index]["installmentAmountPaid"];
                  // print(totalPayableAmount);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1,
                        color: const Color(0xFF673AB7).withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: theProduct.image?.isNotEmpty == true
                                ? theProduct.image!.first
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
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${theProduct.name}',
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Lato',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Visibility(
                                visible:
                                    widget.products[index].optionName != null &&
                                        widget.products[index].optionName!
                                            .isNotEmpty,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          Colors.black.withValues(alpha: 0.5),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    '${widget.products[index].optionName}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Lato',
                                      color:
                                          Colors.black.withValues(alpha: 0.65),
                                    ),
                                  ),
                                ),
                              ),
                              widget.products[index].optionName != null &&
                                      widget.products[index].optionName!
                                          .isNotEmpty
                                  ? const SizedBox(height: 8)
                                  : const SizedBox.shrink(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'NGN${formatCurrency(widget.products[index].price.toString())}', // Replace with actual price
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF673AB7),
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                  Text(
                                    'Qty: ${widget.products[index].quantity}pcs', // Replace with actual quantity
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Lato',
                                      color:
                                          Colors.black.withValues(alpha: 0.65),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Payment Method:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                  Text(
                                    widget.productStates[index]["paymentMethod"]
                                        .toString()
                                        .titleCase,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Visibility(
                                visible: widget.productStates[index]
                                        ["paymentMethod"] ==
                                    "installment",
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'No of Installments:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                    Text(
                                      widget.productStates[index]
                                              ["numberOfInstallments"]
                                          .toString()
                                          .titleCase,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Visibility(
                                visible: widget.productStates[index]
                                        ["paymentMethod"] ==
                                    "installment",
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Installment Amount: ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromRGBO(0, 0, 0, 1),
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                    Text(
                                      'NGN${formatCurrency(widget.productStates[index]["installmentAmountPaid"].toString())}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: BottomAppBar(
            elevation: 0,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: kToolbarHeight * 1.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Payment Amount:",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withValues(alpha: 0.70),
                      ),
                    ),
                    Text(
                      "NGN${formatCurrency(widget.payableAmount.toString())}",
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF673AB7),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total: NGN${formatCurrency(widget.totalPrice.toString())}",
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 20),
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
                        paystackController.isLoading.value = true;
                        if (paystackController.isLoading.value) {
                          Get.dialog(
                            const LoadingWidget(),
                          );
                          //FOR NOW MONNIFY DOES NOT WORK
                          // !Platform.isIOS
                          //     ? await showPaymentDialog(
                          //         widget.productStates,
                          //         userController.userState.value!.email!,
                          //         userController.userState.value!,
                          //       )
                          // await initializePaymentPaystack(
                          //   widget.productStates,
                          //   userController.userState.value!.email!,
                          //   userController.userState.value!,
                          // );

                          var sdkStatus =
                              await paystackController.initializeSDK(
                            publicKey: determinePublicKey() ?? publicKey!,
                            enableLogging: true,
                          );

                          if (sdkStatus != null &&
                              sdkStatus.contains("Initialized Sdk")) {
                            await paystackController.initializePayment(
                              amount: widget.payableAmount!,
                              email: userController.userState.value!.email!,
                              reference: _getReference(),
                              isLive: determineIfLive(),
                            );
                            if (paystackController
                                .accessCode.value.isNotEmpty) {
                              var result = await paystackController.launchSdkUi(
                                  accessCode:
                                      paystackController.accessCode.value);
                              if (result != null) {
                                String reference =
                                    paystackController.responseReference.value;
                                await createOrder(
                                  productStates: widget.productStates,
                                  user: userController.userState.value!,
                                  reference: reference,
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
                )
              ],
            ),
          ),
        ),
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
}
