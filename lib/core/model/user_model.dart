import 'package:learn_riverpod/core/globals/user_role.dart';

class AppUser {
  final String id;
  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final UserRole role;
  final List<String> shopIds;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? deviceId;
  final bool isActive;
  final bool isOnboardingComplete;

  AppUser({
    required this.id,
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    required this.role,
    required this.shopIds,
    required this.createdAt,
    this.updatedAt,
    this.deviceId,
    this.isActive = true,
    this.isOnboardingComplete = false,
  });

  AppUser copyWith({
    String? id,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    UserRole? role,
    List<String>? shopIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deviceId,
    bool? isActive,
    bool? isOnboardingComplete,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      shopIds: shopIds ?? this.shopIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      isActive: isActive ?? this.isActive,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
    );
  }

  // Factory constructor to create AppUser from JSON
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'],
      phone: json['phone_number'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImageUrl: json['photo_url'],
      role: _roleFromId(json['role_id']),
      shopIds: _shopIdFromJson(json['shop_id']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deviceId: json['device_id'],
      isActive: json['is_active'] ?? true,
      isOnboardingComplete: json['is_onboarding_complete'] ?? false,
    );
  }

  // Method to convert AppUser to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phone,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': profileImageUrl,
      'role_id': _roleToId(role),
      'shop_id': _shopIdToJson(shopIds),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'device_id': deviceId,
      'is_active': isActive,
      'is_onboarding_complete': isOnboardingComplete,
    };
  }

  String get fullName =>
      [firstName, lastName].where((e) => e?.isNotEmpty ?? false).join(' ');

  bool hasCapability(UserCapability capability) {
    return role.hasCapability(capability);
  }
}

// Helper functions for role_id and shop_id

UserRole _roleFromId(dynamic roleId) {
  switch (roleId) {
    case 1:
      return UserRole.carOwner;
    case 2:
      return UserRole.shopOwner;
    case 3:
      return UserRole.shopEmployee;
    case 4:
      return UserRole.appraiser;
    case 5:
      return UserRole.whiteGloveOfficer;
    case 6:
      return UserRole.admin;
    case 0:
      return UserRole.undefined;
    default:
      return UserRole.customer;
  }
}

int _roleToId(UserRole role) {
  switch (role) {
    case UserRole.carOwner:
      return 1;
    case UserRole.shopOwner:
      return 2;
    case UserRole.shopEmployee:
      return 3;
    case UserRole.appraiser:
      return 4;
    case UserRole.whiteGloveOfficer:
      return 5;
    case UserRole.admin:
      return 6;
    case UserRole.customer:
      return 1;
    case UserRole.undefined:
      return 0;
  }
}

List<String> _shopIdFromJson(dynamic shopId) {
  if (shopId is String) {
    return [shopId];
  } else if (shopId is List) {
    return List<String>.from(shopId);
  }
  return [];
}

String? _shopIdToJson(List<String> shopIds) {
  return shopIds.isNotEmpty ? shopIds.first : null;
}
