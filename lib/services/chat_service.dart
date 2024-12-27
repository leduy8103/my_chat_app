import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_chat_app/models/user_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getChatId(String userId1, String userId2) {
    final userIds = [userId1, userId2]..sort();
    return userIds.join('_');
  }

  Future<void> createChat(String otherUserId) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatId = getChatId(currentUserId, otherUserId);

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'chatId': chatId,
        'userIds': [currentUserId, otherUserId],
        'lastMessage': null,
        'lastMessageTime': null,
      });
    }
  }

 Stream<List<MessageModel>> getMessages(String otherUserId) {
  final chatId = getChatId(_auth.currentUser!.uid, otherUserId);
  
  return _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => MessageModel(
                messageId: doc.id,
                senderId: doc.data()['senderId'],
                text: doc.data()['text'] ?? '',
                timestamp: DateTime.parse(doc.data()['timestamp']),
              ))
          .toList());
}

  Future<void> sendMessage(String receiverId, String message) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatId = getChatId(currentUserId, receiverId);
    final timestamp = DateTime.now();

    final messageDoc = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': currentUserId,
          'text': message,
          'timestamp': timestamp.toIso8601String(),
        });

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': timestamp.toIso8601String(),
    });
  }

  Future<void> deleteMessage(String receiverId, String messageId) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatId = getChatId(currentUserId, receiverId);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'isDeleted': true,
          'text': '[Message deleted]',
        });
  }

  Future<void> replyToMessage(String receiverId, String replyToMessageId, String newMessage) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatId = getChatId(currentUserId, receiverId);
    final timestamp = DateTime.now();

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': currentUserId,
          'text': newMessage,
          'timestamp': timestamp.toIso8601String(),
          'replyTo': replyToMessageId,
        });
  }

  Stream<List<UserModel>> getUsers() {
    String currentUserId = _auth.currentUser?.uid ?? '';
    
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    });
  }

  Stream<List<UserModel>> getAllUsers() {
    final currentUserId = _auth.currentUser?.uid;
    
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromJson(doc.data()))
            .toList());
  }
  
  Future<void> addReaction(String receiverId, String messageId, String emoji) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatId = getChatId(currentUserId, receiverId);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'reactions.$currentUserId': emoji,
        });
  }
}