class User {
  final String id;
  final String username;
  final String email;
  final bool isAccepted;
  final String familyId;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isAccepted,
    required this.familyId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      isAccepted: json['is_accepted'] ?? false, // Default to false if not present
      familyId: json['family_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'is_accepted': isAccepted,
      'family_id': familyId,
    };
  }
}
