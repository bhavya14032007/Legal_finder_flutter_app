enum MessageSender {
  user,
  ai,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String>? legalCitations;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.legalCitations,
    this.isError = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'citations': legalCitations,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      sender: MessageSender.values.byName(json['sender'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      legalCitations: (json['citations'] as List?)?.cast<String>(),
    );
  }
}

