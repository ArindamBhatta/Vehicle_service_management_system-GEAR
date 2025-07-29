enum UserRole {
  undefined,
  carOwner,
  shopOwner,
  shopEmployee,
  admin,
  appraiser,
  whiteGloveOfficer,
  customer;

  bool get isShopRelated =>
      this == UserRole.shopOwner ||
      this == UserRole.shopEmployee ||
      this == UserRole.appraiser ||
      this == UserRole.whiteGloveOfficer;

  bool get isCarOwnerRelated =>
      this == UserRole.carOwner || this == UserRole.customer;

  bool get isAdmin => this == UserRole.admin;

  // Direct role check getters
  bool get isShopOwner => this == UserRole.shopOwner;
  bool get isShopEmployee => this == UserRole.shopEmployee;
  bool get isAppraiser => this == UserRole.appraiser;
  bool get isWhiteGloveOfficer => this == UserRole.whiteGloveOfficer;
  bool get isCarOwner => this == UserRole.carOwner;
  bool get isCustomer => this == UserRole.customer;

  // Group roles for potential app split
  bool get isInShopApp => isShopRelated || isAdmin;
  bool get isInCarOwnerApp => isCarOwnerRelated || isAdmin;

  String get displayName {
    switch (this) {
      case UserRole.carOwner:
        return 'DIY/Car Enthusiast';
      case UserRole.shopOwner:
        return 'Shop Owner';
      case UserRole.shopEmployee:
        return 'Shop Employee';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.appraiser:
        return 'Appraiser';
      case UserRole.whiteGloveOfficer:
        return 'RestoMag White Glove Officer';
      case UserRole.customer:
        return 'Customer';
      case UserRole.undefined:
        return 'Undefined';
    }
  }

  /// Convert string representation to UserRole enum
  static UserRole fromString(String roleStr) {
    for (var role in UserRole.values) {
      if (role.toString().split('.').last == roleStr) {
        return role;
      }
    }
    // Default role
    return UserRole.customer;
  }

  /// Returns string value for JSON serialization
  String toJson() {
    return toString().split('.').last;
  }

  /// Convert JSON value to enum
  static UserRole fromJson(String json) {
    return fromString(json);
  }

  /// Check if this role has a specific capability
  bool hasCapability(UserCapability capability) {
    switch (capability) {
      case UserCapability.viewShops:
        return true; // All users can view shops
      case UserCapability.manageShops:
        return this == UserRole.shopOwner || this == UserRole.admin;
      case UserCapability.manageUsers:
        return this == UserRole.admin;
      case UserCapability.manageAppointments:
        return isShopRelated || isAdmin;
      case UserCapability.viewReports:
        return this == UserRole.shopOwner || this == UserRole.admin;
    }
  }

  /// Convert UserRole to unique integer ID
  int get roleToId {
    switch (this) {
      case UserRole.carOwner:
        return 1;
      case UserRole.shopOwner:
        return 2;
      case UserRole.shopEmployee:
        return 3;
      case UserRole.admin:
        return 7;
      case UserRole.appraiser:
        return 4;
      case UserRole.whiteGloveOfficer:
        return 6;
      case UserRole.customer:
        return 5;
      case UserRole.undefined:
        return 0; // Or throw an error, as undefined shouldn't be stored
    }
  }
}

/// User capabilities used for permission checks
enum UserCapability {
  viewShops,
  manageShops,
  manageUsers,
  manageAppointments,
  viewReports,
}
