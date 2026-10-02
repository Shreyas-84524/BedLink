import 'package:flutter/foundation.dart';

/// Represents an individual clinical bed or facility capability in the hospital inventory.
@immutable
class HospitalResourceItem {
  const HospitalResourceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.isCountable,
    this.total = 0,
    this.available = 0,
    this.held = 0,
    this.occupied = 0,
    this.isOperational = true,
  })  : assert(available >= 0, 'Available cannot be negative'),
        assert(held >= 0, 'Held cannot be negative'),
        assert(occupied >= 0, 'Occupied cannot be negative'),
        assert(
          !isCountable || (available + held + occupied <= total),
          'available + held + occupied must not exceed total capacity',
        );

  final String id;
  final String name;
  final String category;
  final bool isCountable;
  final int total;
  final int available;
  final int held;
  final int occupied;
  final bool isOperational;

  /// Capacity utilization fraction for countable beds (0.0 .. 1.0).
  double get occupancyRate {
    if (!isCountable || total == 0) return 0.0;
    return ((occupied + held) / total).clamp(0.0, 1.0);
  }

  /// True if can be incremented without exceeding total capacity.
  bool get canIncrement => isCountable && (available + held + occupied < total);

  /// True if can be decremented without going negative.
  bool get canDecrement => isCountable && available > 0;

  HospitalResourceItem copyWith({
    String? id,
    String? name,
    String? category,
    bool? isCountable,
    int? total,
    int? available,
    int? held,
    int? occupied,
    bool? isOperational,
  }) {
    return HospitalResourceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isCountable: isCountable ?? this.isCountable,
      total: total ?? this.total,
      available: available ?? this.available,
      held: held ?? this.held,
      occupied: occupied ?? this.occupied,
      isOperational: isOperational ?? this.isOperational,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HospitalResourceItem &&
        other.id == id &&
        other.total == total &&
        other.available == available &&
        other.held == held &&
        other.occupied == occupied &&
        other.isOperational == isOperational;
  }

  @override
  int get hashCode => Object.hash(
        id,
        total,
        available,
        held,
        occupied,
        isOperational,
      );

  @override
  String toString() =>
      'HospitalResourceItem($name: avail=$available, held=$held, occ=$occupied, total=$total)';
}
