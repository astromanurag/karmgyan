class ConsultantModel {
  final String id;
  final String userId;
  final String? name;
  final String? specialization;
  final int? experienceYears;
  final double? hourlyRate;
  final String? bio;
  final String? profilePhotoUrl;
  final String status; // 'pending', 'approved', 'rejected', 'inactive'
  final Map<String, dynamic>? availability;
  final List<Map<String, dynamic>>? qualifications;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  ConsultantModel({
    required this.id,
    required this.userId,
    this.name,
    this.specialization,
    this.experienceYears,
    this.hourlyRate,
    this.bio,
    this.profilePhotoUrl,
    this.status = 'pending',
    this.availability,
    this.qualifications,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  factory ConsultantModel.fromJson(Map<String, dynamic> json) {
    return ConsultantModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String?,
      specialization: json['specialization'] as String?,
      experienceYears: json['experience_years'] as int?,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      bio: json['bio'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      availability: json['availability'] as Map<String, dynamic>?,
      qualifications: json['qualifications'] != null
          ? List<Map<String, dynamic>>.from(json['qualifications'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      approvedBy: json['approved_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'specialization': specialization,
      'experience_years': experienceYears,
      'hourly_rate': hourlyRate,
      'bio': bio,
      'profile_photo_url': profilePhotoUrl,
      'status': status,
      'availability': availability,
      'qualifications': qualifications,
      'created_at': createdAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by': approvedBy,
    };
  }
}

