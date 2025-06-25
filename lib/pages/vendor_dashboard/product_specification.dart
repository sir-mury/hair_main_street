import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:material_symbols_icons/symbols.dart';

class SpecificationsPage extends StatefulWidget {
  final Function(List)? specificationList;
  const SpecificationsPage({this.specificationList, super.key});

  @override
  State<SpecificationsPage> createState() => _SpecificationsPageState();
}

class _SpecificationsPageState extends State<SpecificationsPage> {
  GlobalKey<FormState> formKey = GlobalKey();
  ProductController productController = Get.find<ProductController>();
  int numberOfTextBox = 1;
  List<TextEditingController> titleControllers = [];
  List<TextEditingController> specControllers = [];
  List<ProductSpecification>? specifications = [];
  bool completed = false;

  @override
  void initState() {
    super.initState();
    titleControllers =
        List.filled(numberOfTextBox, TextEditingController(), growable: true);
    specControllers =
        List.filled(numberOfTextBox, TextEditingController(), growable: true);
    debugPrint(titleControllers.length.toString());
    debugPrint(specControllers.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, stuff) {
        if (didPop) {
          return;
        }
        if (specifications!.isEmpty) {
          productController.showMyToast("You have to add a specification");
        } else if (completed == false) {
          productController.showMyToast(
              "Click Continue below to finish adding specification");
        } else {
          Get.close(1);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          leadingWidth: 40,
          backgroundColor: Colors.white,
          leading: InkWell(
            onTap: () {
              if (specifications!.isEmpty) {
                productController
                    .showMyToast("You have to add a specification");
              } else if (completed == false) {
                productController.showMyToast(
                    "Click Continue below to finish adding specification");
              } else {
                Get.close(1);
              }
            },
            radius: 12,
            child: const Icon(
              Symbols.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.black,
            ),
          ),
          title: const Text(
            'Add Product Specification',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'Lato',
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  ...List.generate(
                    numberOfTextBox,
                    (index) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.5,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextInputWidgetWithoutLabel(
                            controller: titleControllers[index],
                            hintText: "Enter Specification Title",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (titleControllers[0].text.isEmpty &&
                                  specControllers[0].text.isEmpty) {
                                return "You must fill at least 1 specification";
                              } else if (specControllers[index]
                                      .text
                                      .isNotEmpty !=
                                  titleControllers[index].text.isNotEmpty) {
                                return "You must enter a specification for this title";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                titleControllers[index].text = value!;
                                if (specifications == null ||
                                    specifications!.isEmpty) {
                                  final productSpec =
                                      ProductSpecification(title: value);
                                  specifications!.add(productSpec);
                                } else {
                                  specifications![index].title = value;
                                }
                              });
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          TextInputWidgetWithoutLabel(
                            controller: specControllers[index],
                            hintText: "Enter Product Specification",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (titleControllers[0].text == "" &&
                                  specControllers[0].text == "") {
                                return "You must fill at least 1 specification";
                              } else if (specControllers[index]
                                      .text
                                      .isNotEmpty !=
                                  titleControllers[index].text.isNotEmpty) {
                                return "You must enter a title for this specification";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                specControllers[index].text = value!;
                                if (specifications == null ||
                                    specifications!.isEmpty) {
                                  final productSpec = ProductSpecification(
                                      specification: value);
                                  specifications!.add(productSpec);
                                } else {
                                  specifications![index].specification = value;
                                }
                              });
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            numberOfTextBox = numberOfTextBox + 1;
                            titleControllers.add(TextEditingController());
                            specControllers.add(TextEditingController());
                            // print(titleControllers.length);
                          });
                        },
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF673AB7)
                                        .withValues(alpha: 0.75),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  "Add New Specification",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (numberOfTextBox > 1) {
                            setState(() {
                              numberOfTextBox = numberOfTextBox - 1;
                              titleControllers.remove(TextEditingController());
                              specControllers.remove(TextEditingController());
                              // print(titleControllers.length);
                            });
                          }
                        },
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF673AB7)
                                        .withValues(alpha: 0.75),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  "Remove Specification",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
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
                var validate = formKey.currentState!.validate();
                if (validate) {
                  for (var element in specifications!) {
                    debugPrint(element.title);
                    debugPrint(element.specification);
                  }
                  completed = true;
                  if (completed) {
                    Get.back(result: specifications);
                  }
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                backgroundColor: const Color(0xFF673AB7),
                // side:
                //     const BorderSide(color: Colors.white, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Continue",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditSpecificationsPage extends StatefulWidget {
  final List<ProductSpecification>? specificationList;
  const EditSpecificationsPage({this.specificationList, super.key});

  @override
  State<EditSpecificationsPage> createState() => _EditSpecificationsPageState();
}

