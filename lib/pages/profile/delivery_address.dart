import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/pages/profile/add_delivery_address.dart';
import 'package:hair_main_street/pages/profile/edit_delivery_address.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/carbon.dart';
import 'package:material_symbols_icons/symbols.dart';

class DeliveryAddressPage extends StatefulWidget {
  const DeliveryAddressPage({super.key});

  @override
  State<DeliveryAddressPage> createState() => _DeliveryAddressPageState();
}

class _DeliveryAddressPageState extends State<DeliveryAddressPage> {
  UserController userController = Get.find<UserController>();
  // GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    userController.getDeliveryAddresses(userController.userState.value!.uid!);
  }

  @override
  Widget build(BuildContext context) {
    showDeliveryAddressDeleteDialog(String addressID) {
      Get.dialog(
        AlertDialog(
          elevation: 0,
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          contentPadding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
          title: const Text(
            "Delete Delivery Address?",
            style: TextStyle(
              fontSize: 19,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this delivery address?",
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
              color: Colors.black.withValues(alpha: 0.65),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Get.back();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFF673AB7),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                String userID = userController.userState.value!.uid!;
                await userController.deleteDeliveryAddress(userID, addressID);
              },
              child: const Text(
                "Confirm",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    }

    MyUser user = userController.userState.value!;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Symbols.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black),
        ),
        title: const Text(
          'Delivery Address',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lato',
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: DataBaseService().getDeliveryAddresses(user.uid!),
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }
            return Obx(
              () {
                return userController.deliveryAddresses.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: Get.height * 0.12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Iconify(
                                Carbon.location,
                                size: 156,
                                color: const Color(0xFF673AB7)
                                    .withValues(alpha: 0.30),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                "Oops No Delivery Address Added Yet",
                                style: TextStyle(
                                  color: const Color(0xFF673AB7)
                                      .withValues(alpha: 0.70),
                                  fontSize: 30,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: userController.deliveryAddresses.length,
                        itemBuilder: (context, index) {
                          final deliveryAddress =
                              userController.deliveryAddresses[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.fromLTRB(2, 2, 2, 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Iconify(
                                  Carbon.location,
                                  size: 24,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        [
                                          if (deliveryAddress?.landmark != null)
                                            deliveryAddress?.landmark!,
                                          deliveryAddress?.streetAddress,
                                          deliveryAddress?.lGA,
                                          deliveryAddress?.state,
                                          if (deliveryAddress?.zipCode != null)
                                            deliveryAddress?.zipCode!,
                                        ]
                                            .where((element) => element != null)
                                            .join(', '),
                                        style: const TextStyle(
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "${userController.deliveryAddresses[index]!.contactName ?? ""},${userController.deliveryAddresses[index]!.contactPhoneNumber}",
                                        style: const TextStyle(
                                          fontFamily: 'Raleway',
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Get.to(
                                                () => EditDeliveryAddressPage(
                                                  addressID: userController
                                                      .deliveryAddresses[index]!
                                                      .addressID!,
                                                ),
                                              );
                                            },
                                            child: SizedBox(
                                              height: 30,
                                              width: 60,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/Icons/edit.svg",
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                      AppColors.main,
                                                      BlendMode.srcIn,
                                                    ),
                                                    height: 24,
                                                    width: 24,
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  const Text(
                                                    "Edit",
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF673AB7),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          SizedBox(
                                            height: 30,
                                            child: TextButton.icon(
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 0),
                                                backgroundColor: Colors.white,
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 1,
                                                    color: Color(0xFF673AB7),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    8,
                                                  ),
                                                ),
                                              ),
                                              icon: const Icon(
                                                Icons.delete,
                                                size: 14,
                                                color: Color(0xFF673AB7),
                                              ),
                                              onPressed: () {
                                                String? addressID =
                                                    userController
                                                        .deliveryAddresses[
                                                            index]!
                                                        .addressID!;
                                                showDeliveryAddressDeleteDialog(
                                                    addressID);
                                              },
                                              label: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                  fontFamily: 'Lato',
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Get.to(() => const AddDeliveryAddressPage());
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                backgroundColor: const Color(0xFF673AB7),
                // side:
                //     const BorderSide(color: Colors.white, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Add New Address",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
