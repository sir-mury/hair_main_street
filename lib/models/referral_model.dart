import 'package:cloud_firestore/cloud_firestore.dart';

class Referral {
  String? referralID;
  String? referrerID;
  String? referredID; // Consider converting to int
  Timestamp? timestamp;

  Referral({
    this.referralID,
    this.referrerID,
    this.referredID,
    this.timestamp,
  });

  factory Referral.fromJson(Map<String, dynamic> json) => Referral(
        referralID: json['referralID'],
        referrerID: json['referrerID'],
        referredID: json['referredID'],
        timestamp: json['timestamp'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['referralID'] = referralID;
    data['referrerID'] = referrerID;
    data['referredID'] = referredID;
    data['timestamp'] = timestamp;
    return data;
  }
}
