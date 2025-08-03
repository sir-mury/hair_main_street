import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/blank_page.dart';
import 'package:hair_main_street/controllers/notification_controller.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/order_model.dart';
import 'package:hair_main_street/pages/menu/order_detail.dart';
import 'package:hair_main_street/pages/refund.dart';
import 'package:hair_main_street/pages/submit_review_page.dart';
import 'package:hair_main_street/pages/vendor_dashboard/order_details.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  final dynamic data;
  const NotificationsPage({this.data, super.key});

  @override
  Widget build(BuildContext context) {
    // print("data: $data");
    // var screenWidth = Get.width;
    CheckOutController checkOutController = Get.find<CheckOutController>();
    ProductController productController = Get.find<ProductController>();
    UserController userController = Get.find<UserController>();
    NotificationController notificationController =
        Get.find<NotificationController>();
    // if (userController.userState.value != null) {
    //   notificationController.getNotifications();
    // }
    String resolveTimestampWithoutAdding(Timestamp timestamp) {
      DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
      var newDate = DateFormat("dd-MM-yyyy").format(dateTime);
      // Add days to the DateTime
      //DateTime newDateTime = dateTime.add(Duration(days: daysToAdd));

      return newDate;
    }

    String resolveTimestampToTime(Timestamp timestamp) {
      final dateTime = timestamp.toDate();

      // Create a formatter for Nigerian time zone (GMT+01:00)
      final formatter = DateFormat('HH:mm'); // Nigeria locale

      // Format the DateTime object with the Nigerian locale
      final formattedString = formatter.format(dateTime);

      return formattedString;
    }

    return Obx(() {
      if (userController.userState.value == null) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: true,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: Colors.black),
            ),
            centerTitle: false,
            title: const Text(
              "Notifications",
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lato',
              ),
            ),
            bottom: PreferredSize(
              preferredSize:
                  const Size.fromHeight(1.0), // Adjust height as needed
              child: Divider(
                thickness: 1.0, // Adjust thickness as needed
                color: Colors.black
                    .withValues(alpha: 0.2), // Adjust color as needed
              ),
            ),
          ),
          body: BlankPage(
            haveAppBar: true,
            text: "You are not logged In",
            pageIcon: const Icon(
              Icons.person_off_outlined,
              size: 48,
            ),
          ),
        );
      } else {
        notificationController.getNotifications();

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: true,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: Colors.black),
            ),
            centerTitle: false,
            title: const Text(
              "Notifications",
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lato',
              ),
            ),
            bottom: PreferredSize(
              preferredSize:
                  const Size.fromHeight(1.0), // Adjust height as needed
              child: Divider(
                thickness: 1.0, // Adjust thickness as needed
                color: Colors.black
                    .withValues(alpha: 0.2), // Adjust color as needed
              ),
            ),

            // leading: IconButton(
            //   onPressed: () => Get.back(),
            //   icon: const Icon(
            //     Icons.arrow_back_ios_new_rounded,
            //     color: Colors.black,
            //   ),
            // ),
          ),
          backgroundColor: Colors.white,
          body: Obx(() {
            var notification = notificationController.notifications;
            if (notificationController.isLoading.isTrue) {
              return LoadingWidget();
            } else {
              if (notification.isEmpty) {
                return BlankPage(
                  text: "No Notifications",
                  pageIcon: const Icon(
                    Icons.notifications_off_rounded,
                    size: 48,
                  ),
                );
              } else {
                return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    itemCount: notificationController.notifications.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          debugPrint(
                              notification[index].extraData!["orderID"]!);

                          await checkOutController.getSingleOrder(
                              notification[index].extraData!["orderID"]!);
                          DatabaseOrderResponse? order =
                              checkOutController.singleOrder.value;
                          var product = productController.getSingleProduct(
                              order!.orderItem!.first.productId!);
                          // var user = await userController
                          //     .getUserDetails(notification[index].userID!);
                          if (notification[index].extraData!["receiver"] ==
                              'buyer') {
                            Get.to(
                              () => OrderDetailsPage(
                                product: product,
                                orderID: order.orderId,
                                vendorID: order.vendorId,
                              ),
                            );
                          } else if (notification[index]
                                  .extraData!["receiver"] ==
                              'vendor') {
                            Get.to(
                              () => VendorOrderDetailsPage(
                                product: product,
                                orderDetails: order,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.transparent),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 1,
                                spreadRadius: 0,
                                color: const Color(0xFF673AB7)
                                    .withValues(alpha: 0.10),
                                offset: const Offset(0, 1),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification[index].title!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                  ),
                                  Text(
                                    resolveTimestampWithoutAdding(
                                        notification[index].timestamp!),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Raleway',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Color(0xFF673AB7),
                                    radius: 25,
                                    child: Icon(
                                      Icons.notifications_active,
                                      size: 36,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${notification[index].body}",
                                          maxLines: 5,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'Raleway',
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Visibility(
                                          visible: notification[index]
                                              .body!
                                              .contains("review"),
                                          child: GestureDetector(
                                            onTap: () async {
                                              await checkOutController
                                                  .getSingleOrder(notification[
                                                          index]
                                                      .extraData!["orderID"]!);
                                              DatabaseOrderResponse? order =
                                                  checkOutController
                                                      .singleOrder.value;
                                              String productID = order!
                                                  .orderItem!.first.productId!;
                                              Get.to(
                                                () => SubmitReviewPage(
                                                  productID: productID,
                                                ),
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 6),
                                              child: Text(
                                                "Leave Review",
                                                style: TextStyle(
                                                  color: Color(0xFF673AB7),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Lato',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: notification[index]
                                              .title!
                                              .contains("Expired"),
                                          child: InkWell(
                                            onTap: () async {
                                              await checkOutController
                                                  .getSingleOrder(notification[
                                                          index]
                                                      .extraData!["orderID"]!);
                                              DatabaseOrderResponse? order =
                                                  checkOutController
                                                      .singleOrder.value;
                                              // String productID = order
                                              //     .orderItem!
                                              //     .first
                                              //     .productId!;
                                              Get.to(
                                                () => RefundPage(
                                                  orderId: notification[index]
                                                      .extraData!["orderID"],
                                                  paymentAmount:
                                                      order!.paymentPrice,
                                                  reason: "Expired Order",
                                                ),
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 6),
                                              child: Text(
                                                "Request Refund",
                                                style: TextStyle(
                                                  color: Color(0xFF673AB7),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Lato',
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  resolveTimestampToTime(
                                      notification[index].timestamp!),
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withValues(alpha: 0.60),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              }
            }
          }),
        );
      }
    });
  }
}
