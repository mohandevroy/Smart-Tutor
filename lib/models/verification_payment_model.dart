import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationPaymentModel {
  final String? id;
  final String tutorId;
  final String tutorName;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final String phoneNumber;
  final String note;
  final String status;
  final Timestamp? createdAt;

  VerificationPaymentModel({
    this.id,
    required this.tutorId,
    required this.tutorName,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.phoneNumber,
    required this.note,
    required this.status,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'tutorId': tutorId,
      'tutorName': tutorName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'phoneNumber': phoneNumber,
      'note': note,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory VerificationPaymentModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return VerificationPaymentModel(
      id: documentId,
      tutorId: map['tutorId'] ?? '',
      tutorName: map['tutorName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      transactionId: map['transactionId'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      note: map['note'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'],
    );
  }
}