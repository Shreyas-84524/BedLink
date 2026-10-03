import 'package:flutter/foundation.dart';
import '../../domain/models/hospital_resource_item.dart';
import '../models/supabase_bed_dto.dart';

/// Aggregation result representing structured bed counts and metadata.
@immutable
class BedInventoryAggregationResult {
  const BedInventoryAggregationResult({
    required this.resources,
    required this.totalBedRows,
    required this.lastUpdatedAt,
    required this.hasBackendRecords,
    required this.unsupportedResources,
  });

  /// The resulting map of [HospitalResourceItem] keyed by canonical ID.
  final Map<String, HospitalResourceItem> resources;

  /// Total number of individual bed rows processed from the database.
  final int totalBedRows;

  /// The most recent `updated_at` timestamp across all bed rows.
  final DateTime? lastUpdatedAt;

  /// True if at least one bed record existed for this hospital.
  final bool hasBackendRecords;

  /// IDs of resources not present in the backend schema (ventilator, oxygen, etc.).
  final Set<String> unsupportedResources;
}

/// Adapter converting granular bed slots (`List<SupabaseBedDto>`) into aggregate [HospitalResourceItem] pools.
///
/// Strictly enforces:
/// - `available + held + occupied == total`
/// - Canonical ID mapping: `'ICU'` -> `'icu_bed'`, `'emergency'` -> `'er_bed'`, `'general'` -> `'general_bed'`
/// - Status mapping: `'available'` -> `available`, `'reserved'` -> `held`, `'occupied'` -> `occupied`
/// - Clear marking of unsupported backend resources (ventilator, oxygen, pediatric ICU, capabilities)
class BedInventoryAdapter {
  const BedInventoryAdapter();

  /// Supported canonical resource IDs backed by real Supabase rows.
  static const Set<String> supportedLiveTypes = {
    'icu_bed',
    'er_bed',
    'general_bed',
  };

  /// Canonical IDs not backed by real Supabase `public.beds` inventory.
  static const Set<String> unsupportedTypes = {
    'ventilator',
    'oxygen_bed',
    'pediatric_icu',
    'cardiac_care',
    'trauma_care',
    'burns_care',
  };

