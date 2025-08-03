import 'package:contentsize_tabbarview/contentsize_tabbarview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/blank_page.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/controllers/vendor_controller.dart';
import 'package:hair_main_street/extras/delegate.dart';
import 'package:hair_main_street/pages/authentication/sign_in.dart';
import 'package:hair_main_street/services/database.dart';
import 'package:hair_main_street/utils/app_colors.dart';
import 'package:hair_main_street/widgets/cards.dart';
import 'package:hair_main_street/widgets/loading.dart';

import 'messages.dart';

class ClientShopPage extends StatefulWidget {
  final String? vendorID;
  const ClientShopPage({this.vendorID, super.key});

  @override
  State<ClientShopPage> createState() => _ClientShopPageState();
}

class _ClientShopPageState extends State<ClientShopPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  UserController userController = Get.find<UserController>();
  VendorController vendorController = Get.find<VendorController>();

  @override
  void initState() {
    var vendorID = widget.vendorID ?? Get.arguments['vendorID'];
    super.initState();
    vendorController.getVendorDetails(vendorID);
    vendorController.getVendorsProducts(vendorID);
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DataBaseService().getVendorDetails(userID: widget.vendorID),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingWidget();
        }
        return StreamBuilder(
          stream: DataBaseService().getVendorProducts(widget.vendorID!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: LoadingWidget()),
              );
            }

            vendorController.getProductsByAge(vendorController.productList);
            double storeRating = 0.0;

            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: CustomScrollView(
                  // physics: NeverScrollableScrollPhysics(),
                  slivers: [
                    _buildSliverAppBar(storeRating),
                    //  _buildSliverTabBar(),
                    _buildSliverTabBarView(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSliverAppBar(double storeRating) {
    double vendorInfoHeight = 210;
    double tabbarHeight = 51;
    return SliverAppBar(
      scrolledUnderElevation: 0,
      expandedHeight: vendorInfoHeight + tabbarHeight,
      collapsedHeight: kToolbarHeight,
      centerTitle: false,
      pinned: true,
      floating: false,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 24,
          color: AppColors.shade9,
        ),
      ),
      title: _buildSearchButton(),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: SizedBox(
            height: vendorInfoHeight, child: _buildVendorHeader(storeRating)),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(tabbarHeight),
        child: Container(
          color: Colors.transparent,
          height: tabbarHeight,
          child: TabBar(
            controller: tabController,
            labelPadding:
                const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: const Color(0xFF673AB7),
            indicatorWeight: 5,
            indicatorPadding: const EdgeInsets.only(top: 2),
            labelStyle: const TextStyle(
              fontSize: 17,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w500,
              color: Color(0xFF673AB7),
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 17,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            tabs: const [
              Text("All Products"),
              Text("New Arrivals"),
              Text("Shop Details"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 40, // Fixed height to prevent overflow
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              backgroundColor: const Color(0xFFF5F5F5),
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onPressed: () => showSearch(
              context: context,
              delegate: VendorProductSearchDelegate(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  "assets/Icons/search-normal-1.svg",
                  theme: SvgTheme(currentColor: Colors.black.withAlpha(128)),
                  height: 18,
                  width: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Search",
                    style: TextStyle(
                      color: Colors.black.withAlpha(128),
                      fontFamily: 'Raleway',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVendorHeader(double storeRating) {
    return Container(
      // color: Colors.amber,
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  _buildVendorAvatar(),
                  const SizedBox(width: 8.0),
                  Expanded(child: _buildVendorInfo()),
                  const SizedBox(width: 8),
                  _buildMessageButton(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          _buildStoreStats(storeRating),
        ],
      ),
    );
  }

  Widget _buildVendorAvatar() {
    return ClipOval(
      child: vendorController.vendor.value?.shopPicture != null &&
              vendorController.vendor.value!.shopPicture!.isNotEmpty
          ? Image.network(
              vendorController.vendor.value!.shopPicture!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildDefaultAvatar(),
            )
          : _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFF703535),
      height: 60,
      width: 60,
      child: SvgPicture.asset(
        "assets/Icons/user.svg",
        height: 30,
        width: 30,
        theme: SvgTheme(currentColor: Colors.white),
      ),
    );
  }

  Widget _buildVendorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          vendorController.vendor.value?.shopName ?? 'Unknown Shop',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lato',
          ),
        ),
      ],
    );
  }

  Widget _buildMessageButton() {
    return ElevatedButton(
      onPressed: _handleMessageButtonPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF673AB7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      ),
      child: const Text(
        'Message',
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  void _handleMessageButtonPress() {
    if (userController.userState.value == null) {
      Get.to(() => BlankPage(
            haveAppBar: true,
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            buttonStyle: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1.2, color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            pageIcon: const Icon(Icons.person_off_outlined, size: 48),
            text: "You are not Logged In",
            interactionText: "Sign In or Register",
            interactionIcon: const Icon(
              Icons.person_2_outlined,
              size: 24,
              color: Colors.white,
            ),
            interactionFunction: () => Get.to(() => const SignIn()),
          ));
    } else {
      Get.to(() => MessagesPage(
            participant1: userController.userState.value!.uid,
            participant2: vendorController.vendor.value!.userID,
          ));
    }
  }

  Widget _buildStoreStats(double storeRating) {
    return GestureDetector(
      onDoubleTap: () {
        debugPrint("registering");
        var val = vendorController.calculateOverallAverageReviewValue();
        debugPrint("Store Rating: $val");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF673AB7).withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  value: storeRating.toStringAsFixed(1),
                  label: "Store Rating",
                ),
              ),
              Container(
                width: 1.5,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatColumn(
                  value: "${vendorController.productList.length}",
                  label: "Products in Store",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn({required String value, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Widget _buildSliverTabBar() {
  //   return SliverPersistentHeader(
  //     pinned: true,
  //     floating: false,
  //     delegate: _SliverAppBarDelegate(
  //       TabBar(
  //         controller: tabController,
  //         labelPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
  //         isScrollable: true,
  //         tabAlignment: TabAlignment.start,
  //         indicatorColor: const Color(0xFF673AB7),
  //         indicatorWeight: 5,
  //         indicatorPadding: const EdgeInsets.only(top: 2),
  //         labelStyle: const TextStyle(
  //           fontSize: 17,
  //           fontFamily: 'Raleway',
  //           fontWeight: FontWeight.w500,
  //           color: Color(0xFF673AB7),
  //         ),
  //         unselectedLabelStyle: const TextStyle(
  //           fontSize: 17,
  //           fontFamily: 'Raleway',
  //           fontWeight: FontWeight.w500,
  //           color: Colors.black,
  //         ),
  //         tabs: const [
  //           Text("All Products"),
  //           Text("New Arrivals"),
  //           Text("Shop Details"),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSliverTabBarView() {
    return SliverToBoxAdapter(
      child: ContentSizeTabBarView(
        controller: tabController,
        children: [
          _buildAllProductsTab(),
          _buildNewArrivalsTab(),
          _buildShopDetailsTab(),
        ],
      ),
    );
  }

  Widget _buildAllProductsTab() {
    if (vendorController.productList.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return MasonryGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 8,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          shrinkWrap: true,
          itemCount: vendorController.productList.length,
          itemBuilder: (_, index) => ClientShopCard(index: index),
        );
      },
    );
  }

  Widget _buildNewArrivalsTab() {
    if (vendorController.filteredVendorProductList.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vendorController.filteredVendorProductList.length,
      itemBuilder: (context, index) {
        final entry =
            vendorController.filteredVendorProductList.entries.elementAt(index);

        if (entry.value.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            ...entry.value.map((product) => VendorArrivalCard(
                  productID: product.productID,
                )),
          ],
        );
      },
    );
  }

  Widget _buildShopDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(
            title: "Shop Name",
            content: vendorController.vendor.value?.shopName ?? 'N/A',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: "Shop Address",
            content: _buildAddressString(),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: "Phone Number",
            content: vendorController.vendor.value?.contactInfo?['phone number']
                    ?.toString() ??
                'N/A',
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _buildAddressString() {
    final contactInfo = vendorController.vendor.value?.contactInfo;
    if (contactInfo == null) return 'N/A';

    return [
      contactInfo['street address'],
      '${contactInfo['local government']} LGA',
      contactInfo['state'],
      contactInfo['country'],
    ].where((item) => item != null && item.toString().isNotEmpty).join('\n');
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Card(
      elevation: 0,
      color: const Color(0xFF673AB7).withValues(alpha: 0.20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: "Raleway",
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              content,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: "Lato",
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              minLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.do_not_disturb, size: 50, color: Colors.black),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "No Products to display yet",
              style: TextStyle(
                fontSize: 24,
                fontFamily: "Lato",
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   _SliverAppBarDelegate(this._tabBar);

//   final TabBar _tabBar;

//   @override
//   double get minExtent => _tabBar.preferredSize.height;

//   @override
//   double get maxExtent => _tabBar.preferredSize.height;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: Colors.white,
//       child: PreferredSize(
//         preferredSize: _tabBar.preferredSize,
//         child: _tabBar,
//       ),
//     );
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }
