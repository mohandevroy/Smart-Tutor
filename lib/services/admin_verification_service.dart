import 'package:cloud_firestore/cloud_firestore.dart';

class AdminVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updatePaymentStatus({
    required String docId,
    required String tutorId,
    required String newStatus,
  }) async {
    final batch = _firestore.batch();

    final paymentRef = _firestore
        .collection('verification_payments')
        .doc(docId);

    final tutorProfileRef = _firestore
        .collection('tutor_profiles')
        .doc(tutorId);

    batch.update(paymentRef, {
      'status': newStatus,
    });

    batch.set(
      tutorProfileRef,
      {
        'verificationStatus': newStatus,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}