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
  num? refundAmount;
  Timestamp? createdAt;

  RefundRequest({
    this.orderID,
    this.reason,
    this.addedDetails,
    this.refundAmount,
    this.refundStatus,
    this.requestID,
    this.userID,
    this.refundAccountNumber,
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
      userID: data['userId'],
      refundAccountNumber: data['refund account'] ?? '',
      refundBankCode: data['refund bank_code'] ?? '',
      createdAt: data["created at"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'requestID': requestID,
      'reason': reason,
      'added details': addedDetails,
      'refund status': refundStatus,
      'userID': userID,
      'refund amount': refundAmount,
      'refund bank_code': refundBankCode,
      'refund account': refundAccountNumber,
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

  CancellationRequest({
    this.orderID,
    this.reason,
    this.cancellationStatus,
    this.cancellationAmount,
    this.requestID,
    this.cancellationAccount,
    this.cancellationBankCode,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'requestID': requestID,
      'cancellation amount': cancellationAmount,
      'reason': reason,
      'cancellation': cancellationStatus,
      'userID': userID,
      'cancellation account': cancellationAccount,
      'cancellation bank_code': cancellationBankCode,
      'created at': createdAt,
    };
  }
}
