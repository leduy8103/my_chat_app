class MessageModel {
  final String messageId;
  final String senderId;
  final String? text;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isDeleted;
  final Map<String, String>? reactions;
  final String? replyTo;
  final String? replyText;

  MessageModel({
    required this.messageId,
    required this.senderId,
    this.text,
    this.imageUrl,
    required this.timestamp,
    this.isDeleted = false,
    this.reactions,
    this.replyTo,
    this.replyText,
  });

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'senderId': senderId,
    'text': text,
        'imageUrl': imageUrl,
    'timestamp': timestamp.toIso8601String(),
    'isDeleted': isDeleted,
    'reactions': reactions,
        'replyTo': replyTo,
        'replyText': replyText,
  };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    messageId: json['messageId'] ?? '',
    senderId: json['senderId'] ?? '',
        text: json['text'],
        imageUrl: json['imageUrl'],
    timestamp: DateTime.parse(json['timestamp']),
    isDeleted: json['isDeleted'] ?? false,
    reactions: json['reactions'] != null 
        ? Map<String, String>.from(json['reactions'])
        : null,
        replyTo: json['replyTo'],
        replyText: json['replyText'],
  );
}