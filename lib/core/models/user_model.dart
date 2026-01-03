class UserModel {
  final String id;
  final String? email;
  final String? phone;
  final String? name;
  final String role; // 'client', 'consultant', 'admin'
  final String? authProvider; // 'email', 'phone', 'google'
  final String? googleId;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    this.email,
    this.phone,
    this.name,
    this.role = 'client',
    this.authProvider,
    this.googleId,
    this.emailVerified = false,
    this.phoneVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'client',
      authProvider: json['auth_provider'] as String?,
      googleId: json['google_id'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'role': role,
      'auth_provider': authProvider,
      'google_id': googleId,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    String? role,
    String? authProvider,
    String? googleId,
    bool? emailVerified,
    bool? phoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
      authProvider: authProvider ?? this.authProvider,
      googleId: googleId ?? this.googleId,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

