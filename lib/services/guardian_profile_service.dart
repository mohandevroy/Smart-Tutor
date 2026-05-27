import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/guardian_profile_model.dart';

class GuardianProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveGuardianProfile(GuardianProfileModel profile) async {
    await _firestore
        .collection('guardian_profiles')
        .doc(profile.uid)
        .set(profile.toMap());

    await _firestore.collection('users').doc(profile.uid).update({
      'profileCompleted': true,
    });
  }

  Future<GuardianProfileModel?> getGuardianProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc =
        await _firestore.collection('guardian_profiles').doc(user.uid).get();

    if (!doc.exists) return null;

    return GuardianProfileModel.fromMap(doc.data()!);
  }
}