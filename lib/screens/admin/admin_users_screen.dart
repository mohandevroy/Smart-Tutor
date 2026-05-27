import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  String _text(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _role(Map<String, dynamic> userData) {
    return _text(userData['role'], 'unknown').toLowerCase();
  }

  String? _profileCollection(String role) {
    if (role == 'tutor') return 'tutor_profiles';
    if (role == 'guardian' || role == 'parent') return 'guardian_profiles';
    return null;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF16A34A);
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'not submitted':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Future<Map<String, dynamic>> _loadProfile({
    required String uid,
    required String role,
  }) async {
    final collection = _profileCollection(role);
    if (collection == null) {
      return {
        'exists': false,
        'collection': null,
        'data': <String, dynamic>{},
      };
    }

    final doc =
        await FirebaseFirestore.instance.collection(collection).doc(uid).get();

    return {
      'exists': doc.exists,
      'collection': collection,
      'data': doc.data() ?? <String, dynamic>{},
    };
  }

  Future<void> _updateProfileStatus({
    required BuildContext context,
    required String uid,
    required String collection,
    required String status,
  }) async {
    try {
      await FirebaseFirestore.instance.collection(collection).doc(uid).update({
        'adminStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User $status successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
      );
    }
  }

  Future<void> _deleteQueryBatch({
    required WriteBatch batch,
    required String collection,
    required String field,
    required String uid,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where(field, isEqualTo: uid)
        .get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
  }

  Future<void> _removeUser({
    required BuildContext context,
    required String uid,
    required String name,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove user?'),
          content: Text(
            'This will remove $name from Firestore system records. '
            'The Firebase Auth login must be deleted separately from Firebase Console or a backend admin function.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final db = FirebaseFirestore.instance;

      batch.delete(db.collection('users').doc(uid));
      batch.delete(db.collection('guardian_profiles').doc(uid));
      batch.delete(db.collection('tutor_profiles').doc(uid));

      await _deleteQueryBatch(
        batch: batch,
        collection: 'tuition_posts',
        field: 'guardianId',
        uid: uid,
      );
      await _deleteQueryBatch(
        batch: batch,
        collection: 'applications',
        field: 'guardianId',
        uid: uid,
      );
      await _deleteQueryBatch(
        batch: batch,
        collection: 'applications',
        field: 'tutorId',
        uid: uid,
      );
      await _deleteQueryBatch(
        batch: batch,
        collection: 'tutor_requests',
        field: 'guardianId',
        uid: uid,
      );
      await _deleteQueryBatch(
        batch: batch,
        collection: 'tutor_requests',
        field: 'tutorId',
        uid: uid,
      );
      await _deleteQueryBatch(
        batch: batch,
        collection: 'verification_payments',
        field: 'tutorId',
        uid: uid,
      );
      await _deleteQueryBatch(
        batch: batch,
        collection: 'verification_payments',
        field: 'userId',
        uid: uid,
      );

      await batch.commit();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User removed from system records')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove failed: $e')),
      );
    }
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCard({
    required BuildContext context,
    required String uid,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> profileState,
  }) {
    final role = _role(userData);
    final profileExists = profileState['exists'] == true;
    final collection = profileState['collection'] as String?;
    final profileData =
        profileState['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final name = _text(
      profileData['fullName'] ?? userData['name'],
      'No name',
    );
    final email = _text(
      profileData['email'] ?? userData['email'],
      'No email',
    );
    final phone = _text(profileData['phone'], 'No phone');
    final status = profileExists
        ? _text(profileData['adminStatus'], 'pending').toLowerCase()
        : collection == null
            ? 'account'
            : 'not submitted';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEDE9FE),
                child: Icon(
                  role == 'tutor'
                      ? Icons.school_rounded
                      : role == 'guardian' || role == 'parent'
                          ? Icons.family_restroom_rounded
                          : Icons.admin_panel_settings_rounded,
                  color: const Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _chip(status, _statusColor(status)),
            ],
          ),
          const SizedBox(height: 10),
          _info('UID', uid),
          _info('Role', role),
          _info('Phone', phone),
          _info(
            'Profile',
            profileExists ? 'Submitted' : 'Not submitted yet',
          ),
          if (collection != null && profileExists) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: status == 'rejected'
                        ? null
                        : () => _updateProfileStatus(
                              context: context,
                              uid: uid,
                              collection: collection,
                              status: 'rejected',
                            ),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: status == 'approved'
                        ? null
                        : () => _updateProfileStatus(
                              context: context,
                              uid: uid,
                              collection: collection,
                              status: 'approved',
                            ),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Approve',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      disabledBackgroundColor: const Color(0xFF9CA3AF),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _removeUser(
                context: context,
                uid: uid,
                name: name,
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove User'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('All Users'),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final userDoc = docs[index];
              final userData = userDoc.data() as Map<String, dynamic>;
              final role = _role(userData);

              return FutureBuilder<Map<String, dynamic>>(
                future: _loadProfile(uid: userDoc.id, role: role),
                builder: (context, profileSnapshot) {
                  final profileState = profileSnapshot.data ??
                      {
                        'exists': false,
                        'collection': _profileCollection(role),
                        'data': <String, dynamic>{},
                      };

                  return _userCard(
                    context: context,
                    uid: userDoc.id,
                    userData: userData,
                    profileState: profileState,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
