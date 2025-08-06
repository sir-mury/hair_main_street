import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:material_symbols_icons/symbols.dart';

class PaymentSettingsPage extends StatefulWidget {
  const PaymentSettingsPage({super.key});

  @override
  State<PaymentSettingsPage> createState() => _PaymentSettingsPageState();
}

class _PaymentSettingsPageState extends State<PaymentSettingsPage> {
  GlobalKey<FormState>? formKey = GlobalKey();

  TextEditingController? installmentController = TextEditingController();

  String? installment;

  @override
  Widget build(BuildContext context) {
    num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    Gradient myGradient = const LinearGradient(
      colors: [
        Color.fromARGB(255, 255, 224, 139),
        Color.fromARGB(255, 200, 242, 237)
      ],
      stops: [
        0.05,
        0.99,
      ],
      end: Alignment.topCenter,
      begin: Alignment.bottomCenter,
      //transform: GradientRotation(math.pi / 4),
    );
    Gradient appBarGradient = const LinearGradient(
      colors: [
        Color.fromARGB(255, 200, 242, 237),
        Color.fromARGB(255, 255, 224, 139)
      ],
      stops: [
        0.05,
        0.99,
      ],
      end: Alignment.topCenter,
      begin: Alignment.bottomCenter,
      //transform: GradientRotation(math.pi / 4),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Symbols.arrow_back_ios_new_rounded,
              size: 24, color: Colors.black),
        ),
        title: const Text(
          'Payment Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(
              0xFFFF8811,
            ),
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appBarGradient),
        ),
        //backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
        decoration: BoxDecoration(gradient: myGradient),
        child: Form(
            key: formKey,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextInputWidget(
                  textInputType: Platform.isIOS
                      ? TextInputType.phone
                      : TextInputType.number,
                  controller: installmentController,
                  labelText: "No of Installments:",
                  hintText: "Enter a number between 1 to 10",
                  onSubmit: (val) {
                    installment = val;
                    debugPrint(installment);
                    return;
                  },
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please enter a number";
                    }
                    num newVal = int.parse(val);
                    if (newVal > 10) {
                      return "Must be less than or equal to 10";
                    } else if (newVal <= 0) {
                      return "Must be greater than 0";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenHeight * .02,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          bool? validate = formKey?.currentState!.validate();
                          if (validate!) {
                            formKey?.currentState!.save();
                          }
                        },
                        style: TextButton.styleFrom(
                          // padding: EdgeInsets.symmetric(
                          //     horizontal: screenWidth * 0.24),
                          backgroundColor: const Color(0xFF392F5A),
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
