import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/pages/vendor_dashboard/options_page.dart';
import 'package:hair_main_street/pages/vendor_dashboard/product_specification.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:hair_main_street/widgets/misc_widgets.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ic.dart';
import 'package:iconify_flutter_plus/icons/material_symbols.dart';
import 'package:string_validator/string_validator.dart' as validator;
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:material_symbols_icons/symbols.dart';

class AddproductPage extends StatefulWidget {
  const AddproductPage({super.key});

  @override
  State<AddproductPage> createState() => _AddproductPageState();
}

class _AddproductPageState extends State<AddproductPage> {
  GlobalKey<FormState> formKey = GlobalKey();
  ProductController productController = Get.find<ProductController>();
  var categoryValue = "natural hairs";
  final availableValue = "Yes";
  List<TextEditingController> lengthControllers = [];
  List<TextEditingController> colorControllers = [];
  List<TextEditingController> priceControllers = [];
  List<TextEditingController> stockControllers = [];

  bool checkbox1 = true;
  String? hello;
  bool checkbox2 = false;
  int listItems = 1;
  Product? product = Product(
    name: "",
    price: 0,
    quantity: 0,
    hasOptions: false,
    allowInstallment: true,
    isAvailable: true,
    isDeleted: false,
    category: "",
    image: [],
    description: "",
    options: null,
    specifications: null,
  );
  TextEditingController? productName,
      productPrice,
      productDescription,
      quantity = TextEditingController();

  @override
  void initState() {
    super.initState();
    productController.getCategories();
  }

  void addOption() {
    setState(() {
      product!.options!.add(
          ProductOption(length: '', color: "", price: 0.0, stockAvailable: 0));
      lengthControllers.add(TextEditingController());
      colorControllers.add(TextEditingController());
      priceControllers.add(TextEditingController());
      stockControllers.add(TextEditingController());
    });
  }

  void removeOption(int index) {
    setState(() {
      debugPrint("removed");
      lengthControllers.removeAt(index);
      colorControllers.removeAt(index);
      priceControllers.removeAt(index);
      stockControllers.removeAt(index);
      product!.options!.removeAt(index);
    });
  }

