class Message {
  final String user;
  final String message;
  final String channel;
  final String university;
  final DateTime timestamp;
  String? username;
  String? imageUrl;

  Message({
    required this.user,
    required this.message,
    required this.channel,
    required this.university,
    required this.timestamp,
    this.username,
    this.imageUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      user: json['user'],
      message: json['message'],
      channel: json['channel'],
      university: json['university'],
      timestamp: DateTime.parse(json['timestamp']),
      username: json['username'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'message': message,
      'channel': channel,
      'university': university,
      'timestamp': timestamp.toIso8601String(),
      'username': username,
      'imageUrl': imageUrl,
    };
  }
}
