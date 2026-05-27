import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminChatViewScreen extends StatelessWidget {
  final String chatId;
  final String title;

  const AdminChatViewScreen({
    super.key,
    required this.chatId,
    required this.title,
  });

  Widget _bubble({
    required String text,
    required String senderLabel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            senderLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF111827),
              height: 1.35,
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
        title: Text(title),
        backgroundColor: const Color(0xFFF6F8FC),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').doc(chatId).snapshots(),
        builder: (context, chatSnapshot) {
          final chatData = chatSnapshot.data?.data() as Map<String, dynamic>?;

          final guardianId = chatData?['guardianId'] ?? '';
          final tutorId = chatData?['tutorId'] ?? '';
          final guardianName = chatData?['guardianName'] ?? 'Guardian';
          final tutorName = chatData?['tutorName'] ?? 'Tutor';

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(chatId)
                .collection('messages')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(child: Text('No messages yet'));
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;

                  final senderId = data['senderId'] ?? '';
                  final text = data['text'] ?? '';

                  String senderLabel = 'Unknown';
                  if (senderId == guardianId) senderLabel = guardianName;
                  if (senderId == tutorId) senderLabel = tutorName;

                  return _bubble(
                    text: text,
                    senderLabel: senderLabel,
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