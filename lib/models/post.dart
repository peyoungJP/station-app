class Post {
  final String id;
  final String threadId;
  final String body;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.threadId,
    required this.body,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      threadId: json['thread_id'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thread_id': threadId,
      'body': body,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
