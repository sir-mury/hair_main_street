// ignore_for_file: prefer_const_constructors
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/vendors_model.dart';
import 'package:hair_main_street/pages/cancellation_page.dart';
import 'package:hair_main_street/pages/orders_stuff/payment_page.dart';
import 'package:hair_main_street/pages/product_page.dart';
import 'package:hair_main_street/pages/submit_review_page.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/loading.dart';

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/models/order_model.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/pages/messages.dart';
import 'package:hair_main_street/pages/refund.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderDetailsPage extends StatefulWidget {
  final String? orderID;
  final String? vendorID;
  final Product? product;
  const OrderDetailsPage(
      {this.product, this.orderID, this.vendorID, super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  CheckOutController checkOutController = Get.find<CheckOutController>();
  UserController userController = Get.find<UserController>();
  num? installmentDuration;
  DatabaseOrderResponse? orderDetails;

  @override
  void initState() {
    getSingleOrder();
    getVendorDetails();
    super.initState();
  }

  getSingleOrder() async {
    await checkOutController.getSingleOrder(widget.orderID!);
  }

  getVendorDetails() async {
    Vendors? response =
        await userController.getVendorDetailsFuture(widget.vendorID!);
    installmentDuration = response!.installmentDuration!;
  }

  @override
  Widget build(BuildContext context) {
    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width
    String calculateDateTime(int timeInMilliseconds, Timestamp timestamp) {
      // Convert the Timestamp object to milliseconds since epoch
      int timestampMilliseconds =
          timestamp.seconds * 1000 + timestamp.nanoseconds ~/ 1000000;

      // Add the time in milliseconds to the timestamp milliseconds
      int totalMilliseconds = timestampMilliseconds + timeInMilliseconds;

      // Create a DateTime object from the total milliseconds
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(totalMilliseconds);
      String formattedDateTime =
          DateFormat("dd-MMMM-yyyy HH:mm").format(dateTime);
      return formattedDateTime;
    }

    String resolveTimestampWithoutAdding(Timestamp timestamp) {
      DateTime dateTime = timestamp.toDate();
      String formattedDateTime =
          DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
      // Add days to the DateTime
      //DateTime newDateTime = dateTime.add(Duration(days: daysToAdd));

      return formattedDateTime;
    }

    String resolveTimestamp(Timestamp timestamp, int daysToAdd) {
      DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime

      // Add days to the DateTime
      DateTime newDateTime = dateTime.add(Duration(days: daysToAdd));

      // Format the DateTime without the time part
      String formattedDate = DateFormat('dd-MM-yyyy').format(newDateTime);

      return formattedDate;
    }

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Symbols.arrow_back_ios_new_rounded,
              size: 24, color: Colors.black),
        ),
        title: const Text(
          'Order Detail',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lato',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Adjust height as needed
          child: Divider(
            thickness: 1.0, // Adjust thickness as needed
            color:
                Colors.black.withValues(alpha: 0.2), // Adjust color as needed
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (checkOutController.isLoading.isTrue) {
            return LoadingWidget();
          } else if (checkOutController.singleOrder.value == null) {
            return Center(
              child: Text(
                "Cannot obtain order details".camelCase!,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: "Lato",
                ),
              ),
            );
          } else {
            orderDetails = checkOutController.singleOrder.value;
            return FutureBuilder(
                future: userController.getVendorDetailsFuture(widget.vendorID!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return LoadingWidget();
                  }
                  var isVisible =
                      (orderDetails!.orderStatus == "delivered").obs;
                  var isVisible2 =
                      (orderDetails!.orderStatus == "confirmed").obs;
                  Orders order = orderDetails!.toOrders();
                  return SingleChildScrollView(
                    //padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // check if there is still payment left to complete
                              // TO DO: ensure you make it also invisible if the order has expired
                              Visibility(
                                visible: orderDetails!.paymentPrice !=
                                    orderDetails!.totalPrice,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 12),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFf5f5f5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Remaining Payment",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF673AB7),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Amount Remaining: ",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            "₦${formatCurrency((orderDetails!.totalPrice! - orderDetails!.paymentPrice!.toInt()).toString())}",
                                            style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Installment Remaining: ",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "${(orderDetails?.installmentNumber?.toInt() ?? 0) - (orderDetails?.installmentPaid?.toInt() ?? 0)}",
                                            style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "To be Paid Before: ",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Expanded(
                                            child: Text(
                                              calculateDateTime(
                                                  installmentDuration!.toInt(),
                                                  orderDetails!.updatedAt!),
                                              style: TextStyle(
                                                fontFamily: 'Raleway',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Divider(
                                        height: 7,
                                        color: Colors.black,
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton(
                                          onPressed: () {
                                            Get.to(
                                              () => PaymentPage(
                                                orderDetails: orderDetails,
                                                expectedTimeToPay:
                                                    calculateDateTime(
                                                            installmentDuration
                                                                as int,
                                                            orderDetails!
                                                                .updatedAt!)
                                                        .toString(),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Color(0xFF673AB7),
                                            padding: EdgeInsets.all(4),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            "Pay Amount",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Lato',
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => ProductPage(
                                      id: orderDetails!.orderItem![0].productId,
                                    ),
                                    transition: Transition.fadeIn,
                                  );
                                  //debugPrint("Clicked");
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      // decoration: BoxDecoration(
                                      //   color: Colors.black45,
                                      // ),
                                      // width: screenWidth * 0.32,
                                      // height: screenHeight * 0.16,
                                      child: CachedNetworkImage(
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          height: 140,
                                          width: 123,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        fit: BoxFit.fill,
                                        imageUrl: widget.product?.image ==
                                                    null ||
                                                widget.product?.image!
                                                        .isNotEmpty ==
                                                    true
                                            ? widget.product?.image!.first
                                            : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                                        errorWidget: ((context, url, error) =>
                                            Text("Failed to Load Image")),
                                        placeholder: ((context, url) =>
                                            const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        height: 140,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${widget.product!.name}",
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontFamily: 'Lato',
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Order Quantity:",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Raleway',
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Text(
                                                  "${orderDetails!.orderItem!.first.quantity}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Raleway',
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                orderDetails!.paymentStatus ==
                                                        "paid"
                                                    ? Icon(
                                                        Icons
                                                            .check_circle_outline_outlined,
                                                        color:
                                                            Colors.green[400],
                                                        size: 20,
                                                      )
                                                    : Icon(
                                                        Icons.pending_outlined,
                                                        color: Colors.black,
                                                        size: 20,
                                                      ),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Text(
                                                  "${orderDetails!.paymentStatus}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Raleway',
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              ExpansionTile(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Color(0xFF673AB7)
                                        .withValues(alpha: 0.70),
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                collapsedShape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Color(0xFF673AB7)
                                        .withValues(alpha: 0.70),
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                initiallyExpanded: true,
                                tilePadding:
                                    EdgeInsets.symmetric(horizontal: 8),
                                backgroundColor: Colors.white,
                                iconColor: Colors.black,
                                collapsedIconColor: Colors.black,
                                childrenPadding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                title: const Text(
                                  "Order Info",
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF673AB7),
                                  ),
                                ),
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Order ID: ",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "${orderDetails!.orderId}",
                                            style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Order Status: ",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "${orderDetails!.orderStatus}",
                                            style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Placed on: ",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            resolveTimestampWithoutAdding(
                                                orderDetails!.createdAt),
                                            style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Payment Method: ",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "${orderDetails!.paymentMethod}",
                                            style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Total Price: ",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "NGN${formatCurrency(orderDetails!.totalPrice.toString())}",
                                            style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Amount Paid: ",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "NGN${formatCurrency(orderDetails!.paymentPrice.toString())}",
                                            style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              ExpansionTile(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Color(0xFF673AB7)
                                        .withValues(alpha: 0.70),
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                collapsedShape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Color(0xFF673AB7)
                                        .withValues(alpha: 0.70),
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                initiallyExpanded: true,
                                tilePadding:
                                    EdgeInsets.symmetric(horizontal: 8),
                                backgroundColor: Colors.white,
                                iconColor: Colors.black,
                                collapsedIconColor: Colors.black,
                                childrenPadding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                title: const Text(
                                  "Order Timeline",
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF673AB7),
                                  ),
                                ),
                                children: [
                                  TimelineStep(
                                    isFirst: true,
                                    icon: Icons.circle,
                                    iconColor: Colors.green,
                                    isPast: true,
                                    title: "Order Created",
                                    subtitle:
                                        "on the ${resolveTimestampWithoutAdding(orderDetails!.createdAt!)}",
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  TimelineStep(
                                    isPast: orderDetails!.orderStatus ==
                                                'confirmed' ||
                                            orderDetails!.orderStatus ==
                                                "delivered"
                                        ? true
                                        : false,
                                    superTitleColor:
                                        orderDetails!.orderStatus ==
                                                    'confirmed' ||
                                                orderDetails!.orderStatus ==
                                                    "delivered"
                                            ? Colors.green
                                            : Color(0xFF673AB7),
                                    superTitle: orderDetails!.orderStatus ==
                                                'confirmed' ||
                                            orderDetails!.orderStatus ==
                                                "delivered"
                                        ? "Complete"
                                        : "In Progress",
                                    icon: Icons.circle,
                                    iconColor: orderDetails!.orderStatus ==
                                                'confirmed' ||
                                            orderDetails!.orderStatus ==
                                                "delivered"
                                        ? Colors.green
                                        : Color(0xFF673AB7),
                                    title: orderDetails!.orderStatus ==
                                                'confirmed' ||
                                            orderDetails!.orderStatus ==
                                                "delivered"
                                        ? "Delivered"
                                        : "Waiting to be delivered by vendor",
                                    subtitle:
                                        "The vendor has until ${resolveTimestamp(orderDetails!.createdAt, 3)} to deliver the item.",
                                    button: InkWell(
                                      onTap: () {
                                        Get.to(
                                          () => MessagesPage(
                                            participant1: orderDetails!.buyerId,
                                            participant2:
                                                orderDetails!.vendorId,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFf5f5f5),
                                          border: Border.all(
                                            width: 0.8,
                                            color: Colors.black
                                                .withValues(alpha: 0.9),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.all(8),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.chat_bubble_outline_rounded,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 12,
                                            ),
                                            Text(
                                              "Contact Vendor",
                                              style: TextStyle(
                                                fontFamily: 'Raleway',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  TimelineStep(
                                    isPast:
                                        orderDetails!.orderStatus == "confirmed"
                                            ? true
                                            : false,
                                    isLast: true,
                                    icon: Icons.circle,
                                    iconColor:
                                        orderDetails!.orderStatus == 'confirmed'
                                            ? Colors.green
                                            : Colors.grey.shade400,
                                    title:
                                        orderDetails!.orderStatus != 'confirmed'
                                            ? "Item Not Confirmed"
                                            : "Item Confirmed",
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Color(0xFFf5f5f5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Delivery Address",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF673AB7),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.black
                                              .withValues(alpha: 0.5),
                                          width: 0.3,
                                        ),
                                      ),
                                      child: Text(
                                        order.shippingAddress == null
                                            ? "No delivery address specified"
                                            : [
                                                if (order.shippingAddress!
                                                        .landmark !=
                                                    null)
                                                  order.shippingAddress!
                                                      .landmark!,
                                                order.shippingAddress!
                                                    .streetAddress,
                                                order.shippingAddress!.lGA,
                                                order.shippingAddress!.state,
                                                if (order.shippingAddress!
                                                        .zipCode !=
                                                    null)
                                                  order.shippingAddress!
                                                      .zipCode!,
                                              ]
                                                .where((element) =>
                                                    element != null)
                                                .join(', '),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  color: Color(0xFFf5f5f5),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Color(0xFF000000),
                                  //     blurStyle: BlurStyle.normal,
                                  //     offset: Offset.fromDirection(-2.0),
                                  //     blurRadius: 2,
                                  //   ),
                                  // ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Estimated Delivery Date: ",
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      resolveTimestamp(
                                          orderDetails!.createdAt, 7),
                                      style: TextStyle(
                                        fontFamily: 'Raleway',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Row(
                                mainAxisAlignment:
                                    orderDetails!.orderStatus != "confirmed"
                                        ? MainAxisAlignment.spaceBetween
                                        : MainAxisAlignment.center,
                                children: [
                                  Visibility(
                                    visible: orderDetails!.orderStatus !=
                                            "confirmed" &&
                                        orderDetails!.orderStatus !=
                                            'cancelled' &&
                                        orderDetails!.orderStatus != 'expired',
                                    child: Expanded(
                                      flex: 1,
                                      child: TextButton(
                                        onPressed: () {
                                          Get.to(
                                            () => CancellationPage(
                                              orderId: orderDetails!.orderId!,
                                              paymentAmount:
                                                  orderDetails!.paymentPrice!,
                                            ),
                                            transition: Transition.fadeIn,
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Color(0xFF673AB7),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          "Cancel Order",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // orderDetails!.orderStatus == "confirmed"
                                  //     ? const SizedBox(
                                  //         width: 10,
                                  //       )
                                  //     : SizedBox.shrink(),
                                  Visibility(
                                    visible: orderDetails!.orderStatus ==
                                            'confirmed' ||
                                        orderDetails!.orderStatus == "expired",
                                    child: Expanded(
                                      flex: 1,
                                      child: TextButton(
                                        onPressed: () {
                                          Get.to(
                                            () => RefundPage(
                                              orderId: orderDetails!.orderId!,
                                              paymentAmount:
                                                  orderDetails!.paymentPrice!,
                                              reason:
                                                  orderDetails!.orderStatus ==
                                                          'expired'
                                                      ? 'expired'
                                                      : null,
                                            ),
                                            transition: Transition.fadeIn,
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Color(0xFF673AB7),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          "Refund",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Obx(
                          () {
                            return Visibility(
                              visible: isVisible.value,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.offWhite,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Your Order has been marked as delivered by the vendor",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.shade9,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF673AB7),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () async {
                                          order.orderStatus = "confirmed";

                                          // debugPrint(
                                          //     "order: ${order.toJson()}");
                                          await checkOutController
                                              .updateOrder(order);
                                          isVisible.value = false;
                                          await checkOutController
                                              .getSingleOrder(order.orderId!);
                                        },
                                        child: Text(
                                          "Confirm",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontFamily: 'Lato',
                                            // fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Obx(
                          () {
                            return Visibility(
                              visible: isVisible2.value,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFf5f5f5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    width: 0.5,
                                    color: Colors.black.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Care to Write a Review?",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF673AB7),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () {
                                          Get.to(() => SubmitReviewPage(
                                                productID:
                                                    widget.product!.productID,
                                              ));
                                          // order.orderStatus = "confirmed";
                                          // await checkOutController.updateOrder(order);
                                          // isVisible.value = false;
                                        },
                                        child: Text(
                                          "Write a Review",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  );
                });
          }
        }),
      ),
    );
  }
}

class TimelineStep extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final bool? isFirst;
  final bool? isLast;
  final bool? isPast;
  final Color? superTitleColor;
  final String title;
  final String? subtitle;
  final String? superTitle;
  final Widget? button;

  const TimelineStep({
    super.key,
    required this.icon,
    this.isFirst,
    this.isLast,
    this.isPast,
    this.superTitle,
    this.superTitleColor,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.button,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      isFirst: isFirst ?? false,
      isLast: isLast ?? false,
      indicatorStyle: IndicatorStyle(
        width: 24,
        color: isPast ?? false ? Colors.green.shade300 : Colors.grey,
        iconStyle: IconStyle(
          iconData: isPast ?? false ? Icons.done : Icons.done,
          color: isPast ?? false ? Colors.white : Colors.grey,
        ),
      ),
      beforeLineStyle: LineStyle(
        color: isPast ?? false ? Colors.green.shade300 : Colors.grey,
        thickness: 2,
      ),
      endChild: Container(
        margin: EdgeInsets.fromLTRB(12, 4, 0, 4),
        decoration: BoxDecoration(
            color: Color(0xFFf5f5f5), borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (superTitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  superTitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: superTitleColor ??
                        Color(0xFF673AB7).withValues(alpha: 0.70),
                  ),
                ),
              ),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lato',
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            if (button != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: button!,
              ),
          ],
        ),
      ),
    );
  }
}

class HeaderText extends StatelessWidget {
  final String? text;
  const HeaderText({
    this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
      ),
      child: Text(
        text!,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
