enum UserRole {
  admin,
  businessOwner,
  unknown;

  static UserRole fromString(
      String? value,
      ) {
    switch (value?.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;

      case 'BUSINESS_OWNER':
        return UserRole.businessOwner;

      default:
        return UserRole.unknown;
    }
  }
}