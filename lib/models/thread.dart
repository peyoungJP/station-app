class Thread {
  final String id;
  final String stationId;
  final String title;
  final String body;
  final DateTime createdAt;
  final int postCount;
  final DateTime? lastPostedAt;

  const Thread({
    required this.id,
    required this.stationId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.postCount = 0,
    this.lastPostedAt,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'] as String,
      stationId: json['station_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      postCount: json['post_count'] as int? ?? 0,
      lastPostedAt: json['last_posted_at'] != null
          ? DateTime.parse(json['last_posted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'station_id': stationId,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
