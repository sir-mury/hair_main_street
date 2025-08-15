import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/aux_models.dart';
import 'package:hair_main_street/models/cart_item_model.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/loading.dart';

class CartController extends GetxController {
  RxList<CartItem> cartItems = <CartItem>[].obs;
  // num screenHeight = Get.height;
  RxBool isLoading = false.obs;
  RxInt currentPrice = 0.obs;
  RxInt quantity = 0.obs;
  RxBool isVerified = false.obs;
  RxList<VerificationItem> verificationList = <VerificationItem>[].obs;

  // @override
  // onInit() async {
  //   super.onInit();
  //   cartItems.bindStream(fetchCart());
  //   debugPrint("${cartItems}");
  // }

  // @override
  // onReady() {
  //   super.onReady();
  //   UserController userController = Get.find<UserController>();
  //   if (userController.userState.value != null) {
  //     fetchCart();
  //   }
  // }

  //get inventory of specific product
  Map<String, num> getInventoryOfProduct(String productID, String optionName) {
    ProductController productController = Get.find<ProductController>();
    Product? product = productController.products
        .firstWhereOrNull((element) => element!.productID == productID);
    if (product != null) {
      return determineQuantity(product, optionName);
    } else {
      return {"quantity": 0, "currentPrice": 0};
    }
  }

  //get product name by productID
  String getProductNameByID(String productID) {
    ProductController productController = Get.find<ProductController>();
    Product? product = productController.products
        .firstWhereOrNull((element) => element!.productID == productID);
    if (product != null) {
      return product.name ?? "Unknown Product";
    } else {
      return "Unknown Product";
    }
  }

  verifyCartItems(List<CheckOutTickBoxModel> checkoutList) {
    //this function aims to verify if the cart items are still valid
    ProductController productController = Get.find<ProductController>();
    verificationList.clear();

    //check that the product exists in the product list
    for (var cartItem in checkoutList) {
      if (productController.products
          .any((product) => product!.productID == cartItem.productID)) {
        // Check if the item already exists in checkoutList
        continue;
      } else {
        // If the product does not exist, alert user to remove it from cartItems
        showMyToast(
            "The product ${cartItem.productID} is no longer available. Please remove it from your cart.");
      }
    }

    //confirm that the quantity is not more than the stock available
    verificationList.value = List.generate(
      checkoutList.length,
      (index) {
        return VerificationItem(
          productID: checkoutList[index].productID!,
          isVerified: false,
        );
      },
      growable: true,
    );
    for (var cartItem in checkoutList) {
      //obtain the corresponding product of cart item
      var productQuantity = getInventoryOfProduct(
          cartItem.productID!, cartItem.optionName ?? "null")["quantity"];
      if (cartItem.quantity! <= productQuantity!) {
        for (var element in verificationList) {
          element.isVerified = true;
          // debugPrint("element: ${element.isVerified}");
        }
        // debugPrint("productQuantity: $productQuantity");
        // debugPrint("cartItemQuantity: ${cartItem.quantity}");
      } else {
        showMyToast(
          "Your product ${getProductNameByID(cartItem.productID!)} quantity is more than stock available",
          isShort: false,
        );
      }
    }
  }

  updateCheckoutList(CartItem cartitem) {
    //fetchCart();
    UserController userController = Get.find<UserController>();
    CheckOutController checkOutController = Get.find<CheckOutController>();
    MyUser user = userController.userState.value!;

    var index = checkOutController.checkoutList
        .indexWhere((element) => element.productID == cartitem.productID);

    if (index != -1) {
      debugPrint("after executing function: ${cartitem.price}");
      checkOutController.checkoutList[index] = CheckOutTickBoxModel(
        price: cartitem.price,
        quantity: cartitem.quantity,
        productID: cartitem.productID,
        user: user,
      );
      debugPrint(
          "checkoutlist data: ${checkOutController.checkoutList[index].price}");
      //update();
      checkOutController.getTotalPriceAndTotalQuantity();
      //checkOutController.checkoutList.refresh();
    } else {
      debugPrint("cannot update");
    }
  }

