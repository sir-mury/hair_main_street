import 'dart:convert';

Vendors vendorFromData(String str) => Vendors.fromdata(json.decode(str));

String vendorsTodata(Vendors data) => json.encode(data.todata());

class Vendors {
  String? userID;
  String? shopPicture;
  String? shopName;
  String? shopLink;
  Map? accountInfo;
  Map? contactInfo;
  bool? firstVerification;
  bool? secondVerification;
  dynamic createdAt;
  num? installmentDuration;

  Vendors(
      {this.accountInfo,
      this.createdAt,
      this.shopPicture,
      this.contactInfo,
      this.shopLink,
      this.secondVerification,
      this.firstVerification,
      this.shopName,
      this.userID,
      this.installmentDuration});

  factory Vendors.fromdata(Map<String, dynamic> data) => Vendors(
        userID: data['userID'],
        secondVerification: data['second verification'],
        firstVerification: data['first verification'],
        shopName: data['shop name'],
        shopLink: data['shop link'],
        contactInfo: data['contact info'],
        accountInfo: data['account info'],
        createdAt: data['created at'],
        shopPicture: data['shop picture'],
        installmentDuration: data['installment duration'] ?? 0,
      );

  Map<String, dynamic> todata() => {
        "account info": accountInfo,
        "userID": userID,
        "contact info": contactInfo,
        "shop picture": shopPicture,
        "shop link": shopLink,
        "first verification": firstVerification,
        "second verification": secondVerification,
        "shop name": shopName,
        "created at": createdAt,
        "installment duration": installmentDuration,
      };
}
