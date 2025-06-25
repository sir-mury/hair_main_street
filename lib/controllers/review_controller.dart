import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/models/review.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:image_picker/image_picker.dart';

class ReviewController extends GetxController {
  RxList<File> imageList = RxList<File>([]);
  var myReviews = [].obs;
  num screenHeight = Get.height;
  RxList<String> selectedImageList = RxList([]);
  var isImageSelected = false.obs;
  var downloadUrls = <String>[].obs;
  var isLoading = false.obs;

  void showMyToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT, // 3 seconds by default, adjust if needed
      gravity: ToastGravity.CENTER, // Position at the bottom of the screen
      //timeInSec: 0.3, // Display for 0.3 seconds (300 milliseconds)
      backgroundColor:
          const Color(0xFFf5f5f5), // Optional: Set background color
      textColor: Colors.black,
      fontSize: 14.0, // Optional: Set font size
    );
  }

  //select image from file system
  selectImage(ImageSource source, String imagePath) async {
    String? image = await DataBaseService().pickAndSaveImage(source, imagePath);
    if (image != null) {
      isImageSelected.value = true;
      imageList.add(File(image));
      debugPrint(imageList.toString());
    }
  }

  //upload image
  uploadImage(List<File?> reviewImageList) async {
    var result = await DataBaseService()
        .imageUpload(reviewImageList.cast<File>(), "review images");
    if (result.isNotEmpty) {
      showMyToast("Review Photos Added!");
      downloadUrls.addAll(result);
    } else {
      showMyToast("Problems Occured while Uploading Photos");
    }
  }

  addAReview(Review review, String productID) async {
    var result = await DataBaseService().addAReview(review, productID);
    debugPrint(result);
    if (result == "success") {
      Get.snackbar(
        "Successful",
        "Review Submitted",
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
      Get.back();
    } else {
      Get.snackbar(
        "Error",
        "Review Submission Failed",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: const Color.fromARGB(255, 221, 179, 178),
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.08,
        ),
      );
    }
  }

  //edit
  editReview(Review review) async {
    var response = await DataBaseService().editReview(review);
    debugPrint("response $response");
    if (response == "success") {
      isLoading.value = false;
      Get.snackbar(
        "Successful",
        "Review Edited",
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
      Get.close(2);
      downloadUrls.clear();
    } else {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Failed to Edit Review",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: const Color.fromARGB(255, 221, 179, 178),
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.08,
        ),
      );
    }
  }

  //delete review
  deleteReview(String reviewID) async {
    var response = await DataBaseService().deleteReview(reviewID);
    update();
    if (response == "success") {
      isLoading.value = false;
      Get.snackbar(
        "Successful",
        "Review Deleted",
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
      Get.back();
    } else {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Failed to Delete Review",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: const Color.fromARGB(255, 221, 179, 178),
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.08,
        ),
      );
    }
  }

  getMyReviews(String userId) {
    myReviews.bindStream(DataBaseService().getUserReviews(userId));
  }

  Review? getSingleReview(String reviewID) {
    Review review = Review(comment: "", stars: 0);
    for (var element in myReviews) {
      if (element!.reviewID.toString().toLowerCase() ==
          reviewID.toLowerCase()) {
        review = element;
      }
    }
    return review;
  }
}