  addToCart(CartItem cartItem) async {
    isLoading.value = true;
    if (isLoading.value == true) {
      Get.dialog(
        const LoadingWidget(),
        barrierDismissible: false,
      );
    }
    var result = await DataBaseService().addToCart(cartItem);
    num screenHeight = Get.height;
    if (result != "Success") {
      isLoading.value = false;
      Get.back();
      Get.snackbar(
        "Error",
        "Problem adding to cart",
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
    } else {
      isLoading.value = false;
      Get.back();
      Get.snackbar(
        "Success",
        "Added to cart",
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
    }
  }

  void fetchCart() {
    debugPrint("fetching cart");
    ProductController productController = Get.find<ProductController>();
    var result = DataBaseService().fetchCartItems();
    num screenHeight = Get.height;
    if (result.runtimeType == Object) {
      Get.snackbar(
        "Error",
        "Failed to Fetch Cart",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.green[200],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.16,
        ),
      );
    } else {
      cartItems.clear();
      result.listen((cartItemsList) async {
        debugPrint("this has been called");
        if ((cartItemsList.isEmpty)) {
          cartItems.clear();
          return;
        } else {
          // debugPrint("products at start: ${productController.products.length}");
          for (var cartItem in cartItemsList) {
            if (productController.products.isEmpty) {
            } else {
              final productExists = productController.products.any((product) {
                return product != null &&
                    product.productID.toString() ==
                        cartItem.productID.toString();
              });
              if (productExists) {
                int index = cartItems.indexWhere(
                    (item) => item.cartItemID == cartItem.cartItemID);
                if (index == -1) {
                  cartItems.add(cartItem);
                } else {
                  cartItems[index] = cartItem;
                }
              } else {
                cartItems.removeWhere(
                    (item) => item.cartItemID == cartItem.cartItemID);
                var response = await DataBaseService()
                    .removeFromCart([cartItem.cartItemID]);
                // debugPrint("response: $response");
                if (response == "success") {
                  Get.snackbar(
                    "Warning",
                    "Some items were removed from your cart as they no longer are available",
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 1, milliseconds: 800),
                    forwardAnimationCurve: Curves.decelerate,
                    reverseAnimationCurve: Curves.easeOut,
                    backgroundColor: Colors.amber[200],
                    colorText: Colors.black,
                    margin: EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: screenHeight * 0.16,
                    ),
                  );
                }
              }
            }
          }
        }
      });
    }
  }

  //update cart items
  Future updateCartItem({
    String? cartItemID,
    int? newQuantity,
    String? productID,
  }) async {
    CheckOutController checkOutController = Get.find<CheckOutController>();
    isLoading.value = true;
    if (isLoading.value == true) {
      Get.dialog(
        const LoadingWidget(),
        barrierDismissible: false,
      );
    }
    var result = await DataBaseService().updateCartItemQuantityandPrice(
      cartItemID!,
      newQuantity!,
    );
    if (result == "success") {
      isLoading.value = false;
      Get.back();
      showMyToast("Operation Success");
      fetchCart();
      //checkOutController.updateCheckoutItemFromCartItems(cartItems);
      debugPrint(checkOutController.checkoutList.toString());

      // CartItem cartItem =
      //     cartItems.firstWhere((element) => element.cartItemID == cartItemID);
      // debugPrint(cartItem.price);
      // if (checkOutController.checkoutList
      //     .any((element) => element.productID == productID)) {
      //   CartItem cartItem =
      //       cartItems.firstWhere((element) => element.cartItemID == cartItemID);
      //   debugPrint(cartItem.price);
      //   updateCheckoutList(cartItem);
      // } else {
      //   debugPrint("Not inside");
      // }
    } else {
      isLoading.value = false;
      Get.back();
      showMyToast("Operation Failed");
    }
    update();
  }

  //helper function to compare two lists
  bool areListsEqual(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) return false;

    list1.removeWhere((element) => element == "null");
    list2.removeWhere((element) => element == "null");

    // Convert to sets (handles order, but null must be checked separately)
    final set1 = list1.toSet();
    final set2 = list2.toSet();

    return set1.containsAll(list2) && set2.containsAll(list1);
  }

  //function to determine quantity and current price based on product options
  Map<String, num> determineQuantity(Product? product, String? optionName) {
    // Default fallback
    if (product == null) return {"quantity": 0, "currentPrice": 0};

    // Handle products with options
    if (product.hasOptions == true && product.options != null) {
      try {
        if (optionName == null || optionName.isEmpty) {
          throw Exception("Option name is null or empty");
        }

        final parts = optionName.split('\n');
        final option = product.options!.firstWhere((opt) {
          return areListsEqual(
            [opt.color ?? "null", opt.length ?? "null"],
            parts,
          );
        });

        return {
          "quantity": option.stockAvailable ?? 0,
          "currentPrice": option.price ?? 0,
        };
      } catch (e) {
        debugPrint("No matching option found: $e");
        return {"quantity": 0, "currentPrice": product.price ?? 0};
      }
    } else {
      // Handle simple products (no options)
      return {
        "quantity": product.quantity ?? 0,
        "currentPrice": product.price ?? 0,
      };
    }
  }

  void showMyToast(String message, {bool isShort = true}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: isShort
          ? Toast.LENGTH_SHORT
          : Toast.LENGTH_LONG, // 3 seconds by default, adjust if needed
      gravity: ToastGravity.CENTER, // Position at the bottom of the screen
      //timeInSec: 0.3, // Display for 0.3 seconds (300 milliseconds)
      backgroundColor: AppColors.shade2, // Optional: Set background color
      textColor: Colors.black, // Optional: Set text color
      fontSize: 14.0,
      // Optional: Set font size
    );
  }
}

