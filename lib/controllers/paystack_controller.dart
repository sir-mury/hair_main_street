import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:paystack_flutter_sdk/paystack_flutter_sdk.dart';

class PaystackController extends GetxController {
  RxString accessCode = ''.obs;
  final paystack = Paystack();
  RxString responseReference = "".obs;
  // This class will handle Paystack payment processing
  // Add methods for initializing payment, handling callbacks, etc.

  Future<String?> initializeSDK({
    required String publicKey,
    required bool enableLogging,
  }) async {
    try {
      bool isInitialized = await paystack.initialize(publicKey, enableLogging);
      if (isInitialized) {
        return "Initialized Sdk";
      } else {
        return "Failed to initialize SDK";
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  launchSdkUi({required String accessCode}) async {
    try {
      responseReference.value = "";
      var response = await paystack.launch(accessCode);
      if (response.status.toLowerCase() == 'success') {
        responseReference.value = response.reference;
        mySnackBar(
          color: Colors.green[200],
          textColor: Colors.black,
          message: "Payment Successful",
          title: "Success",
        );
      } else if (response.status.toLowerCase() == "cancelled") {
        mySnackBar(
          color: Colors.red,
          title: "Cancelled",
          message: "Payment Cancelled. Please try again.",
          textColor: Colors.white,
        );
      } else if (response.status.toLowerCase() == "failed") {
        mySnackBar(
          color: Colors.red,
          title: "Failed",
          message: "Failed to complete payment. Please try again.",
          textColor: Colors.white,
        );
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> initializePayment({
    required num amount,
    required String email,
    required String reference,
  }) async {
    //first reset accessCode
    accessCode.value = '';
    var response =
        await DataBaseService().initiateTransaction(amount, email, reference);
    if (response != null && response.runtimeType == String) {
      accessCode.value = response;
      // You can now use this access code to redirect to Paystack payment page
      // For example, you can use a webview or open a URL in the browser
      // Get.to(() => PaystackPaymentPage(accessCode: accessCode.value));
    } else {
      // Handle error
      mySnackBar(
        color: Colors.red,
        title: "Error",
        message: "Failed to initialize payment. Please try again.",
        textColor: Colors.white,
      );
      return;
    }
    // Logic to initialize payment with Paystack
  }

  void handlePaymentCallback() {
    // Logic to handle payment callback from Paystack
  }

  // Add more methods as needed for your application
  void mySnackBar(
      {Color? color, String? title, String? message, Color? textColor}) {
    double screenHeight = Get.height;
    Get.snackbar(
      colorText: textColor ?? Colors.white,
      title ?? "",
      message ?? "",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1, milliseconds: 800),
      forwardAnimationCurve: Curves.decelerate,
      reverseAnimationCurve: Curves.easeOut,
      backgroundColor: color ?? AppColors.shade2,
      margin: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: screenHeight * 0.08,
      ),
    );
  }
}
