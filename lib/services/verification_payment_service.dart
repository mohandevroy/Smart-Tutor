import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_tutor/models/verification_payment_model.dart';

class VerificationPaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> hasExistingPayment(String tutorId) async {
    final snapshot = await _firestore
        .collection('verification_payments')
        .where('tutorId', isEqualTo: tutorId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> submitVerificationPayment(
    VerificationPaymentModel payment,
  ) async {
    await _firestore.collection('verification_payments').add(payment.toMap());
  }
}