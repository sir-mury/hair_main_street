import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/admin_controller.dart';
import 'package:hair_main_street/controllers/cart_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/models/review.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/models/vendors_model.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';
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
  RxInt stockRemaining = 0.obs;
  var downloadUrls = [].obs;
  var isLoading = false.obs;
  var isProductadded = false.obs;
  var screenHeight = Get.height;
  var screenWidth = Get.width;
  var dismissible = true;
  var quantity = 1.obs;
  var isImageValid = false.obs;
  RxBool isProductLoaded = false.obs;
  Timer? fetchCartDebounce;

  @override
  void onInit() {
    super.onInit();

    Get.put(CartController());
    var productList = fetchProducts();
    productList.listen((elements) {
      if (elements.isEmpty) {
        isProductLoaded.value = false;
        return;
      } else {
        products.assignAll(elements);
        isProductLoaded.value = true;
        filterTheproductsList(elements);
      }
      // cartController.refresh();
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
    super.onReady();
    getCategories();
    UserController userController = Get.find<UserController>();
    CartController cartController = Get.find<CartController>();

    // bool isLoggedIn = userController.userState.value != null;
    void safeFetchCart() {
      // Cancel previous pending call
      fetchCartDebounce?.cancel();

      // Schedule new call with 300ms delay
      fetchCartDebounce = Timer(const Duration(milliseconds: 300), () {
        if (userController.userState.value != null &&
            isProductLoaded.value &&
            products.isNotEmpty) {
          cartController.fetchCart();
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initial fetch
      safeFetchCart();
    });

// Then modify your ever() listeners:
    ever(userController.userState, (user) => safeFetchCart());
    ever(isProductLoaded, (loaded) => safeFetchCart());
    ever(products, (products) => safeFetchCart());
  }

  @override
  void onClose() {
    super.onClose();
    // Clean up resources if needed
    fetchCartDebounce?.cancel();
    vendorsList.close();
    products.close();
    filteredSearchVendorsList.close();
    filteredSearchProducts.close();
    reviews.close();
    productMap.close();
    imageList.close();
    categories.close();
    downloadUrls.close();
    isLoading.close();
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
    debugPrint("the price range is $priceRange");

    // Start with the full list
    var filtered = originalFilteredProducts.toList();

    // Apply the price filter if a range is provided
    if (priceRange != null && priceRange.length == 2) {
      debugPrint("price range is $priceRange");
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
      debugPrint(originalFilteredProducts.toString());
      filtered = originalFilteredProducts;
    }

    // Update the filteredProducts with the final filtered list
    filteredSearchProducts.value = filtered;
    debugPrint(filteredSearchProducts.toString());
    debugPrint(filtered.toString());
    filteredSearchProducts.refresh();
  }

  //filter products according to category
  void filterTheproductsList(List<Product?> products) {
    AdminController adminController = Get.find<AdminController>();
    // No filter
    productMap["All"] = products;

    if (products.isNotEmpty) {
      // Filter the once only payment method
      for (var category in adminController.adminSettings.value!.categories!) {
        productMap[category] = products
            .where((product) =>
                product!.category != null && product.category == category)
            .toList();
      }
    }

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
      debugPrint(e.toString());
    }
  }

  increaseQuantity({required Product product, ProductOption? selectedOption}) {
    int stockAvailable = determineQuantity(product, selectedOption) ?? 0;
    if (stockAvailable > quantity.value) {
      quantity.value++;
    } else {
      showMyToast("Cannot be more than stock available");
    }
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

  //determineStock
  int? determineQuantity(Product? product, ProductOption? selectedOption) {
    // Default fallback
    if (product == null) return 0;

    // Handle products with options
    if (product.hasOptions == true && product.options != null) {
      try {
        return product.options!
            .firstWhere((option) => option == selectedOption)
            .stockAvailable;
      } catch (e) {
        debugPrint("No matching option found: $e");
        return 0;
      }
    } else {
      // Handle simple products (no options)
      return product.quantity!;
    }
  }

  //determine if product exist
  determineIfProductExist(Product product) {
    stockRemaining.value = 0;
    if (product.hasOptions! && product.options != null) {
      int? stockRemainingLoop = 0;
      for (var option in product.options!) {
        stockRemainingLoop = stockRemainingLoop! + option.stockAvailable!;
      }
      stockRemaining.value = stockRemainingLoop!;
    } else {
      stockRemaining.value = product.quantity ?? 0;
    }
  }

  //fetch products
  Stream<List<Product?>> fetchProducts() {
    var stream = DataBaseService().fetchVerifiedProducts();
    isLoading.value = true;
    stream.listen((data) {
      products.value = data;
      isLoading.value = false;
    });
    return stream;
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
      backgroundColor: AppColors.shade2, // Optional: Set background color
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
  //   debugPrint("imageList:${imageList}");
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
    // debugPrint("running this get review function");
    reviews.bindStream(DataBaseService().getReviews(productID!));
    // debugPrint(reviews);
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
