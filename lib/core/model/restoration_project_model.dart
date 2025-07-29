enum ProjectStatus {
  pending,
  inProgress,
  onHold,
  completed,
  cancelled;

  /// Convert enum to string for JSON
  String get value => _$ProjectStatusEnumMap[this]!;

  /// Convert string to enum from JSON
  static ProjectStatus fromString(String value) {
    return _$ProjectStatusEnumMap.entries
        .firstWhere(
          (e) => e.value == value,
          orElse: () => throw ArgumentError('Unknown ProjectStatus: $value'),
        )
        .key;
  }
}

// Manual map for enum serialization
const _$ProjectStatusEnumMap = {
  ProjectStatus.pending: 'pending',
  ProjectStatus.inProgress: 'in_progress',
  ProjectStatus.onHold: 'on_hold',
  ProjectStatus.completed: 'completed',
  ProjectStatus.cancelled: 'cancelled',
};

class RestorationProject {
  final String id;
  final String name;
  final String vehicleId;
  final String? shopId;
  final String? ownerId;
  final String? description;
  final DateTime? startDate;
  final DateTime? estimatedCompletionDate;
  final DateTime? completionDate;
  final ProjectStatus status;
  final double? budget;
  final double? totalCost;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RestorationProject({
    required this.id,
    required this.name,
    required this.vehicleId,
    this.shopId,
    this.ownerId,
    this.description,
    this.startDate,
    this.estimatedCompletionDate,
    this.completionDate,
    this.status = ProjectStatus.pending,
    this.budget,
    this.totalCost,
    this.createdAt,
    this.updatedAt,
  });

  /// From JSON
  factory RestorationProject.fromJson(Map<String, dynamic> json) {
    return RestorationProject(
      id: json['id'] as String,
      name: json['name'] as String,
      vehicleId: json['vehicleId'] ?? json['vehicle_id'],
      shopId: json['shopId'] ?? json['shop_id'],
      ownerId: json['ownerId'] ?? json['owner_id'],
      description: json['description'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      estimatedCompletionDate: json['estimated_completion_date'] != null
          ? DateTime.parse(json['estimated_completion_date'])
          : null,
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
      status: json['status'] != null
          ? ProjectStatus.fromString(json['status'])
          : ProjectStatus.pending,
      budget: (json['budget'] as num?)?.toDouble(),
      totalCost: (json['totalCost'] ?? json['total_cost']) != null
          ? (json['totalCost'] ?? json['total_cost'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vehicle_id': vehicleId,
      'shop_id': shopId,
      'owner_id': ownerId,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'estimated_completion_date': estimatedCompletionDate?.toIso8601String(),
      'completion_date': completionDate?.toIso8601String(),
      'status': status.value,
      'budget': budget,
      'total_cost': totalCost,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// CopyWith
  RestorationProject copyWith({
    String? id,
    String? name,
    String? vehicleId,
    String? shopId,
    String? ownerId,
    String? description,
    DateTime? startDate,
    DateTime? estimatedCompletionDate,
    DateTime? completionDate,
    ProjectStatus? status,
    double? budget,
    double? totalCost,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestorationProject(
      id: id ?? this.id,
      name: name ?? this.name,
      vehicleId: vehicleId ?? this.vehicleId,
      shopId: shopId ?? this.shopId,
      ownerId: ownerId ?? this.ownerId,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      estimatedCompletionDate:
          estimatedCompletionDate ?? this.estimatedCompletionDate,
      completionDate: completionDate ?? this.completionDate,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      totalCost: totalCost ?? this.totalCost,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
