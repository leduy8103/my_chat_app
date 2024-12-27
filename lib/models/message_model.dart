class MessageModel {
  final String messageId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isDeleted;
  final Map<String, String>? reactions; // userId: emoji

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isDeleted = false,
    this.reactions,
  });

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'senderId': senderId,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'isDeleted': isDeleted,
    'reactions': reactions,
  };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    messageId: json['messageId'] ?? '',
    senderId: json['senderId'] ?? '',
    text: json['text'] ?? '',
    timestamp: DateTime.parse(json['timestamp']),
    isDeleted: json['isDeleted'] ?? false,
    reactions: json['reactions'] != null 
        ? Map<String, String>.from(json['reactions'])
        : null,
  );
}