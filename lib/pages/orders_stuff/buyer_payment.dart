// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:material_symbols_icons/symbols.dart';

class BuyerPaymentPage extends StatefulWidget {
  const BuyerPaymentPage({super.key});

  @override
  State<BuyerPaymentPage> createState() => _BuyerPaymentPageState();
}

class _BuyerPaymentPageState extends State<BuyerPaymentPage> {
  bool? isVisible = true;
  List<bool>? isSelected = [true, false];
  String? dropdownValue;
  GlobalKey<FormState>? formKey = GlobalKey();
  TextEditingController amountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;
    return Form(
      key: formKey,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Symbols.arrow_back_ios_new_rounded,
                size: 24, color: Colors.white),
          ),
          title: const Text(
            'Payment',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(
                0xFFFF8811,
              ),
            ),
          ),
          centerTitle: true,
          // flexibleSpace: Container(
          //   decoration: BoxDecoration(gradient: appBarGradient),
          // ),
          //backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(12, 48, 12, 0),
                height: screenHeight * 1,
                //decoration: BoxDecoration(gradient: myGradient),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ToggleButtons(
                          fillColor: Color(0xFFF4D06F),
                          borderWidth: 2,
                          borderRadius: BorderRadius.circular(8),
                          isSelected: isSelected!,
                          onPressed: (index) {
                            setState(() {
                              for (var i = 0; i < isSelected!.length; i++) {
                                if (index == 1) {
                                  isVisible = false;
                                } else if (index == 0) {
                                  isVisible = true;
                                }
                                isSelected![i] = i == index;
                              }
                            });
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Icon(
                                    Icons.dynamic_feed_rounded,
                                    size: 40,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    "Pay \nInstallmentally",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Icon(
                                    Icons.payment_rounded,
                                    size: 40,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    "Pay \nOnce",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order Total Amount:",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "Price",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: isVisible!,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Number of Installments:",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                              DropdownMenu(
                                // trailingIcon: Icon(
                                //   Icons.arrow_drop_down_rounded,
                                //   color: Colors.white,
                                // ),
                                // textStyle: TextStyle(
                                //   color: Colors.white,
                                // ),
                                hintText: "Select",
                                menuStyle: MenuStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll<Color>(
                                    Colors.grey.shade200,
                                  ),
                                ),
                                //initialSelection: dropdownValue,
                                onSelected: (val) {
                                  setState(() {
                                    dropdownValue = val!;
                                  });
                                },
                                dropdownMenuEntries: List.generate(3, (index) {
                                  int newIndex = index + 1;
                                  return DropdownMenuEntry(
                                    value: newIndex.toString(),
                                    label: "$newIndex",
                                  );
                                }),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextInputWidget(
                            labelText: "Initial Installment Amount(NGN)",
                            hintText: "1000",
                            textInputType: Platform.isIOS
                                ? TextInputType.numberWithOptions()
                                : TextInputType.number,
                            controller: amountController,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Enter an Amount";
                              }
                              return null;
                            },
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                      onPressed: () {
                        if (isVisible == true) {
                          bool? validate = formKey?.currentState!.validate();
                          if (validate!) {
                            formKey?.currentState!.save();
                            debugPrint("isVible true");
                          }
                        } else {
                          debugPrint("isVible false");
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.24),
                        backgroundColor: Color(0xFF392F5A),
                        side: BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Proceed to Pay",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 24),
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
  }
}
