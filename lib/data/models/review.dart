enum ReviewModerationStatus { pending, approved, hidden }

class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.suggestions,
    required this.createdAt,
    this.name,
    this.registrationId,
    this.studentId,
    this.status = ReviewModerationStatus.approved,
  });

  final String id;
  final double rating;
  final String comment;
  final String suggestions;
  final DateTime createdAt;
  final String? name;
  final String? registrationId;
  final String? studentId;
  final ReviewModerationStatus status;

  bool get isPublic => status == ReviewModerationStatus.approved;

  Review copyWith({ReviewModerationStatus? status, String? name}) {
    return Review(
      id: id,
      rating: rating,
      comment: comment,
      suggestions: suggestions,
      createdAt: createdAt,
      name: name ?? this.name,
      registrationId: registrationId,
      studentId: studentId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
        'rating': rating,
        'comment': comment,
        'suggestions': suggestions,
        'createdAt': createdAt.toIso8601String(),
        'name': name,
        'registrationId': registrationId,
        'studentId': studentId,
        'status': status.name,
      };

  factory Review.fromMap(String id, Map<String, dynamic> map) {
    final statusRaw = map['status'] as String? ?? 'approved';
    return Review(
      id: id,
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String? ?? '',
      suggestions: map['suggestions'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      name: map['name'] as String?,
      registrationId: map['registrationId'] as String?,
      studentId: map['studentId'] as String?,
      status: ReviewModerationStatus.values.firstWhere(
        (e) => e.name == statusRaw,
        orElse: () => ReviewModerationStatus.approved,
      ),
    );
  }
}
