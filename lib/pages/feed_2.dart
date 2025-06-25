// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hair_main_street/controllers/productController.dart';
// import 'package:hair_main_street/extras/delegate.dart';
// import 'package:hair_main_street/pages/notifcation.dart';
// import 'package:hair_main_street/widgets/cards.dart';

// class Feed2Page extends StatefulWidget {
//   const Feed2Page({super.key});

//   @override
//   State<Feed2Page> createState() => _Feed2PageState();
// }

// class _Feed2PageState extends State<Feed2Page> {
//   final ScrollController _scrollController = ScrollController();
//   int _selectedCategory = 0;
//   int _itemCount = 1;
//   ProductController productController = Get.find<ProductController>();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_handleScrollPositionChange);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_handleScrollPositionChange);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _handleScrollPositionChange() {
//     final double maxScrollExtent = _scrollController.position.maxScrollExtent;
//     final double currentPosition = _scrollController.position.pixels;

//     if (currentPosition >= maxScrollExtent) {
//       // Load more items when scroll reaches the end
//       setState(() {
//         _itemCount += 5; // Increase item count by 5
//       });
//     }

//     final double screenWidth = MediaQuery.of(context).size.width;
//     final int currentCategory = (currentPosition / screenWidth).floor();

//     if (currentCategory != _selectedCategory) {
//       setState(() {
//         _selectedCategory = currentCategory;
//       });
//     }
//   }

//   void _scrollToCategory(int index) {
//     final double offsetX = index * MediaQuery.of(context).size.width;
//     _scrollController.animateTo(
//       offsetX,
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     List categories = ["All", "Natural Hairs", "Accessories", "Wigs", "Lashes"];
//     //VendorController vendorController = Get.find<VendorController>();
//     GlobalKey<FormState> formKey = GlobalKey();
//     num screenHeight = MediaQuery.of(context).size.height;
//     num screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         // bottom: PreferredSize(
//         //     preferredSize: Size.fromHeight(screenHeight * 0.04),
//         //     child: Form(child: child)),
//         title: const Text(
//           'Home',
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(kToolbarHeight),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                     backgroundColor: Colors.grey.shade50,
//                     //elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       side: BorderSide(
//                         color: Colors.grey.shade500,
//                         width: 0.5,
//                       ),
//                       borderRadius: const BorderRadius.all(
//                         Radius.circular(10),
//                       ),
//                     ),
//                   ),
//                   onPressed: () => showSearch(
//                       context: context, delegate: MySearchDelegate()),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.search,
//                         color: Colors.black54,
//                         size: 24,
//                       ),
//                       SizedBox(
//                         width: 4,
//                       ),
//                       Text(
//                         "Search for hairs, shops and more",
//                         style: TextStyle(color: Colors.black54),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: screenWidth * 1,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       _CategoryButton(
//                         title: categories[0],
//                         isSelected: _selectedCategory == 0,
//                         onTap: () {
//                           _scrollToCategory(0);
//                           setState(() {
//                             _selectedCategory = 0;
//                           });
//                         },
//                       ),
//                       _CategoryButton(
//                         title: categories[1],
//                         isSelected: _selectedCategory == 1,
//                         onTap: () {
//                           _scrollToCategory(1);
//                           setState(() {
//                             _selectedCategory = 1;
//                           });
//                         },
//                       ),
//                       _CategoryButton(
//                         title: categories[2],
//                         isSelected: _selectedCategory == 2,
//                         onTap: () {
//                           _scrollToCategory(2);
//                           setState(() {
//                             _selectedCategory = 2;
//                           });
//                         },
//                       ),
//                       _CategoryButton(
//                         title: categories[3],
//                         isSelected: _selectedCategory == 3,
//                         onTap: () {
//                           _scrollToCategory(3);
//                           setState(() {
//                             _selectedCategory = 3;
//                           });
//                         },
//                       ),
//                       _CategoryButton(
//                         title: categories[4],
//                         isSelected: _selectedCategory == 4,
//                         onTap: () {
//                           _scrollToCategory(4);
//                           setState(() {
//                             _selectedCategory = 4;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         actions: [
//           // IconButton(
//           //   onPressed: () {
//           //     showSearch(context: context, delegate: MySearchDelegate());
//           //   },
//           //   icon: const Icon(
//           //     Icons.search,
//           //     color: Colors.black,
//           //     size: 28,
//           //   ),
//           // ),
//           Transform.rotate(
//             angle: 0.3490659,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: IconButton(
//                 onPressed: () {
//                   Get.to(() => NotificationsPage());
//                 },
//                 icon: const Icon(
//                   Icons.notifications_active_rounded,
//                   size: 28,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           )
//         ],
//         centerTitle: true,
//         //backgroundColor: const Color(0xFF0E4D92),

//         //backgroundColor: Colors.transparent,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: 8),
//         child: Column(
//           children: [
//             SizedBox(
//               height: 400.0, // Adjust the height as needed
//               child: GridView.builder(
//                 controller: _scrollController,
//                 scrollDirection: Axis.horizontal,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2, // Number of columns in the grid
//                   childAspectRatio: 0.8, // Adjust the aspect ratio as needed
//                 ),
//                 itemCount: _itemCount,
//                 itemBuilder: (context, index) {
//                   return ProductCard(
                    
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _CategoryButton extends StatelessWidget {
//   final String title;
//   final bool isSelected;
//   final VoidCallback onTap;

//   _CategoryButton({
//     required this.title,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Text(
//         title,
//         style: TextStyle(
//           color: isSelected ? Colors.blue : null,
//         ),
//       ),
//     );
//   }
// }
