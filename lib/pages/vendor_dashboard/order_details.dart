import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/order_model.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/pages/messages.dart';
import 'package:hair_main_street/pages/product_page.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:material_symbols_icons/symbols.dart';

class VendorOrderDetailsPage extends StatefulWidget {
  final DatabaseOrderResponse? orderDetails;
  final Product? product;
  const VendorOrderDetailsPage({this.orderDetails, this.product, super.key});

  @override
  State<VendorOrderDetailsPage> createState() => _VendorOrderDetailsPageState();
}

class _VendorOrderDetailsPageState extends State<VendorOrderDetailsPage> {
  final GetStorage box = GetStorage();

  late String? dropDownValue;

  UserController userController = Get.find<UserController>();
  CheckOutController checkOutController = Get.find<CheckOutController>();

  ///String selectedStatus = "created";

  @override
  void initState() {
    super.initState();
    if (widget.orderDetails!.buyerId != null) {
      userController.getBuyerDetails(widget.orderDetails!.buyerId!);
    } else {
      userController.buyerDetails.value = null;
    }
    _loadSelectedStatus();
  }

  Future<void> _loadSelectedStatus() async {
    dropDownValue = widget.orderDetails!.orderStatus;
    box.write('dropDownValue', dropDownValue);
    setState(() {});
  }

  Future<void> _saveSelectedStatus(String value) async {
    await box.write('dropDownValue', value);
  }

