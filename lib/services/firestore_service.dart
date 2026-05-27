import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getUser(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).update(data);
  }

  Future<void> setData(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) {
    return _db.collection(collection).doc(docId).set(data);
  }
}