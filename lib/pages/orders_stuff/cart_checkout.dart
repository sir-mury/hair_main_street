// import 'dart:io';

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/aux_models.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/pages/orders_stuff/cart_checkout_confimation.dart';
import 'package:hair_main_street/pages/profile/add_delivery_address.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:recase/recase.dart';
import 'package:string_validator/string_validator.dart' as validator;

class CartCheckoutPage extends StatefulWidget {
  final List<CheckOutTickBoxModel> products;
  const CartCheckoutPage({required this.products, super.key});

  @override
  State<CartCheckoutPage> createState() => _CartCheckoutPageState();
}

class _CartCheckoutPageState extends State<CartCheckoutPage> {
  UserController userController = Get.find<UserController>();
  ProductController productController = Get.find<ProductController>();
  CheckOutController checkOutController = Get.find<CheckOutController>();
  String? publicKey = dotenv.env["PAYSTACK_PUBLIC_KEY"];
  List<Map<String, dynamic>> productStates = [];
  List<TextEditingController> installementControllers = [];
  GlobalKey<FormState> formKey = GlobalKey();
  Address? selectedAddress;
  num totalPayableAmount = 0.0;
  num totalPrice = 0.0;
  Stream? myStream;

  @override
  void initState() {
    super.initState();
    myStream = DataBaseService()
        .getDeliveryAddresses(userController.userState.value!.uid!)
        .handleError((error) {
      Get.snackbar(
        "Error",
        "There was a problem fetching delivery addresses",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1, milliseconds: 800),
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        backgroundColor: Colors.red[200],
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: Get.height * 0.08,
        ),
      );
    });
    userController.getDeliveryAddresses(userController.userState.value!.uid!);
    productStates = List.generate(
        widget.products.length,
        (index) => {
              'paymentMethod': 'once',
              'numberOfInstallments': 3,
              'installmentAmountPaid': 0,
            });
    for (var i = 0; i < productStates.length; i++) {
      installementControllers.add(TextEditingController());
    }
    // if (userController.userState.value!.address != null) {
    //   Address myAddress = userController.userState.value!.address!;

    //   selectedAddress = myAddress;
    // }
    calculateTotal();
  }

  //calculate total Price
  calculateTotal() {
    for (var product in widget.products) {
      totalPrice += product.price!;
    }
  }

  calculatePayableAmount() {
    for (var element in productStates) {
      totalPayableAmount += element["installmentAmountPaid"];
    }
    return totalPayableAmount;
  }

  resetPayableAmount() {
    totalPayableAmount = 0.0;
  }

  String formatCurrency(String numberString) {
    final number =
        double.tryParse(numberString) ?? 0.0; // Handle non-numeric input
    final formattedNumber = number.toStringAsFixed(2); // Format with 2 decimals

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

  @override
  Widget build(BuildContext context) {
    // Product? product;
    // for (var item in widget.products) {
    //   product = productController.getSingleProduct(item.productID!);
    // }

    //error dialog handler
    // void showErrorDialog(String message) {
    //   Get.dialog(
    //     AlertDialog(
    //       contentPadding: const EdgeInsets.all(16),
    //       elevation: 0,
    //       backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
    //       content: Text(
    //         message,
    //         style: const TextStyle(
    //           decoration: TextDecoration.none,
    //           color: Colors.black,
    //           fontSize: 16,
    //           fontWeight: FontWeight.w700,
    //         ),
    //         textAlign: TextAlign.center,
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Get.back(),
    //           style: TextButton.styleFrom(
    //             backgroundColor: Colors.red.shade300,
    //           ),
    //           child: const Text(
    //             'Close',
    //             style: TextStyle(
    //               fontSize: 16,
    //               color: Colors.white,
    //             ),
    //           ),
    //         ),
    //       ],
    //       actionsAlignment: MainAxisAlignment.end,
    //     ),
    //   );
    // }

    //initiate paystack payment for a list of products
    // Future<void> _initiatePaymentForProducts(
    //   List<Map<String, dynamic>> productStates,
    //   String email,
    //   MyUser user,
    // ) async {
    //   Charge charge = Charge()
    //     ..amount = (totalPayableAmount.round()) * 100
    //     ..reference = _getReference()
    //     ..email = email;

    //   CheckoutResponse response = await plugin.checkout(
    //     context,
    //     method: CheckoutMethod.card,
    //     charge: charge,
    //   );
    //   if (response.status) {
    //     bool verified = await checkOutController.verifyTransaction(
    //         reference: response.reference!);
    //     print(response);
    //     print(response.reference);
    //     print("verified:$verified");
    //     if (verified) {
    //       try {
    //         for (var states in productStates) {
    //           int installmentPaid;
    //           var totalPrice = states["productPrice"];
    //           var productPrice =
    //               (states["productPrice"]) / states["orderQuantity"];
    //           if (states["paymentMethod"] == "installment") {
    //             installmentPaid = 1;
    //           } else {
    //             installmentPaid = 0;
    //           }
    //           checkOutController.createOrder(
    //             deliveryAddress: selectedAddress ?? user.address!,
    //             installmentPaid: installmentPaid,
    //             totalPrice: totalPrice,
    //             paymentMethod: states["paymentMethod"],
    //             paymentPrice: states["installmentAmountPaid"],
    //             productID: states["productID"],
    //             transactionID: response.reference,
    //             vendorID: states["vendorID"],
    //             installmentNumber: states["numberOfInstallments"],
    //             orderQuantity: states["orderQuantity"].toString(),
    //             productPrice: productPrice.toString(),
    //             user: user,
    //           );
    //         }

    //         Get.to(() => const PaymentSuccessfulPage());
    //         checkOutController.checkoutList.clear();
    //       } catch (e) {
    //         print("error: $e");
    //       }
    //     } else {
    //       showErrorDialog("An Error Occured in Payment");
    //     }
    //   } else {
    //     showErrorDialog("You Cancelled Your Payment");
    //   }
    // }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        userController.selectedAddress.value = null;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              userController.selectedAddress.value = null;
              Get.back();
            },
            icon: const Icon(Symbols.arrow_back_ios_new_rounded,
                size: 20, color: Colors.black),
          ),
          title: const Text(
            'Cart Checkout',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lato',
              color: Colors.black,
            ),
          ),
          centerTitle: false,
          // flexibleSpace: Container(
          //   decoration: BoxDecoration(gradient: appBarGradient),
          // ),
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: StreamBuilder(
              stream: myStream ?? Stream.empty(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Error loading data',
                          style: TextStyle(color: Colors.red),
                        ),
                        if (kDebugMode) // Only show error details in debug mode
                          Text(
                            snapshot.error.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                } else {
                  if (userController.deliveryAddresses.isNotEmpty &&
                      userController.selectedAddress.value == null) {
                    userController.selectedAddress.value =
                        userController.deliveryAddresses.firstWhereOrNull(
                                (value) => value!.isDefault == true) ??
                            userController.deliveryAddresses.firstOrNull;
                  }
                  return Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order Summary",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF673AB7)
                                  .withValues(alpha: 0.75),
                              fontFamily: 'Lato',
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          SingleChildScrollView(
                            child: Column(
                              children: buildOrderSummaryCard(),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Delivery Address",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF673AB7)
                                    .withValues(alpha: 0.75),
                                fontFamily: 'Lato'),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.to(() => const AddDeliveryAddressPage());
                                  // Get.dialog(
                                  //   ChangeAddressWidget(
                                  //     text: "Delivery Address",
                                  //     onFilled: onFilled,
                                  //   ),
                                  // );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: const Color(0xFF673AB7)
                                          .withValues(alpha: 0.65),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 130,
                                  width: 120,
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 35,
                                        color: Color(0xFF673AB7),
                                      ),
                                      Text(
                                        "Add new\naddress",
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Obx(
                                () => Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: userController
                                              .deliveryAddresses.isEmpty
                                          ? [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.red[300]!,
                                                    width: 1,
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                height: 130,
                                                width: 250,
                                                child: Center(
                                                  child: Text(
                                                    "You need to\nadd a\nDelivery Address",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Lato',
                                                      color: Colors.red[300],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]
                                          : buildAddressCard(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),
        ),
        bottomNavigationBar: SafeArea(
          child: BottomAppBar(
            elevation: 0,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: NGN${formatCurrency(totalPrice.toString())}",
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                    //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                    shape: RoundedRectangleBorder(
                      // side: const BorderSide(
                      //   width: 1.2,
                      //   color: Colors.black,
                      // ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    bool validate = formKey.currentState!.validate();
                    if (validate) {
                      if (userController.selectedAddress.value == null) {
                        userController
                            .showMyToast("Please Enter Your Delivery Address");
                      } else {
                        var value = calculatePayableAmount();
                        Get.to(
                          () => CartCheckoutConfirmationPage(
                            payableAmount: value,
                            productStates: productStates,
                            totalPrice: totalPrice,
                            products: widget.products,
                            selectedAddress:
                                userController.selectedAddress.value!,
                          ),
                        );
                        resetPayableAmount();
                      }
                    }
                  },
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildOrderSummaryCard() {
    return List.generate(widget.products.length, (index) {
      var myControllers = installementControllers;
      //totalPrice += widget.products[index].price!;
      // print(totalPrice);
      // print(widget.products[index].optionName);
      var theProduct =
          productController.getSingleProduct(widget.products[index].productID!);
      if (productStates.isNotEmpty &&
          productStates[index]["paymentMethod"] == "once") {
        productStates[index]["installmentAmountPaid"] =
            (widget.products[index].price!);
      }
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1,
            color: const Color(0xFF673AB7).withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: theProduct?.image?.isNotEmpty == true
                        ? theProduct!.image!.first
                        : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                    errorWidget: ((context, url, error) =>
                        const Text("Failed to Load Image")),
                    placeholder: ((context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        )),
                    imageBuilder: (context, imageProvider) => Container(
                      height: 140,
                      width: 130,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: SizedBox(
                    // height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${theProduct!.name}',
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lato',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Visibility(
                          visible: widget.products[index].optionName != null &&
                              widget.products[index].optionName!.isNotEmpty,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.5),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '${widget.products[index].optionName}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Lato',
                                color: Colors.black.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'NGN ${formatCurrency(widget.products[index].price.toString())}', // Replace with actual price
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF673AB7),
                                fontFamily: 'Lato',
                              ),
                            ),
                            Text(
                              'Qty: ${widget.products[index].quantity}pcs',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Lato',
                                color: Colors.black.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Payment Method:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontFamily: 'Lato',
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: PopupMenuButton<String>(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                elevation: 0,
                                color: Colors.white,
                                itemBuilder: (BuildContext context) {
                                  return <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'once',
                                      child: Text(
                                        'One Time Payment',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Lato',
                                        ),
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'installment',
                                      child: Text(
                                        'Pay in Installments',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Lato',
                                        ),
                                      ),
                                    ),
                                  ];
                                },
                                onSelected: (String value) {
                                  setState(() {
                                    productStates[index]["paymentMethod"] =
                                        value;
                                  });
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(6, 2, 6, 2),
                                  child: productStates.isNotEmpty
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                productStates[index]
                                                        ["paymentMethod"]
                                                    .toString()
                                                    .titleCase,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Lato',
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              size: 20,
                                            ),
                                          ],
                                        )
                                      : const Text("hello"),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Visibility(
                          visible: productStates.isNotEmpty
                              ? productStates[index]["paymentMethod"] ==
                                  "installment"
                              : false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'No of Installments:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Lato',
                                  color: Colors.black,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: PopupMenuButton<String>(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  color: Colors.white,
                                  elevation: 0,
                                  itemBuilder: (BuildContext context) {
                                    return <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: "2",
                                        child: Text(
                                          '2',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                            fontFamily: 'Lato',
                                          ),
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: '3',
                                        child: Text(
                                          '3',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                            fontFamily: 'Lato',
                                          ),
                                        ),
                                      ),
                                    ];
                                  },
                                  onSelected: (String value) {
                                    setState(() {
                                      productStates[index]
                                              ["numberOfInstallments"] =
                                          int.parse(value);
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(6, 2, 6, 2),
                                    child: productStates.isNotEmpty
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                productStates[index]
                                                        ["numberOfInstallments"]
                                                    .toString()
                                                    .titleCase,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  fontFamily: 'Lato',
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_drop_down,
                                                size: 20,
                                              ),
                                            ],
                                          )
                                        : const Text("hello"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Visibility(
                  visible: productStates.isNotEmpty
                      ? productStates[index]["paymentMethod"] == "installment"
                      : false,
                  child: TextFormField(
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: 'Lato',
                    ),
                    controller:
                        myControllers.isNotEmpty ? myControllers[index] : null,
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.red[300],
                      ),
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato',
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                      labelText: 'Initial Installment Amount (NGN)',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "You must specify an initial Amount";
                      }
                      if (!validator.isNumeric(value)) {
                        return "Must be a Number";
                      }
                      if (num.parse(value) > widget.products[index].price!) {
                        return "Amount cannot be more than Price";
                      }
                      if (productStates[index]["numberOfInstallments"] == 2 &&
                          num.parse(value) <
                              (widget.products[index].price! * 0.5)) {
                        return "Must be at least 50%";
                      }
                      if (productStates[index]["numberOfInstallments"] == 3 &&
                          num.parse(value) <
                              (widget.products[index].price! * 0.3)) {
                        return "Must be at least 30%";
                      } else {
                        return null;
                      }
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: Platform.isIOS
                        ? TextInputType.numberWithOptions()
                        : TextInputType.number,
                    onChanged: (value) {
                      if (value.isEmpty) {
                      } else {
                        setState(() {
                          myControllers[index].text = value;
                          productStates[index]["installmentAmountPaid"] =
                              num.parse(value);
                        });
                      }
                      debugPrint(productStates[index]["installmentAmountPaid"]);
                      // Handle initial payment amount input
                    },
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  List<Widget> buildAddressCard() {
    return List.generate(
      userController.deliveryAddresses.length,
      (index) {
        Address address = userController.deliveryAddresses[index]!;
        bool isSelected = userController.selectedAddress.value == address;
        return userController.isLoading.value == true
            ? const LoadingWidget()
            : GestureDetector(
                onTap: () {
                  setState(() {
                    userController.selectedAddress.value = address;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 130,
                  width: 250,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.shade2.withValues(alpha: 0.5)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.main : Colors.black,
                      width: isSelected ? 2 : 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${address.landmark ?? ""},${address.streetAddress},${address.lGA},${address.state}.${address.zipCode ?? ""}",
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "${address.contactName ?? ""}, ${address.contactPhoneNumber}",
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
  // String _getReference() {
  //   String platform;
  //   if (Platform.isIOS) {
  //     platform = 'iOS';
  //   } else {
  //     platform = 'Android';
  //   }

  //   return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  // }
}
