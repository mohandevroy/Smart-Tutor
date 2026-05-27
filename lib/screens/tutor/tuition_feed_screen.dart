import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/core/constants/app_collections.dart';
import 'package:smart_tutor/services/auth_service.dart';

class TuitionFeedScreen extends StatefulWidget {
  const TuitionFeedScreen({super.key});

  @override
  State<TuitionFeedScreen> createState() => _TuitionFeedScreenState();
}

class _TuitionFeedScreenState extends State<TuitionFeedScreen> {
  String _text(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _listText(dynamic value, String fallback) {
    if (value is List && value.isNotEmpty) {
      return value.map((item) => item.toString()).join(', ');
    }
    return _text(value, fallback);
  }

  Future<String> _guardianNameFromPost(Map<String, dynamic> post) async {
    final postName = _text(post['guardianName'], '');
    if (postName.isNotEmpty && postName != 'Guardian') return postName;

    final guardianId = _text(post['guardianId'], '');
    if (guardianId.isEmpty) return 'Guardian';

    final profileDoc = await FirebaseFirestore.instance
        .collection(AppCollections.guardianProfiles)
        .doc(guardianId)
        .get();
    final profileData = profileDoc.data() ?? {};
    final profileName = _text(profileData['fullName'], '');
    if (profileName.isNotEmpty) return profileName;

    final userDoc = await FirebaseFirestore.instance
        .collection(AppCollections.users)
        .doc(guardianId)
        .get();
    final userData = userDoc.data() ?? {};
    return _text(userData['name'] ?? userData['email'], 'Guardian');
  }

  Future<void> _apply({
    required BuildContext context,
    required String postId,
    required Map<String, dynamic> post,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return;

    try {
      final existing = await FirebaseFirestore.instance
          .collection(AppCollections.applications)
          .where('tuitionPostId', isEqualTo: postId)
          .where('tutorId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already applied to this tuition')),
        );
        return;
      }

      final tutorDoc = await FirebaseFirestore.instance
          .collection(AppCollections.tutorProfiles)
          .doc(user.uid)
          .get();
      final tutorData = tutorDoc.data() ?? {};
      final guardianName = await _guardianNameFromPost(post);

      await FirebaseFirestore.instance
          .collection(AppCollections.applications)
          .add({
        'tuitionPostId': postId,
        'guardianId': post['guardianId'] ?? '',
        'guardianName': guardianName,
        'studentName': post['studentName'] ?? '',
        'studentClass': post['studentClass'] ?? '',
        'subjects': post['subjects'] ?? [],
        'budgetRange': post['budgetRange'] ?? '',
        'preferredSchedule': post['preferredSchedule'] ?? '',
        'area': post['area'] ?? '',
        'tuitionMode': post['tuitionMode'] ?? '',
        'tutorId': user.uid,
        'tutorName': tutorData['fullName'] ?? user.displayName ?? 'Tutor',
        'tutorEmail': tutorData['email'] ?? user.email ?? '',
        'tutorPhone': tutorData['phone'] ?? '',
        'tutorSubjects': tutorData['subjects'] ?? [],
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application sent')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apply failed: $e')),
      );
    }
  }

  Widget _info(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF6B7280)),
          const SizedBox(width: 7),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _card(String postId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE0F2FE),
                child: Icon(Icons.school_rounded, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _text(data['studentClass'], 'Tuition'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Text(
                'OPEN',
                style: TextStyle(
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _info(
            Icons.family_restroom_rounded,
            'Guardian',
            _text(data['guardianName'], 'Guardian'),
          ),
          _info(
            Icons.menu_book_outlined,
            'Subjects',
            _listText(data['subjects'], 'No subjects'),
          ),
          _info(
            Icons.location_on_outlined,
            'Area',
            _text(data['area'], 'No area'),
          ),
          _info(
            Icons.payments_outlined,
            'Budget',
            _text(data['budgetRange'], 'No budget'),
          ),
          _info(
            Icons.schedule_outlined,
            'Schedule',
            _text(data['preferredSchedule'], 'No schedule'),
          ),
          _info(
            Icons.computer_outlined,
            'Mode',
            _text(data['tuitionMode'], 'No mode'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _apply(context: context, postId: postId, post: data),
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text(
                'Apply',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
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
        title: const Text('Tuition Feed'),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppCollections.tuitionPosts)
            .where('status', isEqualTo: 'open')
            .snapshots(),
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
                'No open tuition found',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
              ),
            );
          }

          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['createdAt'];
            final bTime = bData['createdAt'];
            if (aTime is Timestamp && bTime is Timestamp) {
              return bTime.compareTo(aTime);
            }
            return 0;
          });

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return _card(doc.id, doc.data() as Map<String, dynamic>);
            },
          );
        },
      ),
    );
  }
}
