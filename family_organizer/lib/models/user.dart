class User {
  final String id;
  final String username;
  final String email;
  final String familyId;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.familyId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      familyId: json['family_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'family_id': familyId,
    };
  }
}
