import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/profile_controller.dart';
import 'package:hair_main_street/extras/country_state.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/pages/homepage.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:hair_main_street/widgets/misc_widgets.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/carbon.dart';
import 'package:keyboard_service/keyboard_service.dart';

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  Widget build(BuildContext context) {
    putController() {
      Get.lazyPut(() => ProfileController());
    }

    putController();

    ProfileController profileController = Get.find<ProfileController>();

    GlobalKey<FormState> formKey = GlobalKey();
    CountryAndStatesAndLocalGovernment countryAndStatesAndLocalGovernment =
        CountryAndStatesAndLocalGovernment();
    TextEditingController fullNameController = TextEditingController();
    TextEditingController phoneNumberController = TextEditingController();
    TextEditingController contactNameController = TextEditingController();
    TextEditingController contactPhoneNumberController =
        TextEditingController();
    TextEditingController landmarkController = TextEditingController();
    TextEditingController zipCodeController = TextEditingController();
    TextEditingController streetAddressController = TextEditingController();
    return KeyboardAutoDismiss(
      scaffold: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          leading: InkWell(
            onTap: () => Get.back(),
            radius: 12,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.black,
            ),
          ),
          title: const Text(
            'Complete Profile',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              fontFamily: 'Lato',
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(10),
                // ),
              ),
              onPressed: () {
                Get.off(() => const HomePage());
              },
              child: Text(
                "Skip",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.main,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Raleway",
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: Form(
          key: formKey,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            children: [
              TextInputWidget(
                // initialValue: profileController.fullname?.value,
                labelColor: AppColors.main,
                labelText: "Full Name",
                fontSize: 16,
                controller: fullNameController,
                hintText: "Enter full name",
                autofillHints: [AutofillHints.name],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Cannot be empty";
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value!.isNotEmpty) {
                    fullNameController.text = value;
                    profileController.fullname?.value = fullNameController.text;
                  }
                },
              ),
              const SizedBox(
                height: 12,
              ),
              TextInputWidget(
                // initialValue: profileController.phoneNumber?.value,
                labelColor: AppColors.main,
                labelText: "Phone Number",
                fontSize: 16,
                controller: phoneNumberController,
                hintText: "Enter phone number",
                autofillHints: [AutofillHints.telephoneNumber],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Cannot be empty";
                  } else if (!value.isNumericOnly) {
                    return "Must be digits only";
                  } else if (value.length > 11 || value.length < 11) {
                    return "Cannot be more than or less than 11 digits";
                  }
                  return null;
                },
                onChanged: (value) {
                  profileController.phoneNumber?.value = value!;
                },
              ),
              const SizedBox(
                height: 12,
              ),
              Obx(
                () => profileController.isDeliveryAddressAdded.isTrue
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) => AddressCard(
                          address: profileController.deliveryAddress[index]!,
                          onTap: () {
                            profileController.selectedAddress.value =
                                profileController.deliveryAddress[index]!;
                            showAddressBottomSheet(
                              isEdit: true,
                              countryAndStatesAndLocalGovernment,
                              profileController,
                              contactNameController,
                              contactPhoneNumberController,
                              landmarkController,
                              zipCodeController,
                              streetAddressController,
                              context: context,
                            );
                          },
                          onDelete: () {
                            profileController.deliveryAddress.removeAt(index);
                          },
                        ),
                        itemCount: profileController.deliveryAddress.length,
                      )
                    : SizedBox.shrink(),
              ),
              const SizedBox(
                height: 12,
              ),
              InkWell(
                onTap: () async {
                  profileController.selectedAddress.value = Address();
                  showAddressBottomSheet(
                      countryAndStatesAndLocalGovernment,
                      profileController,
                      contactNameController,
                      contactPhoneNumberController,
                      landmarkController,
                      zipCodeController,
                      streetAddressController,
                      context: context);
                },
                // style: TextButton.styleFrom(
                //   padding: const EdgeInsets.symmetric(vertical: 8),
                //   backgroundColor: AppColors.shade3,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                // ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.shade2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.shade1,
                      width: 0.8,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.main,
                          size: 25,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          "Add delivery address",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
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
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          height: kToolbarHeight * 1.2,
          elevation: 0,
          color: Colors.white,
          child: TextButton(
            onPressed: () async {
              bool validate = formKey.currentState!.validate();

              // print(
              //     "Profile: ${profileController.fullname}, ${profileController.phoneNumber}");
              if (validate && profileController.deliveryAddress.isNotEmpty) {
                profileController.isLoading.value = true;
                if (profileController.isLoading.isTrue) {
                  Get.dialog(LoadingWidget());
                }
                await profileController.completeProfile();
              } else {
                profileController.showMyToast(
                    "Kindly complete your profile or skip to continue later");
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              backgroundColor: AppColors.main,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Complete Profile",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  showAddressBottomSheet(
    CountryAndStatesAndLocalGovernment countryAndStatesAndLocalGovernment,
    ProfileController profileController,
    TextEditingController contactNameController,
    TextEditingController contactPhoneNumberController,
    TextEditingController landmarkController,
    TextEditingController zipCodeController,
    TextEditingController streetAddressController, {
    bool? isEdit = false,
    BuildContext? context,
  }) {
    void dismissKeyboard() {
      bool isKeyboardVisible = KeyboardService.isVisible(context!);
      if (isKeyboardVisible) {
        KeyboardService.dismiss();
      }
      null;
    }

    Get.bottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      ignoreSafeArea: false,
      elevation: 0,
      backgroundColor: Colors.white,
      StatefulBuilder(builder: (context, setstate) {
        GlobalKey<FormState> bottomSheetFormKey = GlobalKey();
        return Form(
          key: bottomSheetFormKey,
          child: GestureDetector(
            onTap: () {
              dismissKeyboard();
            },
            child: Container(
              height: Get.height * 0.72,
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 8,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.shade3,
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextInputWidgetWithoutLabelForDialog(
                            initialValue: profileController
                                .selectedAddress.value?.contactName,
                            controller: contactNameController,
                            hintText: "Enter Contact Name",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            textInputType: TextInputType.text,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Cannot be empty";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value!.isNotEmpty) {
                                profileController
                                    .selectedAddress.value!.contactName = value;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextInputWidgetWithoutLabelForDialog(
                            initialValue: profileController
                                .selectedAddress.value?.contactPhoneNumber,
                            controller: contactPhoneNumberController,
                            hintText: "Enter contact phone number",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            textInputType: TextInputType.phone,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Cannot be empty";
                              } else if (!value.isNumericOnly) {
                                return "Must be digits only";
                              } else if (value.length > 11 ||
                                  value.length < 11) {
                                return "Cannot be more than or less than 11 digits";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              profileController.selectedAddress.value!
                                  .contactPhoneNumber = value;
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          BuildPicker(
                            labelColor: AppColors.main,
                            labelFontSize: 16,
                            hintText: "Select State",
                            label: "State",
                            items:
                                countryAndStatesAndLocalGovernment.statesList,
                            selectedValue:
                                profileController.selectedAddress.value!.state,
                            onChanged: (value) {
                              profileController.selectedAddress.value!.state =
                                  value;
                              profileController.selectedAddress.value!.lGA =
                                  null;
                              setstate(() {});
                              debugPrint(
                                  "Value ${profileController.selectedAddress.value!.contactName!}");
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          BuildPicker(
                            labelColor: AppColors.main,
                            labelFontSize: 16,
                            hintText: "Select LGA",
                            label: "LGA",
                            items: countryAndStatesAndLocalGovernment
                                        .stateAndLocalGovernments[
                                    profileController
                                        .selectedAddress.value!.state] ??
                                [],
                            selectedValue:
                                profileController.selectedAddress.value!.lGA,
                            onChanged: (value) {
                              setstate(
                                () {
                                  profileController.selectedAddress.value!.lGA =
                                      value;
                                },
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextInputWidgetWithoutLabelForDialog(
                            initialValue: profileController
                                .selectedAddress.value?.streetAddress,
                            controller: streetAddressController,
                            hintText: "Enter Street Address",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            textInputType: TextInputType.text,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Cannot be empty";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value!.isNotEmpty) {
                                profileController.selectedAddress.value!
                                    .streetAddress = value;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextInputWidgetWithoutLabelForDialog(
                            initialValue: profileController
                                .selectedAddress.value?.landmark,
                            controller: landmarkController,
                            hintText: "Enter Landmark",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            textInputType: TextInputType.text,
                            validator: (value) {
                              return null;
                            },
                            onChanged: (value) {
                              if (value!.isNotEmpty) {
                                profileController
                                    .selectedAddress.value!.landmark = value;
                              } else {
                                profileController
                                    .selectedAddress.value!.landmark = null;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextInputWidgetWithoutLabelForDialog(
                            initialValue: profileController
                                .selectedAddress.value?.zipCode,
                            controller: zipCodeController,
                            hintText: "Enter zip code",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            textInputType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Cannot be empty";
                              } else if (!value.isNumericOnly) {
                                return "Must be digits only";
                              } else if (value.length > 6 || value.length < 6) {
                                return "Cannot be more than or less than 6 digits";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value!.isNotEmpty) {
                                profileController
                                    .selectedAddress.value!.zipCode = value;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () async {
                            Get.close(1);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            backgroundColor: AppColors.shade1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.shade9,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            bool validate =
                                bottomSheetFormKey.currentState!.validate();
                            var address =
                                profileController.selectedAddress.value;
                            if (address!.lGA == null ||
                                address.state == null ||
                                !validate) {
                              profileController
                                  .showMyToast("Kindly complete the form");
                            } else {
                              isEdit
                                  ? profileController.editAtDeliveryAddress()
                                  : profileController.addAddressToAdresses();
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            backgroundColor: AppColors.main,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEdit! ? "Edit Address" : "Add Address",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const AddressCard({
    required this.address,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
            color: const Color(0xFF673AB7).withValues(alpha: 0.10),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    if (address.landmark != null) address.landmark!,
                    address.streetAddress,
                    address.lGA,
                    address.state,
                    if (address.zipCode != null) address.zipCode!,
                  ].where((element) => element != null).join(', '),
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
                  "${address.contactName ?? ""},${address.contactPhoneNumber}",
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
                      onTap: onTap,
                      child: SizedBox(
                        height: 30,
                        width: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              "assets/Icons/edit.svg",
                              colorFilter: ColorFilter.mode(
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
                                fontWeight: FontWeight.w600,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 0),
                          backgroundColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: Color(0xFF673AB7),
                            ),
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons.delete,
                          size: 14,
                          color: Color(0xFF673AB7),
                        ),
                        onPressed: onDelete,
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
  }
}
