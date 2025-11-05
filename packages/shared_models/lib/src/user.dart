enum UserRole {
  customer,
  courier,
  restaurant,
  admin,
}

class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.phone,
    this.displayName,
  });

  final String id;
  final String email;
  final UserRole role;
  final String? phone;
  final String? displayName;
}
