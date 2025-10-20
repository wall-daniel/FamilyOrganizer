import 'package:family_organizer/models/user.dart';

class Thought {
  final String id;
  final String content;
  final DateTime timestamp;
  final User user;

  Thought({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.user,
  });

  factory Thought.fromJson(Map<String, dynamic> json) {
    return Thought(
      id: json['id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'user': user.toJson(),
    };
  }
}
