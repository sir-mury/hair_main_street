import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/models/productModel.dart';
import 'package:hair_main_street/models/review.dart';
import 'package:hair_main_street/models/vendorsModel.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:http/http.dart' as http;

class ProductController extends GetxController {
  var toggleSelection = <bool>[].obs;
  Rx<ProductOption?> selectedProductOption = ProductOption().obs;
  RxList<Vendors?> vendorsList = RxList<Vendors?>();
  RxList<Product?> products = RxList<Product?>([]);
  RxList<Vendors?> filteredSearchVendorsList = RxList<Vendors?>();
  RxList<Product?> filteredSearchProducts = RxList<Product?>([]);
  RxList<Product?> seeAlsoProducts = RxList<Product?>([]);
  RxList<Review?> reviews = RxList<Review?>([]);
  RxMap<String, List<Product?>> productMap = RxMap<String, List<Product?>>();
  var isOptionVisible = false.obs;
  // VendorController vendorController = Get.find<VendorController>();
  RxList<File> imageList = RxList<File>([]);
  RxList<String> categories = [""].obs;
  var downloadUrls = [].obs;
  var isLoading = false.obs;
  var isProductadded = false.obs;
  var screenHeight = Get.height;
  var screenWidth = Get.width;
  var dismissible = true;
  var quantity = 1.obs;
  var isImageValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    var productList = fetchProducts();
    productList.listen((elements) {
      products.assignAll(elements);
      filterTheproductsList(elements);
    });
    vendorsList.bindStream(getVendors());
    if (products.isEmpty) {
      isLoading.value = true;
    } else {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onInit();
    getCategories();
  }

  //get categories
  getCategories() {
    var result = DataBaseService().getCategories();
    categories.bindStream(result);
  }

  //filter function dependent on input for search page
  // to be commented for now for possible use in the future
  // filterProductSearchResults(String filterParameter, dynamic filterValue) {
  //   RxList<Product?> originalFilteredProducts = filteredProducts;
  //   switch (filterParameter) {
  //     case "price":
  //       if (filterValue.runtimeType == List) {
  //         filteredProducts.value = filteredProducts.where((product) {
  //           return product!.price! >= filterValue[0] &&
  //               product.price! <= filterValue[1];
  //         }).toList();
  //       } else {}
  //       break;

  //     case "category":
  //       if (filterValue.runtimeType == String) {
  //         filteredProducts.value = filteredProducts
  //             .where((product) => product!.category! == filterValue)
  //             .toList();
  //       }
  //       break;

  //     case "cancel":
  //       filteredProducts = originalFilteredProducts;
  //       break;
  //     default:
  //       filteredProducts;
  //   }
  // }

  //function for handling search products
  void handleSearchProducts(query) {
    filteredSearchVendorsList.value = vendorsList
        .where((vendor) =>
            vendor!.shopName!.toLowerCase().contains(query!.toLowerCase()))
        .toList();
    filteredSearchProducts.value = products
        .where((product) =>
            product!.name!.toLowerCase().contains(query!.toLowerCase()))
        .toList();
  }

  //new function for filtering in search page
  void filterProductSearchResults({
    List<double>? priceRange,
    String? category,
  }) {
    // Store the original list to allow resetting or applying multiple filters
    RxList<Product?> originalFilteredProducts = filteredSearchProducts;
    print("the price range is $priceRange");

    // Start with the full list
    var filtered = originalFilteredProducts.toList();

    // Apply the price filter if a range is provided
    if (priceRange != null && priceRange.length == 2) {
      print("price range is $priceRange");
      filtered = filtered.where((product) {
        return product!.price! >= priceRange[0] &&
            product.price! <= priceRange[1];
      }).toList();
    }

    // Apply the category filter if a category is provided
    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((product) {
        return product!.category == category;
      }).toList();
    }

    // if both are null, restore the original list
    if (category == null && priceRange == null) {
      print(originalFilteredProducts);
      //filtered = originalFilteredProducts;
    }

