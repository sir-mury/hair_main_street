import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:material_symbols_icons/symbols.dart';

class AccountInformationPage extends StatefulWidget {
  const AccountInformationPage({super.key});

  @override
  State<AccountInformationPage> createState() => _AccountInformationPageState();
}

class _AccountInformationPageState extends State<AccountInformationPage> {
  UserController userController = Get.find<UserController>();
  GlobalKey<FormState> formKey = GlobalKey();
  Map<String, dynamic> userData = {};
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    MyUser user = userController.userState.value!;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        userController.isEditingMode.value = false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Symbols.arrow_back_ios_new_rounded,
                size: 20, color: Colors.black),
          ),
          title: const Text(
            'Account Information',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lato',
              color: Colors.black,
            ),
          ),
          centerTitle: false,
          actions: [
            Obx(() {
              return !userController.isEditingMode.value
                  ? Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: InkWell(
                        radius: 100,
                        onTap: () {
                          userController.isEditingMode.value = true;
                        },
                        child: SvgPicture.asset(
                          'assets/Icons/edit.svg',
                          colorFilter: ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                          height: 25,
                          width: 25,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: InkWell(
                        onTap: () {
                          userController.isEditingMode.value = false;
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.red[300],
                            fontSize: 15,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
            })
          ],
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
        ),
        body: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email",
                        style: TextStyle(
                          color: Color(0xFF673AB7),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Raleway',
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 10),
                        //margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: Colors.grey[200],
                          border: Border.all(
                              width: 0.5,
                              color: Colors.black.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          user.email!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  userController.isEditingMode.value
                      ? TextInputWidget(
                          controller: nameController,
                          labelText: "Full Name",
                          labelColor: const Color(0xFF673AB7),
                          initialValue: user.fullname ?? "",
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Cannot be Empty";
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputType: TextInputType.text,
                          onChanged: (val) {
                            if (val!.isNotEmpty) {
                              setState(() {
                                user.fullname = val;
                              });
                            }
                          },
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Full Name",
                              style: TextStyle(
                                color: Color(0xFF673AB7),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Raleway',
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 12),
                              //margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: Colors.grey[200],
                                border: Border.all(
                                    width: 0.5,
                                    color: Colors.black.withValues(alpha: 0.1)),
                              ),
                              child: Text(
                                user.fullname!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Lato',
                                ),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  userController.isEditingMode.value
                      ? TextInputWidget(
                          controller: phoneNumberController,
                          labelText: "Phone Number",
                          labelColor: const Color(0xFF673AB7),
                          initialValue: user.phoneNumber ?? "",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Cannot be Empty";
                            } else if (!val.isNumericOnly) {
                              return "Can only be numbers";
                            } else if (val.length < 11 || val.length > 11) {
                              return "Must be 11 characters long";
                            }
                            return null;
                          },
                          textInputType: Platform.isIOS
                              ? TextInputType.phone
                              : TextInputType.number,
                          onChanged: (val) {
                            if (val!.isNotEmpty) {
                              setState(() {
                                user.phoneNumber = val;
                              });
                            }
                          },
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Phone Number",
                              style: TextStyle(
                                color: Color(0xFF673AB7),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Raleway',
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 12),
                              //margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: Colors.grey[200],
                                border: Border.all(
                                    width: 0.5,
                                    color: Colors.black.withValues(alpha: 0.1)),
                              ),
                              child: Text(
                                user.phoneNumber ?? "",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Lato',
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Obx(() {
          return !userController.isEditingMode.value
              ? const SizedBox.shrink()
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
                    child: TextButton(
                      onPressed: () async {
                        bool? validate = formKey.currentState!.validate();
                        if (validate) {
                          userController.isLoading.value = true;
                          if (userController.isLoading.value) {
                            Get.dialog(const LoadingWidget());
                          }
                          userData = {
                            "fullname": user.fullname,
                            "phonenumber": user.phoneNumber,
                          };
                          var result =
                              await userController.editUserProfile(userData);
                          // print("result: $result");
                          if (result == "success") {
                            Get.close(1);
                            userController.isEditingMode.value = false;
                            Get.snackbar(
                              "Success",
                              "Account Information Updated",
                              snackPosition: SnackPosition.BOTTOM,
                              duration:
                                  const Duration(seconds: 1, milliseconds: 800),
                              forwardAnimationCurve: Curves.decelerate,
                              reverseAnimationCurve: Curves.easeOut,
                              backgroundColor: Colors.green[200],
                              margin: EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: (Get.height) * 0.08,
                              ),
                            );
                          }
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        backgroundColor: const Color(0xFF673AB7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Done",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                );
        }),
      ),
    );
  }
}
