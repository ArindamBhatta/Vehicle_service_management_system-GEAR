import 'package:gear_app/core/globals/user_role.dart';

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
      role: UserRole.fromString(json['role']),
      shopIds: [],
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'device_id': deviceId,
      'is_active': isActive,
      'is_onboarding_complete': isOnboardingComplete,
    };
  }

  String get fullName =>
      [firstName, lastName].where((e) => e?.isNotEmpty ?? false).join(' ');
}
