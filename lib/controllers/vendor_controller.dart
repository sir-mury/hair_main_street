import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/models/vendors_model.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:image_picker/image_picker.dart';

class VendorController extends GetxController {
  var productList = <Product>[].obs;
  Rx<Vendors?> vendor = Rx<Vendors?>(null);
  num screenHeight = Get.height;
  var vendorUID = "".obs;
  var isImageSelected = false.obs;
  var selectedImage = "".obs;
  var isLoading = false.obs;
  RxMap<String, List<Product>> filteredVendorProductList =
      RxMap<String, List<Product>>({});
  RxMap<String, List<Product>> filteredMapByAvailability =
      RxMap<String, List<Product>>({});

  // @override
  // void onInit() async {
  //   super.onInit();

  //   vendor.bindStream(getVendorDetails());
  //   //debugPrint(vendor.value!.firstVerification);
  // }

  // @override
  // void onReady() {
  //   super.onReady();
  //   if (vendorUID.value.isNotEmpty) {
  //     productList.bindStream(getVendorsProducts(vendorUID.value));
  //   } else {
  //     debugPrint("e choke");
  //   }
  //   // _subscription?.cancel();
  //   // _subscription = getVendorsProducts(vendorUID.value).listen((products) {
  //   //   debugPrint("products:${products.first.name}");
  //   //   productList.assignAll(products);
  //   // });
  // }

  // @override
  // void onClose() {
  //   _subscription?.cancel();
  //   super.onClose();
  // }

  // Stream<List<Vendors>> getVendors() {
  //   return DataBaseService().getVendors();
  // }

  ProductController productController = Get.find<ProductController>();
  //calculate average store rating
  double calculateOverallAverageReviewValue() {
    double totalAverageReviewValue = 0;

    for (var product in productList) {
      productController.getReviews(product.productID);
      var reviews = productController.reviews;
      debugPrint("reviews : $reviews");
      // debugPrint("reviews:$reviews");
      double averageReviewValueForProduct =
          calculateAverageReviewValue(reviews);

      totalAverageReviewValue += averageReviewValueForProduct;
      debugPrint("averageReviewValue: $averageReviewValueForProduct");
    }

    return totalAverageReviewValue / productList.length;
  }

  double calculateAverageReviewValue(dynamic reviews) {
    if (reviews.isEmpty) {
      return 0.0;
    }

    double totalStars = 0;
    for (var review in reviews) {
      totalStars += review.stars;
      debugPrint("totalstars:$totalStars");
    }

    return totalStars / reviews.length;
  }

  //filter vendor products with the age
  getProductsByAge(List<Product> vendorOrdersObject) {
    final now = DateTime.now();

    if (vendorOrdersObject.isEmpty) {
      filteredVendorProductList.clear();
    } else {
      filteredVendorProductList["Today"] = vendorOrdersObject
          .where((product) =>
              now.difference(product.createdAt!.toDate()).inHours < 24)
          .toList();

      filteredVendorProductList["Yesterday"] = vendorOrdersObject
          .where((product) =>
              now.difference(product.createdAt!.toDate()).inHours >= 24 &&
              now.difference(product.createdAt!.toDate()).inHours < 72)
          .toList();

      filteredVendorProductList["Last Week"] = vendorOrdersObject
          .where((product) =>
              now.difference(product.createdAt!.toDate()).inDays >= 3 &&
              now.difference(product.createdAt!.toDate()).inDays < 7)
          .toList();
      filteredVendorProductList["Last Month"] = vendorOrdersObject
          .where((product) =>
              now.difference(product.createdAt!.toDate()).inDays >= 7 &&
              now.difference(product.createdAt!.toDate()).inDays < 28)
          .toList();
      filteredVendorProductList["Older"] = vendorOrdersObject
          .where((product) =>
              now.difference(product.createdAt!.toDate()).inDays > 28)
          .toList();

      filteredVendorProductList.refresh();
    }
  }

  //filter by availability
  filterByAvailability(List<Product> vendorOrdersObject) {
    filteredMapByAvailability["All"] = vendorOrdersObject;

    filteredMapByAvailability["Available"] = vendorOrdersObject
        .where((product) => product.isAvailable == true)
        .toList();

    filteredMapByAvailability["Unavailable"] = vendorOrdersObject
        .where((product) => product.isAvailable == false)
        .toList();

    filteredVendorProductList.refresh();
  }

  void showMyToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT, // 3 seconds by default, adjust if needed
      gravity: ToastGravity.CENTER, // Position at the bottom of the screen
      //timeInSec: 0.3, // Display for 0.3 seconds (300 milliseconds)
      backgroundColor: Colors.white, // Optional: Set background color
      textColor: Colors.black, // Optional: Set text color
      fontSize: 14.0, // Optional: Set font size
    );
  }

  selectShopImage(ImageSource source, String imagePath) async {
    String? image = await DataBaseService().pickAndSaveImage(source, imagePath);
    if (image != null) {
      isImageSelected.value = true;
      selectedImage.value = image;
      debugPrint(selectedImage.value);
    }
  }

  shopImageUpload(List<File> images, String imagePath) async {
    var imageUrl = await DataBaseService().imageUpload(images, imagePath);
    var response = await updateVendor("shop picture", imageUrl.first);
    debugPrint(response);
    if (response == "success") {
      showMyToast("Image Upload Successful");
      Get.back();
      selectedImage.value = "";
      isImageSelected.value = false;
    } else {
      showMyToast("Error Uploading\nShop Image\nTry Again");
    }
  }

  deleteShopPicture(String downloadUrl, collection, fieldName, id) async {
    isLoading.value = true;
    var response = await DataBaseService()
        .deleteImage(downloadUrl, collection, id, fieldName);
    debugPrint(response);
    if (response == 'success') {
      isLoading.value = false;
      showMyToast("Image Deleted Successfully");
      Get.close(2);
    } else {
      isLoading.value = false;
      showMyToast("Problem Deleting Image");
    }
  }

  void getVendorsProducts(String vendorID) {
    productList.bindStream(DataBaseService().getVendorProducts(vendorID));
    //debugPrint(productList.value);
  }

  //getVendor
  getVendorDetails(String vendorID) {
    vendor.bindStream(DataBaseService().getVendorDetails(userID: vendorID));
  }

  //create or update vendor
  updateVendor(String fieldName, dynamic value) async {
    var result = await DataBaseService().updateVendor(fieldName, value);
    if (result == 'success') {
      Get.snackbar(
        "Success",
        "Updated Successfully",
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
      //Get.close(1);
      return "success";
    } else {
      Get.snackbar(
        "Error",
        "A problem occured",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.red[200],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.08,
        ),
      );
    }
  }

  //delete a product
  deleteProduct(Product product) async {
    var result = await DataBaseService().vendorSideDeleteProduct(product);
    if (result == "success") {
      //isProductadded.value = true;
      Get.snackbar(
        "Successful",
        "Product Deleted",
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
    } else {
      Get.snackbar(
        "Error",
        "Failed to Delete Product",
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

  //become a seller
  becomeASeller(Vendors vendor) async {
    var result = await DataBaseService().becomeASeller(vendor);
    if (result == 'success') {
      Get.snackbar(
        "Success",
        "",
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
    } else {
      Get.snackbar(
        "Error",
        "A problem occured",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.red[200],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.08,
        ),
      );
    }
  }
}
