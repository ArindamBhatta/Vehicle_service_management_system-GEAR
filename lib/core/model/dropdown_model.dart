import 'package:equatable/equatable.dart';

class DropdownOption extends Equatable {
  final String id;
  final String value;
  final String? category;
  final int displayOrder;
  final bool isActive;
  final String? displayName;
  final String? iconUrl;
  final Map<String, dynamic>? additionalData;

  const DropdownOption({
    required this.id,
    required this.value,
    this.category,
    this.displayOrder = 0,
    this.displayName,
    this.iconUrl,
    this.additionalData,
    this.isActive = true,
  });

  // Getter to maintain compatibility
  String get display => displayName ?? value;

  @override
  List<Object?> get props => [
    id,
    value,
    category,
    displayOrder,
    isActive,
    displayName,
    iconUrl,
    additionalData,
  ];

  factory DropdownOption.fromJson(Map<String, dynamic> json) {
    return DropdownOption(
      id: json['id']?.toString() ?? json['value'] ?? '',
      value: json['value'] as String,
      category: json['category'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      displayName: json['display_name'] as String?,
      iconUrl: json['icon_url'] as String?,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      if (category != null) 'category': category,
      'display_order': displayOrder,
      if (displayName != null) 'display_name': displayName,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (additionalData != null) 'additional_data': additionalData,
      'is_active': isActive,
    };
  }

  @override
  String toString() =>
      'DropdownOption(id: $id, value: $value, display: $display, category: $category, displayOrder: $displayOrder, isActive: $isActive)';
}
