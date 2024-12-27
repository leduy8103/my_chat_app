import 'package:flutter/material.dart';
import 'package:my_chat_app/models/message_model.dart';
import 'package:my_chat_app/services/auth_service.dart';

class MessageOptions extends StatelessWidget {
  final Offset position;
  final MessageModel message;
  final Function(String, String) onReaction;
  final Function(String) onReply;
  final Function(String) onDelete;

  const MessageOptions({
    Key? key,
    required this.position,
    required this.message,
    required this.onReaction,
    required this.onReply,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy - 100,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reactions Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ReactionButton('❤️', () => onReaction(message.messageId, '❤️')),
                  _ReactionButton('👍', () => onReaction(message.messageId, '👍')),
                  _ReactionButton('😆', () => onReaction(message.messageId, '😆')),
                  _ReactionButton('😮', () => onReaction(message.messageId, '😮')),
                  _ReactionButton('😢', () => onReaction(message.messageId, '😢')),
                  _ReactionButton('😡', () => onReaction(message.messageId, '😡')),
                ],
              ),
              const Divider(),
              // Actions Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.reply),
                    onPressed: () => onReply(message.messageId),
                  ),
                  if (message.senderId == AuthService().currentUser?.uid)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(message.messageId),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _ReactionButton(this.emoji, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}