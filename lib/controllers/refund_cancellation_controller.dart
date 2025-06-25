import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/models/refund_request_model.dart';
import 'package:hair_main_street/pages/orders_stuff/payment_successful_page.dart';
import 'package:hair_main_street/services/database.dart';

class RefundCancellationController extends GetxController {
  var isLoading = false.obs;
  var screenHeight = Get.height;

  //submit refund request
  submitRefundRequest(RefundRequest refundRequest) async {
    isLoading.value = true;
    var response = await DataBaseService().submitRefundRequest(refundRequest);
    if (response == "success") {
      isLoading.value = false;
      Get.snackbar(
        "Successful",
        "Refund Request Submitted",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.green[200],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.08,
        ),
      );
      Get.close(1);
      Get.to(
        () => RequestProcessingPage(
          thingBeingProcessed: "Refund",
          getTo: () {
            Get.offNamedUntil('/orders', ModalRoute.withName('/'));
          },
        ),
      );
    } else {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Submission Failed",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.red[400],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.08,
        ),
      );
    }
  }

  // cancellation request
  submitCancellationRequest(CancellationRequest cancellationRequest) async {
    isLoading.value = true;
    var response = await DataBaseService()
        .submitOrderCancellationRequest(cancellationRequest);
    if (response == "success") {
      isLoading.value = false;
      Get.snackbar(
        "Successful",
        "Order Cancellation Request Submitted",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.green[200],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.08,
        ),
      );
      Get.close(1);
      Get.to(
        () => RequestProcessingPage(
          thingBeingProcessed: "Cancellation",
          getTo: () {
            Get.offNamedUntil('/orders', ModalRoute.withName('/'));
          },
        ),
      );
    } else {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Submission Failed",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.red[400],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.08,
        ),
      );
    }
  }
}
