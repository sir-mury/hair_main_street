import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/extras/country_state.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:hair_main_street/widgets/misc_widgets.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:material_symbols_icons/symbols.dart';

class EditDeliveryAddressPage extends StatefulWidget {
  final String addressID;
  const EditDeliveryAddressPage({required this.addressID, super.key});

  @override
  State<EditDeliveryAddressPage> createState() =>
      _EditDeliveryAddressPageState();
}

class _EditDeliveryAddressPageState extends State<EditDeliveryAddressPage> {
  UserController userController = Get.find<UserController>();
  CountryAndStatesAndLocalGovernment countryAndStatesAndLocalGovernment =
      CountryAndStatesAndLocalGovernment();
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController contactNameController = TextEditingController();
  TextEditingController contactPhoneNumberController = TextEditingController();
  TextEditingController streetAddressController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  Address? address;
  bool defaultAddress = false;
  String? contactName,
      contactPhoneNumber,
      streetAddress,
      lGA,
      state,
      landmark,
      zipcode;

  @override
  void initState() {
    address = userController.getSingleAddress(widget.addressID);
    defaultAddress = address!.isDefault!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    state = address!.state;
    lGA = address!.lGA;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 40,
        leading: InkWell(
          onTap: () => Get.back(),
          radius: 12,
          child: const Icon(
            Symbols.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Edit Delivery Address',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            fontFamily: 'Lato',
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: BuildPicker(
                    label: "Region/State",
                    items: countryAndStatesAndLocalGovernment.statesList,
                    hintText: "Choose Region/State",
                    selectedValue: state,
                    onChanged: (val) {
                      setState(() {
                        state = val;
                        lGA = null;
                      });
                    },
                  ),
                ),
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
                const SizedBox(
                  height: 12,
                ),
                TextInputWidget(
                  controller: contactNameController,
                  hintText: "Enter Name",
                  labelColor: Colors.black,
                  initialValue: address!.contactName ?? "",
                  labelText: "Contact Name",
                  fontSize: 18,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputType: TextInputType.name,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Cannot be Empty";
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      // contactNameController.text = val!;
                      // contactName = contactNameController.text;
                      address!.contactName = val!;
                    });
                  },
                ),
                const SizedBox(
                  height: 4,
                ),
                TextInputWidget(
                  controller: contactPhoneNumberController,
                  hintText: "Mobile Number",
                  fontSize: 18,
                  labelColor: Colors.black.withValues(alpha: 0.55),
                  labelText: "Please enter a contact number",
                  initialValue: address!.contactPhoneNumber ?? "",
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputType: TextInputType.number,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Cannot be Empty";
                    } else if (val.length < 11 || val.length > 11) {
                      return "Cannot be less or more than 11 Digits";
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      // contactPhoneNumberController.text = val!;
                      // contactPhoneNumber = contactPhoneNumberController.text;
                      address!.contactPhoneNumber = val!;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
                const SizedBox(
                  height: 12,
                ),
                TextInputWidget(
                  controller: streetAddressController,
                  hintText: "Street Address",
                  labelColor: Colors.black,
                  labelText: "Address",
                  initialValue: address!.streetAddress ?? "",
                  fontSize: 18,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputType: TextInputType.name,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Cannot be Empty";
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      // streetAddressController.text = val!;
                      // streetAddress = streetAddressController.text;
                      address!.streetAddress = val!;
                    });
                  },
                ),
                const SizedBox(
                  height: 4,
                ),
                BuildPicker(
                  //label: "Region/State",
                  hintText: "LGA",
                  items: countryAndStatesAndLocalGovernment
                          .stateAndLocalGovernments[state] ??
                      [],
                  selectedValue: lGA ?? "LGA",
                  onChanged: (val) {
                    setState(() {
                      lGA = val;
                    });
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                TextInputWidgetWithoutLabel(
                  controller: landmarkController,
                  hintText: "Landmark",
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputType: TextInputType.text,
                  initialValue: address!.landmark ?? "",
                  validator: (val) {
                    // if (val!.isEmpty) {
                    //   return "Cannot be Empty";
                    // } else if (val.length < 11 || val.length > 11) {
                    //   return "Cannot be less or more than 11 Digits";
                    // }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      // landmarkController.text = val!;
                      // landmark = landmarkController.text;
                      landmark = val!;
                    });
                    return null;
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                TextInputWidgetWithoutLabel(
                  controller: zipcodeController,
                  hintText: "ZIP code",
                  initialValue: address!.zipCode ?? "",
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputType: TextInputType.number,
                  validator: (val) {
                    if (!val!.isNumericOnly) {
                      return "Must be Numbers Only";
                    } else if (val.length < 6 || val.length > 6) {
                      return "Cannot be less or more than 6 Digits";
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      address!.zipCode = val!;
                    });
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SwitchListTile(
                    value: defaultAddress,
                    onChanged: (value) {
                      setState(() {
                        defaultAddress = value;
                      });
                    },
                    thumbColor: WidgetStatePropertyAll(
                        const Color(0xFF673AB7).withValues(alpha: 0.25)),
                    //activeColor: const Color(0xFF673AB7).withOpacity(0.25),
                    activeTrackColor: const Color(0xFF673AB7),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey[300],
                    //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    trackOutlineColor:
                        const WidgetStatePropertyAll(Colors.white),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: Text(
                      "Set as Default Delivery Address",
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.80),
                        fontSize: 15,
                        fontFamily: "Lato",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
          child: TextButton(
            onPressed: () async {
              bool validate = formKey.currentState!.validate();
              if (validate) {
                userController.isLoading.value = true;
                if (userController.isLoading.value) {
                  Get.dialog(const LoadingWidget());
                }
                // Address address = Address(
                //   landmark: landmark,
                //   streetAddress: streetAddress,
                //   lGA: lGA,
                //   state: state,
                //   contactName: contactName,
                //   contactPhoneNumber: contactPhoneNumber,
                //   zipCode: zipcode,
                // );
                var value = await userController.editDeliveryAddress(
                  userController.userState.value!.uid!,
                  address!,
                  defaultAddress,
                );
                if (value == 'success') {
                  Get.close(2);
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
              "Edit Delivery Address",
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
}
