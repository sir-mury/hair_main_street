import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/pages/vendor_dashboard/edit_product.dart';
import 'package:hair_main_street/widgets/loading.dart';

class ProductEditPreview extends StatefulWidget {
  final String? productName;
  final String? productID;
  const ProductEditPreview({
    this.productID,
    this.productName,
    super.key,
  });

  @override
  State<ProductEditPreview> createState() => _ProductEditPreviewState();
}

class _ProductEditPreviewState extends State<ProductEditPreview> {
  ProductController productController = Get.find<ProductController>();
  Product? product;

  @override
  void initState() {
    product = productController.getSingleProduct(widget.productID!);
    super.initState();
  }

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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 40,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () => Get.back(),
          radius: 12,
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black,
          ),
        ),
        title: Text(
          widget.productName ?? "",
          maxLines: 1,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontFamily: 'Lato',
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              radius: 100,
              onTap: () {
                Get.to(
                  () => EditProductPage(
                    productID: widget.productID,
                  ),
                );
              },
              child: SvgPicture.asset(
                'assets/Icons/edit.svg',
                height: 25,
                width: 25,
                // ignore: deprecated_member_use
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageBuilder: (context, imageProvider) => Container(
                          height: 104,
                          width: 97,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        fit: BoxFit.fill,
                        imageUrl: product!.image!.isNotEmpty == true
                            ? product!.image!.first
                            : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                        errorWidget: ((context, url, error) =>
                            const Text("Failed to Load Image")),
                        placeholder: ((context, url) => const Center(
                              child: CircularProgressIndicator(),
                            )),
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "${product!.name}",
                            maxLines: 1,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            "NGN${formatCurrency(product!.price.toString())}",
                            //maxLines: 1,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 16,
                              color: Color(0xFF673AB7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Switch(
                            value: product!.isAvailable ?? true,
                            onChanged: (value) {
                              setState(() {
                                product!.isAvailable = value;
                              });
                            },
                            thumbColor:
                                const WidgetStatePropertyAll(Colors.white),
                            //activeColor: const Color(0xFF673AB7).withOpacity(0.25),
                            activeTrackColor:
                                const Color(0xFF673AB7).withValues(alpha: 0.73),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey[300],
                            //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            trackOutlineColor:
                                const WidgetStatePropertyAll(Colors.white),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          const Text(
                            "Available",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Stock Quantity",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "${product!.quantity}",
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.black.withValues(alpha: 0.10),
                height: 2,
                thickness: 1,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Available Stock Quantity",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          radius: 17,
                          onTap: () async {
                            if (product!.quantity! > 1) {
                              setState(() {
                                product!.quantity = product!.quantity! - 1;
                              });
                            } else {
                              productController
                                  .showMyToast("Cannot be less than 1");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 0.8,
                                color: Colors.black.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.remove,
                              size: 24,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Text(
                          "${product!.quantity}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            //backgroundColor: Colors.blue,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        InkWell(
                          radius: 17,
                          onTap: () async {
                            setState(() {
                              product!.quantity = product!.quantity! + 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 0.8,
                                color: Colors.black.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 24,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              // const Padding(
              //   padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
              //   child: Text(
              //     "Product History",
              //     style: TextStyle(
              //       fontFamily: 'Lato',
              //       fontSize: 15,
              //       fontWeight: FontWeight.w500,
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
              // Row(),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 0),
                backgroundColor: Colors.white,
                iconColor: Colors.black,
                collapsedIconColor: Colors.black,
                childrenPadding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                title: const Text(
                  "Product Options",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  "${product?.options?.length ?? 0} product options",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withValues(alpha: 0.50),
                  ),
                ),
                children:
                    product!.hasOptions == true && product!.options != null
                        ? List.generate(
                            product!.options!.length,
                            (index) => Container(
                              width: double.infinity,
                              color: const Color(0xFFf5f5f5),
                              margin: const EdgeInsets.only(bottom: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Length: ${product!.options![index].length ?? "Unspecified"}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontFamily: 'Raleway',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    "Colour: ${product!.options?[index].color ?? "Unspecified"}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontFamily: 'Raleway',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "NGN${formatCurrency(product!.options?[index].price.toString() ?? "0")}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF673AB7),
                                      fontFamily: 'Raleway',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "${product!.options?[index].stockAvailable} available",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontFamily: 'Raleway',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : [const SizedBox.shrink()],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          elevation: 0,
          color: Colors.white,
          height: kToolbarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(6),
                    //alignment: Alignment.centerLeft,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.red.shade400, width: 1),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    productController.isLoading.value = true;
                    if (productController.isLoading.value) {
                      Get.dialog(const LoadingWidget(),
                          barrierDismissible: true);
                    }
                    await productController.deleteProduct(product!);
                  },
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.red[400],
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Lato',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(6),
                    //alignment: Alignment.centerLeft,
                    backgroundColor: const Color(0xFF673AB7),
                    shape: const RoundedRectangleBorder(
                      //side: BorderSide(color: Color(0xFF673AB7), width: 2),
                      borderRadius: BorderRadius.all(
                        Radius.circular(9),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    productController.isLoading.value = true;
                    if (productController.isLoading.value) {
                      Get.dialog(const LoadingWidget(),
                          barrierDismissible: false);
                    }
                    await productController.updateProduct(product!);
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Lato',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
