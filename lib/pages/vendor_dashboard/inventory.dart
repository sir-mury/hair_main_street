import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/controllers/vendor_controller.dart';
import 'package:hair_main_street/extras/delegate.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/pages/vendor_dashboard/edit_product_preview.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/charm.dart';
import 'package:iconify_flutter_plus/icons/mdi.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  List<String> categories = ["All", "Available", "Unavailable"];
  VendorController vendorController = Get.find<VendorController>();
  ProductController productController = Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    vendorController.getVendorsProducts(vendorController.vendor.value!.userID!);
    tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SharePlus share = SharePlus.instance;
    String vendorID = vendorController.vendor.value!.userID!;
    // num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;

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

    String generateProductLink(String productID, String productName) {
      // Replace 'your_domain.com' with your actual domain
      final formattedName = productName.toLowerCase().replaceAll(' ', '_');
      return 'https://hairmainstreet.com/products/$productID/$formattedName';
    }

    showBottomSheetHere(
        String productName, bool isAvailable, String productID) {
      Get.bottomSheet(
        enableDrag: true,
        backgroundColor: Colors.white,
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      color: Colors.black.withValues(alpha: 0.75),
                    ),
                    width: 30,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    "assets/Icons/edit.svg",
                    height: 30,
                    width: 30,
                    colorFilter: ColorFilter.mode(
                      AppColors.main.withValues(alpha: 0.50),
                      BlendMode.srcIn,
                    ),
                  ),
                  title: const Text(
                    "Edit",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Get.to(
                      () => ProductEditPreview(
                        productName: productName,
                        productID: productID,
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 4,
                ),
                ListTile(
                  leading: Icon(
                    isAvailable
                        ? Icons.do_not_disturb_alt_outlined
                        : Icons.check,
                    size: 30,
                    color: const Color(0xFF673AB7).withValues(alpha: 0.50),
                  ),
                  title: Text(
                    isAvailable ? "Unavailable" : "Available",
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () async {
                    productController.isLoading.value = true;
                    if (productController.isLoading.value) {
                      Get.dialog(const LoadingWidget(),
                          barrierDismissible: false);
                    }
                    Product? product =
                        productController.getSingleProduct(productID);
                    product!.isAvailable = !isAvailable;
                    await productController.updateProduct(product);
                  },
                ),
                const SizedBox(
                  height: 4,
                ),
                ListTile(
                  leading: Icon(
                    Icons.share,
                    size: 30,
                    color: const Color(0xFF673AB7).withValues(alpha: 0.50),
                  ),
                  title: const Text(
                    "Share",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    var productLink =
                        generateProductLink(productID, productName);
                    String message =
                        "Hey, I am shopping on Hair Main Street\nCheck out this cool product with the link below\n$productLink";
                    share.share(
                      ShareParams(
                        text: message,
                        title: "Product Listing",
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 4,
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outlined,
                    size: 30,
                    color: Colors.red[300],
                  ),
                  title: Text(
                    "Delete",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.red[300],
                    ),
                  ),
                  onTap: () async {
                    productController.isLoading.value = true;
                    if (productController.isLoading.value) {
                      Get.dialog(const LoadingWidget(),
                          barrierDismissible: true);
                    }
                    Product? product =
                        productController.getSingleProduct(productID);
                    await productController.deleteProduct(product!);
                  },
                ),
                const SizedBox(
                  height: 4,
                ),
              ],
            ),
          ),
        ),
        elevation: 0,
      );
    }

    return Scaffold(
      appBar: AppBar(
        // flexibleSpace: Container(
        //   decoration: BoxDecoration(gradient: appBarGradient),
        // ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Symbols.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black),
        ),
        title: const Text(
          'Inventory',
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    backgroundColor: Colors.grey.shade50,
                    //elevation: 2,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.grey.shade500,
                        width: 0.5,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                  onPressed: () => showSearch(
                      context: context, delegate: MySearchDelegate()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        "assets/Icons/search-normal-1.svg",
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.50),
                          BlendMode.srcIn,
                        ),
                        height: 18,
                        width: 18,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Search",
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.45),
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 1,
                child: TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    controller: tabController,
                    indicatorWeight: 5,
                    indicatorColor: const Color(0xFF673AB7),
                    tabs: categories
                        .map((e) => Text(
                              e,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ))
                        .toList()),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder(
          stream: DataBaseService().getVendorProducts(vendorID),
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF673AB7),
                  strokeWidth: 2,
                ),
              );
            }
            if (vendorController.productList.isEmpty) {
              return const Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Iconify(
                      Mdi.package_variant_remove,
                      size: 86,
                      color: Color(0xFF673AB7),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "You have no products yet",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              );
            } else {
              vendorController
                  .filterByAvailability(vendorController.productList);
              return SafeArea(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                            vendorController
                                    .filteredMapByAvailability["All"]?.length ??
                                1, (index) {
                          return vendorController
                                          .filteredMapByAvailability["All"] ==
                                      null ||
                                  vendorController
                                      .filteredMapByAvailability["All"]!.isEmpty
                              ? const Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Iconify(
                                        Mdi.package_variant_remove,
                                        size: 86,
                                        color: Color(0xFF673AB7),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        "You have no products yet",
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 25,
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    Get.to(
                                      () => ProductEditPreview(
                                        productID: vendorController
                                            .filteredMapByAvailability["All"]![
                                                index]
                                            .productID,
                                        productName: vendorController
                                            .filteredMapByAvailability["All"]![
                                                index]
                                            .name,
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              height: 120,
                                              width: 113,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            fit: BoxFit.fill,
                                            imageUrl: vendorController
                                                        .filteredMapByAvailability[
                                                            "All"]![index]
                                                        .image!
                                                        .isNotEmpty ==
                                                    true
                                                ? vendorController
                                                    .filteredMapByAvailability[
                                                        "All"]![index]
                                                    .image!
                                                    .first
                                                : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                                            errorWidget: ((context, url,
                                                    error) =>
                                                const Text(
                                                    "Failed to Load Image")),
                                            placeholder: ((context, url) =>
                                                const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            height: 110,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '${vendorController.filteredMapByAvailability["All"]![index].name}',
                                                        maxLines: 2,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: 'Raleway',
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    vendorController
                                                                .filteredMapByAvailability[
                                                                    "All"]![
                                                                    index]
                                                                .quantity! >
                                                            0
                                                        ? Text(
                                                            "${vendorController.filteredMapByAvailability["All"]![index].quantity}pcs",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                      alpha:
                                                                          0.70),
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 13,
                                                            ),
                                                          )
                                                        : Text(
                                                            "Out of stock",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .red[200],
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "NGN${formatCurrency(vendorController.filteredMapByAvailability["All"]![index].price.toString())}",
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF673AB7),
                                                        fontFamily: 'Lato',
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    vendorController
                                                                .filteredMapByAvailability[
                                                                    "All"]![
                                                                    index]
                                                                .isAvailable ??
                                                            true
                                                        ? const SizedBox
                                                            .shrink()
                                                        : Text(
                                                            "Unavailable",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                alpha: 0.50,
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            showBottomSheetHere(
                                              vendorController
                                                  .filteredMapByAvailability[
                                                      "All"]![index]
                                                  .name!,
                                              vendorController
                                                      .filteredMapByAvailability[
                                                          "All"]![index]
                                                      .isAvailable ??
                                                  true,
                                              vendorController
                                                  .filteredMapByAvailability[
                                                      'All']![index]
                                                  .productID,
                                            );
                                          },
                                          child: Iconify(
                                            Charm.menu_kebab,
                                            size: 25,
                                            color: Colors.black
                                                .withValues(alpha: 0.65),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                        }),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                            vendorController
                                    .filteredMapByAvailability["Available"]
                                    ?.length ??
                                1, (index) {
                          return vendorController.filteredMapByAvailability[
                                          "Available"] ==
                                      null ||
                                  vendorController
                                      .filteredMapByAvailability["Available"]!
                                      .isEmpty
                              ? const Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Iconify(
                                        Mdi.package_variant_remove,
                                        size: 86,
                                        color: Color(0xFF673AB7),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        "You have no available products yet",
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 25,
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    Get.to(
                                      () => ProductEditPreview(
                                        productID: vendorController
                                            .filteredMapByAvailability[
                                                "Available"]![index]
                                            .productID,
                                        productName: vendorController
                                            .filteredMapByAvailability[
                                                "Available"]![index]
                                            .name,
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              height: 130,
                                              width: 113,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            fit: BoxFit.fill,
                                            imageUrl: vendorController
                                                        .filteredMapByAvailability[
                                                            "Available"]![index]
                                                        .image!
                                                        .isNotEmpty ==
                                                    true
                                                ? vendorController
                                                    .filteredMapByAvailability[
                                                        "Available"]![index]
                                                    .image!
                                                    .first
                                                : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                                            errorWidget: ((context, url,
                                                    error) =>
                                                const Text(
                                                    "Failed to Load Image")),
                                            placeholder: ((context, url) =>
                                                const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            height: 129,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '${vendorController.filteredMapByAvailability["Available"]![index].name}',
                                                        maxLines: 2,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: 'Raleway',
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    vendorController
                                                                .filteredMapByAvailability[
                                                                    "All"]![
                                                                    index]
                                                                .quantity! >
                                                            0
                                                        ? Text(
                                                            "${vendorController.filteredMapByAvailability["Available"]![index].quantity}pcs",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                      alpha:
                                                                          0.50),
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 13,
                                                            ),
                                                          )
                                                        : Text(
                                                            "Out of stock",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .red[200],
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "NGN${formatCurrency(vendorController.filteredMapByAvailability["Available"]![index].price.toString())}",
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF673AB7),
                                                        fontFamily: 'Lato',
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    vendorController
                                                            .filteredMapByAvailability[
                                                                "Available"]![
                                                                index]
                                                            .isAvailable!
                                                        ? const SizedBox
                                                            .shrink()
                                                        : Text(
                                                            "Unavailable",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                alpha: 0.50,
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            showBottomSheetHere(
                                              vendorController
                                                  .filteredMapByAvailability[
                                                      "Available"]![index]
                                                  .name!,
                                              vendorController
                                                  .filteredMapByAvailability[
                                                      "Available"]![index]
                                                  .isAvailable!,
                                              vendorController
                                                  .filteredMapByAvailability[
                                                      'Available']![index]
                                                  .productID,
                                            );
                                          },
                                          child: Iconify(
                                            Charm.menu_kebab,
                                            size: 25,
                                            color: Colors.black
                                                .withValues(alpha: 0.65),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                        }),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                            vendorController
                                    .filteredMapByAvailability["Unavailable"]
                                    ?.length ??
                                1, (index) {
                          return vendorController.filteredMapByAvailability[
                                          "Unavailable"] ==
                                      null ||
                                  vendorController
                                      .filteredMapByAvailability["Unavailable"]!
                                      .isEmpty
                              ? const Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Iconify(
                                        Mdi.package_variant_remove,
                                        size: 86,
                                        color: Color(0xFF673AB7),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        "You have no unavailable products yet",
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 25,
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    Get.to(
                                      () => ProductEditPreview(
                                        productID: vendorController
                                            .filteredMapByAvailability[
                                                "Unavailable"]![index]
                                            .productID,
                                        productName: vendorController
                                            .filteredMapByAvailability[
                                                "Unavailable"]![index]
                                            .name,
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              height: 130,
                                              width: 113,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            fit: BoxFit.fill,
                                            imageUrl: vendorController
                                                        .filteredMapByAvailability[
                                                            "Unavailable"]![
                                                            index]
                                                        .image!
                                                        .isNotEmpty ==
                                                    true
                                                ? vendorController
                                                    .filteredMapByAvailability[
                                                        "Unavailable"]![index]
                                                    .image!
                                                    .first
                                                : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                                            errorWidget: ((context, url,
                                                    error) =>
                                                const Text(
                                                    "Failed to Load Image")),
                                            placeholder: ((context, url) =>
                                                const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            height: 129,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '${vendorController.filteredMapByAvailability["Unavailable"]![index].name}',
                                                        maxLines: 2,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: 'Raleway',
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    vendorController
                                                                .filteredMapByAvailability[
                                                                    "Unavailable"]![
                                                                    index]
                                                                .quantity! >
                                                            0
                                                        ? Text(
                                                            "${vendorController.filteredMapByAvailability["Unavailable"]![index].quantity}pcs",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                      alpha:
                                                                          0.50),
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 13,
                                                            ),
                                                          )
                                                        : Text(
                                                            "Out of stock",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .red[200],
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "NGN${formatCurrency(vendorController.filteredMapByAvailability["Unavailable"]![index].price.toString())}",
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF673AB7),
                                                        fontFamily: 'Lato',
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    vendorController
                                                            .filteredMapByAvailability[
                                                                "Unavailable"]![
                                                                index]
                                                            .isAvailable!
                                                        ? const SizedBox
                                                            .shrink()
                                                        : Text(
                                                            "Unavailable",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                alpha: 0.50,
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            showBottomSheetHere(
                                              vendorController
                                                  .filteredMapByAvailability[
                                                      "Unavailable"]![index]
                                                  .name!,
                                              vendorController
                                                  .filteredMapByAvailability[
                                                      "Unavailable"]![index]
                                                  .isAvailable!,
                                              vendorController
                                                  .filteredMapByAvailability[
                                                      'Unavailable']![index]
                                                  .productID,
                                            );
                                          },
                                          child: Iconify(
                                            Charm.menu_kebab,
                                            size: 25,
                                            color: Colors.black
                                                .withValues(alpha: 0.65),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                        }),
                      ),
                    )
                  ],
                ),
              );
            }
          }),
    );
  }
}
