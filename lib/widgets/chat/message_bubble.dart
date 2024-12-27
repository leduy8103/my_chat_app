import 'package:flutter/material.dart';
import 'package:my_chat_app/widgets/chat/message_option.dart';
import '../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Function(String) onDelete;
  final Function(String, String)? onReaction;
  final Function(MessageModel)? onReply;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.onDelete,
    this.onReaction,
    this.onReply,
  }) : super(key: key);

  void _showMessageOptions(BuildContext context) {
    if (message.isDeleted) return;

    final RenderBox messageBox = 
        context.findRenderObject() as RenderBox;
    final messagePosition = messageBox.localToGlobal(Offset.zero);
    final messageSize = messageBox.size;

    final screenWidth = MediaQuery.of(context).size.width;
    double menuX = messagePosition.dx;
    double menuY = messagePosition.dy - 60;

    // Adjust menu position if too close to screen edges
    if (menuX + 200 > screenWidth) {
      menuX = screenWidth - 220;
    }
    if (menuY < 100) {
      menuY = messagePosition.dy + messageSize.height;
    }

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned(
            left: menuX,
            top: menuY,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildReactionButton(context, '❤️'),
                        _buildReactionButton(context, '👍'),
                        _buildReactionButton(context, '😆'),
                        _buildReactionButton(context, '😢'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onReply != null)
                          IconButton(
                            icon: const Icon(Icons.reply),
                            onPressed: () {
                              Navigator.pop(context);
                              onReply!(message);
                            },
                          ),
                        if (isMe)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete(message.messageId);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(BuildContext context, String emoji) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onReaction?.call(message.messageId, emoji);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () => _showMessageOptions(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        if (message.reactions?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.reactions!.values.join(),
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  ' ${message.reactions!.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}