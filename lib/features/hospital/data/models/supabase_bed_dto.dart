import 'package:flutter/foundation.dart';

/// Data Transfer Object representing an individual physical bed slot from Supabase `public.beds`.
///
/// Exactly mirrors the existing cloud table schema:
/// - `id` (uuid, PK)
/// - `hospital_id` (uuid, FK -> hospitals.id)
/// - `bed_type` (varchar: 'emergency', 'general', 'ICU')
/// - `status` (varchar: 'available', 'reserved', 'occupied')
/// - `updated_at` (timestamptz)
@immutable
class SupabaseBedDto {
  const SupabaseBedDto({
    required this.id,
    required this.hospitalId,
    required this.bedType,
    required this.status,
    required this.updatedAt,
  });

  factory SupabaseBedDto.fromJson(Map<String, dynamic> json) {
    return SupabaseBedDto(
      id: json['id']?.toString() ?? '',
      hospitalId: json['hospital_id']?.toString() ?? '',
      bedType: json['bed_type']?.toString().trim() ?? '',
      status: json['status']?.toString().trim().toLowerCase() ?? 'available',
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  final String id;
  final String hospitalId;
  final String bedType;
  final String status;
  final DateTime updatedAt;

  /// Translates raw database `bed_type` to BedLink canonical resource ID.
  ///
  /// Database values:
  /// - `'ICU'` -> `'icu_bed'`
  /// - `'general'` -> `'general_bed'`
  /// - `'emergency'` -> `'er_bed'`
  String get canonicalResourceId {
    final lower = bedType.toLowerCase();
    if (lower == 'icu') return 'icu_bed';
    if (lower == 'general') return 'general_bed';
    if (lower == 'emergency') return 'er_bed';
    return 'unknown_$lower';
  }

  /// Whether this bed belongs to one of the 3 real supported types in Supabase.
  bool get isSupportedType =>
      canonicalResourceId == 'icu_bed' ||
      canonicalResourceId == 'general_bed' ||
      canonicalResourceId == 'er_bed';

  /// Translates raw database `status` to BedLink domain slot status.
  ///
  /// Database values:
  /// - `'available'` -> `'available'`
  /// - `'reserved'`  -> `'held'`
  /// - `'occupied'`  -> `'occupied'`
  String get domainStatus {
    final s = status.toLowerCase();
    if (s == 'available') return 'available';
    if (s == 'reserved') return 'held';
    if (s == 'occupied') return 'occupied';
    return 'unknown';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hospital_id': hospitalId,
      'bed_type': bedType,
      'status': status,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupabaseBedDto &&
        other.id == id &&
        other.hospitalId == hospitalId &&
        other.bedType == bedType &&
        other.status == status &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, hospitalId, bedType, status, updatedAt);

  @override
  String toString() =>
      'SupabaseBedDto(id: $id, hosp: $hospitalId, type: $bedType, status: $status)';
}
