import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/cart_controller.dart';
import 'package:hair_main_street/controllers/chat_controller.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/controllers/review_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/controllers/vendor_controller.dart';
import 'package:hair_main_street/extras/country_state.dart';
import 'package:hair_main_street/extras/paystack_bank_code.dart';
import 'package:hair_main_street/models/aux_models.dart';
import 'package:hair_main_street/models/cart_item_model.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/models/review.dart';
import 'package:hair_main_street/models/vendors_model.dart';
import 'package:hair_main_street/pages/client_shop_page.dart';
import 'package:hair_main_street/pages/messages.dart';
import 'package:hair_main_street/pages/product_page.dart';
import 'package:hair_main_street/pages/refund.dart';
import 'package:hair_main_street/pages/review_page.dart';
import 'package:hair_main_street/pages/vendor_dashboard/order_details.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/utils/screen_sizes.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ic.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_service/keyboard_service.dart';
import 'package:like_button/like_button.dart';
import 'package:share_plus/share_plus.dart';
import '../pages/menu/order_detail.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:recase/recase.dart';
import 'package:string_validator/string_validator.dart' as validator;

class WhatsAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  const WhatsAppButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/Icons/whatsapp_icon.svg', // Replace with the path to your WhatsApp icon SVG file
            width: 24, // Set the icon width
            height: 24, // Set the icon height
            colorFilter: ColorFilter.mode(
              Colors.green,
              BlendMode.srcIn,
            ),
          ),
          onPressed: onPressed,
        ),
        const Text("Whatsapp"),
      ],
    );
  }
}

class ShareCard extends StatelessWidget {
  const ShareCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: PopupMenuButton<String>(
      icon: const Icon(Icons.share),
      onSelected: (String choice) {
        // Implement sharing logic for the selected option.
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<String>>[
          const PopupMenuItem<String>(
            value: 'Facebook',
            child: ListTile(
              leading: Icon(Icons.facebook, color: Colors.blue),
              title: Text('Facebook'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'Twitter',
            child: ListTile(
              leading: Icon(Icons.one_x_mobiledata, color: Colors.blue),
              title: Text('Twitter'),
            ),
          ),
          PopupMenuItem<String>(
              value: 'Whatsapp',
              child: WhatsAppButton(
                onPressed: () {
                  // Handle WhatsApp button press, e.g., open a WhatsApp chat or perform an action
                },
              )),
          // Add more social media options as needed
        ];
      },
    ));
  }
}

