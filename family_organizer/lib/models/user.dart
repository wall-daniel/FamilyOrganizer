class User {
  final int id; // Changed to int
  final String username;
  final String email;
  final bool isAccepted;
  final int familyId; // Changed to int

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isAccepted,
    required this.familyId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int, // Expecting int from JSON
      username: json['username'],
      email: json['email'],
      isAccepted: json['is_accepted'] == 1,
      familyId: json['family_id'] as int, // Expecting int from JSON
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
