class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool profileCompleted;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.profileCompleted,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      profileCompleted: map['profileCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'profileCompleted': profileCompleted,
    };
  }
}