import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/screens/chat/chat_screen.dart';
import 'package:smart_tutor/services/auth_service.dart';
import 'package:smart_tutor/services/chat_service.dart';

class GuardianMyRequestsScreen extends StatelessWidget {
  const GuardianMyRequestsScreen({super.key});

  String _stringValue(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  String _listValue(dynamic value, String fallback) {
    if (value == null) return fallback;

    if (value is List) {
      if (value.isEmpty) return fallback;
      return value.map((e) => e.toString()).join(', ');
    }

    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF16A34A);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.access_time_filled_rounded;
    }
  }

  Future<void> _openChat({
    required BuildContext context,
    required String requestId,
    required Map<String, dynamic> data,
  }) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    final guardianId = _stringValue(data['guardianId'], '');
    final guardianName = _stringValue(data['guardianName'], 'Guardian');
    final tutorId = _stringValue(data['tutorId'], '');
    final tutorName = _stringValue(data['tutorName'], 'Tutor');

    if (guardianId.isEmpty || tutorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat information missing')),
      );
      return;
    }

    try {
      final chatId = await ChatService.createOrGetChat(
        requestId: requestId,
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
            receiverId: tutorId,
            receiverName: tutorName,
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

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF6B7280)),
          const SizedBox(width: 7),
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 56, color: Color(0xFF4F46E5)),
            SizedBox(height: 16),
            Text(
              'No requests yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'When you request a tutor, you will see the request status here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestCard({
    required BuildContext context,
    required String requestId,
    required Map<String, dynamic> data,
  }) {
    final tutorName = _stringValue(data['tutorName'], 'Unknown Tutor');
    final tutorEmail = _stringValue(data['tutorEmail'], 'No email added');
    final tutorPhone = _stringValue(data['tutorPhone'], 'No phone added');
    final tutorSubjects = _listValue(data['tutorSubjects'], 'No subjects added');
    final studentName = _stringValue(data['studentName'], 'No student name added');
    final studentClass = _stringValue(data['studentClass'], 'No class added');
    final budgetRange = _stringValue(data['budgetRange'], 'No budget added');
    final preferredSchedule =
        _stringValue(data['preferredSchedule'], 'No schedule added');

    final status = _stringValue(data['status'], 'pending').toLowerCase();
    final statusColor = _statusColor(status);

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
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFE0F2FE),
                child: Icon(Icons.school_rounded, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tutorName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(_statusIcon(status), color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow(Icons.menu_book_outlined, 'Tutor Subjects', tutorSubjects),
          _infoRow(Icons.email_outlined, 'Tutor Email', tutorEmail),
          _infoRow(Icons.phone_outlined, 'Tutor Phone', tutorPhone),
          const Divider(height: 22),
          _infoRow(Icons.person_outline, 'Student', studentName),
          _infoRow(Icons.class_outlined, 'Class', studentClass),
          _infoRow(Icons.attach_money_outlined, 'Budget', budgetRange),
          _infoRow(Icons.schedule_outlined, 'Schedule', preferredSchedule),
          if (status == 'accepted') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openChat(
                  context: context,
                  requestId: requestId,
                  data: data,
                ),
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                ),
                label: const Text(
                  'Start Chat',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
        title: const Text('My Requests'),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('User not logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tutor_requests')
                  .where('guardianId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Something went wrong: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFDC2626)),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) return _emptyState();

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
                    final data = doc.data() as Map<String, dynamic>;

                    return _requestCard(
                      context: context,
                      requestId: doc.id,
                      data: data,
                    );
                  },
                );
              },
            ),
    );
  }
}