import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/screens/chat/chat_screen.dart';
import 'package:smart_tutor/services/auth_service.dart';
import 'package:smart_tutor/services/chat_service.dart';

class TutorRequestsScreen extends StatelessWidget {
  const TutorRequestsScreen({super.key});

  String _text(dynamic value, String fallback) {
    if (value == null) return fallback;
    final v = value.toString().trim();
    return v.isEmpty ? fallback : v;
  }

  Future<void> _updateStatus({
    required BuildContext context,
    required String requestId,
    required String status,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('tutor_requests')
          .doc(requestId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $status')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
      );
    }
  }

  Future<void> _openChat({
    required BuildContext context,
    required String requestId,
    required Map<String, dynamic> data,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) return;

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

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFF16A34A);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Tutor Requests'),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('User not logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tutor_requests')
                  .where('tutorId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No requests yet',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                      ),
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
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final requestId = doc.id;
                    final guardianName =
                        _text(data['guardianName'], 'Guardian');
                    final studentName =
                        _text(data['studentName'], 'No student');
                    final studentClass =
                        _text(data['studentClass'], 'No class');
                    final budget =
                        _text(data['budgetRange'], 'No budget');
                    final schedule =
                        _text(data['preferredSchedule'], 'No schedule');
                    final status =
                        _text(data['status'], 'pending').toLowerCase();

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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 23,
                                backgroundColor:
                                    Color(0xFFEDE9FE),
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  guardianName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor
                                      .withOpacity(0.12),
                                  borderRadius:
                                      BorderRadius.circular(
                                          20),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text('Student: $studentName'),
                          const SizedBox(height: 4),
                          Text('Class: $studentClass'),
                          const SizedBox(height: 4),
                          Text('Budget: $budget'),
                          const SizedBox(height: 4),
                          Text('Schedule: $schedule'),

                          if (status == 'pending') ...[
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _updateStatus(
                                      context: context,
                                      requestId: requestId,
                                      status:
                                          'accepted',
                                    ),
                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          const Color(
                                              0xFF16A34A),
                                    ),
                                    child: const Text(
                                      'Accept',
                                      style: TextStyle(
                                        color:
                                            Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _updateStatus(
                                      context: context,
                                      requestId: requestId,
                                      status:
                                          'rejected',
                                    ),
                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          const Color(
                                              0xFFDC2626),
                                    ),
                                    child: const Text(
                                      'Reject',
                                      style: TextStyle(
                                        color:
                                            Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (status == 'accepted') ...[
                            const SizedBox(height: 14),
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
                                  style: TextStyle(
                                    color:
                                        Colors.white,
                                  ),
                                ),
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      const Color(
                                          0xFF4F46E5),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}