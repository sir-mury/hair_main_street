import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/cart_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/aux_models.dart';
import 'package:hair_main_street/models/cart_item_model.dart';
import 'package:hair_main_street/models/order_model.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/services/database.dart';

class CheckOutController extends GetxController {
  late CartController cartController = Get.find<CartController>();
  Rx<CheckoutItem> checkOutItem = CheckoutItem().obs;
  Rx<DatabaseOrderResponse?> singleOrder = Rx<DatabaseOrderResponse?>(null);
  //var checkoutList = <CheckOutTickBoxModel>[].obs;
  RxList<DatabaseOrderResponse> buyerOrderList =
      RxList<DatabaseOrderResponse>([]);
  RxList<DatabaseOrderResponse> vendorOrderList =
      RxList<DatabaseOrderResponse>([]);
  Rx<Orders?> order = Rx<Orders?>(null);
  Rx<OrderItem?> orderItem = Rx<OrderItem?>(null);
  RxMap<String, List<DatabaseOrderResponse>> buyerOrderMap =
      RxMap<String, List<DatabaseOrderResponse>>({});
  RxMap<String, List<DatabaseOrderResponse>> vendorOrdersMap =
      RxMap<String, List<DatabaseOrderResponse>>({});
  var orderUpdateStatus = "".obs;
  num screenHeight = Get.height;
  RxString userUID = "".obs;
  var isLoading = false.obs;
  var isChecked = false.obs;
  RxBool toRebuild = false.obs;
  var checkOutTickBoxModel = CheckOutTickBoxModel().obs;
// Map to store the checkbox state for each productID
  final Map<String, RxBool> itemCheckboxState = {};
  RxList<String> deletableCartItems = <String>[].obs;
  bool isMasterToggle = false;
  RxString initialValue = "this week".obs;

  // List to store selected items
  RxList<CheckOutTickBoxModel> checkoutList = <CheckOutTickBoxModel>[].obs;

  // RxBool for the master checkbox
  final RxBool isMasterCheckboxChecked = false.obs;

  RxMap totalPriceAndQuantity = {}.obs;

  // @override
  // void onReady() {
  //   super.onReady();
  //   //isChecked.value = isCheckedFunction(checkOutTickBoxModel.value);
  //   vendorOrderList.bindStream(getSellerOrders(userUID.value));
  //   buyerOrderList.bindStream(getBuyerOrders(userUID.value));
  //   debugPrint(vendorOrderList);
  // }
  @override
  void onInit() {
    super.onInit();
    initCartItemsListener();
  }

  void initializeCheckboxState(String cartItemId) {
    if (!itemCheckboxState.containsKey(cartItemId)) {
      itemCheckboxState[cartItemId] = false.obs;
    }
  }

  void initCartItemsListener() {
    final cartController = Get.find<CartController>();
    cartController.cartItems.listen((cartItems) {
      updateCheckoutItemFromCartItems(cartItems);
    });
  }

  void triggeRebuild() {
    toRebuild.value = !toRebuild.value;
  }

  //function to filter the buyer order list
  void filterTheBuyerOrderList(List<DatabaseOrderResponse> buyerOrder) {
    // No filter
    buyerOrderMap["All"] = buyerOrder;

    // Filter the once only payment method
    buyerOrderMap["Once"] = buyerOrder
        .where((order) =>
            order.paymentMethod != null && order.paymentMethod == "once")
        .toList();

    // Filter the installment only payment method
    buyerOrderMap["Installment"] = buyerOrder
        .where((order) =>
            order.paymentMethod != null && order.paymentMethod == "installment")
        .toList();

    // Filter the completed orders
    buyerOrderMap["Confirmed"] = buyerOrder
        .where((order) =>
            order.orderStatus != null && order.orderStatus == "confirmed")
        .toList();

    // Filter the cancelled orders
    buyerOrderMap["Cancelled"] = buyerOrder
        .where((order) =>
            order.orderStatus != null && order.orderStatus == "cancelled")
        .toList();

    // // Filter the deleted orders
    // buyerOrderMap["Deleted"] = buyerOrder
    //     .where((order) =>
    //         order.orderStatus != null && order.orderStatus == "deleted")
    //     .toList();

    // Filter the expired orders
    buyerOrderMap["Expired"] = buyerOrder
        .where((order) =>
            order.orderStatus != null && order.orderStatus == "expired")
        .toList();

    //debugPrint(buyerOrderMap["once"]!.length);
    // Update listeners after filtering
    // Assuming `buyerOrderMap` is an RxMap or similar reactive object
    buyerOrderMap.refresh();
  }

