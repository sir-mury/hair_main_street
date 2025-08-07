import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:credit_card_type_detector/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/extras/country_state.dart';
import 'package:hair_main_street/models/userModel.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:keyboard_service/keyboard_service.dart';

class ChangeAddressWidget extends StatelessWidget {
  final String? text;
  final Function(Address)? onFilled;
  const ChangeAddressWidget({this.onFilled, this.text, super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey();
    CountryAndStatesAndLocalGovernment countryAndStatesAndLocalGovernment =
        CountryAndStatesAndLocalGovernment();
    String? state, localGovernment, streetAddress, landmark, zipcode;
    TextEditingController streetAddressController = TextEditingController();
    TextEditingController landmarkController = TextEditingController();
    TextEditingController zipcodeController = TextEditingController();
    dismissKeyboard() {
      bool isKeyboardVisible = KeyboardService.isVisible(context);
      isKeyboardVisible ? KeyboardService.dismiss() : null;
    }

    return StatefulBuilder(
      builder: (context, StateSetter setState) => AlertDialog(
        scrollable: true,
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(12),
        elevation: 0,
        content: GestureDetector(
          onTap: () => dismissKeyboard(),
          child: SizedBox(
            height: 700,
            width: double.infinity,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "$text",
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Lato',
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Column(
                      children: [
                        buildPicker(
                            "State",
                            countryAndStatesAndLocalGovernment.statesList,
                            state, (val) {
                          setState(() {
                            state = val;
                            localGovernment = null;
                          });
                        }),
                        const SizedBox(
                          height: 4,
                        ),
                        buildPicker(
                            "Local Government",
                            countryAndStatesAndLocalGovernment
                                    .stateAndLocalGovernments[state] ??
                                [],
                            localGovernment ?? "select", (val) {
                          setState(() {
                            localGovernment = val;
                          });
                        }),
                        const SizedBox(
                          height: 4,
                        ),
                        TextInputWidgetWithoutLabelForDialog(
                          controller: streetAddressController,
                          // initialValue: vendorController
                          //         .vendor.value!.contactInfo!["street address"] ??
                          //     "",
                          hintText: "Enter Street Address",
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Cannot be Empty";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            streetAddressController.text = val!;
                            streetAddress = streetAddressController.text;
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        TextInputWidgetWithoutLabelForDialog(
                          controller: landmarkController,
                          // initialValue: vendorController
                          //         .vendor.value!.contactInfo!["street address"] ??
                          //     "",
                          hintText: "Enter Landmark",
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Cannot be Empty";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            landmarkController.text = val!;
                            landmark = landmarkController.text;
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        TextInputWidgetWithoutLabelForDialog(
                          controller: zipcodeController,
                          // initialValue: vendorController
                          //         .vendor.value!.contactInfo!["street address"] ??
                          //     "",
                          hintText: "Enter Zip Code",
                          textInputType: Platform.isIOS
                              ? TextInputType.phone
                              : TextInputType.number,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Cannot be Empty";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            zipcodeController.text = val!;
                            zipcode = zipcodeController.text;
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        TextInputWidgetWithoutLabelForDialog(
                          controller: zipcodeController,
                          // initialValue: vendorController
                          //         .vendor.value!.contactInfo!["street address"] ??
                          //     "",
                          hintText: "Enter Zip Code",
                          textInputType: Platform.isIOS
                              ? TextInputType.phone
                              : TextInputType.number,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Cannot be Empty";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            zipcodeController.text = val!;
                            zipcode = zipcodeController.text;
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        TextInputWidgetWithoutLabelForDialog(
                          controller: zipcodeController,
                          // initialValue: vendorController
                          //         .vendor.value!.contactInfo!["street address"] ??
                          //     "",
                          hintText: "Enter Zip Code",
                          textInputType: TextInputType.number,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Cannot be Empty";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            zipcodeController.text = val!;
                            zipcode = zipcodeController.text;
                            return null;
                          },
                        ),
                      ],
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                          side: const BorderSide(
                            width: 2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        var validated = formKey.currentState!.validate();
                        if (validated) {
                          formKey.currentState!.save();
                          dismissKeyboard();
                          Address address = Address(
                            lGA: localGovernment,
                            zipCode: zipcode,
                          );

                          onFilled!(address);
                        }
                        Get.back();
                      },
                      child: const Text(
                        "Confirm Edit",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPicker(String label, List<String> items, String? selectedValue,
      Function(String?) onChanged) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isDense: true,
              onChanged: onChanged,
              items: [
                const DropdownMenuItem(
                  value: 'select',
                  child: Text('Select'),
                ),
                ...items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BuildPicker extends StatelessWidget {
  const BuildPicker({
    super.key,
    this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.labelColor,
    this.labelFontSize,
    this.hintText,
  });

  final String? label;
  final Color? labelColor;
  final double? labelFontSize;
  final List<String> items;
  final String? selectedValue;
  final Function(String? val) onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label == null
            ? const SizedBox.shrink()
            : Text(
                label!,
                style: TextStyle(
                  color: labelColor ?? Colors.black,
                  fontSize: labelFontSize ?? 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lato',
                ),
              ),
        const SizedBox(
          height: 4,
        ),
        InputDecorator(
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                width: 0.1,
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),
            fillColor: const Color(0xFFF5F5F5),
            filled: true,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue ?? hintText,
              isDense: true,
              onChanged: onChanged,
              items: [
                DropdownMenuItem(
                  value: hintText,
                  child: Text(
                    hintText ?? "",
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.34),
                      fontSize: 15,
                      fontFamily: "Raleway",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ...items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: "Raleway",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CardUIWidget extends StatelessWidget {
  final void Function()? getTo;
  final void Function()? getBack;
  final String? amountPaid;
  const CardUIWidget({this.amountPaid, this.getBack, this.getTo, super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController creditCardController = TextEditingController();
    TextEditingController cvvController = TextEditingController();
    TextEditingController expiryDateController = TextEditingController();
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

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      "assets/app_icons/HMS main.png",
                      height: 30,
                      width: 100,
                    ),
                    IconButton.filled(
                      onPressed: getBack,
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                CreditCardInputWidget(
                    controller: creditCardController,
                    hintText: "Enter your card number",
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    labelText: "Card Number",
                    labelColor: Colors.black26,
                    fontSize: 15,
                    textInputType: Platform.isIOS
                        ? TextInputType.phone
                        : TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please enter your card number";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        determineCardType(val!);
                        if (val.isNotEmpty) {
                          creditCardController.text = val;
                        }
                      });
                    }),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    CardExpiryDateInputWidget(
                      labelText: "MM/YY",
                      textInputType: Platform.isIOS
                          ? TextInputType.phone
                          : TextInputType.number,
                      labelColor: Colors.black26,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please enter your card expiry date";
                        }
                        return null;
                      },
                      onChanged: (p0) {
                        setState(() {
                          if (p0!.isNotEmpty) {
                            expiryDateController.text = p0;
                          }
                        });
                      },
                      controller: expiryDateController,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    TextInputWidgetWithoutLabelForDialog(
                      textInputType: Platform.isIOS
                          ? TextInputType.phone
                          : TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      hintText: "Cvv/Cvc",
                      // labelColor: Colors.black26,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please enter your card Cvv/Cvc";
                        } else if (val.length > 3) {
                          return "Value cannot exceed 3 digits";
                        }
                        return null;
                      },
                      onChanged: (p0) {
                        setState(() {
                          if (p0!.isNotEmpty) {
                            cvvController.text = p0;
                          }
                        });
                        return null;
                      },
                      controller: cvvController,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: getTo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7),
                      padding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Pay NGN ${formatCurrency(amountPaid!)}",
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class SnackBarWidget extends StatelessWidget {
  final Color color;
  final String message;
  final String? subtitle;
  final num? duration;
  const SnackBarWidget({
    required this.color,
    required this.message,
    this.duration,
    this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({
    super.key,
    required this.title,
    required this.confirmAction,
    required this.cancelAction,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback confirmAction;
  final VoidCallback cancelAction;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      contentPadding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      content: subtitle == null
          ? const SizedBox.shrink()
          : Text(
              subtitle!,
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
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
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
            cancelAction;
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
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
            //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0xFF673AB7),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: confirmAction,
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
    );
  }
}

class ProfilePicturePage extends StatelessWidget {
  final String? imageUrl;
  final bool isUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  const ProfilePicturePage({
    this.imageUrl,
    this.onEdit,
    this.onShare,
    required this.isUrl,
    super.key,
  });

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
          'Profile Picture',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lato',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              onEdit!;
            },
            icon: Icon(
              Icons.edit,
              size: 28,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {
              onShare!;
            },
            icon: Icon(
              Icons.share,
              size: 28,
              color: Colors.black,
            ),
          ),
        ],
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 8),
        color: isUrl ? Colors.black : Colors.white,
        child: isUrl == true
            ? CachedNetworkImage(
                height: 350,
                width: 350,
                fit: BoxFit.cover,
                imageUrl: imageUrl!,
                errorWidget: (context, url, error) {
                  return Text("There was an error $error");
                },
                placeholder: (context, url) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              )
            : SizedBox(
                height: 380,
                width: 380,
                child: ColoredBox(
                  color: Colors.black12,
                  child: SvgPicture.asset(
                    "assets/Icons/user.svg",
                    height: 80,
                    width: 80,
                    colorFilter: ColorFilter.mode(
                      Colors.black54,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}


// LikeButton(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         size: 20,
//                         bubblesSize: 48,
//                         isLiked: isLiked,
//                         onTap: (isTapped) async {
//                           // Only proceed if the user is logged in
//                           if (isUserLoggedIn) {
//                             debugPrint("logged in");
//                             //isTapped = false;
//                             // isLiked = false;
//                             if (userController.userState.value!.uid ==
//                                 productController
//                                     .productMap[mapKey]![index]!.vendorId) {
//                               wishListController.showMyToast(
//                                   "Cannot add your own product to wishlist");
//                               return null;
//                             } else {
//                               if (isLiked) {
//                                 await wishListController
//                                     .removeFromWishlistWithProductID(id!);
//                               } else {
//                                 WishlistItem wishlistItem =
//                                     WishlistItem(wishListItemID: id!);
//                                 await wishListController
//                                     .addToWishlist(wishlistItem);
//                               }
//                             }
//                             return isUserLoggedIn ? !isLiked : false;
//                           } else {
//                             wishListController.showMyToast(
//                                 "Login to add product to your wishlist");
//                             return null;
//                           }
//                         },
//                         likeBuilder: (isLiked) {
//                           if (isLiked) {
//                             return const Icon(
//                               Icons.favorite,
//                               color: Color(0xFF673AB7),
//                             );
//                           } else {
//                             return const Icon(
//                               Icons.favorite_outline_rounded,
//                               color: Color(0xFF673AB7),
//                             );
//                           }
//                         },
//                         bubblesColor: BubblesColor(
//                           dotPrimaryColor: const Color(0xFF673AB7),
//                           dotSecondaryColor:
//                               const Color(0xFF673AB7).withValues(alpha: 0.70),
//                           dotThirdColor: Colors.white,
//                           dotLastColor: Colors.black,
//                         ),
//                       ),