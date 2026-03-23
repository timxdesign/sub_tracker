class Profile {
  const Profile({
    required this.fullName,
    required this.email,
    required this.createdAt,
  });

  final String fullName;
  final String email;
  final DateTime createdAt;
}
