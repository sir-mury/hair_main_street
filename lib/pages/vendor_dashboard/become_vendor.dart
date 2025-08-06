import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/blank_page.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/extras/country_state.dart';
import 'package:hair_main_street/extras/paystack_bank_code.dart';
import 'package:hair_main_street/models/vendors_model.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:hair_main_street/widgets/misc_widgets.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ic.dart';
import 'package:string_validator/string_validator.dart' as validator;

class BecomeAVendorPage extends StatefulWidget {
  const BecomeAVendorPage({super.key});

  @override
  State<BecomeAVendorPage> createState() => _BecomeAVendorPageState();
}

class _BecomeAVendorPageState extends State<BecomeAVendorPage> {
  Vendors vendor =
      Vendors(shopName: '', accountInfo: {}, contactInfo: {}, userID: "");
  CountryAndStatesAndLocalGovernment countryAndStatesAndLocalGovernment =
      CountryAndStatesAndLocalGovernment();
  TextEditingController? shopNameController,
      bankNameController,
      accountNumberController,
      accountNameController,
      streetAddressController,
      phoneNumberController,
      stateController = TextEditingController();
  String? country, state, localGovernment, bankName, bankCode;
  GlobalKey<FormState> formKey = GlobalKey();
  UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    PaystackBankCode banksAndBankCodes = PaystackBankCode();
    Map<String, String> banksandCodes = banksAndBankCodes.paystackBankCodes;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 40,
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
          'Become a Vendor',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            fontFamily: 'Lato',
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.75),
                    width: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Shop Info",
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.65),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextInputWidget(
                      controller: shopNameController,
                      labelText: "Shop Name",
                      labelColor:
                          const Color(0xFF673AB7).withValues(alpha: 0.50),
                      hintText: "",
                      maxLines: 3,
                      minLines: 1,
                      fontSize: 15,
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please Enter Your Shop Name";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          vendor.shopName = val;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    BuildPicker(
                      labelColor:
                          const Color(0xFF673AB7).withValues(alpha: 0.50),
                      label: 'State',
                      hintText: 'Select',
                      labelFontSize: 15,
                      items: countryAndStatesAndLocalGovernment.statesList,
                      selectedValue: state,
                      onChanged: (val) {
                        setState(() {
                          state = val;
                          localGovernment = null;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    BuildPicker(
                      labelColor:
                          const Color(0xFF673AB7).withValues(alpha: 0.50),
                      label: 'L.G.A',
                      hintText: 'Select',
                      labelFontSize: 15,
                      items: countryAndStatesAndLocalGovernment
                              .stateAndLocalGovernments[state] ??
                          [],
                      selectedValue: localGovernment,
                      onChanged: (val) {
                        setState(() {
                          localGovernment = val;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    TextInputWidget(
                      controller: streetAddressController,
                      labelText: "Street Address",
                      labelColor:
                          const Color(0xFF673AB7).withValues(alpha: 0.50),
                      hintText: "",
                      maxLines: 3,
                      minLines: 1,
                      fontSize: 15,
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please Enter Your Shop Name";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          vendor.contactInfo!['street address'] = val;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.75),
                    width: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Contact Details",
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.65),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextInputWidget(
                      controller: phoneNumberController,
                      labelText: "Phone Number",
                      fontSize: 15,
                      hintText: "",
                      labelColor:
                          const Color(0xFF673AB7).withValues(alpha: 0.50),
                      maxLines: 1,
                      textInputType: Platform.isIOS
                          ? TextInputType.phone
                          : TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter your business phone number";
                        } else if (!validator.isNumeric(value)) {
                          return "Phone number must be numbers only";
                        } else if (value.length < 10) {
                          return "Phone Number must be > 10 characters";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          vendor.contactInfo!['phone number'] = val;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.75),
                    width: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Bank Details",
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.65),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      "Bank Name",
                      style: TextStyle(
                        color: Color(0xFF673AB7),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Raleway',
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    DropdownSearch(
                      suffixProps: DropdownSuffixProps(
                        clearButtonProps: ClearButtonProps(
                          icon: Iconify(
                            Ic.baseline_keyboard_arrow_down,
                            size: 24,
                            color: Colors.black,
                          ),
                        ),
                        dropdownButtonProps: const DropdownButtonProps(
                          iconClosed: Iconify(
                            Ic.baseline_keyboard_arrow_down,
                            size: 24,
                            color: Colors.black,
                          ),
                          iconOpened: Iconify(
                            Ic.baseline_keyboard_arrow_down,
                            size: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      dropdownBuilder: (context, selectedItem) =>
                          selectedItem == null
                              ? Text(
                                  "Select Bank",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withValues(alpha: 0.45),
                                  ),
                                )
                              : Text(
                                  selectedItem.toString().capitalizeFirst!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                      popupProps: PopupProps.dialog(
                        fit: FlexFit.loose,
                        itemBuilder: (context, item, isDisabled, isSelected) =>
                            Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            "${item.toString().capitalizeFirst}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        containerBuilder: (context, popupWidget) => Container(
                          //height: 400,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: popupWidget,
                        ),
                        searchFieldProps: TextFieldProps(
                          //expands: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 6,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            hintText: "Search",
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w300,
                              color: Colors.black.withValues(alpha: 0.55),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 20,
                              color: Colors.black.withValues(alpha: 0.55),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black.withValues(alpha: 0.35),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF673AB7), width: 1.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        title: const Text(
                          "Select Bank",
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        listViewProps: const ListViewProps(
                          primary: false,
                          shrinkWrap: true,
                        ),
                        showSearchBox: true,
                      ),
                      compareFn: (item1, item2) => item1 == item2,
                      items: (f, cs) => banksandCodes.keys.toList(),
                      validator: (value) {
                        if (value.toString().isEmpty) {
                          return "Please choose your Bank name";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          bankName = value.toString();
                          if (bankName != null) {
                            vendor.accountInfo!['bank name'] = bankName;
                            bankCode = banksandCodes[bankName];
                            vendor.accountInfo!['bank code'] = bankCode;
                          }
                        });
                      },
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFf5f5f5),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 10),
                          // hintText: "Select Bank",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black.withValues(alpha: 0.35),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFF673AB7), width: 1.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintStyle: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                        ),
                        baseStyle: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    TextInputWidget(
                      controller: accountNumberController,
                      labelText: "Account Number",
                      hintText: "",
                      maxLines: 1,
                      fontSize: 15,
                      labelColor:
                          const Color(0xFF673AB7).withValues(alpha: 0.50),
                      textInputType: Platform.isIOS
                          ? TextInputType.phone
                          : TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter your account number";
                        } else if (!validator.isNumeric(value)) {
                          return "Account Number must be numbers only";
                        } else if (value.length < 10) {
                          return 'Account Number must be > 10 numbers';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          vendor.accountInfo!['account number'] = val;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextInputWidget(
                      controller: accountNameController,
                      labelText: "Account Name",
                      hintText: "",
                      maxLines: 1,
                      fontSize: 15,
                      labelColor:
                          const Color(0xFF673AB7).withValues(alpha: 0.50),
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter your account name";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          vendor.accountInfo!['account name'] = val;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          height: kToolbarHeight,
          elevation: 0,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                bool? validate = formKey.currentState!.validate();
                if (validate) {
                  country = "Nigeria";
                  vendor.contactInfo!['country'] = country;
                  if (state == null ||
                      country == null ||
                      localGovernment == null) {
                    userController
                        .showMyToast("Please Select a Country and State");
                  } else {
                    userController.isLoading.value = true;
                    if (userController.isLoading.value) {
                      Get.dialog(
                        const LoadingWidget(),
                        barrierDismissible: false,
                      );
                    }
                    vendor.userID = userController.userState.value!.uid;
                    formKey.currentState!.save();
                    await userController.becomeASeller(vendor);
                  }
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4),
                backgroundColor: const Color(0xFF673AB7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Submit Request",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MakeshiftBecomeVendorPage extends StatelessWidget {
  const MakeshiftBecomeVendorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black),
        ),
        title: const Text(
          'Become a vendor',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lato',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        // flexibleSpace: Container(
        //   decoration: BoxDecoration(gradient: appBarGradient),
        // ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: BlankPage(
        text: "This feature is coming soon...",
        haveAppBar: true,
        appBarText: "Analytics Page",
        pageIcon: const Icon(
          Icons.construction_rounded,
          color: Color(0xFF673AB7),
          size: 40,
        ),
      ),
    );
  }
}