class _EditSpecificationsPageState extends State<EditSpecificationsPage> {
  GlobalKey<FormState> formKey = GlobalKey();
  ProductController productController = Get.find<ProductController>();
  int? numberOfTextBox;
  List<TextEditingController> titleControllers = [];
  List<TextEditingController> specControllers = [];
  List<ProductSpecification>? specifications = [];
  bool completed = false;

  @override
  void initState() {
    super.initState();
    numberOfTextBox =
        widget.specificationList == null || widget.specificationList!.isEmpty
            ? 1
            : widget.specificationList!.length;
    specifications =
        widget.specificationList == null || widget.specificationList!.isEmpty
            ? []
            : widget.specificationList;
    completed =
        widget.specificationList == null || widget.specificationList!.isEmpty
            ? false
            : true;
    titleControllers =
        List.filled(numberOfTextBox!, TextEditingController(), growable: true);
    specControllers =
        List.filled(numberOfTextBox!, TextEditingController(), growable: true);
    debugPrint(titleControllers.length.toString());
    debugPrint(specControllers.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, stuff) {
        if (didPop) {
          return;
        }
        if (specifications!.isEmpty) {
          productController.showMyToast("You have to add a specification");
        } else if (completed == false) {
          productController.showMyToast(
              "Click Continue below to finish adding specification");
        } else {
          Get.close(1);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          leadingWidth: 40,
          backgroundColor: Colors.white,
          leading: InkWell(
            onTap: () {
              if (specifications!.isEmpty) {
                productController
                    .showMyToast("You have to add a specification");
              } else if (completed == false) {
                productController.showMyToast(
                    "Click Continue below to finish adding specification");
              } else {
                Get.close(1);
              }
            },
            radius: 12,
            child: const Icon(
              Symbols.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.black,
            ),
          ),
          title: const Text(
            'Edit Product Specification',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'Lato',
            ),
          ),
          centerTitle: true,
        ),
        body: widget.specificationList == null ||
                widget.specificationList!.isEmpty
            ? SafeArea(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        ...List.generate(
                          numberOfTextBox!,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextInputWidgetWithoutLabel(
                                  controller: titleControllers[index],
                                  hintText: "Enter Specification Title",
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (widget.specificationList != null) {
                                      return null;
                                    } else {
                                      if (titleControllers[0].text.isEmpty &&
                                          specControllers[0].text.isEmpty) {
                                        return "You must fill at least 1 specification";
                                      } else if (specControllers[index]
                                              .text
                                              .isNotEmpty !=
                                          titleControllers[index]
                                              .text
                                              .isNotEmpty) {
                                        return "You must enter a specification for this title";
                                      }
                                      return null;
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      titleControllers[index].text = value!;
                                      if (specifications == null ||
                                          specifications!.isEmpty) {
                                        final productSpec =
                                            ProductSpecification(title: value);
                                        specifications!.add(productSpec);
                                      } else {
                                        specifications![index].title = value;
                                      }
                                    });
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                TextInputWidgetWithoutLabel(
                                  controller: specControllers[index],
                                  hintText: "Enter Product Specification",
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (widget.specificationList != null) {
                                      return null;
                                    } else {
                                      if (titleControllers[0].text == "" &&
                                          specControllers[0].text == "") {
                                        return "You must fill at least 1 specification";
                                      } else if (specControllers[index]
                                              .text
                                              .isNotEmpty !=
                                          titleControllers[index]
                                              .text
                                              .isNotEmpty) {
                                        return "You must enter a title for this specification";
                                      }
                                      return null;
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      specControllers[index].text = value!;
                                      if (specifications == null ||
                                          specifications!.isEmpty) {
                                        final productSpec =
                                            ProductSpecification(
                                                specification: value);
                                        specifications!.add(productSpec);
                                      } else {
                                        specifications![index].specification =
                                            value;
                                      }
                                    });
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  numberOfTextBox = numberOfTextBox! + 1;
                                  specifications!.add(ProductSpecification());
                                  titleControllers.add(TextEditingController());
                                  specControllers.add(TextEditingController());
                                  // print(titleControllers.length);
                                });
                              },
                              child: Container(
                                color: Colors.white,
                                width: double.infinity,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 4, 0, 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF673AB7)
                                                .withValues(alpha: 0.75)),
                                        child: const Icon(
                                          Icons.add,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        "Add New Specification",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Raleway',
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black
                                              .withValues(alpha: 0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (numberOfTextBox! > 1) {
                                  setState(() {
                                    numberOfTextBox = numberOfTextBox! - 1;
                                    specifications!.removeLast();
                                    titleControllers.removeLast();
                                    specControllers.removeLast();
                                    // print(titleControllers.length);
                                  });
                                }
                              },
                              child: Container(
                                color: Colors.white,
                                width: double.infinity,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 4, 0, 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF673AB7)
                                              .withValues(alpha: 0.75),
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        "Remove Specification",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Raleway',
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black
                                              .withValues(alpha: 0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        ...List.generate(
                          numberOfTextBox!,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextInputWidgetWithoutLabel(
                                  initialValue: specifications == null ||
                                          specifications!.isEmpty
                                      ? ""
                                      : specifications![index].title,
                                  controller: titleControllers[index],
                                  hintText: "Enter Specification Title",
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (widget.specificationList != null) {
                                      return null;
                                    } else {
                                      if (titleControllers[0].text.isEmpty &&
                                          specControllers[0].text.isEmpty) {
                                        return "You must fill at least 1 specification";
                                      } else if (specControllers[index]
                                              .text
                                              .isNotEmpty !=
                                          titleControllers[index]
                                              .text
                                              .isNotEmpty) {
                                        return "You must enter a specification for this title";
                                      }
                                      return null;
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      titleControllers[index].text = value!;
                                      if (specifications == null ||
                                          specifications!.isEmpty) {
                                        final productSpec =
                                            ProductSpecification(title: value);
                                        specifications!.add(productSpec);
                                      } else {
                                        specifications![index].title = value;
                                      }
                                    });
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                TextInputWidgetWithoutLabel(
                                  initialValue:
                                      widget.specificationList == null ||
                                              widget.specificationList!.isEmpty
                                          ? ""
                                          : widget.specificationList![index]
                                              .specification,
                                  controller: specControllers[index],
                                  hintText: "Enter Product Specification",
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (widget.specificationList != null) {
                                      return null;
                                    } else {
                                      if (titleControllers[0].text == "" &&
                                          specControllers[0].text == "") {
                                        return "You must fill at least 1 specification";
                                      } else if (specControllers[index]
                                              .text
                                              .isNotEmpty !=
                                          titleControllers[index]
                                              .text
                                              .isNotEmpty) {
                                        return "You must enter a title for this specification";
                                      }
                                      return null;
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      specControllers[index].text = value!;
                                      if (specifications == null ||
                                          specifications!.isEmpty) {
                                        final productSpec =
                                            ProductSpecification(
                                                specification: value);
                                        specifications!.add(productSpec);
                                      } else {
                                        specifications![index].specification =
                                            value;
                                      }
                                    });
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  numberOfTextBox = numberOfTextBox! + 1;
                                  specifications!.add(ProductSpecification());
                                  titleControllers.add(TextEditingController());
                                  specControllers.add(TextEditingController());
                                  // print(titleControllers.length);
                                });
                              },
                              child: Container(
                                color: Colors.white,
                                width: double.infinity,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 4, 0, 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF673AB7)
                                              .withValues(alpha: 0.75),
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        "Add New Specification",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Raleway',
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black
                                              .withValues(alpha: 0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (numberOfTextBox! > 1) {
                                  setState(() {
                                    numberOfTextBox = numberOfTextBox! - 1;
                                    specifications!.removeLast();
                                    titleControllers.removeLast();
                                    specControllers.removeLast();
                                    // print(titleControllers.length);
                                  });
                                }
                              },
                              child: Container(
                                color: Colors.white,
                                width: double.infinity,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 4, 0, 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF673AB7)
                                              .withValues(alpha: 0.75),
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        "Remove Specification",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Raleway',
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black
                                              .withValues(alpha: 0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
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
                var validate = formKey.currentState!.validate();
                if (validate) {
                  for (var element in specifications!) {
                    debugPrint(element.title);
                    debugPrint(element.specification);
                  }
                  completed = true;
                  if (completed) {
                    Get.back(result: specifications);
                  }
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                backgroundColor: const Color(0xFF673AB7),
                // side:
                //     const BorderSide(color: Colors.white, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Continue",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
