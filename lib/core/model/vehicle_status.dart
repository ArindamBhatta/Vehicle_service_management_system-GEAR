enum VehicleStatus {
  active,
  parked,
  inRestoration,
  sold,
  archived;

  /// Get the string value defined by @JsonValue
  String get value => _$VehicleStatusEnumMap[this]!;

  /// Parse a string value back to VehicleStatus
  static VehicleStatus fromString(String value) {
    return _$VehicleStatusEnumMap.entries
        .firstWhere(
          (entry) => entry.value == value,
          orElse: () => throw ArgumentError('Unknown status: $value'),
        )
        .key;
  }
}

// Manual mapping to match @JsonValue annotations
const _$VehicleStatusEnumMap = {
  VehicleStatus.active: 'active',
  VehicleStatus.parked: 'parked',
  VehicleStatus.inRestoration: 'in_restoration',
  VehicleStatus.sold: 'sold',
  VehicleStatus.archived: 'archived',
};
