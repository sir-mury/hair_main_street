import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/pages/homepage.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';

class ProfileController extends GetxController {
  RxList<Address?> deliveryAddress = <Address?>[].obs;
  RxString? fullname = "".obs;
  RxString? phoneNumber = "".obs;
  Rx<Address?> selectedAddress = Rx<Address?>(null);
  RxBool isProfileUpdated = false.obs;
  RxBool isDeliveryAddressAdded = false.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    ever(deliveryAddress, (newValue) {
      if (newValue.isNotEmpty) {
        isDeliveryAddressAdded.value = true;
      } else {
        isDeliveryAddressAdded.value = false;
      }
    });
    super.onInit();
  }

  void addAddressToAdresses() {
    deliveryAddress.add(selectedAddress.value);
    deliveryAddress.refresh();
    selectedAddress.value = null;
    // debugPrint("delivery address: ${deliveryAddress.first}");
    Get.close(1);
    mySnackBar(
      color: Colors.green[200],
      message: "New Delivery Address Added",
      title: "Success",
      textColor: AppColors.shade9,
    );
  }

  void editAtDeliveryAddress() {
    int index = deliveryAddress.indexOf(selectedAddress.value);
    if (index != -1) {
      deliveryAddress[index] = selectedAddress.value;
      deliveryAddress.refresh();
      selectedAddress.value = null;
      // debugPrint("Edited delivery address: ${deliveryAddress[index]}");
      Get.close(1);
      mySnackBar(
        color: Colors.green[200],
        message: "Delivery Address Edited",
        title: "Success",
        textColor: AppColors.shade9,
      );
    } else {
      mySnackBar(
        color: Colors.red[400],
        message: "Failed to edit Delivery Address",
        title: "Error",
        textColor: AppColors.offWhite,
      );
    }
  }

  Future<void> completeProfile() async {
    isLoading.value = true;
    Map<String, dynamic> profileFields = {
      "fullname": fullname?.value,
      "phonenumber": phoneNumber?.value,
    };
    UserController userController = Get.find<UserController>();

    //first update user profile
    var result = await userController.editUserProfile(profileFields);
    if (result.toLowerCase() == 'success') {
      isProfileUpdated.value = true;
    }

    //then create delivery addresses, ensure 1st one provided is set as default
    for (var address in deliveryAddress) {
      if (deliveryAddress.indexOf(address) == 0) {
        address!.isDefault = true;
      } else {
        address!.isDefault = false;
      }
      var response = await DataBaseService().addDeliveryAddresses(
        userController.userState.value!.uid!,
        address,
      );
      if (response.runtimeType == String &&
          response.toString().toLowerCase() == 'success') {
        isDeliveryAddressAdded.value = true;
      } else {
        isDeliveryAddressAdded.value = false;
      }
    }

    if (isDeliveryAddressAdded.isTrue && isProfileUpdated.isTrue) {
      isLoading.value = false;
      Get.off(() => HomePage());
      mySnackBar(
        color: Colors.green[200],
        title: "Success",
        message: "Profile Completed",
        textColor: AppColors.shade9,
      );
      isDeliveryAddressAdded.value = false;
      isProfileUpdated.value = false;
      fullname?.value = "";
      phoneNumber?.value = "";
      deliveryAddress.clear();
    } else {
      isLoading.value = false;
      //Get.close(1);
      mySnackBar(
        color: Colors.red[400],
        message: "Failed to update Profile",
        title: "Error",
        textColor: AppColors.offWhite,
      );
    }
  }

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

  void showMyToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      webBgColor: "#6736ab",
      webPosition: "center",
      toastLength: Toast.LENGTH_SHORT, // 3 seconds by default, adjust if needed
      gravity: ToastGravity.BOTTOM, // Position at the bottom of the screen
      //timeInSec: 0.3, // Display for 0.3 seconds (300 milliseconds)
      backgroundColor: AppColors.main, // Optional: Set background color
      textColor: Colors.white, // Optional: Set text color
      fontSize: 14.0, // Optional: Set font size
    );
  }
}
