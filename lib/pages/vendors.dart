import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/product_controller.dart';
import 'package:hair_main_street/pages/client_shop_page.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:recase/recase.dart';

class VendorsPage extends StatelessWidget {
  const VendorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    ProductController productController = Get.find<ProductController>();
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        // leading: IconButton(
        //   onPressed: () => Get.back(),
        //   icon: const Icon(
        //       Symbols.arrow_back_ios_new_rounded,
        //       size: 24,
        //       color: Colors.black),
        // ),
        title: const SafeArea(
          child: Text(
            'Vendors',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // shrinkWrap: true,
            children: [
              const Text(
                "Featured Vendors",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lato',
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Obx(
                () => SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  child: CarouselView(
                    onTap: (index) {
                      Get.to(
                        () => ClientShopPage(
                          vendorID:
                              productController.vendorsList[index]!.userID,
                        ),
                        transition: Transition.fadeIn,
                      );
                    },
                    shrinkExtent: 150,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    itemExtent: 300,
                    children: List.generate(
                      productController.vendorsList.length,
                      (index) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: CachedNetworkImage(
                              height: 200,
                              width: 300,
                              fit: BoxFit.cover,
                              imageUrl: productController.vendorsList[index]
                                          ?.shopPicture?.isNotEmpty ==
                                      true
                                  ? productController
                                      .vendorsList[index]!.shopPicture!
                                  : 'https://firebasestorage.googleapis.com/v0/b/hairmainstreet.appspot.com/o/productImage%2FImage%20Not%20Available.jpg?alt=media&token=0104c2d8-35d3-4e4f-a1fc-d5244abfeb3f',
                              errorWidget: ((context, url, error) =>
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Failed to Load Image"),
                                  )),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
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
                                    height: 200,
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              width: 300,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(
                                    12,
                                  ),
                                  bottomRight: Radius.circular(
                                    12,
                                  ),
                                ),
                                color: const Color.fromARGB(255, 207, 188, 238)
                                    .withValues(alpha: 0.90),
                              ),
                              child: Center(
                                child: SelectableText(
                                  productController
                                      .vendorsList[index]!.shopName!.titleCase,
                                  maxLines: 2,
                                  minLines: 1,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w600,
                                  ),
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
              const SizedBox(
                height: 4,
              ),
              const Text(
                "Vendors",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lato',
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Obx(
                () => MasonryGridView.count(
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 8,
                  crossAxisCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shrinkWrap: true,
                  itemCount: productController.vendorsList.length,
                  itemBuilder: (context, index) => VendorHighlightsCard(
                    index: index,
                    // id: productController
                    //     .products.value[index]!.productID,
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
