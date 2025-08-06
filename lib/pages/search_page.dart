import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/mdi.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:recase/recase.dart';

class SearchPage extends StatefulWidget {
  final String? query;
  const SearchPage({@required this.query, super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  GlobalKey<FormState> formKey = GlobalKey();
  ProductController productController = Get.find<ProductController>();
  TextEditingController price1 = TextEditingController();
  TextEditingController price2 = TextEditingController();
  String? selectedCategory = "";
  List<double>? priceRange = [];
  @override
  Widget build(BuildContext context) {
    bool isValidated = true;
// show bottom sheet to specify filter
    showFilterBottomSheet() {
      Get.bottomSheet(
        elevation: 2,
        StatefulBuilder(
          builder: (context, StateSetter setState) => Container(
            //height: 350,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SelectableText(
                          "Filter Search",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(
                            Icons.cancel,
                            size: 24,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const SelectableText(
                    "Category",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Wrap(
                    spacing: 8.0, // Space between buttons horizontally
                    runSpacing: 8.0, // Space between rows vertically
                    children: List.generate(
                      productController.categories.length,
                      (index) {
                        return ToggleButtons(
                          isSelected: [
                            selectedCategory ==
                                productController.categories[index]
                          ],
                          selectedBorderColor: Colors.black,
                          borderWidth: 0.8,
                          borderRadius: BorderRadius.circular(12),
                          borderColor: Colors.black.withValues(alpha: 0.25),
                          fillColor: Colors.black.withValues(alpha: 0.25),
                          onPressed: (buttonIndex) {
                            setState(() {
                              selectedCategory =
                                  productController.categories[index];
                              debugPrint(selectedCategory);
                            });
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                productController.categories[index].titleCase,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Raleway",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const SelectableText(
                    "Price",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Form(
                    key: formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextInputWidgetWithoutLabelForDialog(
                            controller: price1,
                            hintText: "Lower Price Range",
                            textInputType: Platform.isIOS
                                ? TextInputType.phone
                                : TextInputType.number,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value!.isNotEmpty &&
                                  price2.text.isNotEmpty &&
                                  double.tryParse(value)! >
                                      double.tryParse(price2.text)!) {
                                return "cannot be more than the lower price";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value!.isNotEmpty) {
                                price1.text = value;
                                // priceRange[0] = double.tryParse(price1.text)!;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Expanded(
                          child: TextInputWidgetWithoutLabelForDialog(
                            controller: price2,
                            hintText: "Upper Price Range",
                            textInputType: Platform.isIOS
                                ? TextInputType.phone
                                : TextInputType.number,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value!.isNotEmpty &&
                                  price1.text.isNotEmpty &&
                                  double.tryParse(value)! <
                                      double.tryParse(price1.text)!) {
                                return "cannot be less than the lower price";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value!.isNotEmpty) {
                                price2.text = value;
                                // priceRange[1] = double.tryParse(price2.text)!;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Visibility(
                    visible: !isValidated,
                    child: const Text(
                        "You have to fill both lower and upper price ranges"),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 32),
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
                              productController
                                  .handleSearchProducts(widget.query);
                              selectedCategory = "";
                              setState(
                                () {},
                              );
                              //productController.filterProductSearchResults();
                            },
                            child: const Text(
                              "Reset",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 32),
                              //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFF673AB7),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              if (price1.text.isNotEmpty &&
                                      price2.text.isEmpty ||
                                  price1.text.isEmpty &&
                                      price2.text.isNotEmpty) {
                                isValidated = false;
                                setState(() {});
                              } else {
                                if (price1.text.isNotEmpty &&
                                    price2.text.isNotEmpty) {
                                  priceRange?.insert(
                                      0, double.tryParse(price1.text)!);
                                  priceRange?.insert(
                                      1, double.tryParse(price2.text)!);
                                }
                                productController.filterProductSearchResults(
                                  priceRange: priceRange,
                                  category: selectedCategory,
                                );
                                priceRange!.clear();
                                Get.back();
                              }
                            },
                            child: const Text(
                              "Show Results",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                              ),
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
        ),
      );
    }

    // var screenHeight = Get.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Symbols.arrow_back_ios_new_rounded,
              size: 24, color: Colors.white),
        ),
        title: Text(
          '${widget.query}',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            fontFamily: "Lato",
            color: Colors.black,
            // color: Color(
            //   0xFFFF8811,
            // ),
          ),
        ),
        centerTitle: true,
      ),
      body: GetX<ProductController>(
        builder: (controller) {
          controller.handleSearchProducts(widget.query);
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //TO DO: you may need to show vendors in the future
                  // Visibility(
                  //   visible: controller.filteredSearchVendorsList.isNotEmpty,
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: 12),
                  //         child: Text(
                  //           "Vendors",
                  //           style: TextStyle(
                  //             fontSize: 20,
                  //             fontWeight: FontWeight.w700,
                  //             fontFamily: "Lato",
                  //             color: Colors.black,
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(
                  //         height: 4,
                  //       ),
                  //       MasonryGridView.count(
                  //         crossAxisCount: 2,
                  //         padding: const EdgeInsets.symmetric(
                  //             horizontal: 8, vertical: 12),
                  //         shrinkWrap: true,
                  //         crossAxisSpacing: 4,
                  //         mainAxisSpacing: 8,
                  //         physics: const NeverScrollableScrollPhysics(),
                  //         itemBuilder: (_, index) => ShopSearchCard(
                  //           index: index,
                  //         ),
                  //         itemCount:
                  //             controller.filteredSearchVendorsList.length,
                  //       ),
                  //       const SizedBox(
                  //         height: 4,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Products",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  controller.filteredSearchProducts.isEmpty
                      ? Text(
                          "No products available",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: "Lato",
                            color: AppColors.shade9,
                          ),
                        )
                      : MasonryGridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 8,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (_, index) => SearchCard(
                            index: index,
                          ),
                          itemCount: controller.filteredSearchProducts.length,
                        ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: IconButton(
        style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7),
            shape: const CircleBorder(
              side: BorderSide(
                width: 1.4,
                color: Colors.white,
              ),
            )),
        onPressed: () {
          showFilterBottomSheet();
        },
        padding: const EdgeInsets.all(8),
        icon: const Iconify(
          Mdi.filter,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
