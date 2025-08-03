import 'package:hair_main_street/models/userModel.dart';

class CheckOutTickBoxModel {
  String? productID;
  num? price;
  int? quantity;
  String? optionName;
  String? cartID;
  MyUser? user;

  CheckOutTickBoxModel({
    this.price,
    this.productID,
    this.quantity,
    this.user,
    this.optionName,
    this.cartID,
  });
}

class Reminders {
  bool expirationReminderSent;
  bool threeDayPaymentReminderSent;
  bool oneDayPaymentReminderSent;

  Reminders({
    required this.expirationReminderSent,
    required this.threeDayPaymentReminderSent,
    required this.oneDayPaymentReminderSent,
  });

  factory Reminders.fromData(Map<String, dynamic> data) {
    return Reminders(
      expirationReminderSent: data['expirationReminderSent'] ?? false,
      threeDayPaymentReminderSent: data['threeDayPaymentReminderSent'] ?? false,
      oneDayPaymentReminderSent: data['oneDayPaymentReminderSent'] ?? false,
    );
  }

  Map<String, dynamic> toData() {
    return {
      'expirationReminderSent': expirationReminderSent,
      'threeDayPaymentReminderSent': threeDayPaymentReminderSent,
      'oneDayPaymentReminderSent': oneDayPaymentReminderSent,
    };
  }
}

class MessagePageData {
  String? name;
  String? imageUrl;
  String? id;

  MessagePageData({this.id, this.imageUrl, this.name});
}

class VerificationItem {
  String productID;
  bool isVerified;

  VerificationItem({
    required this.productID,
    this.isVerified = false,
  });

  Map<String, dynamic> toData() {
    return {
      'productID': productID,
      'isVerified': isVerified,
    };
  }

  factory VerificationItem.fromData(Map<String, dynamic> data) {
    return VerificationItem(
      productID: data['productID'] ?? '',
      isVerified: data['isVerified'] ?? false,
    );
  }
}
