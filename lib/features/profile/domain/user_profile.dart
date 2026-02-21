import 'package:luxe/features/profile/domain/user_role.dart';

class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final UserRole role;
  final bool isVerified;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.role,
    this.isVerified = false,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRoleX.fromString((json['role'] as String?) ?? 'customer'),
      isVerified: (json['is_verified'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role.name,
      'is_verified': isVerified,
    };
  }
}
