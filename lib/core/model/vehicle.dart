import 'package:learn_riverpod/core/model/vehicle_status.dart';

class Vehicle {
  final String id;
  final String? make;
  final String? model;
  final int? year;
  final String? licensePlate;
  final String? color;
  final String? vin;
  final int? mileage;
  final DateTime? lastServiceDate;
  final String vehicleType;
  final VehicleStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vehicle({
    required this.id,
    this.make,
    this.model,
    this.year,
    this.licensePlate,
    this.color,
    this.vin,
    this.mileage,
    this.lastServiceDate,
    this.vehicleType = 'Sedan',
    this.status = VehicleStatus.active,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a Vehicle from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      make: json['make'],
      model: json['model'],
      year: json['year'],
      licensePlate: json['license_plate'],
      color: json['color'],
      vin: json['vin'],
      mileage: json['mileage'],
      lastServiceDate: json['last_service_date'] != null
          ? DateTime.parse(json['last_service_date'])
          : null,
      vehicleType: json['vehicle_type'] ?? 'Sedan',
      status: VehicleStatus.fromString(json['status'] ?? 'active'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Convert Vehicle to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'color': color,
      'vin': vin,
      'mileage': mileage,
      'last_service_date': lastServiceDate?.toIso8601String(),
      'vehicle_type': vehicleType,
      'status': status.value,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// CopyWith method
  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    String? color,
    String? vin,
    int? mileage,
    DateTime? lastServiceDate,
    String? vehicleType,
    VehicleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      vin: vin ?? this.vin,
      mileage: mileage ?? this.mileage,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
