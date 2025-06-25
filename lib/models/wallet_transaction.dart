import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

Wallet walletFromJson(String str) => Wallet.fromJson(json.decode(str));

String walletToJson(Wallet data) => json.encode(data.toJson());

class Wallet {
  String? userId;
  int? balance;
  num? withdrawableBalance;

  Wallet({
    this.userId,
    this.balance,
    this.withdrawableBalance,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        userId: json["userID"],
        balance: json["balance"],
        withdrawableBalance: json['withdrawable balance'],
      );

  Map<String, dynamic> toJson() => {
        "userID": userId,
        "balance": balance,
        "withdrawable balance": withdrawableBalance
      };
}

Transactions transactionFromJson(String str) =>
    Transactions.fromJson(json.decode(str));

String transactionToJson(Transactions data) => json.encode(data.toJson());

class Transactions {
  String? transactionId;
  num? amount;
  dynamic timestamp;
  String? type;
  String? description;

  Transactions({
    this.transactionId,
    this.amount,
    this.timestamp,
    this.type,
    this.description,
  });

  factory Transactions.fromJson(Map<String, dynamic> json) => Transactions(
        transactionId: json["transactionID"],
        amount: json["amount"],
        timestamp: json["timestamp"],
        type: json["type"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "transactionID": transactionId,
        "amount": amount,
        "timestamp": timestamp,
        "type": type,
        "description": description,
      };
}

Wallet dataBaseWalletResponseFromJson(String str) =>
    Wallet.fromJson(json.decode(str));

String dataBaseWalletResponsetoJson(Wallet data) => json.encode(data.toJson());

class DataBaseWalletResponse {
  String? userId;
  String? balance;
  num? withdrawableBalance;
  String? transactionId;
  num? amount;
  dynamic timestamp;
  String? type;
  String? description;

  DataBaseWalletResponse({
    this.transactionId,
    this.amount,
    this.timestamp,
    this.type,
    this.description,
    this.withdrawableBalance,
    this.userId,
    this.balance,
  });

  factory DataBaseWalletResponse.fromJson(Map<String, dynamic> json) =>
      DataBaseWalletResponse(
        transactionId: json["transactionID"],
        amount: json["amount"],
        timestamp: json["timestamp"],
        type: json["type"],
        description: json["description"],
        userId: json['userID'],
        balance: json['balance'],
        withdrawableBalance: json["withdrawable balance"],
      );

  Map<String, dynamic> toJson() => {
        "transactionID": transactionId,
        "amount": amount,
        "timestamp": timestamp,
        "type": type,
        "description": description,
        'userID': userId,
        "balance": balance,
        "withdrawable balance": withdrawableBalance,
      };
}

class WithdrawalRequest {
  String? userId;
  String? requestID;
  num? withdrawalAmount;
  String? accountNumber;
  String? accountName;
  String? bankName;
  bool? isDeleted = false;
  String? bankCode;
  String? status;
  Timestamp? createdAt;

  WithdrawalRequest({
    this.withdrawalAmount,
    this.accountName,
    this.requestID,
    this.bankCode,
    this.createdAt,
    this.accountNumber,
    this.bankName,
    this.status,
    this.userId,
    this.isDeleted = false,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      accountName: json["account name"],
      accountNumber: json["account number"],
      createdAt: json["created at"],
      bankName: json["bank name"],
      requestID: json["requestID"],
      status: json["status"],
      bankCode: json["bank code"],
      isDeleted: json['isDeleted'] ?? false,
      userId: json['userID'],
      withdrawalAmount: json['withdrawal amount'],
    );
  }

  Map<String, dynamic> toJson() => {
        "account name": accountName,
        "account number": accountNumber,
        "created at": createdAt,
        "bank name": bankName,
        "isDeleted": isDeleted ?? false,
        "status": status ?? "created",
        "requestID": requestID,
        "userID": userId,
        "withdrawal amount": withdrawalAmount,
        "bank code": bankCode,
      };
}
