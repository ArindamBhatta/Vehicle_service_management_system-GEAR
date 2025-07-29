class Shop {
  final String id;
  final String name;
  final String ownerId;
  final String? description;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? logoUrl;
  final List<String> employeeIds;
  final List<String> serviceIds;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Shop({
    required this.id,
    required this.name,
    required this.ownerId,
    this.description,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country = 'US',
    this.phoneNumber,
    this.email,
    this.website,
    this.logoUrl,
    this.employeeIds = const [],
    this.serviceIds = const [],
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory to create a Shop from JSON
  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['owner_id'] as String,
      description: json['description'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      country: json['country'] ?? 'US',
      phoneNumber: json['phone_number'],
      email: json['email'],
      website: json['website'],
      logoUrl: json['logo_url'],
      employeeIds: (json['employeeIds'] as List?)?.cast<String>() ?? [],
      serviceIds: (json['serviceIds'] as List?)?.cast<String>() ?? [],
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Method to convert Shop to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_id': ownerId,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'phone_number': phoneNumber,
      'email': email,
      'website': website,
      'logo_url': logoUrl,
      'employeeIds': employeeIds,
      'serviceIds': serviceIds,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create an empty Shop object
  factory Shop.empty() {
    return Shop(id: '', name: '', ownerId: '', createdAt: DateTime.now());
  }

  /// Helper: is the shop profile filled out?
  bool get isComplete {
    return name.isNotEmpty &&
        address?.isNotEmpty == true &&
        city?.isNotEmpty == true &&
        phoneNumber?.isNotEmpty == true;
  }

  /// Helper: nicely formatted address
  String get formattedAddress {
    final parts = [
      address,
      city,
      state,
      zipCode,
      country,
    ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.join(', ');
  }

  /// Optional: CopyWith if needed
  Shop copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? description,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? phoneNumber,
    String? email,
    String? website,
    String? logoUrl,
    List<String>? employeeIds,
    List<String>? serviceIds,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      employeeIds: employeeIds ?? this.employeeIds,
      serviceIds: serviceIds ?? this.serviceIds,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
