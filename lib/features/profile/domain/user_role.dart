enum UserRole {
  customer,
  retailer,
}

extension UserRoleX on UserRole {
  String get name => toString().split('.').last;
  
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.customer,
    );
  }
}
