import 'package:cloud_firestore/cloud_firestore.dart';

class RefundRequest {
  String? requestID;
  String? orderID;
  String? reason;
  String? addedDetails;
  String? refundStatus;
  String? userID;
  String? refundAccountNumber;
  String? refundBankCode;
  String? vendorID;
  String? vendorResponse;
  num? refundAmount;
  Timestamp? createdAt;
  bool isDeleted = false;

  RefundRequest({
    this.orderID,
    this.reason,
    this.addedDetails,
    this.refundAmount,
    this.refundStatus,
    this.requestID,
    this.userID,
    this.vendorID,
    this.vendorResponse,
    this.refundAccountNumber,
    this.isDeleted = false,
    this.refundBankCode,
    this.createdAt,
  });

  factory RefundRequest.fromData(Map<String, dynamic> data) {
    return RefundRequest(
      orderID: data['orderID'] ?? '',
      reason: data['reason'] ?? '',
      requestID: data['requestID'],
      addedDetails: data['added details'] ?? '',
      refundAmount: data['refund amount'] ?? 0,
      refundStatus: data['refund status'] ?? '',
      userID: data['userID'],
      vendorID: data["vendorID"],
      vendorResponse: data["vendor response"],
      refundAccountNumber: data['refund account'] ?? '',
      refundBankCode: data['refund bank_code'] ?? '',
      createdAt: data["created at"],
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'requestID': requestID,
      'reason': reason,
      'added details': addedDetails,
      'refund status': refundStatus,
      'vendorID': vendorID,
      "vendor response": vendorResponse,
      'userID': userID,
      'refund amount': refundAmount,
      'refund bank_code': refundBankCode,
      'refund account': refundAccountNumber,
      'isDeleted': isDeleted,
      'created at': createdAt,
    };
  }
}

class CancellationRequest {
  String? userID;
  String? requestID;
  String? orderID;
  String? reason;
  String? cancellationStatus;
  String? cancellationAccount;
  String? cancellationBankCode;
  num? cancellationAmount;
  Timestamp? createdAt;
  bool isDeleted = false;

  CancellationRequest({
    this.orderID,
    this.reason,
    this.cancellationStatus,
    this.cancellationAmount,
    this.requestID,
    this.cancellationAccount,
    this.cancellationBankCode,
    this.isDeleted = false,
    this.userID,
    this.createdAt,
  });

  factory CancellationRequest.fromData(Map<String, dynamic> data) {
    return CancellationRequest(
      orderID: data['orderID'] ?? '',
      reason: data['reason'] ?? '',
      requestID: data['requestID'],
      cancellationAmount: data['cancellation amount'] ?? 0,
      cancellationStatus: data['cancellation status'],
      userID: data["userID"],
      cancellationAccount: data['cancellation account'],
      cancellationBankCode: data['cancellation bank_code'],
      createdAt: data['created at'],
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'requestID': requestID,
      'cancellation amount': cancellationAmount,
      'reason': reason,
      'cancellation status': cancellationStatus,
      'userID': userID,
      'cancellation account': cancellationAccount,
      'cancellation bank_code': cancellationBankCode,
      'created at': createdAt,
      'isDeleted': isDeleted,
    };
  }
}
