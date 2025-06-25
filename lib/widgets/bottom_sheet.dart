import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProductOptionBottomSheetWidget extends StatefulWidget {
  final Product? product;
  final Function(ProductOption)? onOptionSelected;
  const ProductOptionBottomSheetWidget(
      {this.onOptionSelected, this.product, super.key});

  @override
  State<ProductOptionBottomSheetWidget> createState() =>
      _ProductOptionBottomSheetWidgetState();
}

class _ProductOptionBottomSheetWidgetState
    extends State<ProductOptionBottomSheetWidget> {
  List<bool> toggleSelection = [false];
  ProductController productController = Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    toggleSelection =
        widget.product!.options == null || widget.product!.options!.isEmpty
            ? List.filled(2, false)
            : List.filled(widget.product!.options!.length, false);
  }

  ProductOption? selectedOption;

  void handleOptionSelection(int index) {
    setState(() {
      for (int i = 0; i < toggleSelection.length; i++) {
        toggleSelection[i] = i == index;
      }
      selectedOption = widget.product!.options![index];
      widget.onOptionSelected!(
          selectedOption!); // Call the callback with the selected option
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      //height: 300, // Adjust the height as needed
      child: Stack(
        children: [
          // Content of the bottom sheet
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Visibility(
                    visible: widget.product!.hasOptions! == true,
                    child: Column(
                      children: [
                        const Text(
                          "Options",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        widget.product!.hasOptions == false
                            ? const SizedBox.shrink()
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ToggleButtons(
                                      selectedBorderColor: Colors.black,
                                      borderWidth: 2.4,
                                      //selectedColor: Colors.red[50],
                                      fillColor: Colors.grey[200],
                                      isSelected: toggleSelection,
                                      onPressed: handleOptionSelection,
                                      children: List.generate(
                                        widget.product?.options?.length ?? 0,
                                        (index) => Toggles(
                                          name: widget.product?.options?[index]
                                                  .length ??
                                              '',
                                          price: widget.product?.options?[index]
                                                  .price ??
                                              0,
                                          stockAvailable: widget
                                                  .product
                                                  ?.options?[index]
                                                  .stockAvailable ??
                                              0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Quantity",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Divider(
                        thickness: 1.5,
                        color: Colors.transparent,
                        height: 4,
                      ),
                      GetX<ProductController>(
                        builder: (controller) {
                          num? quantity = productController.quantity.value;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () {
                                  controller.decreaseQuantity();
                                  debugPrint(quantity.toString());
                                },
                                icon: const Icon(
                                  Symbols.remove,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 1, horizontal: 2),
                                //width: 28,
                                //height: 28,
                                color: const Color.fromARGB(255, 200, 242, 237),
                                child: Center(
                                  child: Text(
                                    "$quantity",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      //backgroundColor: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  controller.increaseQuantity();
                                  debugPrint(quantity.toString());
                                },
                                icon: const Icon(
                                  Symbols.add,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Button to close the bottom sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  // padding: EdgeInsets.symmetric(
                  //   vertical: 8,
                  //   horizontal: screenWidth * 0.26,
                  // ),
                  //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(
                      width: 0.5,
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                ),
                onPressed: () => Get.back(), // Close the bottom sheet

                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Toggles extends StatelessWidget {
  final String? name;
  final num? price;
  final int? stockAvailable;
  const Toggles({
    this.name,
    this.price,
    this.stockAvailable,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$name",
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(
            thickness: 2,
            color: Colors.green,
            height: 4,
          ),
          Text(
            "$price",
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(
            thickness: 1.5,
            color: Colors.transparent,
            height: 4,
          ),
          Text(
            "$stockAvailable available",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.green[200],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