class WishListController extends GetxController {
  RxList<WishlistItem> wishListItems = <WishlistItem>[].obs;
  RxBool isEditingMode = false.obs;
  RxBool isLoading = false.obs;
  RxList<String> deletableItems = <String>[].obs;
  RxMap<String, RxBool> itemCheckboxState = RxMap<String, RxBool>();
  RxBool masterCheckboxState = false.obs;
  RxMap<String, bool> isLikedMap = RxMap<String, bool>();

  // @override
  // onInit() async {
  //   super.onInit();
  //   wishListItems.bindStream(fetchWishList());
  //   debugPrint("${wishListItems}");
  // }
  // Future<void> initializeIsLikedState(
  //     String productId, bool isUserLoggedIn) async {
  //   //debugPrint("is Called");
  //   debugPrint("calling productID: $productId");
  //   if (isUserLoggedIn) {
  //     await fetchWishList();
  //     if (wishListItems.isNotEmpty) {
  //       isLikedMap.putIfAbsent(
  //         productId,
  //         () => wishListItems.any((item) {
  //           debugPrint("executing now");
  //           return item.productID == productId;
  //         }),
  //       );
  //     } else {
  //       debugPrint("its empty");
  //     }
  //     update();
  //   }
  // }

  // Method to toggle wishlist status for a product
  // Future<void> toggleWishlistStatus(String productId) async {
  //   if (isLikedMap[productId] == true) {
  //     await removeFromWishlistWithProductID(productId);
  //     isLikedMap[productId] = false;
  //   } else {
  //     WishlistItem item = WishlistItem(productID: productId);
  //     await addToWishlist(item);
  //     isLikedMap[productId] = true;
  //   }
  // }

  //is product in wishlist
  bool isProductInWishlist(String productID, bool isUserLoggedIn) {
    // ProductController productController = Get.find<ProductController>();
    WishlistItem? result = wishListItems.firstWhereOrNull(
        (WishlistItem item) => item.wishListItemID == productID);

    return result != null ? true : false;
  }

  addToWishlist(WishlistItem wishlistItem) async {
    isLoading.value = true;
    var result = await DataBaseService().addToWishList(wishlistItem);
    num screenHeight = Get.height;
    if (result == 'not authorized') {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Problem adding to wishlist",
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
    } else if (result == 'new') {
      isLoading.value = false;
      Get.snackbar(
        "Success",
        "Added to wishList",
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
    } else if (result == 'exists') {
      isLoading.value = false;
      Get.snackbar(
        "Already in your wishlists",
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
    }
  }

  fetchWishList() {
    var result = DataBaseService().fetchWishListItems();
    num screenHeight = Get.height;
    if (result.runtimeType == Object) {
      Get.snackbar(
        "Error",
        "Failed to Fetch WishList",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.red[200],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.16,
        ),
      );
    }
    wishListItems.bindStream(result);
    update();
  }

  deleteFromWishlist() async {
    isLoading.value = true;
    //debugPrint(deletableItems.length);
    var result = await DataBaseService().removeFromWishList(deletableItems);
    num screenHeight = Get.height;

    if (result == 'success') {
      isLoading.value = false;
      Get.snackbar(
        "Deleted",
        "Successfully Deleted Items from Wishlist",
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
      return "success";
    } else {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Error Deleting Items from Wishlist",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.red[300],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.08,
        ),
      );
    }
    update();
  }

  removeFromWishlistWithProductID(String productID) async {
    isLoading.value = true;
    //debugPrint(deletableItems.length);
    num screenHeight = Get.height;

    var result =
        await DataBaseService().removeFromWishlistWithProductID(productID);
    if (result == 'success') {
      isLoading.value = false;
      Get.snackbar(
        "Success",
        "Removed from wishList",
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
      return "success";
    } else {
      isLoading.value = false;
      showMyToast("Problems removing from wishlist");
    }
    update();
  }

  toggleMasterCheckbox() {
    masterCheckboxState.value = !masterCheckboxState.value;
    itemCheckboxState.forEach((itemId, checkboxValue) {
      checkboxValue.value = masterCheckboxState.value;
      toggleCheckBox(checkboxValue.value, itemId);
    });
  }

  toggleCheckBox(bool value, String itemID) {
    debugPrint('pressed');
    itemCheckboxState[itemID]!.value = value;
    if (value) {
      bool itemExists = deletableItems.any((id) => id == itemID);

      if (!itemExists) {
        deletableItems.add(itemID);
      } else {}
    } else {
      deletableItems.removeWhere((id) => id == itemID);
    }
    update();
  }

  void showMyToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT, // 3 seconds by default, adjust if needed
      gravity: ToastGravity.BOTTOM, // Position at the bottom of the screen
      //timeInSec: 0.3, // Display for 0.3 seconds (300 milliseconds)
      backgroundColor:
          const Color(0xFFf5f5f5), // Optional: Set background color
      textColor: Colors.black, // Optional: Set text color
      fontSize: 14.0,
      // Optional: Set font size
    );
  }
}
