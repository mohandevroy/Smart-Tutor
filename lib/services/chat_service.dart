import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String buildChatId({
    required String guardianId,
    required String tutorId,
  }) {
    return '${guardianId}_$tutorId';
  }

  static Future<String> createOrGetChat({
    required String requestId,
    required String guardianId,
    required String guardianName,
    required String tutorId,
    required String tutorName,
  }) async {
    final chatId = buildChatId(
      guardianId: guardianId,
      tutorId: tutorId,
    );

    final chatRef = _firestore.collection('chats').doc(chatId);

    await chatRef.set(
      {
        'chatId': chatId,
        'requestId': requestId,
        'guardianId': guardianId,
        'guardianName': guardianName,
        'tutorId': tutorId,
        'tutorName': tutorName,
        'participants': [guardianId, tutorId],
        'chatType': 'tuition',
        'status': 'active',
        'blockedBy': null,
        'hiddenFor': [],
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return chatId;
  }

  static Future<Map<String, String>> createOrGetAdminSupportChat({
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    const adminId = 'platform_admin_support';
    const adminName = 'Admin Support';
    final chatId = 'support_${userId}_$adminId';
    final chatRef = _firestore.collection('chats').doc(chatId);

    await chatRef.set(
      {
        'chatId': chatId,
        'chatType': 'support',
        'supportUserId': userId,
        'supportUserName': userName,
        'supportUserRole': userRole,
        'adminId': adminId,
        'adminName': adminName,
        'participants': [userId, adminId],
        'status': 'active',
        'blockedBy': null,
        'hiddenFor': [],
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return {
      'chatId': chatId,
      'adminId': adminId,
      'adminName': adminName,
    };
  }

  static Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) return;

    final chatRef = _firestore.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc();

    await messageRef.set({
      'messageId': messageRef.id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': cleanText,
      'type': 'text',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await chatRef.update({
      'lastMessage': cleanText,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> blockChat({
    required String chatId,
    required String blockedBy,
  }) async {
    await _firestore.collection('chats').doc(chatId).update({
      'status': 'blocked',
      'blockedBy': blockedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> hideChatForUser({
    required String chatId,
    required String userId,
  }) async {
    await _firestore.collection('chats').doc(chatId).update({
      'hiddenFor': FieldValue.arrayUnion([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