  /// Aggregates a list of database bed slots into the complete frontend resources map.
  BedInventoryAggregationResult aggregateBeds(
    List<SupabaseBedDto> beds, {
    Map<String, HospitalResourceItem>? baselineResources,
  }) {
    if (beds.isEmpty) {
      return BedInventoryAggregationResult(
        resources: baselineResources ?? _buildEmptyResources(),
        totalBedRows: 0,
        lastUpdatedAt: null,
        hasBackendRecords: false,
        unsupportedResources: unsupportedTypes,
      );
    }

    // Counters for supported types: Map<canonicalId, Map<status, count>>
    final counts = <String, Map<String, int>>{
      'icu_bed': {'available': 0, 'held': 0, 'occupied': 0},
      'er_bed': {'available': 0, 'held': 0, 'occupied': 0},
      'general_bed': {'available': 0, 'held': 0, 'occupied': 0},
    };

    DateTime? maxTimestamp;

    for (final bed in beds) {
      final canonicalId = bed.canonicalResourceId;
      final domainStatus = bed.domainStatus;

      // Track max updated_at for freshness
      if (maxTimestamp == null || bed.updatedAt.isAfter(maxTimestamp)) {
        maxTimestamp = bed.updatedAt;
      }

      if (counts.containsKey(canonicalId)) {
        final bucket = counts[canonicalId]!;
        if (bucket.containsKey(domainStatus)) {
          bucket[domainStatus] = bucket[domainStatus]! + 1;
        } else {
          // If unknown status appears, count it as occupied defensively so total invariant holds
          debugPrint('Unknown bed status "${bed.status}" on bed ${bed.id}; treating as occupied.');
          bucket['occupied'] = bucket['occupied']! + 1;
        }
      }
    }

    final resultMap = <String, HospitalResourceItem>{};

    // 1. Build live supported countable resources: ICU, ER, General
    final icu = counts['icu_bed']!;
    final icuTotal = icu['available']! + icu['held']! + icu['occupied']!;
    resultMap['icu_bed'] = HospitalResourceItem(
      id: 'icu_bed',
      name: 'ICU Beds',
      category: 'Critical Care',
      isCountable: true,
      total: icuTotal,
      available: icu['available']!,
      held: icu['held']!,
      occupied: icu['occupied']!,
      isOperational: icuTotal > 0,
    );

    final er = counts['er_bed']!;
    final erTotal = er['available']! + er['held']! + er['occupied']!;
    resultMap['er_bed'] = HospitalResourceItem(
      id: 'er_bed',
      name: 'General Emergency Beds',
      category: 'Acute & Emergency',
      isCountable: true,
      total: erTotal,
      available: er['available']!,
      held: er['held']!,
      occupied: er['occupied']!,
      isOperational: erTotal > 0,
    );

    final gen = counts['general_bed']!;
    final genTotal = gen['available']! + gen['held']! + gen['occupied']!;
    resultMap['general_bed'] = HospitalResourceItem(
      id: 'general_bed',
      name: 'General Ward Beds',
      category: 'Acute & Emergency',
      isCountable: true,
      total: genTotal,
      available: gen['available']!,
      held: gen['held']!,
      occupied: gen['occupied']!,
      isOperational: genTotal > 0,
    );

    // 2. Build unsupported resources (Ventilator, Oxygen, Pediatric ICU)
    // Preserves UI non-crash guarantees while clearly maintaining capacity boundaries.
    resultMap['ventilator'] = HospitalResourceItem(
      id: 'ventilator',
      name: 'Ventilator Beds (Mock Only)',
      category: 'Critical Care',
      isCountable: true,
      total: baselineResources?['ventilator']?.total ?? 8,
      available: baselineResources?['ventilator']?.available ?? 2,
      held: baselineResources?['ventilator']?.held ?? 0,
      occupied: baselineResources?['ventilator']?.occupied ?? 6,
      isOperational: false, // Flagged: not real cloud inventory
    );

    resultMap['pediatric_icu'] = HospitalResourceItem(
      id: 'pediatric_icu',
      name: 'Pediatric ICU (Mock Only)',
      category: 'Critical Care',
      isCountable: true,
      total: baselineResources?['pediatric_icu']?.total ?? 6,
      available: baselineResources?['pediatric_icu']?.available ?? 1,
      held: baselineResources?['pediatric_icu']?.held ?? 0,
      occupied: baselineResources?['pediatric_icu']?.occupied ?? 5,
      isOperational: false,
    );

    resultMap['oxygen_bed'] = HospitalResourceItem(
      id: 'oxygen_bed',
      name: 'Oxygen Beds (Mock Only)',
      category: 'Acute & Emergency',
      isCountable: true,
      total: baselineResources?['oxygen_bed']?.total ?? 30,
      available: baselineResources?['oxygen_bed']?.available ?? 8,
      held: baselineResources?['oxygen_bed']?.held ?? 0,
      occupied: baselineResources?['oxygen_bed']?.occupied ?? 22,
      isOperational: false,
    );

    // 3. Build specialized capabilities
    resultMap['cardiac_care'] = HospitalResourceItem(
      id: 'cardiac_care',
      name: 'Cardiac Care Unit (Cath Lab)',
      category: 'Specialized Capabilities',
      isCountable: false,
      isOperational: baselineResources?['cardiac_care']?.isOperational ?? true,
    );

    resultMap['trauma_care'] = HospitalResourceItem(
      id: 'trauma_care',
      name: 'Level-1 Trauma Bays',
      category: 'Specialized Capabilities',
      isCountable: false,
      isOperational: baselineResources?['trauma_care']?.isOperational ?? true,
    );

    resultMap['burns_care'] = HospitalResourceItem(
      id: 'burns_care',
      name: 'Burns Care Unit',
      category: 'Specialized Capabilities',
      isCountable: false,
      isOperational: baselineResources?['burns_care']?.isOperational ?? true,
    );

    return BedInventoryAggregationResult(
      resources: Map.unmodifiable(resultMap),
      totalBedRows: beds.length,
      lastUpdatedAt: maxTimestamp,
      hasBackendRecords: true,
      unsupportedResources: unsupportedTypes,
    );
  }

  static Map<String, HospitalResourceItem> _buildEmptyResources() {
    return {
      'icu_bed': const HospitalResourceItem(
        id: 'icu_bed',
        name: 'ICU Beds',
        category: 'Critical Care',
        isCountable: true,
        total: 0,
        available: 0,
        held: 0,
        occupied: 0,
        isOperational: false,
      ),
      'er_bed': const HospitalResourceItem(
        id: 'er_bed',
        name: 'General Emergency Beds',
        category: 'Acute & Emergency',
        isCountable: true,
        total: 0,
        available: 0,
        held: 0,
        occupied: 0,
        isOperational: false,
      ),
      'general_bed': const HospitalResourceItem(
        id: 'general_bed',
        name: 'General Ward Beds',
        category: 'Acute & Emergency',
        isCountable: true,
        total: 0,
        available: 0,
        held: 0,
        occupied: 0,
        isOperational: false,
      ),
    };
  }
}
