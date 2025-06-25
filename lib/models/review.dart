import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  String? reviewID;
  String? userID;
  String? displayName;
  String? productID;
  String? extraInfo;
  List<String>? reviewImages; // Ensured type safety for image URLs
  String comment;
  double stars;
  dynamic createdAt;

  Review({
    required this.comment,
    required this.stars,
    this.userID,
    this.displayName,
    this.productID,
    this.extraInfo,
    this.reviewImages,
    this.createdAt,
    this.reviewID,
  });

  factory Review.fromData(Map<String, dynamic> data) {
    return Review(
      comment: data['comment'] as String,
      stars: data['stars'] as double,
      userID: data['userID'] as String?,
      displayName: data['display name'] as String?,
      extraInfo: data['extra info'] as String?,
      productID: data['productID'],
      reviewImages:
          data['review images']?.cast<String>(), // Safely cast to List<String>
      createdAt: data['created at'],
      reviewID: data['reviewID'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'comment': comment,
        'productID': productID,
        'stars': stars,
        'userID': userID,
        'display name': displayName,
        'extra info': extraInfo,
        'review images': reviewImages,
        'created at': createdAt,
        'reviewID': reviewID,
      };
}

class DatabaseReview {
  String? reviewID;
  String? userID;
  String? displayName;
  String? extraInfo;
  List<String>? reviewImages; // Ensured type safety for image URLs
  String comment;
  double stars;
  String? productID;
  dynamic createdAt;

  DatabaseReview({
    required this.comment,
    required this.stars,
    this.userID,
    this.displayName,
    this.extraInfo,
    this.reviewImages,
    this.createdAt,
    this.reviewID,
    this.productID,
  });

  factory DatabaseReview.fromData(Map<String, dynamic> data) {
    return DatabaseReview(
      comment: data['comment'] as String,
      stars: data['stars'] as double,
      userID: data['userID'] as String?,
      displayName: data['display name'] as String?,
      extraInfo: data['extra info'] as String?,
      reviewImages:
          data['review images']?.cast<String>(), // Safely cast to List<String>
      createdAt: data['created at'],
      reviewID: data['reviewID'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'comment': comment,
        'stars': stars,
        'userID': userID,
        'display name': displayName,
        'extra info': extraInfo,
        'review images': reviewImages,
        'created at': createdAt,
        'reviewID': reviewID,
      };
}

List<Review> reviews = [
  Review(
      userID: 'User1',
      comment: 'Great product!',
      stars: 5,
      createdAt: FieldValue.serverTimestamp()),
  Review(
      userID: 'User2',
      comment: 'Good product, but could be better.',
      stars: 4,
      createdAt: FieldValue.serverTimestamp()),
  Review(
      userID: 'User3',
      comment: 'Not satisfied with the quality.',
      stars: 2,
      createdAt: FieldValue.serverTimestamp()),

  // Add more reviews as needed
];
