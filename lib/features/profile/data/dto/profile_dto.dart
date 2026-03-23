import '../../domain/models/profile.dart';

class ProfileDto {
  const ProfileDto({
    required this.fullName,
    required this.email,
    required this.createdAt,
  });

  final String fullName;
  final String email;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Profile toDomain() {
    return Profile(fullName: fullName, email: email, createdAt: createdAt);
  }

  factory ProfileDto.fromDomain(Profile profile) {
    return ProfileDto(
      fullName: profile.fullName,
      email: profile.email,
      createdAt: profile.createdAt,
    );
  }
}
