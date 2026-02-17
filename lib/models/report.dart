class Report {
  final String id;
  final String contentType; // 'thread' or 'post'
  final String contentId;
  final String reason;
  final String? details;

  const Report({
    required this.id,
    required this.contentType,
    required this.contentId,
    required this.reason,
    this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_type': contentType,
      'content_id': contentId,
      'reason': reason,
      'details': details,
    };
  }
}
