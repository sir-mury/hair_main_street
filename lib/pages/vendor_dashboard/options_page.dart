import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:keyboard_service/keyboard_service.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProductOptionsPage extends StatefulWidget {
  final List<ProductOption>? productOptions;
  const ProductOptionsPage({this.productOptions, super.key});

  @override
  State<ProductOptionsPage> createState() => _ProductOptionsPageState();
}

class _ProductOptionsPageState extends State<ProductOptionsPage> {
  List<ProductOption> options = [];
  List<TextEditingController> lengthControllers = [];
  List<TextEditingController> colorControllers = [];
  List<TextEditingController> priceControllers = [];
  List<TextEditingController> stockControllers = [];
  GlobalKey<FormState> formKey = GlobalKey();
  bool hasOption = false;
  Map<String, dynamic> resultMap = {
    "hasOption": false,
    "options": [],
  };

  @override
  void initState() {
    super.initState();
    if (widget.productOptions == null || widget.productOptions!.isEmpty) {
      options.add(
          ProductOption(length: '', color: "", price: 0, stockAvailable: 0));
      debugPrint("options unfilled $options");
      lengthControllers.add(TextEditingController());
      colorControllers.add(TextEditingController());
      stockControllers.add(TextEditingController());
      priceControllers.add(TextEditingController());
    } else {
      options = widget.productOptions!;
      debugPrint("options filled $options");
      lengthControllers =
          List.filled(options.length, TextEditingController(), growable: true);
      colorControllers =
          List.filled(options.length, TextEditingController(), growable: true);
      stockControllers =
          List.filled(options.length, TextEditingController(), growable: true);
      priceControllers =
          List.filled(options.length, TextEditingController(), growable: true);
    }
  }

  void removeOption(int index) {
    setState(() {
      lengthControllers.removeAt(index);
      colorControllers.removeAt(index);
      priceControllers.removeAt(index);
      stockControllers.removeAt(index);
      options.removeAt(index);
    });
  }

  void addOption() {
    setState(() {
      options.add(
          ProductOption(length: '', color: "", price: 0, stockAvailable: 0));
      lengthControllers.add(TextEditingController());
      colorControllers.add(TextEditingController());
      priceControllers.add(TextEditingController());
      stockControllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardAutoDismiss(
      scaffold: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          //leadingWidth: 40,
          backgroundColor: Colors.white,
          leading: InkWell(
            onTap: () {
              widget.productOptions != null && widget.productOptions!.isNotEmpty
                  ? resultMap["hasOption"] = true
                  : resultMap['hasOption'] = false;
              widget.productOptions != null && widget.productOptions!.isNotEmpty
                  ? resultMap["options"] = widget.productOptions
                  : resultMap['options'] = null;
              // resultMap['options'] = null;
              Get.back(result: resultMap);
            },
            radius: 12,
            child: const Icon(
              Symbols.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.black,
            ),
          ),
          title: const Text(
            'Add Product Options',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: 'Lato',
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  // CheckboxListTile(
                  //   contentPadding:
                  //       const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  //   value: checkbox2,
                  //   onChanged: (val) {
                  //     setState(() {
                  //       checkbox2 = val!;
                  //       product!.hasOptions = val;
                  //       if (val) {
                  //         addOption();
                  //       } else {
                  //         removeOption(0);
                  //       }
                  //     });
                  //   },
                  //   title: const Text(
                  //     "Product Has Options?",
                  //     style: TextStyle(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  // ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(
                      options.length,
                      (index) => Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: TextInputWidget(
                                      controller: lengthControllers[index],
                                      fontSize: 14,
                                      initialValue: options[index].length ?? "",
                                      labelText: "Length",
                                      hintText: "Enter Product Length",
                                      validator: (val) {
                                        if (val!.isEmpty &&
                                            options[index].color == null) {
                                          return "You must at least fill this";
                                        } else if (val.isEmpty &&
                                            options[index].color!.isEmpty) {
                                          return "You must at least fill this";
                                        }
                                        return null;
                                      },
                                      onChanged: (val) {
                                        setState(() {
                                          if (val!.isEmpty) {
                                            options[index].length = null;
                                          }
                                          options[index].length = val;
                                        });
                                        // return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: TextInputWidget(
                                      controller: lengthControllers[index],
                                      fontSize: 14,
                                      labelText: "Colour",
                                      hintText: "Enter product colour",
                                      initialValue: options[index].color ?? "",
                                      validator: (val) {
                                        if (val!.isEmpty &&
                                            options[index].length == null) {
                                          return "You must at least fill this";
                                        } else if (val.isEmpty &&
                                            options[index].length!.isEmpty) {
                                          return "You must at least fill this";
                                        }
                                        return null;
                                      },
                                      onChanged: (val) {
                                        setState(() {
                                          if (val!.isEmpty) {
                                            options[index].color = null;
                                          }
                                          options[index].color = val;
                                        });
                                        // return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: TextInputWidget(
                                      textInputType: TextInputType.number,
                                      controller: priceControllers[index],
                                      initialValue:
                                          options[index].price?.toString() ??
                                              "0",
                                      fontSize: 14,
                                      labelText: "Price",
                                      hintText: "Enter option price",
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return 'Please Enter an Option Price';
                                        }
                                        return null;
                                      },
                                      onChanged: (val) {
                                        setState(() {
                                          if (val!.isNotEmpty) {
                                            options[index].price =
                                                num.parse(val);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: TextInputWidget(
                                      controller: stockControllers[index],
                                      initialValue: options[index]
                                              .stockAvailable
                                              ?.toString() ??
                                          "0",
                                      textInputType: TextInputType.number,
                                      fontSize: 14,
                                      labelText: "Stock Available",
                                      hintText: "Enter stock available",
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return 'Please Enter the stock available';
                                        }
                                        return null;
                                      },
                                      onChanged: (val) {
                                        setState(() {
                                          if (val!.isNotEmpty) {
                                            options[index].stockAvailable =
                                                int.parse(val);
                                          }
                                        });
                                        return;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        addOption();
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      size: 20,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (options.length > 1) {
                                          removeOption(index);
                                        }
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.remove_circle_outline_rounded,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
          child: BottomAppBar(
            elevation: 0,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            height: kToolbarHeight,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                  shape: RoundedRectangleBorder(
                    // side: const BorderSide(
                    //   width: 1.2,
                    //   color: Colors.black,
                    // ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  bool validate = formKey.currentState!.validate();
                  if (validate) {
                    hasOption = true;
                    resultMap['hasOption'] = hasOption;
                    resultMap['options'] = options;
                    Get.back(result: resultMap);
                  }
                },
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