    // Update the filteredProducts with the final filtered list
    filteredSearchProducts.value = filtered;
    debugPrint(filteredSearchProducts.toString());
    debugPrint(filtered.toString());
    filteredSearchProducts.refresh();
  }

  //filter products according to category
  void filterTheproductsList(List<Product?> products) {
    // No filter
    productMap["All"] = products;

    // Filter the once only payment method
    productMap["Natural Hairs"] = products
        .where((product) =>
            product!.category != null && product.category == "natural hairs")
        .toList();

    // Filter the installment only payment method
    productMap["Accessories"] = products
        .where((product) =>
            product!.category != null && product.category == "accessories")
        .toList();

    // Filter the completed orders
    productMap["Wigs"] = products
        .where((product) =>
            product!.category != null && product.category == "wigs")
        .toList();

    // Filter the cancelled orders
    productMap["Lashes"] = products
        .where((product) =>
            product!.category != null && product.category == "lashes")
        .toList();

    productMap.refresh();
  }

  Stream<List<Vendors>> getVendors() {
    return DataBaseService().getVendors();
  }

  checkValidity(String url) async {
    try {
      Uri uri = Uri.parse(url);
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        isImageValid.value = true;
      }
    } catch (e) {
      print(e);
    }
  }

  increaseQuantity() {
    quantity.value++;
    update();
  }

  decreaseQuantity() {
    if (quantity.value == 1) {
      quantity.value = 1;
    } else {
      quantity.value--;
    }
    update();
  }

  //fetch products
  Stream<List<Product?>> fetchProducts() {
    return DataBaseService().fetchProducts();
  }

  //get single product
  Product? getSingleProduct(String id) {
    Product product = Product();
    for (var element in products) {
      if (element!.productID.toString().toLowerCase() == id.toLowerCase()) {
        product = element;
      }
    }
    return product;
  }

  //add a product
  addAProduct(Product product) async {
    var result = await DataBaseService().addProduct(product: product);
    if (result == "success") {
      isProductadded.value = true;
      Get.snackbar(
        "Successful",
        "Product Added",
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
      imageList.clear();
      downloadUrls.clear();
    } else {
      Get.snackbar(
        "Error",
        "Product Upload Failed",
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

  //select image from file system
  selectImage() async {
    var images = await DataBaseService().createLocalImages();
    if (images.isNotEmpty) {
      for (File photo in images) {
        imageList.add(photo);
        showMyToast("Image Added");
      }
    }
  }

// flutter toast
  void showMyToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT, // 3 seconds by default, adjust if needed
      gravity: ToastGravity.CENTER, // Position at the bottom of the screen
      //timeInSec: 0.3, // Display for 0.3 seconds (300 milliseconds)
      backgroundColor:
          const Color(0xFFf5f5f5), // Optional: Set background color
      textColor: Colors.black, // Optional: Set text color
      fontSize: 14.0, // Optional: Set font size
    );
  }

  //upload image
  uploadImage() async {
    var result = await DataBaseService().uploadProductImage(imageList);
    if (result.isNotEmpty) {
      showMyToast("Photos uploaded successfully!");
      downloadUrls.value = result;
      imageList.clear();
    } else {
      showMyToast("Problems Occured while Uploading Photos");
    }
  }

  deleteProductImage(
      String downloadUrl, collection, fieldName, id, int index) async {
    var response = await DataBaseService()
        .deleteImage(downloadUrl, collection, id, fieldName, index: index);
    if (response == 'success') {
      isLoading.value = false;
      showMyToast("Image Deleted Successfully");
      update();
    } else {
      isLoading.value = false;
      showMyToast("Problem Deleting Image");
      update();
    }
  }

  //upload a product Image
  // uploadImage() async {
  //   var image = await DataBaseService().uploadProductImage();
  //   if (image == null) {}
  //   imageList.value = image ?? [];
  //   print("imageList:${imageList}");
  //   for (var imageRef in imageList) {
  //     if (imageRef.state == TaskState.success) {
  //       var downloadUrl = await imageRef.ref.getDownloadURL();
  //       downloadUrls.add(downloadUrl);
  //     }
  //   }
  // }

  //update a product
  updateProduct(Product product) async {
    isLoading.value = true;
    var result = await DataBaseService().updateProduct(product: product);
    if (result == "success") {
      isLoading.value = false;
      Get.snackbar(
        "Successful",
        "Product Edited",
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
    } else {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Product Edit Failed",
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

  //delete a product
  deleteProduct(Product product) async {
    var result = await DataBaseService().vendorSideDeleteProduct(product);
    if (result == "success") {
      isProductadded.value = true;
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
      Get.close(2);
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

  //get reviews of products
  dynamic getReviews(String? productID) {
    // print("running this get review function");
    reviews.bindStream(DataBaseService().getReviews(productID!));
    // print(reviews);
  }

  //get vendors list
  Vendors clientGetVendorName(String vendorID) {
    Vendors vendorDetails = Vendors();
    for (var vendor in vendorsList) {
      if (vendor!.userID == vendorID) {
        vendorDetails = vendor;
      }
    }
    return vendorDetails;
  }

  void toggleOption(int index, Product product) {
    toggleSelection[index] = !toggleSelection[index];
    selectedProductOption.value = product.options![index];
    update(); // This will trigger a rebuild of the widgets that use this controller
  }

  void deleteLocalImage(int index) async {
    await imageList[index].delete();
    update();
  }
}
