import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/core/constants/app_collections.dart';
import 'package:smart_tutor/screens/chat/chat_screen.dart';
import 'package:smart_tutor/services/auth_service.dart';
import 'package:smart_tutor/services/chat_service.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

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

  Future<String> _guardianName(Map<String, dynamic> data) async {
    final savedName = _text(data['guardianName'], '');
    if (savedName.isNotEmpty && savedName != 'Guardian') return savedName;

    final guardianId = _text(data['guardianId'], '');
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'guardian_accepted':
        return const Color(0xFF2563EB);
      case 'confirmed':
        return const Color(0xFF16A34A);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'guardian_accepted':
        return 'OFFERED';
      case 'confirmed':
        return 'CONFIRMED';
      default:
        return status.toUpperCase();
    }
  }

  Future<void> _confirmOffer({
    required BuildContext context,
    required String applicationId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final appRef = FirebaseFirestore.instance
          .collection(AppCollections.applications)
          .doc(applicationId);
      batch.update(appRef, {
        'status': 'confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final tuitionPostId = _text(data['tuitionPostId'], '');
      if (tuitionPostId.isNotEmpty) {
        final postRef = FirebaseFirestore.instance
            .collection(AppCollections.tuitionPosts)
            .doc(tuitionPostId);
        batch.update(postRef, {
          'status': 'closed',
          'selectedTutorId': data['tutorId'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tuition confirmed')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirm failed: $e')),
      );
    }
  }

  Future<void> _openChat({
    required BuildContext context,
    required String applicationId,
    required Map<String, dynamic> data,
  }) async {
    final guardianId = _text(data['guardianId'], '');
    final guardianName = _text(data['guardianName'], 'Guardian');
    final tutorId = _text(data['tutorId'], '');
    final tutorName = _text(data['tutorName'], 'Tutor');

    if (guardianId.isEmpty || tutorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat info missing')),
      );
      return;
    }

    try {
      final chatId = await ChatService.createOrGetChat(
        requestId: applicationId,
        guardianId: guardianId,
        guardianName: guardianName,
        tutorId: tutorId,
        tutorName: tutorName,
      );

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            receiverId: guardianId,
            receiverName: guardianName,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open chat: $e')),
      );
    }
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF6B7280)),
          const SizedBox(width: 7),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _card({
    required BuildContext context,
    required String applicationId,
    required Map<String, dynamic> data,
  }) {
    final status = _text(data['status'], 'pending').toLowerCase();
    final statusColor = _statusColor(status);

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
                child:
                    Icon(Icons.assignment_outlined, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _text(data['studentClass'], 'Tuition Application'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FutureBuilder<String>(
            future: _guardianName(data),
            builder: (context, snapshot) {
              return _row(
                Icons.family_restroom_rounded,
                'Guardian',
                snapshot.data ?? _text(data['guardianName'], 'Guardian'),
              );
            },
          ),
          _row(Icons.menu_book_outlined, 'Subjects',
              _listText(data['subjects'], 'No subjects')),
          _row(Icons.location_on_outlined, 'Area',
              _text(data['area'], 'No area')),
          _row(Icons.payments_outlined, 'Budget',
              _text(data['budgetRange'], 'No budget')),
          _row(Icons.schedule_outlined, 'Schedule',
              _text(data['preferredSchedule'], 'No schedule')),
          if (status == 'guardian_accepted') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmOffer(
                  context: context,
                  applicationId: applicationId,
                  data: data,
                ),
                icon:
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  'Accept Tuition',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                ),
              ),
            ),
          ],
          if (status == 'confirmed') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openChat(
                  context: context,
                  applicationId: applicationId,
                  data: data,
                ),
                icon:
                    const Icon(Icons.chat_bubble_outline, color: Colors.white),
                label: const Text(
                  'Start Chat',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('User not logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AppCollections.applications)
                  .where('tutorId', isEqualTo: user.uid)
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
                      'No applications yet',
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
                    return _card(
                      context: context,
                      applicationId: doc.id,
                      data: doc.data() as Map<String, dynamic>,
                    );
                  },
                );
              },
            ),
    );
  }
}
