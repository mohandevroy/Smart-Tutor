import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/screens/admin/admin_chat_view_screen.dart';
import 'package:smart_tutor/screens/chat/chat_screen.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({super.key});

  String _text(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Chat Monitoring'),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final chatType = _text(data['chatType'], 'tuition');
              final isSupport = chatType == 'support';
              final guardianName = _text(data['guardianName'], 'Guardian');
              final tutorName = _text(data['tutorName'], 'Tutor');
              final supportUserName =
                  _text(data['supportUserName'], 'Support User');
              final supportUserRole = _text(data['supportUserRole'], 'user');
              final supportUserId = _text(data['supportUserId'], '');
              final lastMessage = _text(data['lastMessage'], 'No messages yet');
              final status = _text(data['status'], 'active');
              final title = isSupport
                  ? 'Support: $supportUserName'
                  : '$guardianName to $tutorName';

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  if (isSupport && supportUserId.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatId: doc.id,
                          receiverId: supportUserId,
                          receiverName: supportUserName,
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminChatViewScreen(
                        chatId: doc.id,
                        title: title,
                      ),
                    ),
                  );
                },
                child: Container(
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: status == 'blocked'
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFEDE9FE),
                        child: Icon(
                          status == 'blocked'
                              ? Icons.block
                              : isSupport
                                  ? Icons.support_agent_outlined
                                  : Icons.forum,
                          color: status == 'blocked'
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF4F46E5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              status == 'blocked'
                                  ? 'Blocked chat'
                                  : isSupport
                                      ? '${supportUserRole.toUpperCase()} - $lastMessage'
                                      : lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
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
