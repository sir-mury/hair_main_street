import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/blank_page.dart';
import 'package:hair_main_street/controllers/cart_controller.dart';
import 'package:hair_main_street/controllers/order_checkout_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/cart_item_model.dart';
import 'package:hair_main_street/models/product_model.dart';
import 'package:hair_main_street/models/review.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/pages/authentication/sign_in.dart';
import 'package:hair_main_street/pages/chats_page.dart';
import 'package:hair_main_street/pages/client_shop_page.dart';
import 'package:hair_main_street/pages/menu/profile.dart';
import 'package:hair_main_street/pages/menu/wishlist.dart';
import 'package:hair_main_street/pages/messages.dart';
import 'package:hair_main_street/pages/orders_stuff/installment_checkout.dart';
import 'package:hair_main_street/pages/orders_stuff/once_checkout.dart';
import 'package:hair_main_street/pages/review_page.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:hair_main_street/widgets/loading.dart';
// import 'package:like_button/like_button.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:recase/recase.dart';
import 'package:share_plus/share_plus.dart';

class ProductPage extends StatefulWidget {
  final String? id;
  //final int? index;
  const ProductPage({this.id, super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  ProductController productController = Get.find<ProductController>();
  //VendorController vendorController = Get.find<VendorController>();
  UserController userController = Get.find<UserController>();
  CartController cartController = Get.find<CartController>();
  WishListController wishListController = Get.find<WishListController>();
  CheckOutController checkOutController = Get.put(CheckOutController());

  bool? isVisible = false;
  num? quantity;
  String? productID;
  List<bool>? lengthToggleSelection = [false];
  List<bool>? colourToggleSelection = [false];
  List<bool>? optionToggleSelection = [false];
  Product? product;
  ProductOption? selectedOptionHere;
  SharePlus share = SharePlus.instance;

  //function to determine number of products to show in the see also panel
  int numberOfProductsToShow(int length) {
    return length > 6 ? 6 : length;
  }

  // function to filter the list of products to show in the see also panel and then show them
  List<Product?> getSeeAlsoProducts(List<Product?> products) {
    // debugPrint("running this see also product function");
    return products
        .where((product) => product!.productID != widget.id)
        .toList();
  }

  void onOptionSelected(ProductOption selectedOption) {
    setState(() {
      selectedOptionHere = selectedOption;
      productController.isOptionVisible.value = true;
      debugPrint('Selected option: ${selectedOption.price}');
    });
  }

  @override
  void initState() {
    super.initState();
    productID = widget.id;
    productController.getReviews(productID);
    product = productController.getSingleProduct(productID!);
    //productController.selectedProductOption.value = product!.options![0];

    if (product!.hasOptions == true &&
        product!.options != null &&
        product!.options!.isNotEmpty) {
      optionToggleSelection =
          List.filled(product!.options!.length, false, growable: true);
      debugPrint(optionToggleSelection!.length.toString());
      // var totalLength = 0;
      // var totalColour = 0;
      // for (var option in product!.options!) {
      //   if (option.length != null) {
      //     totalLength += 1;
      //   } else if (option.color != null) {
      //     totalColour += 1;
      //   }
      // }
      // lengthToggleSelection = List.filled(totalLength, false);
      // colourToggleSelection = List.filled(totalColour, false);
    }
  }

  determineIfProductExist(Product product) {
    WidgetsBinding.instance.scheduleFrameCallback((_) {
      productController.determineIfProductExist(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    //productController.getReviews(widget.id!);
    productController.seeAlsoProducts.value = getSeeAlsoProducts(
        productController.productMap[product!.category ?? "All"] ?? []);

    showPaymentDialog() {
      return Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          alignment: Alignment.center,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(8),
          elevation: 0,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    radius: 40,
                    onTap: () {
                      Get.back();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.clear,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 2,
              ),
              const Text(
                "How would you like to pay?",
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                "You can decide to make payments in installments or pay at once",
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
              const Divider(
                height: 12,
                color: Colors.grey,
                thickness: 1,
              ),
              InkWell(
                child: const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Text(
                      "Pay in Installments",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  if (userController.userState.value == null) {
                    Get.close(1);
                    Get.to(() => BlankPage(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          buttonStyle: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7),
                            shape: RoundedRectangleBorder(
                              // side: const BorderSide(
                              //   width: 1.2,
                              //   color: Colors.black,
                              // ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          pageIcon: const Icon(
                            Icons.person_off_outlined,
                            size: 48,
                          ),
                          text: "Your are not Logged In",
                          interactionText: "Sign In or Register",
                          interactionIcon: const Icon(
                            Icons.person_2_outlined,
                            size: 24,
                            color: Colors.white,
                          ),
                          interactionFunction: () =>
                              Get.to(() => const SignIn()),
                        ));
                  } else if (product!.hasOptions == true) {
                    var val = checkOutController.createCheckBoxItem(
                      product!.productID,
                      productController.quantity.value,
                      (selectedOptionHere?.price!)! *
                          (productController.quantity.value),
                      userController.userState.value!,
                      optionName:
                          "${selectedOptionHere!.length}\n${selectedOptionHere!.color}",
                    );
                    Get.close(1);
                    Get.to(
                      () => InstallmentCheckoutPage(
                        products: [val],
                      ),
                    );
                  } else {
                    var val = checkOutController.createCheckBoxItem(
                        product!.productID,
                        productController.quantity.value,
                        (product!.price! as num) *
                            (productController.quantity.value),
                        userController.userState.value!);
                    Get.close(1);
                    Get.to(
                      () => InstallmentCheckoutPage(
                        products: [val],
                      ),
                    );
                  }

                  debugPrint(
                      checkOutController.checkOutItem.value.address.toString());
                },
              ),
              const Divider(
                height: 4,
                color: Colors.grey,
                thickness: 1,
              ),
              InkWell(
                onTap: () {
                  if (userController.userState.value == null) {
                    Get.close(1);
                    Get.to(() => BlankPage(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          buttonStyle: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7),
                            shape: RoundedRectangleBorder(
                              // side: const BorderSide(
                              //   width: 1.2,
                              //   color: Colors.black,
                              // ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          pageIcon: const Icon(
                            Icons.person_off_outlined,
                            size: 48,
                          ),
                          text: "Your are not Logged In",
                          interactionText: "Sign In or Register",
                          interactionIcon: const Icon(
                            Icons.person_2_outlined,
                            size: 24,
                            color: Colors.white,
                          ),
                          interactionFunction: () =>
                              Get.to(() => const SignIn()),
                        ));
                  } else if (product!.hasOptions == true) {
                    var val = checkOutController.createCheckBoxItem(
                      product!.productID,
                      productController.quantity.value,
                      (selectedOptionHere?.price!)! *
                          (productController.quantity.value),
                      userController.userState.value!,
                      optionName:
                          "${selectedOptionHere!.length}\n${selectedOptionHere!.color}",
                    );
                    Get.close(1);
                    Get.to(() => OnceCheckoutPage(
                          products: [val],
                        ));
                  } else {
                    var val = checkOutController.createCheckBoxItem(
                      product!.productID,
                      productController.quantity.value,
                      (product!.price! as num) *
                          (productController.quantity.value),
                      userController.userState.value!,
                    );
                    Get.close(1);
                    Get.to(
                      () => OnceCheckoutPage(
                        products: [val],
                      ),
                    );
                  }
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Text(
                      "Pay Once",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              // const SizedBox(
              //   width: 4,
              // ),
            ],
          ),
        ),
      );
    }

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

    averageRating() {
      double sum = 0;
      for (var review in productController.reviews) {
        sum += review!.stars;
      }
      double average = sum / productController.reviews.length;
      //debugPrint(average);
      return average;
    }

    String generateProductLink(String productID, String productName) {
      // Replace 'your_domain.com' with your actual domain
      final formattedName = productName.toLowerCase().replaceAll(' ', '_');
      return 'https://app.hairmainstreet.com/products/$productID/$formattedName';
    }

    showSpecificationBottomSheet() {
      Get.bottomSheet(
        ignoreSafeArea: true,
        backgroundColor: Colors.white,
        enableDrag: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
          ),
        ),
        SafeArea(
          child: Card(
            elevation: 0,
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20)),
                      height: 5,
                      width: 30,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                    ),
                  ),
                  const Text(
                    'Specifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lato',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(
                    product!.specifications?.length ?? 1,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product!.specifications?[index].title!.titleCase ??
                                "Title",
                            style: TextStyle(
                              fontSize: 15.5,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withValues(alpha: 0.75),
                            ),
                          ),
                          Text(
                            product!.specifications?[index].specification!
                                    .titleCase ??
                                "Value",
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 2,
                    thickness: 0.5,
                    color: Colors.black.withValues(
                      alpha: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // num screenHeight = MediaQuery.of(context).size.height;
    num screenWidth = MediaQuery.of(context).size.width;
    num pictureHeight = 390;

    CarouselSliderController carouselController = CarouselSliderController();
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, result) async {
        if (didPop) {
          productController.isOptionVisible.value = false;
          productController.quantity.value = 1;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Symbols.arrow_back_ios_new_rounded,
                size: 24, color: Colors.black),
          ),

          actions: [
            IconButton(
              tooltip: "Share",
              onPressed: () {
                var productLink =
                    generateProductLink(productID!, product!.name!);
                String message =
                    "Hey, I am shopping on Hair Main Street\nCheck out this cool product with the link below\n$productLink";
                share.share(ShareParams(
                  title: "Product Listing",
                  text: message,
                ));
              },
              icon: const Icon(
                Symbols.share,
                size: 24,
                color: Colors.black,
              ),
            ),
            PopupMenuButton<String>(
              color: Colors.white.withValues(alpha: 0.80),
              tooltip: "More Option",
              position: PopupMenuPosition.under,
              icon: const Icon(
                Icons.more_vert,
                size: 24,
                color: Colors.black,
              ), // Three dots icon
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'wishlist',
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 18,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        'Wishlist',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Raleway',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'chats',
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/Icons/chat.svg',
                        height: 18,
                        width: 18,
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        'Chats',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Raleway',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/Icons/user.svg',
                        height: 18,
                        width: 18,
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Raleway',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (String value) async {
                switch (value) {
                  case 'wishlist':
                    // Handle 'Wishlist' option
                    if (userController.userState.value == null) {
                      Get.to(() => BlankPage(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            buttonStyle: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1.2,
                                  color: Color(0xFF673AB7),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            pageIcon: const Icon(
                              Icons.person_off_outlined,
                              size: 48,
                            ),
                            text: "Your are not Logged In",
                            interactionText: "Sign In or Register",
                            interactionIcon: const Icon(
                              Icons.person_2_outlined,
                              size: 24,
                              color: Colors.white,
                            ),
                            interactionFunction: () =>
                                Get.to(() => const SignIn()),
                          ));
                    } else {
                      // var wishlistItem = WishlistItem(productID: productID);
                      // await wishListController.addToWishlist(wishlistItem);
                      Get.to(() => const WishListPage());
                    }
                    break;
                  case 'chats':
                    // Handle 'chats' option
                    if (userController.userState.value == null) {
                      Get.to(() => BlankPage(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            buttonStyle: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1.2,
                                  color: Color(0xFF673AB7),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            pageIcon: const Icon(
                              Icons.person_off_outlined,
                              size: 48,
                            ),
                            text: "Your are not Logged In",
                            interactionText: "Sign In or Register",
                            interactionIcon: const Icon(
                              Icons.person_2_outlined,
                              size: 24,
                              color: Colors.white,
                            ),
                            interactionFunction: () =>
                                Get.to(() => const SignIn()),
                          ));
                    } else {
                      // var wishlistItem = WishlistItem(productID: productID);
                      // await wishListController.addToWishlist(wishlistItem);
                      Get.to(() => const ChatPage());
                    }
                    break;
                  case 'profile':
                    // Handle 'profile' option
                    if (userController.userState.value == null) {
                      Get.to(() => BlankPage(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            buttonStyle: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1.2,
                                  color: Color(0xFF673AB7),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            pageIcon: const Icon(
                              Icons.person_off_outlined,
                              size: 48,
                            ),
                            text: "Your are not Logged In",
                            interactionText: "Sign In or Register",
                            interactionIcon: const Icon(
                              Icons.person_2_outlined,
                              size: 24,
                              color: Colors.white,
                            ),
                            interactionFunction: () =>
                                Get.to(() => const SignIn()),
                          ));
                    } else {
                      // var wishlistItem = WishlistItem(productID: productID);
                      // await wishListController.addToWishlist(wishlistItem);
                      Get.to(() => ProfilePage());
                    }
                    break;
                }
              },
            ),
          ],
          //backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: StreamBuilder(
              stream: DataBaseService().getReviews(productID!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //debugPrint("hello");
                  return SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildImageSection(productID!, product!, isUserLoggedIn,
                            pictureHeight, carouselController),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "${product!.name}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "NGN${formatCurrency(product!.price.toString())}",
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF673AB7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Text(
                              "(Price per unit)",
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Visibility(
                          visible: product!.description!.isEmpty != true,
                          child: Text(
                            "${product!.description}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Raleway',
                              color: Colors.black,
                            ),
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        // ...existing code...
                        // Place optionsWidget() as a method call, not as a widget in a list
                        optionsWidget(),

                        const SizedBox(
                          height: 8,
                        ),
                        GetX<ProductController>(
                          builder: (controller) {
                            determineIfProductExist(product!);
                            if (controller.stockRemaining.value == 0) {
                              return Text(
                                "Out of stock".titleCase,
                                style: TextStyle(
                                  color: AppColors.cancelled,
                                  fontSize: 16,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  //backgroundColor: Colors.blue,
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Quantity",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      radius: 17,
                                      onTap: () async {
                                        productController.decreaseQuantity();
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
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Text(
                                      "${productController.quantity}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
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
                                        if (product!.hasOptions! &&
                                            selectedOptionHere == null) {
                                          productController.showMyToast(
                                              "Please select an option first");
                                        } else if (product!.hasOptions! &&
                                            selectedOptionHere != null) {
                                          productController.increaseQuantity(
                                            selectedOption: selectedOptionHere,
                                            product: product!,
                                          );
                                        } else {
                                          productController.increaseQuantity(
                                            product: product!,
                                            selectedOption: null,
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
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "${product!.quantity}pcs left in stock",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        const Divider(
                          height: 4,
                          thickness: 1.5,
                        ),
                        GestureDetector(
                          onTap: () {
                            showSpecificationBottomSheet();
                          },
                          child: Container(
                            color: Colors.transparent,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: const Row(
                              children: [
                                Text(
                                  "Specifications",
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const Divider(
                          thickness: 2.5,
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                                color: Colors.transparent,
                                width: screenWidth * 0.60,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/Icons/shop.svg',
                                          colorFilter: ColorFilter.mode(
                                            Colors.black,
                                            BlendMode.srcIn,
                                          ),
                                          height: 18,
                                          width: 18,
                                        ),
                                        const Text(
                                          "Store",
                                          style: TextStyle(
                                            color: Color(0xFF673AB7),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Flexible(
                                      child: Text(
                                        "${productController.clientGetVendorName(product!.vendorId).shopName}",
                                        style: const TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: 19,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF673AB7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.30,
                              child: TextButton(
                                onPressed: () {
                                  if (userController.userState.value == null) {
                                    Get.to(() => BlankPage(
                                          haveAppBar: true,
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                          buttonStyle: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF673AB7),
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                width: 1.2,
                                                color: Colors.black,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          pageIcon: const Icon(
                                            Icons.person_off_outlined,
                                            size: 48,
                                          ),
                                          text: "Your are not Logged In",
                                          interactionText:
                                              "Sign In or Register",
                                          interactionIcon: const Icon(
                                            Icons.person_2_outlined,
                                            size: 24,
                                            color: Colors.white,
                                          ),
                                          interactionFunction: () =>
                                              Get.to(() => const SignIn()),
                                        ));
                                  } else {
                                    Get.to(
                                      () => MessagesPage(
                                        participant1:
                                            userController.userState.value!.uid,
                                        participant2: product!.vendorId,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF673AB7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 18),
                                ),
                                child: const Text(
                                  "Message",
                                  style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          thickness: 1.5,
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Reviews(${productController.reviews.length})",
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            // SizedBox(
                            //   width: screenWidth * 0.32,
                            // ),
                            // SizedBox(
                            //   width: 4,
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: List.generate(
                                    productController.reviews.isNotEmpty
                                        ? averageRating().round()
                                        : 1,
                                    (index) => const Icon(
                                      Icons.star,
                                      size: 22,
                                      color: Color(0xFF673AB7),
                                    ),
                                  ),
                                ),
                                Text(
                                  productController.reviews.isNotEmpty
                                      ? "${averageRating()}"
                                      : "0",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Lato',
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // SizedBox(
                                //   width: 8,
                                // ),
                                Visibility(
                                  visible: productController.reviews.isNotEmpty,
                                  child: IconButton(
                                    onPressed: () {
                                      Get.to(() => ReviewPage(productController
                                          .reviews
                                          .cast<Review>()));
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Visibility(
                          visible: productController.reviews.isNotEmpty,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                productController.reviews.length,
                                (index) => ReviewCard(
                                  index: index,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          "See Also",
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Divider(
                          height: 1.5,
                          thickness: 1.5,
                          color: Colors.black.withValues(alpha: 0.50),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ...List.generate(
                                  numberOfProductsToShow(
                                    productController.seeAlsoProducts.length,
                                  ), (index) {
                                return SeeAlsoCard(
                                  index: index,
                                );
                              }),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                } else {
                  return const LoadingWidget();
                }
              }),
        ),
        bottomNavigationBar: SafeArea(
          child: BottomAppBar(
            height: kToolbarHeight * 1.5,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            elevation: 0,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      width: 2,
                      color: const Color(0xFF673AB7).withValues(alpha: 0.30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Total Price:",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      GetX<ProductController>(
                        builder: (controller) {
                          return product!.hasOptions == true
                              ? Text(
                                  "NGN ${formatCurrency(selectedOptionHere != null ? ((selectedOptionHere!.price!) * (productController.quantity.value)).toString() : (controller.quantity.value * 0).toString())}",
                                  style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF673AB7),
                                  ),
                                )
                              : Text(
                                  "NGN ${formatCurrency(((product!.price!) * (productController.quantity.value)).toString())}",
                                  style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF673AB7),
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.47,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          // padding: EdgeInsets.symmetric(
                          //     vertical: 8, horizontal: screenWidth * 0.26),
                          //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1.5,
                              color: Color(0xFF673AB7),
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: () {
                          handleAddToCart();
                        },
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(
                    //   width: 4,
                    // ),
                    SizedBox(
                      width: screenWidth * 0.47,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF673AB7),
                          // padding: EdgeInsets.symmetric(
                          //   vertical: 8,
                          //   horizontal: screenWidth * 0.26,
                          // ),
                          //maximumSize: Size(screenWidth * 0.70, screenHeight * 0.10),
                          shape: const RoundedRectangleBorder(
                            // side: BorderSide(
                            //   width: 0.5,
                            //   color: Colors.white,
                            // ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: () {
                          handlePayment(isUserLoggedIn, showPaymentDialog);
                        },
                        child: const Text(
                          "Buy",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        extendBody: true,
      ),
    );
  }

  Widget optionsWidget() {
    return Visibility(
      visible: product!.hasOptions! == true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFFF5F5F5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Options",
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ToggleButtons(
                borderWidth: 1.5,
                isSelected: optionToggleSelection!,
                selectedBorderColor: Colors.black,
                fillColor: Colors.white,
                onPressed: (index) {
                  for (int i = 0; i < optionToggleSelection!.length; i++) {
                    setState(() {
                      optionToggleSelection![i] = i == index;
                    });
                  }
                  selectedOptionHere = product!.options![index];
                },
                children: List.generate(
                  optionToggleSelection?.length ?? 1,
                  (index) => TogglesProductPage(
                    length: product!.options?[index].length ?? "",
                    color: product!.options?[index].color ?? "",
                    price: product!.options?[index].price ?? 0,
                    stockAvailable:
                        product!.options?[index].stockAvailable ?? 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handlePayment(
      bool isUserLoggedIn, Future<dynamic> Function() showPaymentDialog) {
    if (!isUserLoggedIn) {
      productController.showMyToast("Kindly login to buy items");
    } else {
      if (productController.stockRemaining.value == 0) {
        productController.showMyToast("Out of Stock");
      } else {
        if (isUserLoggedIn &&
            userController.userState.value!.uid == product!.vendorId) {
          productController
              .showMyToast("Cannot place order for your own products");
        } else {
          if (product!.hasOptions! && selectedOptionHere == null) {
            productController
                .showMyToast("Please Select a product Option First");
          } else if (selectedOptionHere != null &&
              selectedOptionHere!.stockAvailable == 0) {
            productController
                .showMyToast("Option out of stock, Select Another");
          } else {
            showPaymentDialog();
          }
        }
      }
    }
  }

  void handleAddToCart() {
    if (userController.userState.value == null) {
      Get.to(() => BlankPage(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            buttonStyle: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              shape: RoundedRectangleBorder(
                // side: const BorderSide(
                //   width: 1.2,
                //   color: Colors.black,
                // ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            pageIcon: const Icon(
              Icons.person_off_outlined,
              size: 48,
            ),
            text: "Your are not Logged In",
            interactionText: "Sign In or Register",
            interactionIcon: const Icon(
              Icons.person_2_outlined,
              size: 24,
              color: Colors.white,
            ),
            interactionFunction: () => Get.to(() => const SignIn()),
          ));
    } else {
      if (productController.stockRemaining.value == 0) {
        productController.showMyToast("Out of Stock");
      } else {
        if (product!.hasOptions == false) {
          if (userController.userState.value!.uid == product!.vendorId) {
            productController
                .showMyToast("Cannot add your own product to cart");
          } else {
            cartController.addToCart(
              CartItem(
                price: product!.price! * (productController.quantity.value),
                quantity: productController.quantity.value,
                productID: product!.productID,
              ),
            );
          }
        } else {
          if (selectedOptionHere == null) {
            productController
                .showMyToast("Please Select a product Option First");
          } else if (selectedOptionHere != null &&
              selectedOptionHere!.stockAvailable == 0) {
            productController
                .showMyToast("Option out of stock, Select Another");
          } else if (userController.userState.value!.uid == product!.vendorId) {
            productController
                .showMyToast("Cannot add your own product to cart");
          } else {
            cartController.addToCart(
              CartItem(
                price: (selectedOptionHere?.price!)! *
                    (productController.quantity.value),
                quantity: productController.quantity.value,
                productID: product!.productID,
                optionName:
                    "${selectedOptionHere!.length}\n${selectedOptionHere!.color}",
              ),
            );
          }
        }
      }
    }
  }

  Widget buildImageSection(
    String productID,
    Product product,
    bool isUserLoggedIn,
    num pictureHeight,
    CarouselSliderController carouselController,
  ) {
    if (product.image == null || product.image!.isEmpty) {
      return Stack(
        children: [
          CachedNetworkImage(
            fit: BoxFit.fill,
            imageBuilder: (context, imageProvider) => Container(
              width: double.infinity,
              height: pictureHeight.toDouble(),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            imageUrl:
                'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
            errorWidget: ((context, url, error) =>
                const Text("Failed to Load Image")),
            placeholder: ((context, url) => const Center(
                  child: CircularProgressIndicator(),
                )),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              width: 40,
              height: 32,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  width: 0.8,
                  color: const Color(0xFF673AB7),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: GetX<WishListController>(
                  builder: (controller) {
                    RxBool isLiked = false.obs;
                    isLiked.value = controller.isProductInWishlist(
                        productID, isUserLoggedIn);

                    return GestureDetector(
                      onDoubleTap: () async {
                        //to add a product to wishlist
                        //cannot work if user is not logged in
                        if (!isUserLoggedIn) {
                          userController
                              .showMyToast("Log in to add to wishlist");
                        } else {
                          if (userController.userState.value!.uid ==
                              product.vendorId) {
                            wishListController.showMyToast(
                                "Cannot add your own product to wishlist");
                          } else {
                            if (isLiked.value) {
                              userController
                                  .showMyToast("Already in your wishlists");
                            } else {
                              WishlistItem wishlistItem =
                                  WishlistItem(wishListItemID: productID);
                              await controller.addToWishlist(wishlistItem);
                              controller.isProductInWishlist(
                                productID,
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
                                .removeFromWishlistWithProductID(productID);
                            wishListController.isProductInWishlist(
                                productID, isUserLoggedIn);
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
                              size: 22,
                            )
                          : Icon(
                              Icons.favorite_border_rounded,
                              color: AppColors.main,
                              size: 22,
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    } else if (product.image!.length == 1) {
      return Stack(
        children: [
          CachedNetworkImage(
            fit: BoxFit.fill,
            imageBuilder: (context, imageProvider) => Container(
              width: double.infinity,
              height: pictureHeight.toDouble(),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            imageUrl: product.image!.first,
            errorWidget: ((context, url, error) =>
                const Text("Failed to Load Image")),
            placeholder: ((context, url) => const Center(
                  child: CircularProgressIndicator(),
                )),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 40,
              height: 30,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  "1/${product.image!.length}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Raleway',
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              width: 40,
              height: 32,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  width: 0.8,
                  color: const Color(0xFF673AB7),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: GetX<WishListController>(
                  builder: (controller) {
                    RxBool isLiked = false.obs;
                    isLiked.value = controller.isProductInWishlist(
                        productID, isUserLoggedIn);

                    return GestureDetector(
                      onDoubleTap: () async {
                        //to add a product to wishlist
                        //cannot work if user is not logged in
                        if (!isUserLoggedIn) {
                          userController
                              .showMyToast("Log in to add to wishlist");
                        } else {
                          if (userController.userState.value!.uid ==
                              product.vendorId) {
                            wishListController.showMyToast(
                                "Cannot add your own product to wishlist");
                          } else {
                            if (isLiked.value) {
                              userController
                                  .showMyToast("Already in your wishlists");
                            } else {
                              WishlistItem wishlistItem =
                                  WishlistItem(wishListItemID: productID);
                              await controller.addToWishlist(wishlistItem);
                              controller.isProductInWishlist(
                                productID,
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
                                .removeFromWishlistWithProductID(productID);
                            wishListController.isProductInWishlist(
                                productID, isUserLoggedIn);
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
                              size: 22,
                            )
                          : Icon(
                              Icons.favorite_border_rounded,
                              color: AppColors.main,
                              size: 22,
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          CarouselSlider(
            items: List.generate(
              product.image!.length,
              (index) => Stack(
                children: [
                  CachedNetworkImage(
                    imageBuilder: (context, imageProvider) => Container(
                      width: double.infinity,
                      height: pictureHeight.toDouble(),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    fit: BoxFit.fill,
                    imageUrl: "${product.image![index]}",
                    errorWidget: ((context, url, error) =>
                        const Text("Failed to Load Image")),
                    placeholder: ((context, url) =>
                        const Center(child: CircularProgressIndicator())),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 40,
                      height: 30,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}/${product.image!.length}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Raleway',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            carouselController: carouselController,
            options: CarouselOptions(
              enlargeFactor: 0.08,
              height: pictureHeight.toDouble(),
              autoPlay: true,
              pauseAutoPlayOnManualNavigate: true,
              enlargeCenterPage: true,
              viewportFraction: 0.95,
              autoPlayInterval: const Duration(milliseconds: 1900),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              width: 40,
              height: 32,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  width: 0.8,
                  color: const Color(0xFF673AB7),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: GetX<WishListController>(
                  builder: (controller) {
                    RxBool isLiked = false.obs;
                    isLiked.value = controller.isProductInWishlist(
                        productID, isUserLoggedIn);

                    return GestureDetector(
                      onDoubleTap: () async {
                        //to add a product to wishlist
                        //cannot work if user is not logged in
                        if (!isUserLoggedIn) {
                          userController
                              .showMyToast("Log in to add to wishlist");
                        } else {
                          if (userController.userState.value!.uid ==
                              product.vendorId) {
                            wishListController.showMyToast(
                                "Cannot add your own product to wishlist");
                          } else {
                            if (isLiked.value) {
                              userController
                                  .showMyToast("Already in your wishlists");
                            } else {
                              WishlistItem wishlistItem =
                                  WishlistItem(wishListItemID: productID);
                              await controller.addToWishlist(wishlistItem);
                              controller.isProductInWishlist(
                                productID,
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
                                .removeFromWishlistWithProductID(productID);
                            wishListController.isProductInWishlist(
                                productID, isUserLoggedIn);
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
                              size: 22,
                            )
                          : Icon(
                              Icons.favorite_border_rounded,
                              color: AppColors.main,
                              size: 22,
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}

class TogglesProductPage extends StatelessWidget {
  final String? length;
  final String? color;
  final num? price;
  final int? stockAvailable;
  const TogglesProductPage({
    this.length,
    this.color,
    this.price,
    this.stockAvailable,
    super.key,
  });

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

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$length",
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
            "$color",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'Raleway',
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(
            thickness: 2,
            color: Colors.green,
            height: 4,
          ),
          Text(
            "NGN${formatCurrency(price.toString())}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF673AB7),
              fontFamily: 'Raleway',
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(
            thickness: 1.5,
            color: Colors.transparent,
            height: 4,
          ),
          Text(
            "$stockAvailable available",
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
    );
  }
}
