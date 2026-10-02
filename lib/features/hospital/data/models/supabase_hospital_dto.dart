import 'package:flutter/foundation.dart';
import '../../../../core/theme/semantic_tokens.dart';
import '../../../matching/domain/models/hospital_match.dart';
import '../../../matching/domain/models/match_score.dart';

/// Data Transfer Object mapping directly to the existing `public.hospitals` Supabase table.
///
/// Columns mapped:
/// - `id` (uuid)
/// - `name` (varchar)
/// - `address` (text)
/// - `latitude` (numeric, nullable)
/// - `longitude` (numeric, nullable)
/// - `hospital_load` (integer, default 0)
/// - `facilities` (jsonb, string array e.g. `["Trauma Care", "Emergency", "ICU"]`)
/// - `is_active` (boolean, default true)
/// - `created_at` (timestamptz)
/// - `ward_name` (text, nullable)
/// - `hospital_type` (text, nullable)
/// - `total_beds` (integer, nullable)
/// - `contact` (text, nullable)
/// - `availability_is_simulated` (boolean, default true)
@immutable
class SupabaseHospitalDto {
  const SupabaseHospitalDto({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.hospitalLoad = 0,
    this.facilities = const [],
    this.isActive = true,
    this.createdAt,
    this.wardName,
    this.hospitalType,
    this.totalBeds,
    this.contact,
    this.availabilityIsSimulated = true,
  });

  /// Factory deserializer converting raw PostgREST JSON row to [SupabaseHospitalDto].
  factory SupabaseHospitalDto.fromJson(Map<String, dynamic> json) {
    // Parse coordinates with support for num or string representation
    double? parseCoordinate(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val.trim());
      return null;
    }

    // Parse facilities JSONB array safely
    List<String> parseFacilities(dynamic val) {
      if (val == null) return const [];
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      }
      return const [];
    }

    // Parse total beds safely
    int? parseBeds(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val.trim());
      return null;
    }

    // Parse hospital load safely
    int parseLoad(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val.trim()) ?? 0;
      return 0;
    }

    // Parse created_at safely
    DateTime? parseDateTime(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return SupabaseHospitalDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: parseCoordinate(json['latitude']),
      longitude: parseCoordinate(json['longitude']),
      hospitalLoad: parseLoad(json['hospital_load']),
      facilities: parseFacilities(json['facilities']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: parseDateTime(json['created_at']),
      wardName: json['ward_name']?.toString().trim(),
      hospitalType: json['hospital_type']?.toString().trim(),
      totalBeds: parseBeds(json['total_beds']),
      contact: json['contact']?.toString().trim(),
      availabilityIsSimulated: json['availability_is_simulated'] as bool? ?? true,
    );
  }

  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final int hospitalLoad;
  final List<String> facilities;
  final bool isActive;
  final DateTime? createdAt;
  final String? wardName;
  final String? hospitalType;
  final int? totalBeds;
  final String? contact;
  final bool availabilityIsSimulated;

  /// Whether valid latitude and longitude coordinates exist for this hospital.
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Serializes DTO to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'hospital_load': hospitalLoad,
      'facilities': facilities,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'ward_name': wardName,
      'hospital_type': hospitalType,
      'total_beds': totalBeds,
      'contact': contact,
      'availability_is_simulated': availabilityIsSimulated,
    };
  }

  /// Maps raw database facilities strings into standardized BedLink capability codes.
  ///
  /// Maps:
  /// - 'Trauma Care' -> 'trauma_care'
  /// - 'Emergency'   -> 'emergency_care'
  /// - 'ICU'         -> 'icu_care'
  ///
  /// Explicitly does NOT invent unsupported capabilities (cardiac, burns, pediatric icu).
  Set<String> mapSupportedCapabilities() {
    final capabilities = <String>{};
    for (final facility in facilities) {
      final normalized = facility.toLowerCase();
      if (normalized.contains('trauma')) {
        capabilities.add('trauma_care');
      }
      if (normalized.contains('emergency')) {
        capabilities.add('emergency_care');
      }
      if (normalized.contains('icu')) {
        capabilities.add('icu_care');
      }
    }
    return capabilities;
  }

  /// Converts this database DTO into a Phase 11 hybrid [HospitalMatch] domain object.
  ///
  /// Combines:
  /// - REAL backend data: id, name, address, ward/area, coordinates, contact, total beds, capabilities.
  /// - PRESERVED mock data: rank, etaMinutes, distanceKm, matchScore, availability counts, freshness.
  HospitalMatch toDomainMatch({
    int rank = 1,
    double defaultDistanceKm = 5.0,
    int defaultEtaMinutes = 12,
    double defaultScore = 88.0,
    RecommendationTier defaultTier = RecommendationTier.strongMatch,
  }) {
    // Determine load state from hospitalLoad (0..100)
    HospitalLoadState loadState;
    if (hospitalLoad < 40) {
      loadState = HospitalLoadState.low;
    } else if (hospitalLoad < 75) {
      loadState = HospitalLoadState.moderate;
    } else {
      loadState = HospitalLoadState.high;
    }

    final areaLabel = wardName != null && wardName!.isNotEmpty
        ? 'Ward $wardName, Mumbai'
        : (hospitalType != null && hospitalType!.isNotEmpty
            ? '$hospitalType Hospital, Mumbai'
            : 'Mumbai, Maharashtra');

    // Simulate bed availability proportionally from total_beds or default fallback
    final bedsBase = totalBeds ?? 50;
    final simulatedGeneral = (bedsBase * 0.15).round().clamp(1, 40);
    final simulatedEmergency = (bedsBase * 0.08).round().clamp(1, 15);
    final hasIcu = facilities.any((f) => f.toLowerCase().contains('icu'));
    final simulatedIcu = hasIcu ? (bedsBase * 0.05).round().clamp(1, 10) : 0;

    return HospitalMatch(
      id: id,
      name: name,
      address: address,
      area: areaLabel,
      latitude: latitude,
      longitude: longitude,
      distanceKm: defaultDistanceKm,
      etaMinutes: defaultEtaMinutes,
      updatedMinutesAgo: 3,
      freshnessState: FreshnessState.fresh,
      loadState: loadState,
      occupancyRate: hospitalLoad.clamp(0, 100),
      rank: rank,
      recommendationTier: rank == 1 ? RecommendationTier.topMatch : defaultTier,
      matchScore: defaultScore,
      availableBedCounts: {
        'general_bed': simulatedGeneral,
        'emergency_bed': simulatedEmergency,
        'icu_bed': simulatedIcu,
        'oxygen_bed': (simulatedGeneral * 0.4).round(),
        'ventilator': (simulatedIcu * 0.5).round(),
        'pediatric_icu_bed': 0,
      },
      supportedCapabilities: mapSupportedCapabilities(),
      routeSummary: 'via Mumbai Emergency Transit Corridor',
      emergencyPhone: (contact != null && contact!.isNotEmpty)
          ? contact!
          : '+91 22 2410 7000',
      scoreBreakdown: MatchScoreBreakdown(
        clinicalFitScore: 38.0,
        travelTimeScore: 25.0,
        freshnessScore: 13.5,
        loadScore: 11.5,
        totalScore: defaultScore,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupabaseHospitalDto &&
        other.id == id &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(id, name, latitude, longitude, isActive);
}
