enum UserRole {
  carOwner,
  shopOwner,
  shopEmployee;

  bool get isShopRelated =>
      this == UserRole.shopOwner || this == UserRole.shopEmployee;

  // Direct role check getters
  bool get isShopOwner => this == UserRole.shopOwner;
  bool get isShopEmployee => this == UserRole.shopEmployee;
  bool get isCarOwner => this == UserRole.carOwner;

  // Group roles for potential app split
  bool get isInShopApp => isShopRelated;

  /// Convert string representation to UserRole enum
  static UserRole fromString(String roleStr) {
    for (var role in UserRole.values) {
      if (role.toString().split('.').last == roleStr) {
        return role;
      }
    }
    // Default role
    return UserRole.carOwner;
  }

  /// Returns string value for JSON serialization
  String toJson() {
    return toString().split('.').last;
  }

  /// Convert JSON value to enum
  static UserRole fromJson(String json) {
    return fromString(json);
  }
}
