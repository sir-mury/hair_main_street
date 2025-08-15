import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/review_controller.dart';
import 'package:hair_main_street/controllers/user_controller.dart';
import 'package:hair_main_street/models/review.dart';
import 'package:hair_main_street/widgets/loading.dart';
import 'package:hair_main_street/widgets/text_input.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ph.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

class SubmitReviewPage extends StatefulWidget {
  final String? productID;
  const SubmitReviewPage({this.productID, super.key});

  @override
  SubmitReviewPageState createState() => SubmitReviewPageState();
}

class SubmitReviewPageState extends State<SubmitReviewPage> {
  UserController userController = Get.find<UserController>();
  TextEditingController commentController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Review review = Review(comment: "", stars: 0.0);
  final double _rating = 0.0;
  List<File?> selectedImages =
      List.filled(3, null); // Changed to File? to match image_picker

  setReviewController() {
    Get.lazyPut(() => ReviewController());
  }

  @override
  Widget build(BuildContext context) {
    setReviewController();
    ReviewController reviewController = Get.find<ReviewController>();

    void selectImage(int index) async {
      reviewController.selectImage(
        ImageSource.gallery,
        "review_images/${widget.productID}/${DateTime.now().millisecondsSinceEpoch}.jpg",
        index,
      );
    }

    void removeImage(int index) {
      reviewController.removeImage(index);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Symbols.arrow_back_ios_new_rounded,
            size: 24,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Leave Review',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            fontFamily: "Lato",
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextInputWidget(
                  labelColor: Colors.black,
                  controller: displayNameController,
                  labelText: "Display Name (optional)",
                  autofillHints: [AutofillHints.name],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  fontSize: 18,
                  hintText: "Display name",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null;
                    }
                    if (value.length > 15) {
                      return 'Max characters Exceeded (15)';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    review.displayName = value!;
                  },
                ),
                const SizedBox(height: 12),
                TextInputWidget(
                  labelText: "Comment",
                  labelColor: Colors.black,
                  fontSize: 18,
                  controller: commentController,
                  hintText: "Enter review details",
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your review';
                    }
                    return null;
                  },
                  minLines: 5,
                  maxLines: 10,
                  onChanged: (value) {
                    review.comment = value!;
                  },
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Image",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                        3,
                        (index) => GestureDetector(
                          onTap: () => selectImage(index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.black, width: 0.8),
                            ),
                            child: Obx(
                              () => reviewController.imageList[index] != null
                                  ? Stack(
                                      children: [
                                        SizedBox(
                                          width: 86,
                                          height: 86,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.file(
                                              reviewController
                                                  .imageList[index]!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () => removeImage(index),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black
                                                    .withValues(alpha: 0.65),
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Icon(Icons.add, size: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                const Text(
                  'Ratings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                RatingBar.builder(
                  itemSize: 52,
                  initialRating: _rating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5, // Set to 6 for a "0 to 5 stars" rating system
                  itemBuilder: (context, _) => Iconify(
                    Ph.star_fill,
                    size: 35,
                    color: Color.fromARGB(255, 161, 121, 230),
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      review.stars = rating;
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Leave a honest review to help others',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Raleway",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              //padding: const EdgeInsets.symmetric(vertical: 8),
              backgroundColor: Color(0xFF673AB7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                //review.productID = widget.productID;

                reviewController.isLoading.value = true;
                if (reviewController.isLoading.isTrue) {
                  Get.dialog(LoadingWidget(), barrierDismissible: false);
                }
                List<File?> reviewImageList = reviewController.imageList
                    .where((image) => image != null)
                    .toList();

                if (reviewImageList.isNotEmpty) {
                  await reviewController.uploadImage(reviewImageList);
                  review.reviewImages = reviewController.downloadUrls.isNotEmpty
                      ? reviewController.downloadUrls
                      : null;
                  review.userID = userController.userState.value!.uid!;
                  await reviewController.addAReview(review, widget.productID!);
                } else {
                  review.reviewImages = null; // No images selected
                  review.userID = userController.userState.value!.uid!;
                  await reviewController.addAReview(review, widget.productID!);
                }

                // Here you can handle the submission of the review
                // For example, you can send the review to Firestore
                // and then navigate back to the previous screen
                //Navigator.pop(context);
              }
            },
            child: const Text(
              'Submit Review',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