  @override
  Widget build(BuildContext context) {
    //MyUser? buyerDetails = userController.buyerDetails.value;

    DateTime resolveTimestampWithoutAdding(Timestamp timestamp) {
      DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime

      // Add days to the DateTime
      //DateTime newDateTime = dateTime.add(Duration(days: daysToAdd));

      return dateTime;
    }

    // String resolveTimestamp(Timestamp timestamp, int daysToAdd) {
    //   DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime

    //   // Add days to the DateTime
    //   DateTime newDateTime = dateTime.add(Duration(days: daysToAdd));

    //   // Format the DateTime without the time part
    //   String formattedDate = DateFormat('yyyy-MM-dd').format(newDateTime);

    //   return formattedDate;
    // }

    String formatCurrency(String numberString) {
      final number =
          double.tryParse(numberString) ?? 0.0; // Handle non-numeric input
      final formattedNumber =
          number.toStringAsFixed(2); // Format with 2 decimals

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

    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Symbols.arrow_back_ios_new_rounded,
              size: 24, color: Colors.black),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lato',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        // flexibleSpace: Container(
        //   decoration: BoxDecoration(gradient: appBarGradient),
        // ),
        //backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Obx(() {
          MyUser? buyerDetails = userController.buyerDetails.value;
          return userController.buyerDetails.value == null
              ? const LoadingWidget()
              : Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  //decoration: BoxDecoration(gradient: myGradient),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 12),
                    children: [
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //       TextButton(
                      //         onPressed: () {},
                      //         style: TextButton.styleFrom(
                      //           // padding: EdgeInsets.symmetric(
                      //           //     horizontal: screenWidth * 0.24),
                      //           backgroundColor: Colors.black,
                      //           side:
                      //               const BorderSide(color: Colors.white, width: 2),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(12),
                      //           ),
                      //         ),
                      //         child: const Text(
                      //           "Print",
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(color: Colors.white, fontSize: 20),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      //  const SizedBox(
                      //     height: 8,
                      //   ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            width: 1,
                            color: Colors.black,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1,
                              spreadRadius: 0,
                              color: const Color(0xFF673AB7)
                                  .withValues(alpha: 0.10),
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Product Info",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Lato",
                              ),
                            ),
                            const Divider(
                              height: 4,
                              color: Colors.black,
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(
                                  () => ProductPage(
                                    id: widget.product!.productID,
                                  ),
                                  transition: Transition.fadeIn,
                                );
                                //debugPrint("Clicked");
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                      child: CachedNetworkImage(
                                        height: 154,
                                        width: 154,
                                        fit: BoxFit.cover,
                                        imageUrl: widget.product?.image
                                                    ?.isNotEmpty ==
                                                true
                                            ? widget.product!.image!.first
                                            : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                                        errorWidget: ((context, url, error) =>
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child:
                                                  Text("Failed to Load Image"),
                                            )),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        placeholder: ((context, url) =>
                                            const SizedBox(
                                              width: double.infinity,
                                              height: 154,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            )),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${widget.product!.name}",
                                            maxLines: 2,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontFamily: "Raleway",
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            "NGN${formatCurrency(widget.product!.price.toString())}",
                                            style: const TextStyle(
                                              color: Color(0xFF673AB7),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Lato",
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text("Qty Available"),
                                              // const SizedBox(
                                              //   width: 30,
                                              // ),
                                              Text(
                                                  "x ${widget.product!.quantity}")
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            width: 1,
                            color: Colors.black,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1,
                              spreadRadius: 0,
                              color: const Color(0xFF673AB7)
                                  .withValues(alpha: 0.10),
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Customer Info",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Lato",
                              ),
                            ),
                            const Divider(
                              color: Colors.black,
                              height: 4,
                            ),
                            Row(
                              children: [
                                const Text("Name: "),
                                Expanded(
                                  child: Text(buyerDetails?.fullname ??
                                      "[deleted User]"),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const Text("Phone Number: "),
                                Text(buyerDetails?.phoneNumber ??
                                    "[deleted User]")
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const Text("Email: "),
                                Expanded(
                                  child: Text(
                                      buyerDetails!.email ?? 'Not Available'),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Delivery Address: "),
                                buyerDetails.address != null
                                    ? Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${buyerDetails.address!.landmark ?? ""},${buyerDetails.address!.streetAddress},${buyerDetails.address!.lGA},${buyerDetails.address!.state}.${buyerDetails.address!.zipCode ?? ""}",
                                            ),
                                            Text(
                                              "${buyerDetails.address!.contactName ?? ""},${buyerDetails.address!.contactPhoneNumber},",
                                            ),
                                          ],
                                        ),
                                      )
                                    : const Text("Not Available")
                              ],
                            ),
                            const Divider(
                              height: 4,
                              color: Colors.black,
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  if (buyerDetails.fullname == null) {
                                    userController.showMyToast(
                                        "Cannot contact this buyer");
                                  } else {
                                    Get.to(
                                      () => MessagesPage(
                                        participant1:
                                            widget.orderDetails!.vendorId,
                                        participant2:
                                            widget.orderDetails!.buyerId,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF673AB7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 18),
                                ),
                                child: const Text(
                                  "Contact Customer",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            width: 1,
                            color: Colors.black,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1,
                              spreadRadius: 0,
                              color: const Color(0xFF673AB7)
                                  .withValues(alpha: 0.10),
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Order Info",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Lato",
                              ),
                            ),
                            const Divider(
                              height: 4,
                              color: Colors.black,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Order ID: ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "${widget.orderDetails!.orderId}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Order Date: ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "${resolveTimestampWithoutAdding(widget.orderDetails!.createdAt)}",
                                  style: const TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Total Price: ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "NGN ${formatCurrency(widget.orderDetails!.paymentPrice.toString())}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF673AB7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Qty Ordered: ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "x${widget.orderDetails!.orderItem!.first.quantity}",
                                  style: const TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Payment Method: ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "${widget.orderDetails!.paymentMethod}",
                                  style: const TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Payment Status: ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "${widget.orderDetails!.paymentStatus}",
                                  style: const TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Visibility(
                              visible:
                                  widget.orderDetails!.orderStatus == "expired",
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Order Status: ",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      widget.orderDetails!.orderStatus!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Visibility(
                              visible: widget.orderDetails!.orderItem!.first
                                      .optionName !=
                                  null,
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Option Ordered: ",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      widget.orderDetails!.orderItem!.first
                                              .optionName ??
                                          "",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Visibility(
                              visible: widget.orderDetails!.paymentPrice ==
                                  widget.orderDetails!.totalPrice,
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Order Status: ",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  dropDownValue == "confirmed" ||
                                          dropDownValue == "expired" ||
                                          dropDownValue == "cancelled"
                                      ? Expanded(
                                          flex: 2,
                                          child: Text(
                                            dropDownValue!.capitalizeFirst!,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        )
                                      : Expanded(
                                          child: DropdownButton(
                                            isExpanded: true,
                                            //hint: Text("Hello"),
                                            //style: TextStyle(color: Colors.black),
                                            value: dropDownValue,
                                            items: [
                                              "created",
                                              "not delivered",
                                              "delivered"
                                            ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                                onTap: () async =>
                                                    await checkOutController
                                                        .updateOrderStatus(
                                                            widget.orderDetails!
                                                                .orderId!,
                                                            value),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              _saveSelectedStatus(
                                                  val as String);
                                              setState(() {
                                                dropDownValue = val;
                                                debugPrint(dropDownValue);
                                              });
                                              // _loadSelectedStatus();
                                            },
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Visibility(
                        visible: widget.orderDetails!.paymentPrice !=
                            widget.orderDetails!.totalPrice,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              width: 1,
                              color: Colors.black,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 1,
                                spreadRadius: 0,
                                color: const Color(0xFF673AB7)
                                    .withValues(alpha: 0.10),
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Remaining Payment",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Lato",
                                ),
                              ),
                              const Divider(
                                height: 4,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "Amount Remaining: ",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "NGN${formatCurrency((widget.orderDetails!.totalPrice! - widget.orderDetails!.paymentPrice!.toInt()).toString())}",
                                    style: const TextStyle(
                                      color: Color(0xFF673AB7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "Installments Paid: ",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${widget.orderDetails!.installmentPaid} out of ${widget.orderDetails!.installmentNumber}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              // Visibility(
                              //   visible: widget.orderDetails!.paymentPrice ==
                              //       widget.orderDetails!.totalPrice,
                              //   child: Center(
                              //     child: GetX<CheckOutController>(
                              //       builder: (_) {
                              //         return DropdownButton(
                              //           value: dropDownValue,
                              //           items: dropDownItems.map((item) {
                              //             return DropdownMenuItem(
                              //               value: item,
                              //               child: Text("$item"),
                              //             );
                              //           }).toList(),
                              //           onChanged: (val) {
                              //             dropDownValue = val as String;
                              //             print(dropDownValue);
                              //           },
                              //         );
                              //       },
                              //     ),
                              //   ),
                              // ),

                              // Divider(
                              //   height: 7,
                              //   color: Colors.black,
                              // ),
                              // Center(
                              //   child: TextButton(
                              //     onPressed: () {
                              //       Get.to(() => MessagesPage());
                              //     },
                              //     style: TextButton.styleFrom(
                              //       backgroundColor: Color(0xFF392F5A),
                              //       padding: EdgeInsets.all(4),
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(12),
                              //         side: const BorderSide(
                              //           width: 1.5,
                              //           color: Colors.black,
                              //         ),
                              //       ),
                              //     ),
                              //     child: Text(
                              //       "Pay Amount",
                              //       style: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 20,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        }),
      ),
    );
  }
}