  //filter vendor orders
  void filterVendorOrdersList(List<DatabaseOrderResponse> vendorOrders) {
    // No filter
    vendorOrdersMap["All"] = vendorOrders;

    // Filter the once only payment method
    vendorOrdersMap["Active"] = vendorOrders
        .where(
          (order) =>
              order.orderStatus != null &&
              order.orderStatus != "expired" &&
              order.orderStatus != 'confirmed',
        )
        .toList();

    // Filter the expired orders
    vendorOrdersMap["Expired"] = vendorOrders
        .where((order) =>
            order.orderStatus != null && order.orderStatus == "expired")
        .toList();

    //
    vendorOrdersMap["Delivered"] = vendorOrders
        .where((order) =>
            order.orderStatus != null && order.orderStatus == "delivered")
        .toList();

    // Filter the cancelled orders
    vendorOrdersMap["Cancelled"] = vendorOrders
        .where((order) =>
            order.orderStatus != null && order.orderStatus == "cancelled")
        .toList();

    // Filter the completed orders
    vendorOrdersMap["Completed"] = vendorOrders
        .where((order) =>
            order.orderStatus != null && order.orderStatus == "confirmed")
        .toList();

    vendorOrdersMap.refresh();
  }

  //update checkoutlist based on cart items
  void updateCheckoutItemFromCartItems(List<CartItem> cartItems) {
    UserController userController = Get.find<UserController>();
    MyUser user = userController.userState.value!;

    for (var cartItem in cartItems) {
      int index = checkoutList
          .indexWhere((element) => element.cartID == cartItem.cartItemID);
      if (index != -1) {
        checkoutList[index] = CheckOutTickBoxModel(
          optionName: cartItem.optionName,
          price: cartItem.price,
          quantity: cartItem.quantity,
          productID: cartItem.productID,
          cartID: cartItem.cartItemID,
          user: user,
        );
      }
    }

    // Update the total price and quantity
    getTotalPriceAndTotalQuantity();
    update();
  }

  //get total sales
  RxMap<String, num> getTotalSales() {
    DateTime now = DateTime.now();
    RxMap<String, num> completedOrdersMap = {
      "this week": 0,
      "last week": 0,
      "this month": 0,
      "older": 0,
    }.obs;

    List<DatabaseOrderResponse>? completedOrders = vendorOrdersMap["Completed"];

    if (completedOrders != null) {
      for (var order in completedOrders) {
        DateTime updatedAt = order.updatedAt.toDate();
        int daysDifference = now.difference(updatedAt).inDays;

        if (order.paymentPrice != null) {
          if (daysDifference <= 7) {
            completedOrdersMap["this week"] =
                (completedOrdersMap["this week"] ?? 0) + order.paymentPrice!;
          } else if (daysDifference > 7 && daysDifference <= 14) {
            completedOrdersMap["last week"] =
                (completedOrdersMap["last week"] ?? 0) + order.paymentPrice!;
          } else if (daysDifference > 14 && daysDifference <= 30) {
            completedOrdersMap["this month"] =
                (completedOrdersMap["this month"] ?? 0) + order.paymentPrice!;
          } else {
            completedOrdersMap["older"] =
                (completedOrdersMap["older"] ?? 0) + order.paymentPrice!;
          }
        }
      }
    }

    return completedOrdersMap;
  }

  //update checkoutlist
  updateCheckoutList(CartItem cartitem) {
    //fetchCart();
    UserController userController = Get.find<UserController>();
    MyUser user = userController.userState.value!;

    var index = checkoutList
        .indexWhere((element) => element.productID == cartitem.productID);

    if (index != -1) {
      debugPrint("after executing function: ${cartitem.price}");
      checkoutList[index] = CheckOutTickBoxModel(
        price: cartitem.price,
        quantity: cartitem.quantity,
        productID: cartitem.productID,
        user: user,
      );
      debugPrint("checkoutlist data: ${checkoutList[index].price}");
      //update();
      getTotalPriceAndTotalQuantity();
      //checkOutController.checkoutList.refresh();
    } else {
      debugPrint("cannot update");
    }
  }

