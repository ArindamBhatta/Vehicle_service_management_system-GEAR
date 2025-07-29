class VehicleImage {
  final String id;
  final String vehicleId;
  final String imageUrl;
  final bool isPrimary;
  final String? caption;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VehicleImage({
    required this.id,
    required this.vehicleId,
    required this.imageUrl,
    this.isPrimary = false,
    this.caption,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to create a VehicleImage from JSON
  factory VehicleImage.fromJson(Map<String, dynamic> json) {
    return VehicleImage(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      imageUrl: json['image_url'] as String,
      isPrimary: json['is_primary'] ?? false,
      caption: json['caption'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Method to convert a VehicleImage to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'caption': caption,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// CopyWith method for updating fields
  VehicleImage copyWith({
    String? id,
    String? vehicleId,
    String? imageUrl,
    bool? isPrimary,
    String? caption,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleImage(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