class ProductCard extends StatelessWidget {
  final String? id;
  final int index;
  final String? mapKey;
  const ProductCard({required this.index, this.id, this.mapKey, super.key});
  @override
  Widget build(BuildContext context) {
    ProductController productController = Get.find<ProductController>();
    UserController userController = Get.find<UserController>();
    WishListController wishListController = Get.find<WishListController>();
    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    //debugPrint(id);

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

    return GetX<WishListController>(
      builder: (controller) {
        bool isUserLoggedIn = userController.userState.value != null;

        RxBool isLiked = false.obs;

        isLiked.value = controller.isProductInWishlist(id!, isUserLoggedIn);

        return InkWell(
          onTap: () {
            Get.to(
              () => ProductPage(
                id: id,
                //index: index,
              ),
              transition: Transition.fadeIn,
            );
          },
          splashColor: Colors.black,
          child: Card(
            elevation: 1,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              // side: BorderSide(
              //   color: Colors.white,
              //   width: 0.5,
              // ),
            ),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: productController.productMap[mapKey]![index]
                                ?.image?.isNotEmpty ==
                            true
                        ? productController
                            .productMap[mapKey]![index]!.image!.first
                        : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                    errorWidget: ((context, url, error) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Failed to Load Image"),
                        )),
                    imageBuilder: (context, imageProvider) => Container(
                      //width: double.infinity,
                      height: !Responsive.isMobile(context) ? 250 : 154,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: ((context, url) => const SizedBox(
                          width: double.infinity,
                          height: 154,
                          child: Center(child: CircularProgressIndicator()),
                        )),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                SizedBox(
                  height: 45,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    child: Text(
                      ReCase("${productController.productMap[mapKey]![index]!.name}")
                          .titleCase,
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    "NGN ${formatCurrency(productController.productMap[mapKey]![index]!.price.toString())}",
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.main,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                    child: GestureDetector(
                      onDoubleTap: () async {
                        //to add a product to wishlist
                        //cannot work if user is not logged in
                        if (!isUserLoggedIn) {
                          userController
                              .showMyToast("Log in to add to wishlist");
                        } else {
                          if (userController.userState.value!.uid ==
                              productController
                                  .productMap[mapKey]![index]!.vendorId) {
                            wishListController.showMyToast(
                                "Cannot add your own product to wishlist");
                          } else {
                            if (isLiked.value) {
                              userController
                                  .showMyToast("Already in your wishlists");
                            } else {
                              WishlistItem wishlistItem =
                                  WishlistItem(wishListItemID: id!);
                              await controller.addToWishlist(wishlistItem);
                              controller.isProductInWishlist(
                                id!,
                                isUserLoggedIn,
                              );
                            }
                          }
                        }
                      },
                      onTap: () async {
                        //if product is added, remove from wishlist, if not instruct to double tap
                        //cannot work if user is not logged in
                        if (!isUserLoggedIn) {
                          userController
                              .showMyToast("Log in to remove from wishlist");
                        } else {
                          if (isLiked.value) {
                            await wishListController
                                .removeFromWishlistWithProductID(id!);
                            wishListController.isProductInWishlist(
                                id!, isUserLoggedIn);
                          } else {
                            userController
                                .showMyToast("Double tap to add to wishlist");
                          }
                        }
                      },
                      child: isUserLoggedIn && isLiked.value
                          ? Icon(
                              Icons.favorite,
                              color: AppColors.main,
                            )
                          : Icon(
                              Icons.favorite_border_rounded,
                              color: AppColors.main,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SeeAlsoCard extends StatelessWidget {
  // final String? id;
  final int index;
  // final String? mapKey;
  const SeeAlsoCard({
    required this.index,
    // this.id,
    // this.mapKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    ProductController productController = Get.find<ProductController>();
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

    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 154,
      // height: 242,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            spreadRadius: 0,
            color: const Color(0xFF673AB7).withValues(alpha: 0.10),
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                id: productController.seeAlsoProducts[index]!.productID,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: CachedNetworkImage(
                height: 154,
                width: 154,
                fit: BoxFit.cover,
                imageUrl: productController
                            .seeAlsoProducts[index]?.image?.isNotEmpty ==
                        true
                    ? productController.seeAlsoProducts[index]!.image!.first
                    : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                errorWidget: ((context, url, error) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Failed to Load Image"),
                    )),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: ((context, url) => const SizedBox(
                      width: double.infinity,
                      height: 154,
                      child: Center(child: CircularProgressIndicator()),
                    )),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            SizedBox(
              height: screenHeight * 0.055,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                child: Text(
                  ReCase("${productController.seeAlsoProducts[index]!.name}")
                      .titleCase,
                  style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                "NGN ${formatCurrency(productController.seeAlsoProducts[index]!.price.toString())}",
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShopSearchCard extends StatelessWidget {
  final int index;
  const ShopSearchCard({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    // var screenHeight = Get.height;
    // var screenWidth = Get.width;
    ProductController productController = Get.find<ProductController>();
    var imageUrl = productController
            .clientGetVendorName(
                productController.filteredSearchVendorsList[index]!.userID!)
            .shopPicture ??
        "https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f";
    return InkWell(
      onTap: () {
        Get.to(
            () => ClientShopPage(
                  vendorID: productController
                      .filteredSearchVendorsList[index]!.userID,
                ),
            transition: Transition.fadeIn);
      },
      splashColor: Theme.of(context).primaryColorDark,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: CachedNetworkImage(
                //color: Colors.white,
                //repeat: ImageRepeat.repeat,
                imageBuilder: (context, imageProvider) => Container(
                  width: double.infinity,
                  height: 154,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                fit: BoxFit.contain,
                imageUrl: imageUrl,
                errorWidget: ((context, url, error) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Failed to Load Image"),
                    )),
                placeholder: ((context, url) => const Center(
                      child: CircularProgressIndicator(),
                    )),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Container(
              width: double.infinity,
              //height: 50,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF673AB7).withValues(alpha: 0.20),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                ReCase("${productController.filteredSearchVendorsList[index]!.shopName}")
                    .titleCase,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// for vendor highlights
class VendorHighlightsCard extends StatelessWidget {
  final int index;
  const VendorHighlightsCard({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    // var screenHeight = Get.height;
    // var screenWidth = Get.width;
    ProductController productController = Get.find<ProductController>();
    var imageUrl = productController
            .clientGetVendorName(productController.vendorsList[index]!.userID!)
            .shopPicture ??
        "https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f";
    return InkWell(
      onTap: () {
        Get.to(
            () => ClientShopPage(
                  vendorID: productController.vendorsList[index]!.userID,
                ),
            transition: Transition.fadeIn);
      },
      splashColor: Theme.of(context).primaryColorDark,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: CachedNetworkImage(
                //color: Colors.white,
                //repeat: ImageRepeat.repeat,
                imageBuilder: (context, imageProvider) => Container(
                  width: double.infinity,
                  height: 154,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                fit: BoxFit.contain,
                imageUrl: imageUrl,
                errorWidget: ((context, url, error) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Failed to Load Image"),
                    )),
                placeholder: ((context, url) => const Center(
                      child: CircularProgressIndicator(),
                    )),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Container(
              width: double.infinity,
              //height: 50,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF673AB7).withValues(alpha: 0.20),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                ReCase("${productController.vendorsList[index]!.shopName}")
                    .titleCase,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchCard extends StatelessWidget {
  final int index;
  const SearchCard({required this.index, super.key});
  @override
  Widget build(BuildContext context) {
    ProductController productController = Get.find<ProductController>();

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

    return GetX<ProductController>(builder: (controller) {
      return InkWell(
        onTap: () {
          Get.to(
              () => ProductPage(
                    id: productController
                        .filteredSearchProducts[index]!.productID,
                  ),
              transition: Transition.fadeIn);
        },
        splashColor: Theme.of(context).primaryColorDark,
        child: Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: productController.filteredSearchProducts[index]
                              ?.image?.isNotEmpty ==
                          true
                      ? productController
                          .filteredSearchProducts[index]!.image!.first
                      : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                  errorWidget: ((context, url, error) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Failed to Load Image"),
                      )),
                  imageBuilder: (context, imageProvider) => Container(
                    width: double.infinity,
                    height: !Responsive.isMobile(context) ? 250 : 154,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: ((context, url) => const SizedBox(
                        width: double.infinity,
                        height: 154,
                        child: Center(child: CircularProgressIndicator()),
                      )),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                child: Text(
                  productController
                      .filteredSearchProducts[index]!.name!.titleCase,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "Raleway",
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 0, 0),
                child: Text(
                  "NGN ${formatCurrency(productController.filteredSearchProducts[index]!.price.toString())}",
                  style: const TextStyle(
                    color: AppColors.shade9,
                    fontSize: 15,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class ClientShopCard extends StatelessWidget {
  final int? index;
  const ClientShopCard({this.index, super.key});
  @override
  Widget build(BuildContext context) {
    ProductController productController = Get.find<ProductController>();
    UserController userController = Get.find<UserController>();
    WishListController wishListController = Get.find<WishListController>();
    //bool showSocialMediaIcons = false;
    num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    Product? product = productController.products[index!]!;

    bool isUserLoggedIn = userController.userState.value != null;

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

    return FutureBuilder(
      future: DataBaseService().isProductInWishlist(product.productID!),
      builder: (context, snapshot) {
        bool isLiked = false;
        if (snapshot.hasData) {
          isLiked = snapshot.data!;
        }

        return InkWell(
          onTap: () {
            Get.to(
                () => ProductPage(
                      id: product.productID,
                      //index: index,
                    ),
                transition: Transition.fadeIn);
          },
          splashColor: Colors.black,
          child: Card(
            elevation: 1,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              // side: BorderSide(
              //   color: Colors.white,
              //   width: 0.5,
              // ),
            ),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: product.image?.isNotEmpty == true
                        ? product.image!.first
                        : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                    errorWidget: ((context, url, error) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Failed to Load Image"),
                        )),
                    imageBuilder: (context, imageProvider) => Container(
                      width: double.infinity,
                      height: !Responsive.isMobile(context) ? 250 : 154,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: ((context, url) => const Center(
                          child: CircularProgressIndicator(),
                        )),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                SizedBox(
                  height: screenHeight * 0.055,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    child: Text(
                      ReCase("${product.name}").titleCase,
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    "NGN ${formatCurrency(product.price.toString())}",
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
                  child: LikeButton(
                    mainAxisAlignment: MainAxisAlignment.end,
                    size: 20,
                    bubblesSize: 48,
                    isLiked: isLiked,
                    onTap: (isTapped) async {
                      // Only proceed if the user is logged in
                      if (isUserLoggedIn) {
                        if (isLiked) {
                          await wishListController
                              .removeFromWishlistWithProductID(
                                  product.productID!);
                        } else {
                          WishlistItem wishlistItem =
                              WishlistItem(wishListItemID: product.productID!);
                          await wishListController.addToWishlist(wishlistItem);
                        }
                      }
                      return isUserLoggedIn ? !isLiked : false;
                    },
                    likeBuilder: (isLiked) {
                      if (isLiked) {
                        return const Icon(
                          Icons.favorite,
                          color: Color(0xFF673AB7),
                        );
                      } else {
                        return const Icon(
                          Icons.favorite_outline_rounded,
                          color: Color(0xFF673AB7),
                        );
                      }
                    },
                    bubblesColor: BubblesColor(
                      dotPrimaryColor: const Color(0xFF673AB7),
                      dotSecondaryColor:
                          const Color(0xFF673AB7).withValues(alpha: 0.70),
                      dotThirdColor: Colors.white,
                      dotLastColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CarouselCard extends StatelessWidget {
  const CarouselCard({super.key});

  @override
  Widget build(BuildContext context) {
    num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight * 0.24,
      width: screenWidth * 0.70,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
        color: Color(0xFFF4D06F),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000),
            blurStyle: BlurStyle.outer,
            blurRadius: 0.4,
          ),
        ],
      ),
      child: const Text("Hello"),
    );
  }
}

class CartCard extends StatelessWidget {
  final String? id;
  final String? cartId;
  final String? optionName;
  final CartItem? cartItem;
  const CartCard(
      {this.cartId, this.id, this.optionName, this.cartItem, super.key});
  @override
  Widget build(BuildContext context) {
    UserController userController = Get.find<UserController>();

    CartController cartController = Get.find<CartController>();

    ProductController productController = Get.find<ProductController>();

    CheckOutController checkOutController = Get.find<CheckOutController>();

    // Initialize the checkbox state for this item
    if (!checkOutController.itemCheckboxState
        .containsKey(cartItem!.cartItemID)) {
      checkOutController.itemCheckboxState[cartItem!.cartItemID] = false.obs;
    }

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

    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    //cartController.assignCartProduct(id!, productController.products);
    return GetX<CartController>(builder: (controller) {
      Product? product;
      RxInt quantity = 0.obs;
      RxInt currentPrice = 0.obs;

      fetchProduct() {
        product = productController.products.firstWhereOrNull((element) {
          return element!.productID! == cartItem!.productID;
        });
        quantity.value = cartController
            .determineQuantity(product, optionName)["quantity"]!
            .toInt();
        currentPrice.value = cartController
            .determineQuantity(product, optionName)["currentPrice"]!
            .toInt();
      }

      fetchProduct();

      debounce(productController.products, (newProduct) {
        // debugPrint("debouncing");
        fetchProduct();
      }, time: const Duration(seconds: 1));
      return Column(
        children: [
          Container(
            //height: screenHeight * 0.18,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            //margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: const BoxDecoration(
              // borderRadius: BorderRadius.all(
              //   Radius.circular(16),
              // ),
              color: Colors.white,
              // boxShadow: [
              //   BoxShadow(
              //     color: Color(0xFF000000),
              //     blurStyle: BlurStyle.normal,
              //     offset: Offset.fromDirection(-4.0),
              //     blurRadius: 4,
              //   ),
              // ],
            ),
            child: Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GetX<CheckOutController>(
                  builder: (_) {
                    return Checkbox(
                      shape: const CircleBorder(side: BorderSide()),
                      value: checkOutController
                          .itemCheckboxState[cartItem!.cartItemID]!.value,
                      onChanged: (val) {
                        //debugPrint(object)
                        checkOutController.toggleCheckbox(
                          productID: cartItem!.productID,
                          quantity: cartItem!.quantity!,
                          price: cartItem!.price!,
                          user: userController.userState.value,
                          cartID: cartId!,
                          value: val!,
                          optionName: cartItem!.optionName,
                        );
                        //debugPrint(checkOutController.checkoutList.first.price);
                        checkOutController.getTotalPriceAndTotalQuantity();
                        // Optionally, you can notify listeners here if needed
                        // checkOutController.itemCheckboxState[id!]!.notifyListeners();
                      },
                    );
                  },
                ),
                const SizedBox(
                  width: 1,
                ),
                buildProductImage(product),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${product?.name}",
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Raleway',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        "NGN${formatCurrency(cartItem!.price.toString())}",
                        style: const TextStyle(
                          fontSize: 17,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF673AB7),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Current price (each): NGN${formatCurrency(currentPrice.value.toString())}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF673AB7),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            radius: 17,
                            onTap: () async {
                              if (cartItem!.quantity! > 1) {
                                await cartController.updateCartItem(
                                  cartItemID: cartId,
                                  newQuantity: -1,
                                  productID: id,
                                );
                              } else {
                                cartController
                                    .showMyToast("Cannot be less than 1");
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(0.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF673AB7)
                                    .withValues(alpha: 0.10),
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
                            "${cartItem!.quantity}",
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
                            radius: 50,
                            onTap: () async {
                              if (cartItem!.quantity! >= quantity.value) {
                                cartController.showMyToast(
                                    "Cannot add more than available stock");
                                return;
                              } else {
                                await cartController.updateCartItem(
                                  cartItemID: cartId,
                                  newQuantity: 1,
                                  productID: id,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(0.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF673AB7)
                                    .withValues(alpha: 0.10),
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
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        "${quantity.value} left",
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.main,
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => ClientShopPage(
                              vendorID: productController
                                  .clientGetVendorName(product?.vendorId)
                                  .userID,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          color: Colors.transparent,
                          //width: screenWidth * 0.60,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/Icons/shop.svg',
                                height: 16,
                                width: 16,
                                colorFilter: ColorFilter.mode(
                                  Colors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Flexible(
                                child: Text(
                                  "${productController.clientGetVendorName(product?.vendorId ?? "").shopName}",
                                  style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 17,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 4,
            thickness: 1,
          ),
        ],
      );
    });
  }

  Widget buildProductImage(Product? product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageBuilder: (context, imageProvider) => Container(
          height: 150,
          width: 130,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        fit: BoxFit.cover,
        imageUrl: product?.image?.isNotEmpty == true
            ? product?.image!.first
            : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
        errorWidget: (context, url, error) =>
            const Text("Failed to Load Image"),
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class WishListCard extends StatelessWidget {
  final String? productID;
  const WishListCard({this.productID, super.key});

  @override
  Widget build(BuildContext context) {
    ProductController productController = Get.find<ProductController>();
    CartController cartController = Get.find<CartController>();
    WishListController wishListController = Get.find<WishListController>();
    Product? product;
    for (var element in productController.products) {
      if (element!.productID == productID) {
        product = element;
      }
    }
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

    if (!wishListController.itemCheckboxState.containsKey(productID)) {
      wishListController.itemCheckboxState[productID!] = false.obs;
    }

    // num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          //height: screenHeight * 0.20,
          width: screenWidth * 0.88,
          padding: const EdgeInsets.all(6),
          //margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              wishListController.isEditingMode.value
                  ? GetX<WishListController>(builder: (controller) {
                      return Checkbox(
                        shape: const CircleBorder(side: BorderSide()),
                        value: wishListController
                            .itemCheckboxState[productID]!.value,
                        onChanged: (val) {
                          wishListController.toggleCheckBox(val!, productID!);
                        },
                      );
                    })
                  : const SizedBox.shrink(),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                // decoration: BoxDecoration(
                //   color: Colors.black45,
                // ),
                // width: screenWidth * 0.36,
                // height: screenHeight * 0.20,
                child: CachedNetworkImage(
                  //fit: BoxFit.contain,
                  imageUrl: product?.image?.isNotEmpty == true
                      ? product!.image!.first
                      : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                  errorWidget: ((context, url, error) =>
                      const Text("Failed to Load Image")),
                  placeholder: ((context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      )),
                  imageBuilder: (context, imageProvider) => Container(
                    height: 140,
                    width: 130,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product!.name ?? "",
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "NGN${formatCurrency(product.price.toString())}",
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF673AB7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                          () => ClientShopPage(
                            vendorID: productController
                                .clientGetVendorName(product!.vendorId)
                                .userID,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        color: Colors.transparent,
                        //width: screenWidth * 0.60,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/Icons/shop.svg',
                              height: 16,
                              width: 16,
                              colorFilter: ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Flexible(
                              child: Text(
                                "${productController.clientGetVendorName(product.vendorId).shopName}",
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 17,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     IconButton(
                    //       onPressed: () {},
                    //       icon: Icon(
                    //         Symbols.remove,
                    //         size: 24,
                    //         color: Colors.black,
                    //       ),
                    //     ),
                    //     Container(
                    //       width: 28,
                    //       height: 28,
                    //       color: const Color(0xFF392F5A),
                    //       child: Center(
                    //         child: Text(
                    //           "1",
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 24,
                    //             //backgroundColor: Colors.blue,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     IconButton(
                    //       onPressed: () {},
                    //       icon: Icon(
                    //         Symbols.add,
                    //         size: 24,
                    //         color: Colors.black,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    wishListController.isEditingMode.value
                        ? const SizedBox.shrink()
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: () async {
                                await cartController.addToCart(CartItem(
                                    quantity: 1,
                                    productID: productID,
                                    price: product!.price));
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(12),
                                //   side: const BorderSide(
                                //     width: 1.5,
                                //     color: Colors.black,
                                //   ),
                                // ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF673AB7),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    "Add to Cart",
                                    style: TextStyle(
                                      color: Color(0xFF673AB7),
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 2,
          thickness: 0.5,
          color: Colors.black.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}

class VendorArrivalCard extends StatelessWidget {
  final String? productID;
  const VendorArrivalCard({this.productID, super.key});

  @override
  Widget build(BuildContext context) {
    ProductController productController = Get.find<ProductController>();
    Product? product;
    product = productController.products
        .firstWhere((product) => product?.productID == productID);
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

    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ProductPage(
            id: productID,
          ),
        );
      },
      child: Container(
        color: Colors.white,
        //height: screenHeight * 0.20,
        width: double.infinity,
        padding: const EdgeInsets.all(6),
        //margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              // decoration: BoxDecoration(
              //   color: Colors.black45,
              // ),
              // width: screenWidth * 0.36,
              // height: screenHeight * 0.20,
              child: CachedNetworkImage(
                //fit: BoxFit.contain,
                imageUrl: product?.image?.isNotEmpty == true
                    ? product!.image!.first
                    : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                errorWidget: ((context, url, error) =>
                    const Text("Failed to Load Image")),
                placeholder: ((context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    )),
                imageBuilder: (context, imageProvider) => Container(
                  height: 140,
                  width: 130,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: SizedBox(
                height: 140,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product!.name ?? "",
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "NGN${formatCurrency(product.price.toString())}",
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF673AB7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Function? onTap;
  final int? index;
  final String? mapKey;
  const OrderCard({this.onTap, this.index, this.mapKey, super.key});

  @override
  Widget build(BuildContext context) {
    CheckOutController checkOutController = Get.find<CheckOutController>();
    ProductController productController = Get.find<ProductController>();
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

    sortOrderStatusColors(String orderStatus) {
      switch (orderStatus.toLowerCase()) {
        case "created":
          return AppColors.created;
        case "expired":
          return AppColors.expired;
        case "cancelled":
          return AppColors.cancelled;
        case "confirmed":
          return AppColors.confirmed;
        case "delivered":
          return AppColors.delivered;
        case "not delivered":
          return AppColors.notDelivered;
        default:
          return AppColors.background;
      }
    }

    sortOrderStatusTextColors(String orderStatus) {
      switch (orderStatus.toLowerCase()) {
        case "created":
          return AppColors.shade9;
        case "cancelled":
          return Colors.white;
        case "confirmed":
          return Colors.white;
        case "expired":
          return Colors.white;
        case "delivered":
          return Colors.white;
        case "not delivered":
          return AppColors.shade9;
        default:
          return AppColors.background;
      }
    }

    sortPaymentMethodColor(String paymentMethod) {
      switch (paymentMethod.toLowerCase()) {
        case "once":
          return AppColors.once;
        case "installment":
          return AppColors.installment;
        default:
          return AppColors.background;
      }
    }

    sortPaymentMethodTextColor(String paymentMethod) {
      switch (paymentMethod.toLowerCase()) {
        case "once":
          return Colors.white;
        case "installment":
          return AppColors.offWhite;
        default:
          return AppColors.background;
      }
    }

    var orderDetails = checkOutController.buyerOrderMap[mapKey]![index!];
    var product = productController.getSingleProduct(checkOutController
        .buyerOrderMap[mapKey]![index!].orderItem!.first.productId!);
    // num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => Get.to(
        () => OrderDetailsPage(
          orderID: orderDetails.orderId,
          vendorID: orderDetails.vendorId,
          product: product,
        ),
        transition: Transition.fadeIn,
      ),
      child: Container(
        //height: screenHeight * 0.20,
        width: screenWidth * 0.88,
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(
            width: 0.5,
            color: Colors.black.withValues(alpha: 0.80),
          ),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 145,
                      height: 140,
                      child: Image.network(
                        product?.image?.isNotEmpty == true
                            ? product!.image!.first
                            : "https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2Fnot%20available.jpg?alt=media&token=ea001edd-ec0f-4ffb-9a2d-efae1a28fc40",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${product!.name}",
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "NGN ${formatCurrency(orderDetails.totalPrice.toString())}",
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          color: Color(0xFF673AB7),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      // Container(
                      //   padding:
                      //       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      //   decoration: const BoxDecoration(
                      //     borderRadius: BorderRadius.all(
                      //       Radius.circular(12),
                      //     ),
                      //     color: Colors.black,
                      //     // boxShadow: [
                      //     //   BoxShadow(
                      //     //     color: Color(0xFF000000),
                      //     //     blurStyle: BlurStyle.normal,
                      //     //     offset: Offset.fromDirection(-4.0),
                      //     //     blurRadius: 1.2,
                      //     //   ),
                      //     // ],
                      //   ),
                      //   child: Text(
                      //     "${orderDetails.paymentStatus}",
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 8,
                      // ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          color:
                              sortOrderStatusColors(orderDetails.orderStatus!),
                          border: Border.all(
                            width: 0.3,
                            color: Colors.black.withValues(alpha: 0.85),
                          ),
                        ),
                        child: Text(
                          "${orderDetails.orderStatus!.capitalizeFirst}",
                          style: TextStyle(
                            color: sortOrderStatusTextColors(
                                orderDetails.orderStatus!),
                            fontSize: 11,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          color: sortPaymentMethodColor(
                              orderDetails.paymentMethod!),
                          border: Border.all(
                            width: 0.3,
                            color: Colors.black.withValues(alpha: 0.85),
                          ),
                        ),
                        child: Text(
                          "${orderDetails.paymentMethod!.capitalizeFirst}",
                          style: TextStyle(
                            color: sortPaymentMethodTextColor(
                                orderDetails.paymentMethod!),
                            fontSize: 11,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Visibility(
                        visible: orderDetails.paymentMethod == "installment",
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color:
                                const Color(0xFF673AB7).withValues(alpha: 0.30),
                          ),
                          child: Text(
                            "Amount Paid: NGN${formatCurrency(orderDetails.paymentPrice.toString())}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'Lato',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: orderDetails.orderStatus == "confirmed",
                            child: GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => RefundPage(
                                    orderId: orderDetails.orderId!,
                                    paymentAmount: orderDetails.paymentPrice!,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 9),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  color: Color(0xFF673AB7),
                                ),
                                child: const Text(
                                  "Request Refund",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Lato',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Visibility(
                            visible: orderDetails.orderStatus!.toLowerCase() ==
                                    "expired" ||
                                orderDetails.orderStatus!.toLowerCase() ==
                                    "cancelled" ||
                                orderDetails.orderStatus!.toLowerCase() ==
                                    "confirmed",
                            child: TextButton(
                              onPressed: () async {
                                checkOutController.isLoading.value = true;
                                if (checkOutController.isLoading.value) {
                                  Get.dialog(LoadingWidget());
                                }
                                await checkOutController
                                    .deleteOrderBuyer(orderDetails.orderId!);
                              },
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lato',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VendorOrderCard extends StatelessWidget {
  final Function? onTap;
  final String? mapKey;
  final int? index;
  const VendorOrderCard({this.onTap, this.mapKey, this.index, super.key});

  @override
  Widget build(BuildContext context) {
    CheckOutController checkOutController = Get.find<CheckOutController>();
    ProductController productController = Get.find<ProductController>();
    var orderDetails = checkOutController.vendorOrdersMap[mapKey]![index!];
    var product = productController.getSingleProduct(checkOutController
        .vendorOrdersMap[mapKey]![index!].orderItem!.first.productId!);
    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
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

    sortOrderStatusColors(String orderStatus) {
      switch (orderStatus.toLowerCase()) {
        case "created":
          return AppColors.created;
        case "expired":
          return AppColors.expired;
        case "cancelled":
          return AppColors.cancelled;
        case "confirmed":
          return AppColors.confirmed;
        case 'delivered':
          return AppColors.delivered;
        default:
          return AppColors.background;
      }
    }

    sortOrderStatusTextColors(String orderStatus) {
      switch (orderStatus.toLowerCase()) {
        case "created":
          return AppColors.shade9;
        case "cancelled":
          return Colors.grey[50];
        case "confirmed":
          return Colors.grey[50];
        case "expired":
          return Colors.white;
        case 'delivered':
          return Colors.white;
        default:
          return AppColors.shade9;
      }
    }

    sortPaymentMethodColor(String paymentMethod) {
      switch (paymentMethod.toLowerCase()) {
        case "once":
          return AppColors.once;
        case "installment":
          return AppColors.installment;
        default:
          return AppColors.background;
      }
    }

    sortPaymentMethodTextColor(String paymentMethod) {
      switch (paymentMethod.toLowerCase()) {
        case "once":
          return Colors.white;
        case "installment":
          return AppColors.offWhite;
        default:
          return AppColors.background;
      }
    }

    return GestureDetector(
      onTap: () => Get.to(
        () => VendorOrderDetailsPage(
          product: product,
          orderDetails: orderDetails,
        ),
        transition: Transition.fadeIn,
      ),
      child: Container(
        // height: screenHeight * 0.20,
        // width: screenWidth * 0.88,
        //padding: EdgeInsets.fromLTRB(),
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              // decoration: BoxDecoration(
              //   color: Colors.black45,
              // ),
              // width: screenWidth * 0.32,
              // height: screenHeight * 0.16,
              child: CachedNetworkImage(
                imageBuilder: (context, imageProvider) => Container(
                  height: 140,
                  width: 123,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                fit: BoxFit.fill,
                imageUrl: product!.image != null &&
                        product.image!.isNotEmpty == true
                    ? product.image!.first
                    : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                errorWidget: ((context, url, error) =>
                    const Text("Failed to Load Image")),
                placeholder: ((context, url) => Container(
                      alignment: Alignment.center,
                      height: 140,
                      width: 123,
                      child: const CircularProgressIndicator(),
                    )),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${product.name}",
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Raleway',
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Qty:${orderDetails.orderItem!.first.quantity}pcs",
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Amount Paid:${formatCurrency(orderDetails.paymentPrice.toString())}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: sortPaymentMethodColor(
                            orderDetails.paymentMethod!,
                          ),
                        ),
                        child: Text(
                          "Payment Method: ${orderDetails.paymentMethod}",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            fontFamily: 'Lato',
                            color: sortPaymentMethodTextColor(
                              orderDetails.paymentMethod!,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "Total: ${formatCurrency(orderDetails.totalPrice.toString())}",
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF673AB7),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: sortOrderStatusColors(
                            orderDetails.orderStatus!,
                          ),
                        ),
                        child: Text(
                          "${orderDetails.orderStatus}",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Raleway',
                            fontSize: 12,
                            color: sortOrderStatusTextColors(
                                orderDetails.orderStatus!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Container(
                  //       padding:
                  //           EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //       decoration: BoxDecoration(
                  //         borderRadius: const BorderRadius.all(
                  //           Radius.circular(12),
                  //         ),
                  //         color: Color.fromARGB(255, 200, 242, 237),
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Color(0xFF000000),
                  //             blurStyle: BlurStyle.normal,
                  //             offset: Offset.fromDirection(-4.0),
                  //             blurRadius: 1.2,
                  //           ),
                  //         ],
                  //       ),
                  //       child: Text("${orderDetails.paymentStatus}"),
                  //     ),
                  //     const SizedBox(
                  //       height: 2,
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(
                  //   height: 8,
                  // ),
                  // Container(
                  //   padding: EdgeInsets.all(4),
                  //   decoration: BoxDecoration(
                  //     borderRadius: const BorderRadius.all(
                  //       Radius.circular(12),
                  //     ),
                  //     color: Color.fromARGB(255, 200, 242, 237),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Color(0xFF000000),
                  //         blurStyle: BlurStyle.normal,
                  //         offset: Offset.fromDirection(-4.0),
                  //         blurRadius: 4,
                  //       ),
                  //     ],
                  //   ),
                  //   child: Text("Delivery Status"),
                  // )
                ],
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final int? index;
  const ReviewCard({super.key, this.index});

  @override
  Widget build(BuildContext context) {
    String resolveTimestampWithoutAdding(Timestamp timestamp) {
      DateTime dateTime = timestamp.toDate();
      String formattedDate =
          DateFormat('dd MMM yyyy', 'en_US').format(dateTime);
      return formattedDate;
    }

    ProductController productController = Get.find<ProductController>();
    Review review = productController.reviews[index!]!;
    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    return Card(
      //height: screenHeight * 0.16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      color: Colors.grey[300],
      child: SizedBox(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  review.stars.round(),
                  (index) => const Icon(
                    Icons.star,
                    size: 24,
                    color: Color(0xFF673AB7),
                  ),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                resolveTimestampWithoutAdding(review.createdAt),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Raleway',
                  color: Color(0xFF673AB7),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                review.comment,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Raleway',
                  color: Color(0xFF673AB7),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Visibility(
                visible: review.displayName != null &&
                    review.displayName!.isNotEmpty,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "-${review.displayName}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Raleway',
                      color: Color(0xFF673AB7),
                    ),
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

class FullReviewCard extends StatelessWidget {
  final int? index;
  const FullReviewCard({super.key, this.index});

  @override
  Widget build(BuildContext context) {
    String resolveTimestampWithoutAdding(Timestamp timestamp) {
      DateTime dateTime = timestamp.toDate();
      String formattedDate =
          DateFormat('dd MMM yyyy', 'en_US').format(dateTime);
      return formattedDate;
    }

    ProductController productController = Get.find<ProductController>();
    Review review = productController.reviews[index!]!;
    // num screenHeight = MediaQuery.of(context).size.height;
    // num screenWidth = MediaQuery.of(context).size.width;
    return Card(
      //height: screenHeight * 0.16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      color: Colors.grey[300],
      child: SizedBox(
        // width: 300,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  review.stars.round(),
                  (index) => const Icon(
                    Icons.star,
                    size: 24,
                    color: Color(0xFF673AB7),
                  ),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                resolveTimestampWithoutAdding(review.createdAt),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Raleway',
                  color: Color(0xFF673AB7),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                review.comment,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Raleway',
                  color: Color(0xFF673AB7),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Visibility(
                visible: review.displayName != null &&
                    review.displayName!.isNotEmpty,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "-${review.displayName}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Raleway',
                      color: Color(0xFF673AB7),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Visibility(
                visible: review.reviewImages != null &&
                    review.reviewImages!.isNotEmpty,
                child: SizedBox(
                  height: 88,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.reviewImages?.length ?? 0,
                    itemBuilder: (context, imageIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageBuilder: (context, imageProvider) => Container(
                              height: 88,
                              width: 88,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            fit: BoxFit.fill,
                            imageUrl: review.reviewImages![imageIndex],
                            errorWidget: ((context, url, error) => const Text(
                                  "Failed to Load Image",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                )),
                            placeholder: ((context, url) => Container(
                                  alignment: Alignment.center,
                                  height: 88,
                                  width: 88,
                                  child: const CircularProgressIndicator(),
                                )),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReferralCard extends StatelessWidget {
  final String? title;
  final String? text;
  const ReferralCard({this.title, this.text, super.key});

  @override
  Widget build(BuildContext context) {
    // num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;
    return Container(
      //height: 36,
      width: screenWidth * 0.88,
      padding: const EdgeInsets.all(8),
      //margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(16),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            spreadRadius: 0,
            color: const Color(0xFF673AB7).withValues(alpha: 0.10),
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${title!}:",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          Text(
            text!,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class ShopDetailsCard extends StatefulWidget {
  const ShopDetailsCard({super.key});

  @override
  State<ShopDetailsCard> createState() => _ShopDetailsCardState();
}

class _ShopDetailsCardState extends State<ShopDetailsCard> {
  String _selectedUnit = "Week(s)";
  final TextEditingController _controller = TextEditingController();
  VendorController vendorController = Get.find<VendorController>();
  UserController userController = Get.find<UserController>();
  PaystackBankCode banksAndCodes = PaystackBankCode();

  void _initializeInputFromMilliseconds(int milliseconds) {
    int number;
    String unit;
    if (milliseconds % (7 * 24 * 60 * 60 * 1000) == 0) {
      number = milliseconds ~/ (7 * 24 * 60 * 60 * 1000);
      unit = "Week(s)";
    } else if (milliseconds % (30 * 24 * 60 * 60 * 1000) == 0) {
      number = milliseconds ~/ (30 * 24 * 60 * 60 * 1000);
      unit = "Month(s)";
    } else {
      number = milliseconds ~/ (365 * 24 * 60 * 60 * 1000);
      unit = "Year(s)";
    }
    setState(() {
      _controller.text = number.toString();
      _selectedUnit = unit;
    });
  }

  @override
  void initState() {
    _initializeInputFromMilliseconds(
        vendorController.vendor.value!.installmentDuration!.toInt());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SharePlus share = SharePlus.instance;
    num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;
    GlobalKey<FormState>? formKey = GlobalKey();
    // GlobalKey<FormState>? formKey2 = GlobalKey();
    CountryAndStatesAndLocalGovernment countryAndStatesAndLocalGovernment =
        CountryAndStatesAndLocalGovernment();
    TextEditingController? bankNameController = TextEditingController();
    TextEditingController? streetController = TextEditingController();
    TextEditingController? accountNumberController = TextEditingController();
    TextEditingController? accountNameController = TextEditingController();
    TextEditingController? phoneNumberController = TextEditingController();
    TextEditingController? shopNameController = TextEditingController();
    Vendors vendor = vendorController.vendor.value!;
    String? accountName,
        accountNumber,
        street,
        state = vendor.contactInfo!["state"],
        localGovernment = vendor.contactInfo!["local government"],
        phoneNumber,
        shopName,
        bankName;
    String message =
        "Hello there, I am on Hair Main Street, Visit my shop using this link below:\n${vendorController.vendor.value!.shopLink}";
    Text? referralText = Text(
      vendorController.vendor.value!.shopLink!,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      maxLines: 3,
      overflow: TextOverflow.clip,
    );
    void dismissKeyboard() {
      bool isKeyboardVisible = KeyboardService.isVisible(context);
      isKeyboardVisible ? KeyboardService.dismiss() : null;
    }

    double determineHeight(String label) {
      double theScreen;
      if (label == 'account info') {
        theScreen = screenHeight * .40;
      } else if (label == 'contact info') {
        theScreen = screenHeight * .60;
      } else {
        theScreen = screenHeight * .24;
      }
      return theScreen;
    }

    showImageUploadDialog() {
      return Get.dialog(
        Obx(() {
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              height: vendorController.isImageSelected.value
                  ? screenHeight * 0.80
                  : screenHeight * 0.30,
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: vendorController.isImageSelected.value,
                      child: Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.45,
                            width: screenWidth * 0.70,
                            child: vendorController
                                    .selectedImage.value.isNotEmpty
                                ? Image.file(
                                    File(vendorController.selectedImage.value),
                                    fit: BoxFit.fill,
                                  )
                                : const Text("Hello"),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
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
                                  await vendorController.shopImageUpload([
                                    File(vendorController.selectedImage.value)
                                  ], "shop photo");
                                },
                                child: const Text(
                                  "Done",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
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
                                  vendorController.selectedImage.value = "";
                                  vendorController.isImageSelected.value =
                                      false;
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.black,
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
                              await vendorController.selectShopImage(
                                  ImageSource.camera, "shop_photo");
                            },
                            child: const Text(
                              "Take\nPhoto",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 1,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                                side: const BorderSide(
                                  width: 2,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              await vendorController.selectShopImage(
                                  ImageSource.gallery, "shop_photo");
                            },
                            child: const Text(
                              "Choose From Gallery",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                            side: const BorderSide(
                              width: 2,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (vendor.shopPicture != null) {
                            vendorController.isLoading.value = true;
                            if (vendorController.isLoading.value) {
                              Get.dialog(const LoadingWidget());
                            }
                            await vendorController.deleteShopPicture(
                                vendor.shopPicture!,
                                "vendors",
                                "shop picture",
                                vendor.userID);
                          } else {
                            vendorController.showMyToast("No Shop Image");
                          }
                        },
                        child: const Text(
                          "Delete Photo",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                            side: const BorderSide(
                              width: 2,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          Get.back();
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        barrierColor: Colors.transparent,
        barrierDismissible: true,
      );
    }

    showCancelDialog(String text, {String? label}) {
      return Get.dialog(
        StatefulBuilder(
          builder: (context, StateSetter setState) => AlertDialog(
            scrollable: true,
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            content: SizedBox(
              width: double.infinity,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Edit $text",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      if (label == "contact info")
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            const SizedBox(height: 3),
                            buildPicker(
                                "Local Government",
                                countryAndStatesAndLocalGovernment
                                    .stateAndLocalGovernments[state]!,
                                localGovernment ?? "select", (val) {
                              setState(() {
                                localGovernment = val;
                              });
                            }),
                            const SizedBox(height: 3),
                            TextInputWidgetWithoutLabelForDialog(
                              controller: streetController,
                              initialValue: vendorController.vendor.value!
                                      .contactInfo!["street address"] ??
                                  "",
                              hintText: "Street Address",
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Cannot be Empty";
                                }
                                return null;
                              },
                              onChanged: (val) {
                                streetController.text = val!;
                                street = streetController.text;
                                return null;
                              },
                            ),
                          ],
                        )
                      else if (label == "phone number")
                        TextInputWidgetWithoutLabelForDialog(
                          controller: phoneNumberController,
                          initialValue: vendorController
                              .vendor.value!.contactInfo!["phone number"],
                          hintText: "Phone Number",
                          textInputType: TextInputType.phone,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Cannot be Empty";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            phoneNumberController.text = val!;
                            phoneNumber = phoneNumberController.text;
                            return null;
                          },
                        )
                      else if (label == "account info")
                        Column(
                          children: [
                            TextInputWidgetWithoutLabelForDialog(
                              controller: accountNumberController,
                              initialValue: vendorController
                                  .vendor.value!.accountInfo!["account number"],
                              hintText: "Account Number",
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Cannot be Empty";
                                }
                                if (!validator.isNumeric(val)) {
                                  return "Must Be A Number";
                                }
                                if (val.length < 10) {
                                  return "Account Number must have at least 10 digits";
                                }
                                return null;
                              },
                              onChanged: (val) {
                                accountNumberController.text = val!;
                                accountNumber = accountNumberController.text;
                                return null;
                              },
                            ),
                            TextInputWidgetWithoutLabelForDialog(
                              controller: accountNameController,
                              hintText: "Account Name",
                              initialValue: vendor.accountInfo!["account name"],
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Cannot be Empty";
                                }
                                return null;
                              },
                              onChanged: (val) {
                                accountNameController.text = val!;
                                accountName = accountNameController.text;
                                return null;
                              },
                            ),
                            Text(
                              "Bank Name",
                              style: TextStyle(
                                color: const Color(0xFF673AB7).withAlpha(150),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Raleway',
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            DropdownSearch(
                              compareFn: (item1, item2) => item1 == item2,
                              suffixProps: DropdownSuffixProps(
                                clearButtonProps: ClearButtonProps(
                                  icon: Iconify(
                                    Ic.baseline_keyboard_arrow_down,
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
                                          "Select Bank",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black
                                                .withValues(alpha: 0.45),
                                          ),
                                        )
                                      : Text(
                                          selectedItem
                                              .toString()
                                              .capitalizeFirst!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                              popupProps: PopupProps.dialog(
                                fit: FlexFit.loose,
                                itemBuilder:
                                    (context, item, isDisabled, isSelected) =>
                                        Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
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
                                      color:
                                          Colors.black.withValues(alpha: 0.55),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 20,
                                      color:
                                          Colors.black.withValues(alpha: 0.55),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black
                                            .withValues(alpha: 0.35),
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
                                  "Select Bank",
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
                              items: (f, cs) =>
                                  banksAndCodes.paystackBankCodes.keys.toList(),
                              validator: (value) {
                                if (value.toString().isEmpty) {
                                  return "Please choose your Bank name";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  bankName = value.toString();
                                });
                              },
                              decoratorProps: DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFf5f5f5),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 10),
                                  // hintText: "Select Bank",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          Colors.black.withValues(alpha: 0.35),
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
                                    fontFamily: 'Lato',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withValues(alpha: 0.45),
                                  ),
                                ),
                                baseStyle: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                          ],
                        )
                      else if (label == "name")
                        TextInputWidgetWithoutLabelForDialog(
                          controller: shopNameController,
                          initialValue: vendor.shopName,
                          hintText: text,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Cannot be Empty";
                            }
                            return null;
                          },
                          textInputType: TextInputType.text,
                          onChanged: (val) {
                            shopNameController.text = val!;
                            shopName = shopNameController.text;
                            return null;
                          },
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7),
                            padding: const EdgeInsets.all(6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            var validated = formKey.currentState!.validate();
                            if (validated) {
                              formKey.currentState!.save();
                              switch (label) {
                                case "Phone Number":
                                  var result = await vendorController
                                      .updateVendor('contact info',
                                          {"phone number": phoneNumber});
                                  if (result == "success") {
                                    Get.close(1);
                                  }
                                  break;
                                case "contact info":
                                  var result = await vendorController
                                      .updateVendor("contact info", {
                                    "country": "Nigeria",
                                    "state": state,
                                    "street address": street,
                                    "local government": localGovernment,
                                  });
                                  if (result == "success") {
                                    Get.close(1);
                                  }
                                case "account info":
                                  var result = await vendorController
                                      .updateVendor("account info", {
                                    "bank name": bankName,
                                    "account name": accountName,
                                    "account number": accountNumber,
                                  });
                                  if (result == "success") {
                                    Get.close(1);
                                  }
                                case "name":
                                  var result = await vendorController
                                      .updateVendor("shop name", shopName);
                                  if (result == "success") {
                                    Get.close(1);
                                  }
                                default:
                              }
                              //Get.back();
                            }
                          },
                          child: const Text(
                            "Confirm Edit",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
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

    return Obx(
      () => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: [
          GestureDetector(
            onTap: () => dismissKeyboard(),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Center(
                child: Stack(
                  //alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    userController.userState.value == null ||
                            vendorController.vendor.value!.shopPicture == null
                        ? CircleAvatar(
                            radius: 68,
                            backgroundColor: const Color(0xFFF5f5f5),
                            child: SvgPicture.asset(
                              "assets/Icons/user.svg",
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.70),
                                BlendMode.srcIn,
                              ),
                              height: 50,
                              width: 50,
                            ),
                          )
                        : CircleAvatar(
                            radius: 68,
                            //backgroundColor: Colors.black,
                            backgroundImage: NetworkImage(
                              vendorController.vendor.value!.shopPicture!,
                              scale: 1,
                            ),
                          ),
                    Positioned(
                      bottom: -2,
                      right: 8,
                      child: IconButton(
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.black,
                              width: 0.5,
                            )),
                        onPressed: () {
                          showImageUploadDialog();
                        },
                        icon: Icon(
                          Icons.camera_alt_rounded,
                          size: 28,
                          color: const Color(0xFF673AB7).withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFf5f5f5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.transparent),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 1,
                      spreadRadius: 0,
                      color: const Color(0xFF673AB7).withValues(alpha: 0.10),
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Shop Details",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Lato',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    const Text(
                      "Shop Link",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        color: Color(0xFF673AB7),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(3),
                      child: Column(
                        children: [
                          referralText,
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: TextButton.icon(
                                  icon: const Icon(
                                    Icons.copy,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFF673AB7),
                                    padding: const EdgeInsets.all(4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    FlutterClipboard.copy(referralText.data!);
                                    Get.snackbar(
                                      "Link Copied",
                                      "Successful",
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(
                                          seconds: 1, milliseconds: 200),
                                      forwardAnimationCurve: Curves.decelerate,
                                      reverseAnimationCurve: Curves.easeOut,
                                      backgroundColor: const Color(0xFF673AB7)
                                          .withValues(alpha: 0.8),
                                      margin: EdgeInsets.only(
                                        left: 12,
                                        right: 12,
                                        bottom: screenHeight * 0.16,
                                      ),
                                    );
                                  },
                                  label: const Text(
                                    "Copy",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                flex: 1,
                                child: TextButton.icon(
                                  icon: const Icon(
                                    Icons.share,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFF673AB7),
                                    padding: const EdgeInsets.all(4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    share.share(
                                      ShareParams(
                                        text: message,
                                        title: "Hair Main Street Shop Link",
                                      ),
                                    );
                                  },
                                  label: const Text(
                                    "Share",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Shop Name",
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  color: Color(0xFF673AB7),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              InkWell(
                                child: SvgPicture.asset(
                                  "assets/Icons/edit.svg",
                                  colorFilter: ColorFilter.mode(
                                    AppColors.main,
                                    BlendMode.srcIn,
                                  ),
                                  height: 25,
                                  width: 25,
                                ),
                                onTap: () {
                                  showCancelDialog("Name", label: "name");
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            "${vendorController.vendor.value!.shopName}",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 12,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFf5f5f5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.transparent),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 1,
                      spreadRadius: 0,
                      color: const Color(0xFF673AB7).withValues(alpha: 0.10),
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Contact Info",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lato',
                              color: Color(0xFF673AB7),
                            ),
                          ),
                          InkWell(
                            child: SvgPicture.asset(
                              "assets/Icons/edit.svg",
                              colorFilter: ColorFilter.mode(
                                AppColors.main,
                                BlendMode.srcIn,
                              ),
                              height: 25,
                              width: 25,
                            ),
                            onTap: () {
                              showCancelDialog("Contact Info",
                                  label: "contact info");
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(3),
                      child: Text(
                        "${vendorController.vendor.value!.contactInfo!['street address']}\n${vendorController.vendor.value!.contactInfo!['local government']} LGA\n${vendorController.vendor.value!.contactInfo!['state']}\n${vendorController.vendor.value!.contactInfo!['country']}",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Phone number",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Lato",
                                  color: Color(0xFF673AB7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              InkWell(
                                child: SvgPicture.asset(
                                  "assets/Icons/edit.svg",
                                  colorFilter: ColorFilter.mode(
                                    AppColors.main,
                                    BlendMode.srcIn,
                                  ),
                                  height: 25,
                                  width: 25,
                                ),
                                onTap: () {
                                  showCancelDialog("Phone Number",
                                      label: "phone number");
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            "${vendorController.vendor.value?.contactInfo?['phone number']}",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFf5f5f5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.transparent),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 1,
                      spreadRadius: 0,
                      color: const Color(0xFF673AB7).withValues(alpha: 0.10),
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Account Info",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF673AB7),
                              fontFamily: "Lato",
                            ),
                          ),
                          InkWell(
                            child: SvgPicture.asset(
                              "assets/Icons/edit.svg",
                              colorFilter: ColorFilter.mode(
                                AppColors.main,
                                BlendMode.srcIn,
                              ),
                              width: 25,
                              height: 25,
                            ),
                            onTap: () {
                              showCancelDialog("Account Info",
                                  label: "account info");
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(3),
                      child: Text(
                        "${vendorController.vendor.value!.accountInfo!['account number']}\n${vendorController.vendor.value!.accountInfo!['account name']}\n${vendorController.vendor.value!.accountInfo!['bank name']}",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFf5f5f5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.transparent),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 1,
                      spreadRadius: 0,
                      color: const Color(0xFF673AB7).withValues(alpha: 0.10),
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Choose Installment Duration",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF673AB7),
                        fontFamily: "Lato",
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _controller,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Enter a number",
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Enter a Number";
                                } else if (!validator.isNumeric(value)) {
                                  return "Please Enter a Number";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        DropdownButton<String>(
                          value: _selectedUnit,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedUnit = newValue!;
                            });
                          },
                          items: ["Week(s)", "Month(s)", "Year(s)"]
                              .map((unit) => DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(unit),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // padding: EdgeInsets.symmetric(
                        //     horizontal: screenWidth * 0.24),
                        backgroundColor: const Color(0xFF673AB7),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        _validateAndSend();
                      },
                      child: const Text(
                        "Submit",
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // Form(
              //   key: formKey2,
              //   child: Column(
              //     //mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: [
              //       TextInputWidget(
              //         textInputType: TextInputType.number,
              //         controller: installmentController,
              //         labelText: "No of Installments:",
              //         hintText: "Enter a number between 1 to 10",
              //         onSubmit: (val) {
              //           installment = val;
              //           debugdebugPrint(installment);
              //         },
              //         validator: (val) {
              //           if (val!.isEmpty) {
              //             return "Please enter a number";
              //           }
              //           num newVal = int.parse(val);
              //           if (newVal > 10) {
              //             return "Must be less than or equal to 10";
              //           } else if (newVal <= 0) {
              //             return "Must be greater than 0";
              //           }
              //           return null;
              //         },
              //       ),
              //       SizedBox(
              //         height: screenHeight * .02,
              //       ),
              //       Row(
              //         children: [
              //           Expanded(
              //             child: TextButton(
              //               onPressed: () {
              //                 bool? validate = formKey2.currentState!.validate();
              //                 if (validate) {
              //                   formKey2.currentState!.save();
              //                   installment = installmentController.text;
              //                 }
              //               },
              //               style: TextButton.styleFrom(
              //                 // padding: EdgeInsets.symmetric(
              //                 //     horizontal: screenWidth * 0.24),
              //                 backgroundColor: Color(0xFF392F5A),
              //                 side:
              //                     const BorderSide(color: Colors.white, width: 2),

              //                 shape: RoundedRectangleBorder(
              //                   borderRadius: BorderRadius.circular(12),
              //                 ),
              //               ),
              //               child: const Text(
              //                 "Save",
              //                 textAlign: TextAlign.center,
              //                 style: TextStyle(color: Colors.white, fontSize: 20),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  void _validateAndSend() {
    final input = int.tryParse(_controller.text);
    if (input != null && input > 0) {
      int milliseconds = 0;
      switch (_selectedUnit) {
        case "Week(s)":
          milliseconds = input * 7 * 24 * 60 * 60 * 1000;
          break;
        case "Month(s)":
          milliseconds = input * 30 * 24 * 60 * 60 * 1000;
          break;
        case "Year(s)":
          milliseconds = input * 365 * 24 * 60 * 60 * 1000;
          break;
      }
      // Send milliseconds to the database
      vendorController.updateVendor("installment duration", milliseconds);
      debugPrint("Milliseconds: $milliseconds");
    } else {
      // Show error message or handle invalid input
      debugPrint("Invalid input");
    }
  }

  Widget buildPicker(String label, List<String> items, String? selectedValue,
      Function(String?) onChanged) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            elevation: 0,
            isExpanded: true,
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
    );
  }
}

class InventoryCard extends StatelessWidget {
  final String? imageUrl;
  final String productName;
  final int stock;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InventoryCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.stock,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8), // Add padding around the entire card
        child: Row(
          children: <Widget>[
            // Child 1: Product Image
            Container(
              width: 120,
              height: 130,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl ??
                      "https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Add spacing between the image and other content
            const SizedBox(width: 12),

            // Child 2: Product Name and Stock
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8), // Add vertical spacing

                  Text(
                    'In Stock: $stock',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Child 3: Edit and Delete Buttons
            Column(
              children: <Widget>[
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserReviewCard extends StatefulWidget {
  final int? index;

  const UserReviewCard({
    super.key,
    this.index,
  });

  @override
  State<UserReviewCard> createState() => _UserReviewCardState();
}

class _UserReviewCardState extends State<UserReviewCard> {
  ReviewController reviewController = Get.find<ReviewController>();
  UserController userController = Get.find<UserController>();
  bool isExpanded = false;
  GlobalKey<PopupMenuButtonState> popUpKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    Review review = reviewController.myReviews[widget.index!];
    String resolveTimestamp(Timestamp timestamp) {
      DateFormat formatter = DateFormat("MMM d yy");
      DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime

      // Add days to the DateTime
      //DateTime newDateTime = dateTime.add(Duration(days: daysToAdd));

      return formatter.format(dateTime);
    }

    // var screenWidth = Get.width;
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      onLongPress: () {
        setState(() {
          popUpKey.currentState!.showButtonMenu();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: Colors.black.withValues(alpha: 0.5), width: 0.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              spreadRadius: 0,
              color: const Color(0xFF673AB7).withValues(alpha: 0.20),
              offset: const Offset(0, 1),
            ),
          ],
        ),
        // Add some margin if needed (replace with desired values)
        //margin: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            userController.userState.value == null ||
                    userController.userState.value!.profilePhoto == null
                ? CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black12,
                    child: SvgPicture.asset(
                      "assets/Icons/user.svg",
                      colorFilter: ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                      height: 30,
                      width: 30,
                    ),
                  )
                : CircleAvatar(
                    radius: 30,
                    //backgroundColor: Colors.black,
                    backgroundImage: NetworkImage(
                      userController.userState.value!.profilePhoto!,
                      scale: 1,
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
                    Text(
                      "${review.displayName}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Lato",
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star_half_rounded,
                          color: Color.fromARGB(255, 161, 121, 230),
                        ),
                        Text(
                          "${review.stars}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: "Lato",
                          ),
                        ),
                      ],
                    ),
                    Text(
                      review.comment,
                      maxLines: isExpanded == false ? 1 : 5,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 63,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PopupMenuButton(
                    key: popUpKey,
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.black.withValues(alpha: 0.30),
                        width: 0.8,
                      ),
                    ),
                    position: PopupMenuPosition.under,
                    tooltip: "More Options",
                    padding: const EdgeInsets.all(4),
                    itemBuilder: (context) {
                      List options = ["Edit", "Delete"];
                      return List.generate(options.length, (index) {
                        return PopupMenuItem(
                          onTap: () {
                            if (options[index] == "Edit") {
                              Get.to(
                                () => EditReviewPage(
                                  productID: "${review.productID}",
                                  reviewID: "${review.reviewID}",
                                ),
                              );
                            } else if (options[index] == "Delete") {
                              showDeleteDialog(reviewController, review);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (options[index] == "Edit")
                                const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.black,
                                )
                              else if (options[index] == "Delete")
                                const Icon(
                                  Icons.delete,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              Text(
                                options[index],
                                style: const TextStyle(
                                  fontFamily: "Raleway",
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                    },
                    child: const Icon(
                      Icons.more_horiz_outlined,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    resolveTimestamp(review.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Raleway",
                      color: Colors.black.withValues(alpha: 0.50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteDialog(ReviewController reviewController, Review review) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Delete Review'),
        content:
            const Text('You are about to delete this review.\nAre you sure?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await reviewController.deleteReview(review.reviewID!);
              //Get.back();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatsCard extends StatefulWidget {
  final int? index;
  final String? nameToDisplay;
  final Vendors? vendorDetails;
  final MessagePageData? member1;
  final MessagePageData? member2;

  const ChatsCard({
    super.key,
    this.member1,
    this.member2,
    this.index,
    this.nameToDisplay,
    this.vendorDetails,
  });

  @override
  State<ChatsCard> createState() => _ChatsCardState();
}

class _ChatsCardState extends State<ChatsCard> {
  ChatController chatController = Get.find<ChatController>();
  UserController userController = Get.find<UserController>();

  MessagePageData? sender;
  MessagePageData? receiver;

  @override
  void initState() {
    var currentUserID = userController.userState.value!.uid!;
    if (currentUserID == widget.member2!.id) {
      sender = widget.member2!;
      receiver = widget.member1!;
    } else if (currentUserID == widget.member1!.id) {
      sender = widget.member1!;
      receiver = widget.member2!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Vendors? vendors = userController.vendorDetails.value;
    // DateTime resolveTimestampWithoutAdding(Timestamp timestamp) {
    //   final now = DateTime.now();
    //   final timestampDateTime = timestamp.toDate();

    //   // Calculate the difference in hours between the timestamp and now
    //   final hourDifference = now.difference(timestampDateTime).inHours;

    //   // If the difference is less than 24 hours, return only the time component
    //   if (hourDifference < 24) {
    //     return DateTime(
    //       0,
    //       0,
    //       0,
    //       timestampDateTime.hour,
    //       timestampDateTime.minute,
    //     );
    //   } else {
    //     // If the difference is 24 hours or more, return only the date component
    //     // without extra zeros for the time component
    //     return DateTime(
    //       timestampDateTime.year,
    //       timestampDateTime.month,
    //       timestampDateTime.day,
    //     );
    //   }
    // }

    //Review review = reviewController.myReviews[index!];
    // var screenWidth = Get.width;
    return InkWell(
      onTap: () => Get.to(
        () => MessagesPage(
          participant1: sender!.id,
          participant2: receiver!.id,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 0.3,
                      color: const Color(0xFF673AB7).withValues(alpha: 0.45),
                    ),
                  ),
                  child:
                      receiver!.imageUrl == null || receiver!.imageUrl!.isEmpty
                          ? CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFf5f5f5),
                              child: SvgPicture.asset(
                                "assets/Icons/user.svg",
                                colorFilter: ColorFilter.mode(
                                  Colors.black,
                                  BlendMode.srcIn,
                                ),
                                height: 24,
                                width: 24,
                              ),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                receiver!.imageUrl!,
                              ),
                            ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 20,
                            child: Text(
                              receiver!.name!,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Text(
                          //   resolveTimestampWithoutAdding(chatController
                          //           .myChats[widget.index!]!.recentMessageSentAt!)
                          //       .toString()
                          //       .split(" ")[0],
                          //   style: const TextStyle(
                          //     fontSize: 14,
                          //     fontWeight: FontWeight.w500,
                          //     color: Colors.black,
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        chatController
                                .myChats[widget.index!]!.recentMessageText ??
                            "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 2,
            thickness: 1,
            color: Colors.black.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}
