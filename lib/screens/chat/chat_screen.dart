import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/auth_service.dart';
import 'package:smart_tutor/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendMessage() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      await ChatService.sendMessage(
        chatId: widget.chatId,
        senderId: user.uid,
        receiverId: widget.receiverId,
        text: text,
      );

      _messageController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _blockChat() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    await ChatService.blockChat(
      chatId: widget.chatId,
      blockedBy: user.uid,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact blocked')),
    );
  }

  Future<void> _removeChat() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    await ChatService.hideChatForUser(
      chatId: widget.chatId,
      userId: user.uid,
    );

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat removed from your list')),
    );
  }

  Widget _messageBubble({
    required String text,
    required bool isMe,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.74,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: Radius.circular(isMe ? 8 : 3),
            bottomRight: Radius.circular(isMe ? 3 : 8),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x080F172A),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : const Color(0xFF111827),
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _inputBar(bool isBlocked) {
    if (isBlocked) {
      return Container(
        padding: const EdgeInsets.all(14),
        color: Colors.white,
        child: const SafeArea(
          child: Text(
            'This chat is blocked. Messages are disabled.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFDC2626),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF2563EB),
              child: IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FB),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        title: Text(widget.receiverName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'block') _blockChat();
              if (value == 'remove') _removeChat();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'block',
                child: Text('Block contact'),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Text('Remove chat'),
              ),
            ],
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('User not logged in'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .snapshots(),
              builder: (context, chatSnapshot) {
                final chatData =
                    chatSnapshot.data?.data() as Map<String, dynamic>?;

                final isBlocked = chatData?['status'] == 'blocked';

                return Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chats')
                            .doc(widget.chatId)
                            .collection('messages')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];

                          if (docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'No messages yet. Start the conversation.',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data =
                                  docs[index].data() as Map<String, dynamic>;

                              final senderId = data['senderId'] ?? '';
                              final text = data['text'] ?? '';

                              return _messageBubble(
                                text: text,
                                isMe: senderId == user.uid,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    _inputBar(isBlocked),
                  ],
                );
              },
            ),
    );
  }
}
