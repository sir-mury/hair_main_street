import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_paystack_max/flutter_paystack_max.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/order_checkoutController.dart';
import 'package:hair_main_street/controllers/userController.dart';
import 'package:hair_main_street/models/orderModel.dart';
import 'package:hair_main_street/pages/orders_stuff/payment_successful_page.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:string_validator/string_validator.dart' as validator;
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:monnify_payment_sdk/monnify_payment_sdk.dart';

class PaymentPage extends StatefulWidget {
  String? expectedTimeToPay;
  DatabaseOrderResponse? orderDetails;
  PaymentPage({this.expectedTimeToPay, this.orderDetails, super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  TextEditingController amountPaidController = TextEditingController();
  UserController userController = Get.find<UserController>();
  CheckOutController checkOutController = Get.find<CheckOutController>();
  num amountPaid = 0;
  GlobalKey<FormState> formKey = GlobalKey();
  String? publicKey = dotenv.env["PAYSTACK_PUBLIC_KEY"];
  String? secretKey = dotenv.env["PAYSTACK_SECRET_KEY"];
  String? callbackUrl = dotenv.env["CALLBACK_URL"];
  String? monnifyAPIKey = dotenv.env["MONNIFY_API_KEY"];
  String? monnifyContractCode = dotenv.env["MONNIFY_CONTRACT_CODE"];
  Monnify? monnify;
  Orders? orders;
  String userEmail = "";

  initializeMonnify() async {
    ApplicationMode applicationMode =
        kDebugMode ? ApplicationMode.TEST : ApplicationMode.LIVE;
    try {
      monnify = await Monnify.initialize(
        applicationMode: ApplicationMode.TEST,
        apiKey: monnifyAPIKey!,
        contractCode: monnifyContractCode!,
      );
    } on PlatformException catch (e) {
      userController.showMyToast(
          "There was a problem initializing the payment gateway ${e.message}");
    }
  }

  @override
  void initState() {
    initializeMonnify();
    orders = convertDatabaseresponsetoOrderresponse(widget.orderDetails!);
    super.initState();
  }

  getUserEmail() async {
    var user =
        await userController.getUserDetails(widget.orderDetails!.buyerId!);
    userEmail = user!.email!;
  }

  Orders convertDatabaseresponsetoOrderresponse(
      DatabaseOrderResponse databaseOrderResponse) {
    return Orders(
      orderId: databaseOrderResponse.orderId,
      paymentPrice: databaseOrderResponse.paymentPrice,
      buyerId: databaseOrderResponse.buyerId,
      vendorId: databaseOrderResponse.vendorId,
      totalPrice: databaseOrderResponse.totalPrice,
      shippingAddress: databaseOrderResponse.shippingAddress,
      installmentNumber: databaseOrderResponse.installmentNumber,
      installmentPaid: databaseOrderResponse.installmentPaid,
      refundStatus: databaseOrderResponse.refundStatus,
      orderStatus: databaseOrderResponse.orderStatus,
      createdAt: databaseOrderResponse.createdAt,
      updatedAt: databaseOrderResponse.updatedAt,
      recipientCode: databaseOrderResponse.recipientCode,
      paymentMethod: databaseOrderResponse.paymentMethod,
      paymentStatus: databaseOrderResponse.paymentStatus,
      transactionID: databaseOrderResponse.transactionID,
    );
  }

  @override
  Widget build(BuildContext context) {
    num screenHeight = Get.height;
    num screenWidth = Get.width;
    String getReference() {
      String platform;
      if (Platform.isIOS) {
        platform = 'iOS';
      } else {
        platform = 'Android';
      }

      return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
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

    void showErrorDialog(String message) {
      Get.dialog(
        AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          elevation: 0,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          content: Text(
            message,
            style: const TextStyle(
              decoration: TextDecoration.none,
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.close(2),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        ),
      );
    }

    initiatePaymentMonnify({
      num? paymentPrice,
      String? orderID,
      String? email,
    }) async {
      String reference = getReference();
      TransactionDetails transactionDetails = TransactionDetails().copyWith(
        currencyCode: "NGN",
        customerEmail: email!,
        amount: paymentPrice!.toDouble(),
        paymentMethods: [
          PaymentMethod.CARD,
          PaymentMethod.USSD,
          PaymentMethod.ACCOUNT_TRANSFER,
          PaymentMethod.DIRECT_DEBIT,
        ],
        paymentReference: reference,
      );
      try {
        final response =
            await monnify?.initializePayment(transaction: transactionDetails);

        switch (response?.transactionStatus) {
          case "PAID":
            try {
              orders?.installmentPaid =
                  widget.orderDetails!.installmentPaid! + 1;
              orders?.transactionID = orders?.transactionID == null
                  ? [reference]
                  : [
                      ...widget.orderDetails!.transactionID!,
                      ...[reference]
                    ];
              orders?.paymentPrice =
                  widget.orderDetails!.paymentPrice! + paymentPrice;
              // orders.orderId = orderID;
              var result = await checkOutController.updateOrder(orders!);
              if (result == "success") {
                int installmentRemaining =
                    orders!.installmentNumber! - orders!.installmentPaid!;
                Get.to(
                  () => InstallmentPaymentSuccessfulPage(
                      installmentRemaining: installmentRemaining),
                );
              }
            } catch (e) {
              print("error: $e");
            }
            break;
          case "FAILED":
            showErrorDialog("Payment Failed");
            break;
          case "CANCELLED":
            showErrorDialog("Payment Cancelled");
            break;
          case null:
            showErrorDialog("Payment Failed");
            break;
          default:
            showErrorDialog("Payment Failed");
            break;
        }
      } on PlatformException catch (e) {
        // handle exceptions in here.
        userController
            .showMyToast("There was an error initiating payment ${e.message}");
      }
    }

    num amountRemaining = (widget.orderDetails!.totalPrice! -
        widget.orderDetails!.paymentPrice!.toInt());

    int installmentRemaining = widget.orderDetails!.installmentNumber! -
        widget.orderDetails!.installmentPaid!;

    returnOriginalVal(String val) {
      String originalString = val;
      int index = originalString.indexOf(".");

      if (index != -1) {
        String newString = originalString.substring(0, index);
        newString = newString.substring(3);
        newString = newString.splitMapJoin(",", onMatch: (e) => "");
        return newString;
      } else {
        print("Character not found");
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Complete Payment",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            fontFamily: "Lato",
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Symbols.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: userController.getUserDetails(widget.orderDetails!.buyerId!),
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }
            userEmail = snapshot.data!.email!;
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf5f5f5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                "OrderID: ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: "Raleway",
                                ),
                              ),
                              Text(
                                "${widget.orderDetails!.orderId}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Lato",
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              const Text(
                                "Total Product Price: ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                "NGN${formatCurrency(widget.orderDetails!.totalPrice.toString())}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Lato",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              const Text(
                                "Amount Paid: ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                "NGN${formatCurrency(widget.orderDetails!.paymentPrice.toString())}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Lato",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              const Text(
                                "Amount Remaining: ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                "NGN${formatCurrency(amountRemaining.toString())}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Lato",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              const Text(
                                "Installment Remaining: ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                "$installmentRemaining",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Lato",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              const Text(
                                "To be Paid Before: ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "${widget.expectedTimeToPay}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Lato",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextInputWidget(
                      labelText: "Amount to Pay",
                      fontSize: 18,
                      hintText:
                          "NGN${formatCurrency(installmentRemaining != 1 ? (amountRemaining / 2).toString() : amountRemaining.toString())}",
                      textInputType: TextInputType.number,
                      controller: amountPaidController,
                      asCurrency: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please Enter an Amount";
                        } else {
                          val = returnOriginalVal(val);
                          if (!validator.isNumeric(val!)) {
                            return "Must be a number";
                          } else if (installmentRemaining == 1 &&
                              num.parse(val) < (amountRemaining)) {
                            return "Must be the remaining amount to pay";
                          } else if (installmentRemaining == 2 &&
                              num.parse(val) < (amountRemaining * 0.5)) {
                            return "Must be at least 50% of the remaining amount to pay";
                          } else if (num.parse(val) > amountRemaining) {
                            return "Cannot be greater than amount remaining";
                          }
                        }
                        return null;
                      },
                      onChanged: (val) {
                        val!.isEmpty ? "" : amountPaidController.text = val;
                        amountPaid = num.parse(
                            returnOriginalVal(amountPaidController.text)!);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              bool validated = formKey.currentState!.validate();
              if (validated) {
                checkOutController.isLoading.value = true;
                if (checkOutController.isLoading.isTrue) {
                  Get.dialog(
                    const Center(child: CircularProgressIndicator()),
                  );
                }
                try {
                  initiatePaymentMonnify(
                    paymentPrice: amountPaid,
                    orderID: orders?.orderId,
                    email: userEmail,
                  );
                } catch (e) {
                  print(e);
                }
              }
            },
            child: const Text(
              "Pay Now",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: "Lato",
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