  String? validateFields(int index) {
    if (lengthControllers[index].text.isEmpty &&
        colorControllers[index].text.isEmpty) {
      return 'Either length or color must be filled.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;

    // void applySelectedValue(String value) {
    //   // Implement your logic to apply the selected value
    //   debugPrint('Selected value: $value');
    // }

    // showCancelDialog() {
    //   return Get.dialog(
    //     AlertDialog(
    //       elevation: 0,
    //       backgroundColor: Colors.white,
    //       titlePadding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
    //       contentPadding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
    //       title: const Text(
    //         "Cancel Adding Product?",
    //         style: TextStyle(
    //           fontSize: 19,
    //           fontFamily: 'Lato',
    //           fontWeight: FontWeight.w600,
    //           color: Colors.black,
    //         ),
    //       ),
    //       content: Text(
    //         "Are you sure you want to cancel adding this product?",
    //         style: TextStyle(
    //           fontSize: 14,
    //           fontFamily: 'Lato',
    //           fontWeight: FontWeight.w400,
    //           color: Colors.black.withValues(alpha: 0.65),
    //         ),
    //       ),
    //       actionsAlignment: MainAxisAlignment.spaceEvenly,
    //       actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
    //       actions: [
    //         ElevatedButton(
    //           style: ElevatedButton.styleFrom(
    //             backgroundColor: const Color(0xFF673AB7),
    //             padding:
    //                 const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
    //             //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
    //             shape: RoundedRectangleBorder(
    //               side: const BorderSide(
    //                 width: 1,
    //                 color: Color(0xFF673AB7),
    //               ),
    //               borderRadius: BorderRadius.circular(10),
    //             ),
    //           ),
    //           onPressed: () {
    //             Get.back();
    //           },
    //           child: const Text(
    //             "No",
    //             style: TextStyle(
    //               fontSize: 15,
    //               color: Colors.black,
    //               fontFamily: 'Lato',
    //               fontWeight: FontWeight.w500,
    //             ),
    //           ),
    //         ),
    //         ElevatedButton(
    //           style: ElevatedButton.styleFrom(
    //             backgroundColor: Colors.white,
    //             padding:
    //                 const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
    //             //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
    //             shape: RoundedRectangleBorder(
    //               side: BorderSide(
    //                 width: 1,
    //                 color: Colors.red.shade400,
    //               ),
    //               borderRadius: BorderRadius.circular(10),
    //             ),
    //           ),
    //           onPressed: () {
    //             Get.close(2);
    //           },
    //           child: Text(
    //             "Yes",
    //             style: TextStyle(
    //               fontSize: 15,
    //               color: Colors.red.shade400,
    //               fontFamily: 'Lato',
    //               fontWeight: FontWeight.w500,
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //     barrierDismissible: true,
    //   );
    // }

    return StreamBuilder(
        stream: DataBaseService().getCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingWidget();
          }
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, result) async {
              if (didPop) {
                return;
              } else {
                await Get.dialog(
                  DeleteDialog(
                    title: "Cancel Adding Product?",
                    confirmAction: () {
                      Get.close(2);
                    },
                    cancelAction: () {
                      Get.back();
                    },
                    subtitle:
                        "Are you sure you want to cancel adding this product?",
                  ),
                  barrierDismissible: true,
                );
              }
            },
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                scrolledUnderElevation: 0,
                leadingWidth: 40,
                backgroundColor: Colors.white,
                leading: InkWell(
                  onTap: () async {
                    await Get.dialog(
                      DeleteDialog(
                        title: "Cancel Adding Product?",
                        confirmAction: () {
                          Get.close(2);
                        },
                        cancelAction: () {
                          Get.back();
                        },
                        subtitle:
                            "Are you sure you want to cancel adding this product?",
                      ),
                      barrierDismissible: true,
                    );
                  },
                  radius: 12,
                  child: const Icon(
                    Symbols.arrow_back_ios_new_rounded,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
                title: const Text(
                  'Add Product',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    fontFamily: 'Lato',
                  ),
                ),
                centerTitle: false,
              ),
              body: Container(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                //decoration: BoxDecoration(gradient: myGradient),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add Product Images",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Row(
                          children: [
                            InkWell(
                              //highlightColor: Colors.,
                              splashColor: Colors.black,
                              onTap: () {
                                productController.selectImage();
                              },
                              child: Container(
                                width: 120,
                                height: 120,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12),
                                //margin: EdgeInsets.fromLTRB(2, 2, 2, 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: const Color(0xFF673AB7)
                                      .withValues(alpha: 0.10),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xFF673AB7),
                                  ),
                                  //shape: BoxShape.circle,
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Iconify(
                                      MaterialSymbols.upload,
                                      size: 34,
                                      color: Color(0xFF673AB7),
                                    ),
                                    Text(
                                      "Add Image(s)",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "Raleway",
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF673AB7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: GetX<ProductController>(
                                  builder: (controller) {
                                return controller.imageList.isNotEmpty
                                    ? SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: List.generate(
                                              controller.imageList.length,
                                              (index) => Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: const Color(
                                                            0xFF673AB7),
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    margin: const EdgeInsets
                                                        .fromLTRB(0, 0, 8, 0),
                                                    height: 120,
                                                    width: 120,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.file(
                                                        controller
                                                            .imageList[index]
                                                            .absolute,
                                                        fit: BoxFit.cover,

                                                        // loadingBuilder:
                                                        //     (context, child, loadingProgress) =>
                                                        //         const Text(
                                                        //   "Loading...",
                                                        //   style: TextStyle(
                                                        //     color: Colors.white,
                                                        //   ),
                                                        // ),
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return const Text(
                                                            "Error \nLoading \nImage...",
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  )),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextInputWidgetWithoutLabel(
                          controller: productName,
                          hintText: "Enter Product Name",
                          maxLines: 3,
                          textInputType: TextInputType.text,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Please enter the product name";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(() {
                              product!.name = val;
                              debugPrint(product!.name);
                            });
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextInputWidgetWithoutLabel(
                          controller: productPrice,
                          hintText: "Enter Price",
                          textInputType: TextInputType.number,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Cannot be empty, set a price";
                            } else if (validator.isNumeric(val) == false) {
                              return "Must be a Number";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(() {
                              product!.price = int.parse(val!);
                            });
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        // Row(
                        //   //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     const Expanded(
                        //       child: Text(
                        //         "Category:",
                        //         style: TextStyle(
                        //           fontSize: 15,
                        //           fontWeight: FontWeight.bold,
                        //           fontFamily: "Raleway",
                        //         ),
                        //       ),
                        //     ),
                        //     Expanded(
                        //       flex: 2,
                        //       child: PopupMenuButton<String>(
                        //         //shadowColor: Colors.red,
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(10),
                        //           side: const BorderSide(
                        //             color: Colors.black,
                        //             width: 1,
                        //           ),
                        //         ),
                        //         elevation: 10,
                        //         itemBuilder: (BuildContext context) {
                        //           return <PopupMenuEntry<String>>[
                        //             const PopupMenuItem<String>(
                        //               value: 'natural hairs',
                        //               child: Text('Natural Hairs'),
                        //             ),
                        //             const PopupMenuItem<String>(
                        //               value: 'accessories',
                        //               child: Text('Accessories'),
                        //             ),
                        //             const PopupMenuItem<String>(
                        //               value: 'wigs',
                        //               child: Text('Wigs'),
                        //             ),
                        //             const PopupMenuItem<String>(
                        //               value: 'lashes',
                        //               child: Text('Lashes'),
                        //             ),
                        //           ];
                        //         },
                        //         onSelected: (String value) {
                        //           setState(() {
                        //             _categoryValue = value;
                        //             product!.category = _categoryValue;
                        //             // _updateSelectedValue(
                        //             //     value); // Update Firestore with the new value
                        //           });
                        //         },
                        //         child: ListTile(
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(10),
                        //             side: const BorderSide(
                        //               color: Colors.black,
                        //               width: 1,
                        //             ),
                        //           ),
                        //           title: Text(
                        //             _categoryValue.titleCase,
                        //             style: const TextStyle(
                        //               fontSize: 16,
                        //             ),
                        //           ),
                        //           trailing: const Icon(Icons.arrow_drop_down),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(
                        //   height: 16,
                        // ),
                        // Row(
                        //   //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     const Expanded(
                        //       child: Text(
                        //         "Available:",
                        //         style: TextStyle(
                        //           fontSize: 20,
                        //           fontWeight: FontWeight.w700,
                        //         ),
                        //       ),
                        //     ),
                        //     Expanded(
                        //       flex: 2,
                        //       child: PopupMenuButton<String>(
                        //         //shadowColor: Colors.red,
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(10),
                        //           side: const BorderSide(
                        //             color: Colors.black,
                        //             width: 1,
                        //           ),
                        //         ),
                        //         elevation: 10,
                        //         itemBuilder: (BuildContext context) {
                        //           return <PopupMenuEntry<String>>[
                        //             const PopupMenuItem<String>(
                        //               value: 'Yes',
                        //               child: Text('Yes'),
                        //             ),
                        //             const PopupMenuItem<String>(
                        //               value: 'No',
                        //               child: Text('No'),
                        //             ),
                        //           ];
                        //         },
                        //         onSelected: (String value) {
                        //           setState(() {
                        //             if (value == "Yes") {
                        //               _availableValue = value;
                        //               product!.isAvailable = true;
                        //             } else if (value == "No") {
                        //               _availableValue = value;
                        //               product!.isAvailable = false;
                        //             }
                        //             debugPrint(product!.isAvailable);
                        //             // _updateSelectedValue(
                        //             //     value); // Update Firestore with the new value
                        //           });
                        //         },
                        //         child: ListTile(
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(10),
                        //             side: const BorderSide(
                        //               color: Colors.black,
                        //               width: 1,
                        //             ),
                        //           ),
                        //           title: Text(
                        //             _availableValue.toString(),
                        //             style: const TextStyle(
                        //               fontSize: 16,
                        //             ),
                        //           ),
                        //           trailing: const Icon(Icons.arrow_drop_down),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        TextInputWidgetWithoutLabel(
                          controller: productDescription,
                          maxLines: 7,
                          minLines: 5,
                          hintText: "Enter Product Description",
                          onChanged: (val) {
                            setState(() {
                              val!.isEmpty
                                  ? product!.description = ""
                                  : product!.description = val;
                            });
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextInputWidgetWithoutLabel(
                          controller: quantity,
                          textInputType: TextInputType.number,
                          //maxLines: 5,
                          hintText: "Stock Quantity",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Cannot be empty, enter a quantity";
                            } else if (validator.isNumeric(val) == false) {
                              return "Must be a number";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(() {
                              product!.quantity = int.parse(val!);
                            });
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        DropdownSearch(
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
                                      "Add Product Category",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Raleway',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black
                                            .withValues(alpha: 0.45),
                                      ),
                                    )
                                  : Text(
                                      selectedItem.toString().capitalizeFirst!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Raleway',
                                        fontWeight: FontWeight.w600,
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
                            containerBuilder: (context, popupWidget) =>
                                Container(
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
                              "Choose Category",
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
                          items: (f, cs) => productController.categories,
                          onChanged: (value) {
                            debugPrint(value.toString());
                            setState(() {
                              product!.category = value.toString();
                            });
                          },
                          compareFn: (item1, item2) => item1 == item2,
                          decoratorProps: DropDownDecoratorProps(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 10),
                              // hintText: "Add Product Category",
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
                                fontFamily: 'Raleway',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withValues(alpha: 0.45),
                              ),
                            ),
                            baseStyle: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        InkWell(
                          onTap: () async {
                            final result =
                                await Get.to(() => const SpecificationsPage());
                            if (result != null) {
                              setState(() {
                                product!.specifications = result;
                                debugPrint(product!.specifications.toString());
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 1,
                                color: Colors.black.withValues(alpha: 0.45),
                              ),
                              color: Colors.white,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Product Specifications",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withValues(alpha: 0.45),
                                  ),
                                ),
                                const Iconify(
                                  Ic.baseline_keyboard_arrow_right,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        product!.specifications == null
                            ? const Text(
                                "You must add specifications",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(
                          height: 24,
                        ),
                        GestureDetector(
                          child: Container(
                            color:
                                const Color(0xFF673AB7).withValues(alpha: 0.10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Product Options",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontFamily: 'Raleway',
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "Add product colours, length, variants and more",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Raleway',
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black
                                                .withValues(alpha: 0.45),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const Iconify(
                                    Ic.baseline_keyboard_arrow_right,
                                    size: 24,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () async {
                            var result =
                                await Get.to(() => const ProductOptionsPage());
                            if (result != null) {
                              debugPrint(result);
                              product!.hasOptions = result["hasOption"];
                              product!.options = result["options"];
                            }
                          },
                        ),
                        const SizedBox(
                          height: 8,
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
                      bool? validate = formKey.currentState!.validate();
                      if (validate) {
                        productController.isLoading.value == true;
                        if (product!.specifications == null) {
                          productController
                              .showMyToast("You must add specification");
                        }
                        if (productController.isLoading.value == true &&
                            product!.specifications != null) {
                          Get.dialog(
                            const LoadingWidget(),
                          );
                        }
                        if (productController.imageList.isNotEmpty) {
                          await productController.uploadImage();
                        }
                        if (productController.downloadUrls.isNotEmpty) {
                          for (String? url in productController.downloadUrls) {
                            product!.image!.add(url!);
                          }
                        }
                        if (product!.category == "") {
                          product!.category = categoryValue;
                        }
                        formKey.currentState!.save();
                        //debugPrint(product!.options);
                        await productController.addAProduct(product!);
                        //debugdebugPrint(hello);
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
                      "Add Product",
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
        });
  }
}
