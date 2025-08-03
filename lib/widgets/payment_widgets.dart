import 'dart:io';

import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:credit_card_type_detector/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
// import 'package:hair_main_street/widgets/cards.dart';
// import 'package:hair_main_street/widgets/misc_widgets.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:string_validator/string_validator.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class PaymentWidget extends StatefulWidget {
  const PaymentWidget({super.key});

  @override
  State<PaymentWidget> createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Align(
          //   alignment: Alignment.center,
          //   child: Container(
          //     width: 50,
          //     height: 6,
          //     decoration: BoxDecoration(
          //       color: Colors.black,
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          // const Text(
          //   "Payment Methods",
          //   style: TextStyle(
          //     fontFamily: "Lato",
          //     fontSize: 20,
          //     color: Colors.black,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          InkWell(
            onTap: () {
              WoltModalSheet.of(context).showNext();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: Colors.black.withValues(alpha: 0.70), width: 0.5),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 1,
                    spreadRadius: 0,
                    color: const Color(0xFF673AB7).withValues(alpha: 0.20),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    "assets/Icons/card-outline.svg",
                    height: 26,
                    width: 26,
                    colorFilter: ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Debit/Credit Cards",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Raleway",
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: Colors.black.withValues(alpha: 0.70), width: 0.5),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 1,
                    spreadRadius: 0,
                    color: const Color(0xFF673AB7).withValues(alpha: 0.20),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    "assets/Icons/bank transfer.svg",
                    height: 26,
                    width: 26,
                    colorFilter: ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Bank Transfer",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Raleway",
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardUIPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onValueReturned;
  final String amountToPay;
  const CardUIPage({
    required this.onValueReturned,
    required this.amountToPay,
    super.key,
  });

  @override
  State<CardUIPage> createState() => _CardUIPageState();
}

class _CardUIPageState extends State<CardUIPage> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  String? cardNumber;
  String? cvv;
  int? expiryYear;
  int? expiryMonth;
  @override
  Widget build(BuildContext context) {
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

    String determineCardType(String value) {
      List<CreditCardType> cardTypes = detectCCType(value);
      if (cardTypes.contains(CreditCardType.visa())) {
        return "assets/card_images/visa.png";
      } else if (cardTypes.contains(CreditCardType.mastercard())) {
        return "assets/card_images/mastercard.png";
      } else if (cardTypes.contains(CreditCardType.dinersClub())) {
        return "assets/card_images/dinners_club.png.png";
      } else if (cardTypes.contains(CreditCardType.americanExpress())) {
        return "assets/card_images/american_express.png";
      } else if (cardTypes.contains(CreditCardType.discover())) {
        return "assets/card_images/discover.png";
      } else {
        return "assets/card_images/others.png";
      }
    }

    String assetImage = "";

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
        child: Column(
          children: [
            CreditCardInputWidget(
              controller: cardNumberController,
              fontSize: 16,
              hintText: "",
              labelText: "Card Number",
              textInputType: Platform.isIOS
                  ? TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    )
                  : TextInputType.number,
              labelColor: Colors.black,
              assetImage: assetImage,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter your card number";
                } else if (!value.isCreditCard) {
                  return "Can only take card numbers";
                }
                return null;
              },
              onChanged: (value) {
                if (value!.isNotEmpty) {
                  setState(() {
                    assetImage = determineCardType(value);
                    debugPrint(assetImage);
                    cardNumberController.text = value;
                  });
                  return;
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            CardExpiryDateInputWidget(
              fontSize: 16,
              controller: expiryDateController,
              labelText: "Expiry Date",
              hintText: "00/00",
              textInputType: Platform.isIOS
                  ? TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    )
                  : TextInputType.number,
              labelColor: Colors.black,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter your card expiry date";
                } else if (DateTime.tryParse(value) != null) {
                  return "Can only take date time";
                }
                return null;
              },
              onChanged: (value) {
                if (value!.isNotEmpty) {
                  setState(() {
                    expiryDateController.text = value;
                  });
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextInputWidget(
              controller: cvvController,
              labelText: "Cvv/Cvc",
              fontSize: 16,
              hintText: "",
              labelColor: Colors.black,
              textInputType: Platform.isIOS
                  ? TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    )
                  : TextInputType.number,
              onChanged: (value) {
                if (value!.isNotEmpty) {
                  setState(() {
                    cvvController.text = value;
                  });
                }
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please fill in your card cvv/cvc";
                }
                if (value.length > 5 || value.length < 3) {
                  return "cvv/cvc must be between 3 to 5 digits";
                }
                if (!value.isNumericOnly) {
                  return "Can only be numbers";
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                // print(expiryDateController.text);
                // print(cardNumberController.text);
                bool validate = formKey.currentState!.validate();
                if (validate) {
                  String expiryDate = expiryDateController.text.splitMapJoin(
                    "/",
                    onMatch: (m) => "",
                  );
                  cardNumber = cardNumberController.text.splitMapJoin(
                    ' ',
                    onMatch: (m) => "",
                  );
                  cvv = cvvController.text;

                  expiryMonth = int.tryParse(expiryDate.substring(0, 2));
                  expiryYear = int.tryParse(expiryDate.substring(2));
                  Map<String, dynamic> valueReturned = {
                    "cardNumber": cardNumber,
                    "cvv": cvv,
                    "expiryMonth": expiryMonth,
                    "expiryYear": expiryYear,
                  };
                  widget.onValueReturned(valueReturned);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
              ),
              child: Text(
                "Pay NGN${formatCurrency(widget.amountToPay)}",
                style: const TextStyle(
                  fontFamily: "Lato",
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
