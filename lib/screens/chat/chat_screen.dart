import 'package:flutter/material.dart';
import 'package:my_chat_app/services/auth_service.dart';
import 'package:my_chat_app/widgets/chat/chat_input.dart';
import '../../models/user_model.dart';
import '../../models/message_model.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final UserModel receiver;
  const ChatScreen({Key? key, required this.receiver}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  MessageModel? replyingTo;
  final ChatService _chatService = ChatService();

  void _handleReaction(String messageId, String reaction) {
    _chatService.addReaction(
      widget.receiver.uid,
      messageId,
      reaction,
    );
  }

  void _handleReply(MessageModel message) {
    setState(() {
      replyingTo = message;
    });
  }

  void _cancelReply() {
    setState(() {
      replyingTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.receiver.photoUrl != null
                  ? NetworkImage(widget.receiver.photoUrl!)
                  : null,
              child: widget.receiver.photoUrl == null
                  ? Text(widget.receiver.name[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiver.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<MessageModel>>(
        stream: _chatService.getMessages(widget.receiver.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final messages = snapshot.data!;
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListView.builder(
              reverse: true,
              physics: const BouncingScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final previousMessage =
                    index < messages.length - 1 ? messages[index + 1] : null;
                final bool isSameSender =
                    previousMessage?.senderId == message.senderId;

                return Padding(
                  padding: EdgeInsets.only(
                    top: isSameSender ? 4.0 : 16.0,
                    bottom: index == 0 ? 8.0 : 0.0,
                  ),
                  child: MessageBubble(
                    message: message,
                    isMe: message.senderId == AuthService().currentUser?.uid,
                    onDelete: (messageId) => _chatService.deleteMessage(
                      widget.receiver.uid,
                      messageId,
                    ),
                    onReaction: _handleReaction,
                    onReply: _handleReply,
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ChatInput(
          receiverId: widget.receiver.uid,
          replyingTo: replyingTo,
          onCancelReply: _cancelReply,
          onSend: _cancelReply,
        ),
      ),
    );
  }
}