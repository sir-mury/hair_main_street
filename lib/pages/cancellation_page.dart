import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/refund_cancellation_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/extras/paystack_bank_code.dart';
import 'package:hair_main_street/models/refund_request_model.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ic.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:recase/recase.dart';
import 'package:string_validator/string_validator.dart' as validator;

class CancellationPage extends StatefulWidget {
  final String orderId; // Pass the actual order ID as a String
  final num paymentAmount;

  const CancellationPage(
      {super.key, required this.orderId, required this.paymentAmount});

  @override
  State<CancellationPage> createState() => _CancellationPageState();
}

class _CancellationPageState extends State<CancellationPage> {
  String selectedReason = "Changed My Mind"; // Initial selected reason
  TextEditingController othersController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  UserController userController = Get.find<UserController>();
  PaystackBankCode banksAndBankCodes = PaystackBankCode();
  RefundCancellationController refundCancellationController =
      Get.find<RefundCancellationController>();
  GlobalKey<FormState> formKey = GlobalKey();
  num? convenienceFee;
  String? accountNumber;
  String? bankCode;
  String? bankName;
  String? accountName;

  @override
  void initState() {
    if (userController.adminVariables.value?.convinienceFee != null) {
      convenienceFee =
          userController.adminVariables.value!.convinienceFee! / 100;
    } else {
      convenienceFee = 0;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> bankAndCodes = banksAndBankCodes.paystackBankCodes;
    CancellationRequest cancellationRequest = CancellationRequest(
        orderID: widget.orderId, userID: userController.userState.value!.uid);
    showMyAlertDialog() {
      return Get.dialog(
        AlertDialog(
          elevation: 0,
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          contentPadding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
          title: const Text(
            "Cancellation Confirmation",
            style: TextStyle(
              fontSize: 19,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: Text(
            "Are you sure you want to cancel this order? There may be charges",
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
                refundCancellationController.isLoading.value = true;
                if (refundCancellationController.isLoading.value == true) {
                  Get.dialog(const LoadingWidget());
                }
                await refundCancellationController
                    .submitCancellationRequest(cancellationRequest);
                // Perform the proceed action here
                debugPrint('Proceed button clicked');
                //Get.back();
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Symbols.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black,
          ),
        ),
        title: const Text(
          "Cancel Order",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            fontFamily: "Lato",
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Order ID Row
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(0xFF673AB7).withValues(alpha: 0.30),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "Order ID:",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        widget.orderId, // Display the actual order ID
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                // Reason for cancellation
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Reason for Cancellation:",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: Color(0xFFf5f5f5),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                        color: Colors.white,
                        initialValue: selectedReason,
                        //icon: const Icon(Icons.arrow_drop_down),
                        onSelected: (String? newValue) {
                          setState(() {
                            selectedReason = newValue!;
                          });
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: "Changed My Mind",
                            child: Text("Changed My Mind"),
                          ),
                          const PopupMenuItem<String>(
                            value: "Wrong Order",
                            child: Text("Wrong Order"),
                          ),
                          const PopupMenuItem<String>(
                            value: "No Funds To Complete Order",
                            child: Text("No Funds To Complete Order"),
                          ),
                          const PopupMenuItem<String>(
                            value: "Others",
                            child: Text("Others"),
                          ),
                        ],
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black26,
                              width: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              selectedReason.titleCase,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Visibility(
                  visible: selectedReason == "Others",
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
                    child: TextInputWidgetWithoutLabel(
                      controller: othersController,
                      hintText: "Specify Reason",
                      onChanged: (value) {
                        if (value!.isNotEmpty) {
                          othersController.text = value;
                          selectedReason = othersController.text;
                        }
                        return null;
                      },
                      validator: (value) {
                        if (value!.isEmpty && selectedReason == "Others") {
                          return "Please Specify Your Reason";
                        }
                        return null;
                      },
                      minLines: 3,
                      maxLines: 7,
                    ),
                  ),
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
                        compareFn: (item1, item2) => item1 == item2,
                        suffixProps: DropdownSuffixProps(
                          clearButtonProps: ClearButtonProps(
                            icon: Iconify(
                              Ic.clear,
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
                                      color:
                                          Colors.black.withValues(alpha: 0.45),
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
                          itemBuilder:
                              (context, item, isDisabled, isSelected) =>
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
                        items: (f, cs) => bankAndCodes.keys.toList(),
                        validator: (value) {
                          if (value.toString().isEmpty) {
                            return "Please choose your Bank name";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            bankName = value.toString();
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
                        hintText: "Enter Account Number",
                        maxLines: 1,
                        fontSize: 15,
                        labelColor: const Color(0xFF673AB7),
                        autofillHints: [AutofillHints.transactionAmount],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textInputType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter your account number";
                          } else if (!validator.isNumeric(value)) {
                            return "Account Number must be numbers only";
                          } else if (value.length < 10) {
                            return 'Account Number must be > 10 numbers';
                          } else if (value.length > 10) {
                            return 'Account Number must be 10 numbers only';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            accountNumber = val;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextInputWidget(
                        controller: accountNameController,
                        labelText: "Account Name",
                        hintText: "Enter your account name",
                        maxLines: 1,
                        fontSize: 15,
                        labelColor: const Color(0xFF673AB7),
                        textInputType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter your account name";
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            accountName = val!;
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
                  height: 14,
                ),

                Row(
                  children: [
                    Icon(
                      Icons.info_outlined,
                      color: const Color(0xFF673AB7).withValues(alpha: 0.50),
                      size: 20,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        "Order cancellations attract charges and are subject to approval. Once approved, the amount will be sent to the specified within 3 working days.\nThank you",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          color: Colors.black.withValues(alpha: 0.50),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          height: kToolbarHeight,
          elevation: 0,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              var validated = formKey.currentState!.validate();
              if (validated) {
                formKey.currentState!.save();
                cancellationRequest.reason = selectedReason;
                cancellationRequest.cancellationAmount = widget.paymentAmount -
                    (widget.paymentAmount * convenienceFee!);
                cancellationRequest.cancellationAccount = accountNumber;
                cancellationRequest.cancellationBankCode =
                    bankAndCodes[bankName!];
                showMyAlertDialog();
              }
              // Handle submit button press (e.g., submit refund request)
            },
            child: const Text(
              "Submit Cancellation Request",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
