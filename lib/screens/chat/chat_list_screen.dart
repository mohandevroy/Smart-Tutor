import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/screens/chat/chat_screen.dart';
import 'package:smart_tutor/services/auth_service.dart';

class ChatListScreen extends StatelessWidget {
  final String role;

  const ChatListScreen({
    super.key,
    required this.role,
  });

  String _text(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _formatTime(dynamic value) {
    if (value is! Timestamp) return '';
    final date = value.toDate();

    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    final idField = role == 'guardian' ? 'guardianId' : 'tutorId';
    final receiverIdField = role == 'guardian' ? 'tutorId' : 'guardianId';
    final receiverNameField = role == 'guardian' ? 'tutorName' : 'guardianName';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: const Color(0xFFF4F7FB),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('User not logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where(idField, isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                final visibleDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final hiddenFor = data['hiddenFor'];

                  if (hiddenFor is List) {
                    return !hiddenFor.contains(user.uid);
                  }

                  return true;
                }).toList();

                visibleDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;

                  final aTime = aData['lastMessageAt'];
                  final bTime = bData['lastMessageAt'];

                  if (aTime is Timestamp && bTime is Timestamp) {
                    return bTime.compareTo(aTime);
                  }

                  return 0;
                });

                if (visibleDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No chats yet',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                      ),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth =
                        constraints.maxWidth >= 900 ? 760.0 : 520.0;

                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                          itemCount: visibleDocs.length,
                          itemBuilder: (context, index) {
                            final doc = visibleDocs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            final chatId = doc.id;
                            final receiverId = _text(data[receiverIdField], '');
                            final receiverName =
                                _text(data[receiverNameField], 'Unknown User');
                            final lastMessage =
                                _text(data['lastMessage'], 'No messages yet');
                            final status = _text(data['status'], 'active');
                            final time = _formatTime(data['lastMessageAt']);

                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                if (receiverId.isEmpty) return;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      chatId: chatId,
                                      receiverId: receiverId,
                                      receiverName: receiverName,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x080F172A),
                                      blurRadius: 14,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: status == 'blocked'
                                          ? const Color(0xFFFEE2E2)
                                          : const Color(0xFFEFF6FF),
                                      child: Icon(
                                        status == 'blocked'
                                            ? Icons.block
                                            : Icons.chat_bubble_outline,
                                        color: status == 'blocked'
                                            ? const Color(0xFFDC2626)
                                            : const Color(0xFF2563EB),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            receiverName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            status == 'blocked'
                                                ? 'Blocked chat'
                                                : lastMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (time.isNotEmpty)
                                      Text(
                                        time,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
