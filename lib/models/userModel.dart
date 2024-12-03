// ignore_for_file: file_names

class MyUser {
  String? uid;
  String? fullname;
  String? email;
  String? phoneNumber;
  Address? address;
  bool? isBuyer = true;
  bool? isVendor;
  bool? isAdmin;
  String? referralCode;
  String? profilePhoto;
  String? referralLink;

  MyUser({
    this.uid,
    this.address,
    this.email,
    this.phoneNumber,
    this.fullname,
    this.isAdmin,
    this.isBuyer,
    this.isVendor,
    this.profilePhoto,
    this.referralCode,
    this.referralLink,
  });

  factory MyUser.fromJson(Map<String, dynamic> json) => MyUser(
        uid: json["uid"],
        fullname: json["fullname"],
        email: json["email"],
        phoneNumber: json["phonenumber"],
        isAdmin: json["isAdmin"],
        isBuyer: json["isBuyer"],
        isVendor: json["isVendor"],
        profilePhoto: json["profile photo"],
        address:
            json["address"] != null ? Address.fromJson(json["address"]) : null,
        referralCode: json["referral code"],
        referralLink: json["referral link"],
      );
}

class Address {
  String? addressID;
  String? state;
  String? lGA;
  String? zipCode;
  String? contactName;
  String? contactPhoneNumber;
  String? streetAddress;
  String? landmark;
  bool? isDefault = false;

  Address({
    this.addressID,
    this.contactName,
    this.contactPhoneNumber,
    this.lGA,
    this.landmark,
    this.state,
    this.streetAddress,
    this.zipCode,
    this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        streetAddress: json['street address'],
        addressID: json['addressID'],
        lGA: json['LGA'],
        state: json['state'],
        contactName: json['contact name'],
        contactPhoneNumber: json['contact phonenumber'],
        zipCode: json['zipcode'],
        landmark: json['landmark'],
        isDefault: json['isDefault'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['street address'] = streetAddress;
    data['addressID'] = addressID;
    data['LGA'] = lGA;
    data['state'] = state;
    data['contact name'] = contactName;
    data['contact phonenumber'] = contactPhoneNumber;
    data['zipcode'] = zipCode;
    data['landmark'] = landmark;
    data['isDefault'] = isDefault;
    return data;
  }
}
