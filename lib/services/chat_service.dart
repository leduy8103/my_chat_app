import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_chat_app/models/user_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
                  replyTo: doc.data()['replyTo'],
                  replyText: doc.data()['replyText'],
                  reactions: doc.data()['reactions'] != null
                      ? Map<String, String>.from(doc.data()['reactions'])
                      : null,
              ))
          .toList());
}

  Future<void> sendMessage(
    String receiverId, {
    String? text,
    File? imageFile,
    MessageModel? replyTo,
  }) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatId = getChatId(currentUserId, receiverId);
    final timestamp = DateTime.now();

    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadImage(receiverId, imageFile);
    }

    final messageData = {
      'senderId': currentUserId,
      'timestamp': timestamp.toIso8601String(),
    };

    if (text != null) messageData['text'] = text;
    if (imageUrl != null) messageData['imageUrl'] = imageUrl;

    if (replyTo != null) {
      messageData['replyTo'] = replyTo.messageId;
      messageData['replyText'] = replyTo.text ?? '';
    }

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text ?? (imageUrl != null ? '[Image]' : ''),
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

  Future<void> replyToMessage(
      String receiverId, MessageModel replyToMessage, String newMessage) async {
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
      'replyTo': replyToMessage.messageId,
      'replyText': replyToMessage.text,
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

  Future<String?> uploadImage(String receiverId, File imageFile) async {
    try {
      final currentUserId = _auth.currentUser!.uid;
      final chatId = getChatId(currentUserId, receiverId);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final ref = _storage
          .ref()
          .child('chats')
          .child(chatId)
          .child('images')
          .child('IMG_$timestamp.jpg');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}