  //get total price and quantity in a checkout list
  void getTotalPriceAndTotalQuantity() {
    num totalPrice = 0.0;
    //num totalQuantity = 0.0;

    for (var item in checkoutList) {
      if (item.price != null && item.quantity != null) {
        totalPrice += item.price!;
        //totalQuantity += item.quantity;
      }
    }

    // Calculate total quantity in checkout list by summing up all product quantities
    num totalQuantity = checkoutList.length;

    totalPriceAndQuantity.value = {
      "totalPrice": totalPrice,
      "totalQuantity": totalQuantity,
    };
  }

  // Method to toggle the state of the master checkbox
  void toggleMasterCheckbox() {
    isMasterToggle = true;
    isMasterCheckboxChecked.value = !isMasterCheckboxChecked.value;

    itemCheckboxState.forEach((cartID, checkboxState) {
      checkboxState.value = isMasterCheckboxChecked.value;
      for (var cartItem in cartController.cartItems) {
        if (cartItem.cartItemID == cartID) {
          toggleCheckbox(
            productID: cartItem.productID,
            value: isMasterCheckboxChecked.value,
            quantity: cartItem.quantity!,
            price: cartItem.price!,
            cartID: cartItem.cartItemID,
            optionName: cartItem.optionName,
          );
          // break; // Exit the loop once the matching item is found
        }
      }
    });
    isMasterToggle = false;
  }

  // void toggleCheckbox({
  //   String? productID,
  //   bool? value,
  //   quantity,
  //   price,
  //   user,
  // }) {
  //   itemCheckboxState[productID]?.value = value!;
  //   if (value!) {
  //     // Add the item to the checkoutList
  //     checkoutList.add(
  //       CheckOutTickBoxModel(
  //         productID: productID,
  //         price: price,
  //         quantity: quantity,
  //         user: user,
  //         // Add other necessary properties
  //       ),
  //     );
  //   } else {
  //     // Remove the item from the checkoutList
  //     checkoutList.removeWhere((item) => item.productID == productID);
  //   }
  //   update();
  // }

