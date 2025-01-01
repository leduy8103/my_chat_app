import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../models/message_model.dart';

class ChatInput extends StatefulWidget {
  final String receiverId;
  final MessageModel? replyingTo;
  final VoidCallback? onSend;
  final VoidCallback? onCancelReply;

  const ChatInput({
    Key? key, 
    required this.receiverId,
    this.replyingTo,
    this.onSend,
    this.onCancelReply,
  }) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.replyingTo != null)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Row(
              children: [
                const Icon(Icons.reply, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Replying to:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        widget.replyingTo!.text ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancelReply,
                ),
              ],
            ),
          ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    try {
      await _chatService.createChat(widget.receiverId);
      
      if (widget.replyingTo != null) {
        await _chatService.sendMessage(
          widget.receiverId,
          text: _messageController.text.trim(),
          replyTo: widget.replyingTo,
        );
      } else {
        await _chatService.sendMessage(
          widget.receiverId,
          text: _messageController.text.trim(),
        );
      }

      _messageController.clear();
      widget.onSend?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}