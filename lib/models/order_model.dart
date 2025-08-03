import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hair_main_street/models/userModel.dart';

Orders ordersFromJson(String str) => Orders.fromJson(json.decode(str));

String ordersToJson(Orders data) => json.encode(data.toJson());

class Orders {
  String? orderId;
  num? paymentPrice;
  String? buyerId;
  String? vendorId;
  num? totalPrice;
  Address? shippingAddress;
  int? installmentNumber;
  int? installmentPaid;
  String? orderStatus;
  String? refundStatus;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  String? paymentMethod;
  String? paymentStatus;
  String? recipientCode;
  bool isDeleted = false;
  List<String?>? transactionID;

  Orders({
    this.orderId,
    this.paymentPrice,
    this.refundStatus,
    this.buyerId,
    this.vendorId,
    this.totalPrice,
    this.shippingAddress,
    this.installmentNumber,
    this.recipientCode,
    this.installmentPaid,
    this.orderStatus,
    this.createdAt,
    this.updatedAt,
    this.paymentMethod,
    this.paymentStatus,
    this.transactionID,
    this.isDeleted = false,
  });

  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
      orderId: json['orderID'],
      paymentPrice: json['payment price'],
      buyerId: json['buyerID'],
      vendorId: json['vendorID'],
      totalPrice: json['totalPrice'],
      shippingAddress: json['shipping address'] != null
          ? Address.fromJson(json['shipping address'])
          : null,
      installmentNumber: json['installment number'],
      installmentPaid: json['installment paid'],
      refundStatus: json['refund status'],
      orderStatus: json['order status'],
      createdAt: json['created at'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(json['created at'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(json['updated at'])
          : null,
      recipientCode: json['recipient code'],
      paymentMethod: json['payment method'],
      paymentStatus: json['payment status'],
      isDeleted: json['isDeleted'] ?? false,
      transactionID: json['transactionID'] != null
          ? List<String?>.from(json['transactionID'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderId,
      'payment price': paymentPrice,
      'buyerID': buyerId,
      'vendorID': vendorId,
      'totalPrice': totalPrice,
      'shipping address': shippingAddress!.toJson(),
      'installment number': installmentNumber,
      'installment paid': installmentPaid,
      'order status': orderStatus,
      'refund status': refundStatus,
      "isDeleted": isDeleted,
      'created at': Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch),
      'updated at': Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch),
      'payment method': paymentMethod,
      'payment status': paymentStatus,
      'transactionID': transactionID,
    };
  }
}

OrderItem orderItemFromJson(String str) => OrderItem.fromJson(json.decode(str));

String orderItemToJson(OrderItem data) => json.encode(data.toJson());

class OrderItem {
  String? productId;
  String? quantity;
  String? price;
  String? optionName;

  OrderItem({
    this.productId,
    this.quantity,
    this.price,
    this.optionName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json["productID"],
        quantity: json["quantity"],
        price: json["price"],
        optionName: json["option"],
      );

  Map<String, dynamic> toJson() => {
        "productID": productId,
        "quantity": quantity,
        "price": price,
        "option": optionName!,
      };
}

DatabaseOrderResponse databaseOrderResponseFromJson(String str) =>
    DatabaseOrderResponse.fromJson(json.decode(str));

String databaseOrderResposeToJson(OrderItem data) => json.encode(data.toJson());

class DatabaseOrderResponse {
  String? orderId;
  num? paymentPrice;
  String? buyerId;
  String? vendorId;
  num? totalPrice;
  String? recipientCode;
  Address? shippingAddress;
  int? installmentNumber;
  int? installmentPaid;
  String? orderStatus;
  String? refundStatus;
  dynamic createdAt;
  dynamic updatedAt;
  String? paymentMethod;
  String? paymentStatus;
  List<String?>? transactionID;
  List<OrderItem>? orderItem;
  bool? isDeleted;

  DatabaseOrderResponse(
      {this.buyerId,
      this.createdAt,
      this.installmentNumber,
      this.installmentPaid,
      this.recipientCode,
      this.orderId,
      this.orderStatus,
      this.paymentMethod,
      this.paymentPrice,
      this.refundStatus,
      this.paymentStatus,
      this.orderItem,
      this.shippingAddress,
      this.transactionID,
      this.totalPrice,
      this.updatedAt,
      this.isDeleted,
      this.vendorId});

  factory DatabaseOrderResponse.fromJson(Map<String, dynamic> json) {
    // print(
    //     "${Address.fromJson(json["shipping address"]).addressID} and the type is : ${json["shipping address"].runtimeType}");
    return DatabaseOrderResponse(
      orderId: json["orderID"],
      buyerId: json["buyerID"],
      vendorId: json["vendorID"],
      totalPrice: json["totalPrice"],
      isDeleted: json['isDeleted'] ?? false,
      recipientCode: json['recipient code'],
      shippingAddress: json["shipping address"] != null
          ? Address.fromJson(json["shipping address"])
          : null,
      orderStatus: json["order status"],
      createdAt: json["created at"],
      refundStatus: json['refund status'],
      updatedAt: json["updated at"],
      installmentNumber: json["installment number"],
      installmentPaid: json["installment paid"],
      paymentMethod: json['payment method'],
      paymentStatus: json['payment status'],
      transactionID: json['transactionID'] != null
          ? List<String?>.from(json['transactionID'])
          : null,
      paymentPrice: json['payment price'],
      orderItem: List<OrderItem>.from(json["orderItems"].map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
        "orderID": orderId,
        "payment price": paymentPrice,
        "buyerID": buyerId,
        'refund status': refundStatus,
        "vendorID": vendorId,
        "isDeleted": isDeleted,
        "totalPrice": totalPrice,
        "shipping address": shippingAddress!.toJson(),
        "order status": orderStatus,
        "recipient code": recipientCode,
        "created at": createdAt,
        "updated at": updatedAt,
        "transactionID": transactionID,
        "payment method": paymentMethod,
        "payment status": paymentStatus,
        "installment number": installmentNumber,
        "installment paid": installmentPaid,
        "order item": orderItem,
      };
}
