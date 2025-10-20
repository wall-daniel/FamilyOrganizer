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
      id: json['id'] as int,
      username: json['username'],
      email: json['email'],
      isAccepted: json['is_accepted'],
      familyId: json['family_id'] as int,
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