  removeFromCart() async {
    isLoading.value = true;
    //debugPrint(deletableItems.length);
    var result = await DataBaseService().removeFromCart(deletableCartItems);
    if (result == 'success') {
      isLoading.value = false;
      Get.snackbar(
        "Deleted",
        "Successfully deleted item(s) from cart ",
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
      itemCheckboxState.clear();
      totalPriceAndQuantity.clear();
      cartController.fetchCart();
      checkoutList.clear();
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

  void toggleCheckbox({
    required String productID,
    required bool value,
    required int quantity,
    MyUser? user,
    required num price,
    required String cartID,
    String? optionName,
  }) {
    itemCheckboxState[cartID]?.value = value;

    if (value) {
      // Check if the item already exists in the checkoutList
      final existingItem = checkoutList.firstWhereOrNull((item) {
        if (optionName != null) {
          return item.cartID == cartID && item.optionName == optionName;
        } else {
          return item.cartID == cartID;
        }
      });
      // debugPrint("does it exist?:$existingItem");

      if (existingItem == null) {
        checkoutList.add(
          CheckOutTickBoxModel(
            productID: productID,
            cartID: cartID,
            price: price,
            quantity: quantity,
            user: user,
            optionName: optionName,
            // Add other necessary properties
          ),
        );
        deletableCartItems.add(cartID);
      }
    } else {
      checkoutList.removeWhere((item) {
        if (optionName != null) {
          return item.cartID == cartID && item.optionName == optionName;
        } else {
          return item.cartID == cartID;
        }
      });
      deletableCartItems.remove(cartID);
    }

    if (!isMasterToggle) {
      if (!value) {
        isMasterCheckboxChecked.value = false;
      } else {
        bool allSelected = itemCheckboxState.values
            .every((checkbox) => checkbox.value == true);
        isMasterCheckboxChecked.value = allSelected;
      }
    }

    // Update the state
    update();
  }

  createCheckOutItem(
    String productID,
    quantity,
    price,
    MyUser user,
  ) {
    checkOutItem.value = CheckoutItem(
      productId: productID,
      quantity: quantity.toString(),
      price: price.toString(),
      fullName: user.fullname,
      address: user.address,
      phoneNumber: user.phoneNumber,
      createdAt: DateTime.now().toString(),
    );
    return checkOutItem.value;
  }

  //create checkboxItem
  createCheckBoxItem(String productID, int quantity, num price, MyUser user,
      {String? optionName}) {
    var value = CheckOutTickBoxModel(
      productID: productID,
      quantity: quantity,
      price: price,
      user: user,
      optionName: optionName ?? "",
    );
    return value;
  }

  //create order
  Future<String> createOrder({
    String? paymentMethod,
    String? transactionID,
    String? productPrice,
    String? orderQuantity,
    String? productID,
    String? vendorID,
    Address? deliveryAddress,
    num? totalPrice,
    String? recipientCode,
    MyUser? user,
    num? paymentPrice,
    int? installmentNumber,
    int? installmentPaid,
    String? optionName,
  }) async {
    order.value = Orders(
        buyerId: user!.uid,
        vendorId: vendorID,
        installmentNumber: installmentNumber,
        paymentPrice: paymentPrice,
        installmentPaid: installmentPaid,
        shippingAddress: deliveryAddress,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
        recipientCode: recipientCode,
        paymentStatus: "paid",
        orderStatus: "created",
        transactionID: [transactionID]);
    orderItem.value = OrderItem(
      productId: productID,
      quantity: orderQuantity,
      price: productPrice,
      optionName: optionName,
    );

    var response =
        await DataBaseService().createOrder(order.value!, orderItem.value!);
    isLoading.value = true;
    if (response.keys.contains('Order Created')) {
      //isLoading.value = false;
      Get.snackbar(
        "Success",
        "Order has been placed",
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
      return 'success';
      // Timer(const Duration(seconds: 3), () {
      //   DataBaseService().updateWalletAfterOrderPlacement(
      //       order.value!.vendorId!,
      //       order.value!.paymentPrice!,
      //       response["Order Created"],
      //       "credit");
      // });
    } else {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Problem creating your order",
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
      return "failed";
    }
  }

  //update order status
  updateOrderStatus(String orderID, String orderStatus) async {
    var result =
        await DataBaseService().updateOrderStatus(orderID, orderStatus);
    if (result == "success") {
      Get.snackbar(
        "Success",
        "Order Status Updated",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 500),
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
        "Failed to update Order Status",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 500),
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

  //get buyer orders
  Stream<List<DatabaseOrderResponse>> getBuyerOrders(String userID) {
    var resultStream = DataBaseService().getBuyerOrdersStream(userID);
    resultStream.listen((buyerOrders) {
      buyerOrderList.assignAll(buyerOrders);
      filterTheBuyerOrderList(buyerOrders);
    });
    return resultStream;
  }

  //get sellers orders
  Stream<List<DatabaseOrderResponse>> getSellerOrders(String userID) {
    var resultStream = DataBaseService().getVendorsOrders(userID);
    resultStream.listen((buyerOrders) {
      vendorOrderList.assignAll(buyerOrders);
      filterVendorOrdersList(buyerOrders);
      //getTotalSales();
    });
    return resultStream;
  }

  //get single order irrespective of user
  Future<void> getSingleOrder(String orderID) async {
    isLoading.value = true;
    singleOrder.value = await DataBaseService().getSingleOrder(orderID);
    isLoading.value = false;
  }

  //update order
  Future updateOrder(Orders order) async {
    var result = await DataBaseService().updateOrder(order);
    if (result == "success") {
      orderUpdateStatus.value = result;
      Get.snackbar(
        "Success",
        "Order Status Updated",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 500),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.green[200],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.08,
        ),
      );
      orderUpdateStatus.value = "";
      return "success";
    } else {
      Get.snackbar(
        "Error",
        "Failed to update Order Status",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 500),
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

  //delete order
  Future deleteOrderBuyer(String orderID) async {
    var result = await DataBaseService().deleteBuyerOrder(orderID);
    if (result == "Order deleted successfully") {
      isLoading.value = false;
      Get.close(1);
      Get.snackbar(
        "Success",
        "Order Deleted",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 500),
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
    } else if (result == "Not authorized to delete this order") {
      isLoading.value = false;
      Get.close(1);
      Get.snackbar(
        "Error",
        "Not authorized to delete this order",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 500),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.yellow[200],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: screenHeight * 0.08,
        ),
      );
    } else {
      Get.close(1);
      Get.snackbar(
        "Error",
        "Failed to delete Order",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 500),
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

  //verify paystack transaction
  Future<bool> verifyTransaction({required String reference}) async {
    var response =
        await DataBaseService().verifyTransaction(reference: reference);
    return response;
  }
}
