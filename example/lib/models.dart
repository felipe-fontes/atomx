class Message {
  final String id;
  final String fromId;
  final String toId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.content,
    required this.timestamp,
  });
}

class Contact {
  final String id;
  final String name;

  Contact({
    required this.id,
    required this.name,
  });
} 