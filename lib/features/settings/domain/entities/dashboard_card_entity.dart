// ============================================================
// FEATURE: Settings — Domain Entity
// lib/features/settings/domain/entities/dashboard_card_entity.dart
// ============================================================

import 'package:equatable/equatable.dart';

class DashboardCardEntity extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final bool isEnabled;
  final int sortOrder;

  const DashboardCardEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.isEnabled,
    required this.sortOrder,
  });

  DashboardCardEntity copyWith({
    String? id, String? title, String? subtitle, String? iconName,
    bool? isEnabled, int? sortOrder,
  }) {
    return DashboardCardEntity(
      id: id ?? this.id, title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle, iconName: iconName ?? this.iconName,
      isEnabled: isEnabled ?? this.isEnabled, sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [id, title, subtitle, iconName, isEnabled, sortOrder];
}
