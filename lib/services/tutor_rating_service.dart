import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_tutor/core/constants/app_collections.dart';

class TutorRatingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> rateTutor({
    required String tutorId,
    required String guardianId,
    required String guardianName,
    required String applicationId,
    required double rating,
    required String comment,
  }) async {
    final reviewId = '${guardianId}_$tutorId';
    final reviewRef =
        _firestore.collection(AppCollections.reviews).doc(reviewId);

    await reviewRef.set(
      {
        'reviewId': reviewId,
        'applicationId': applicationId,
        'tutorId': tutorId,
        'guardianId': guardianId,
        'guardianName': guardianName,
        'rating': rating,
        'comment': comment.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    final reviews = await _firestore
        .collection(AppCollections.reviews)
        .where('tutorId', isEqualTo: tutorId)
        .get();

    var total = 0.0;
    var count = 0;

    for (final doc in reviews.docs) {
      final value = doc.data()['rating'];
      final ratingValue = value is num
          ? value.toDouble()
          : double.tryParse(value?.toString() ?? '');
      if (ratingValue == null) continue;
      total += ratingValue;
      count++;
    }

    final average = count == 0 ? 0.0 : total / count;

    await _firestore.collection(AppCollections.tutorProfiles).doc(tutorId).set(
      {
        'guardianRatingAverage': double.parse(average.toStringAsFixed(1)),
        'guardianTotalReviews': count,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      SetOptions(merge: true),
    );
  }
}
