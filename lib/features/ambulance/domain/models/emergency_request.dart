import 'package:flutter/foundation.dart';
import 'clinical_urgency.dart';

/// Canonical lifecycle status of an emergency transfer request.
enum EmergencyRequestStatus {
  searching,
  offered,
  reserved,
  arrived,
  completed,
  cancelled;

  bool get isPending => this == searching || this == offered;
  bool get isReserved => this == reserved;
  bool get isCompleted => this == arrived || this == completed;
  bool get isCancelled => this == cancelled;

  /// Translates domain status to Supabase public.ambulance_requests status check constraint.
  String toDatabaseStatus() {
    switch (this) {
      case EmergencyRequestStatus.searching:
      case EmergencyRequestStatus.offered:
        return 'pending';
      case EmergencyRequestStatus.reserved:
        return 'matched';
      case EmergencyRequestStatus.arrived:
      case EmergencyRequestStatus.completed:
        return 'completed';
      case EmergencyRequestStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Parses database status string to domain enum.
  static EmergencyRequestStatus fromDatabaseStatus(String raw) {
    final lower = raw.trim().toLowerCase();
    switch (lower) {
      case 'matched':
        return EmergencyRequestStatus.reserved;
      case 'completed':
        return EmergencyRequestStatus.completed;
      case 'cancelled':
        return EmergencyRequestStatus.cancelled;
      case 'pending':
      default:
        return EmergencyRequestStatus.offered;
    }
  }
}

/// Domain model representing an emergency transfer request persisted in Supabase.
@immutable
class EmergencyRequest {
  const EmergencyRequest({
    required this.id,
    required this.ambulanceId,
    required this.bedType,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.urgency = ClinicalUrgency.urgent,
    this.requiredResources = const {},
    this.requiredCapabilities = const [],
    this.patientName,
    this.patientAge,
    this.chiefComplaint,
    this.hospitalId,
    this.hospitalName,
    this.expiresAt,
    this.cancellationReason,
  });

  final String id;
  final String ambulanceId;
  final String bedType;
  final double latitude;
  final double longitude;
  final EmergencyRequestStatus status;
  final DateTime createdAt;
  final ClinicalUrgency urgency;
  final Map<String, int> requiredResources;
  final List<String> requiredCapabilities;
  final String? patientName;
  final int? patientAge;
  final String? chiefComplaint;
  final String? hospitalId;
  final String? hospitalName;
  final DateTime? expiresAt;
  final String? cancellationReason;

  EmergencyRequest copyWith({
    String? id,
    String? ambulanceId,
    String? bedType,
    double? latitude,
    double? longitude,
    EmergencyRequestStatus? status,
    DateTime? createdAt,
    ClinicalUrgency? urgency,
    Map<String, int>? requiredResources,
    List<String>? requiredCapabilities,
    String? patientName,
    int? patientAge,
    String? chiefComplaint,
    String? hospitalId,
    String? hospitalName,
    DateTime? expiresAt,
    String? cancellationReason,
  }) {
    return EmergencyRequest(
      id: id ?? this.id,
      ambulanceId: ambulanceId ?? this.ambulanceId,
      bedType: bedType ?? this.bedType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      urgency: urgency ?? this.urgency,
      requiredResources: requiredResources ?? this.requiredResources,
      requiredCapabilities: requiredCapabilities ?? this.requiredCapabilities,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      expiresAt: expiresAt ?? this.expiresAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  /// Deserializer mapping a Supabase PostgREST JSON row to domain model.
  factory EmergencyRequest.fromJson(Map<String, dynamic> json) {
    // Parse coordinates
    double parseCoord(dynamic val, double fallback) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? fallback;
      return fallback;
    }

    final lat = parseCoord(json['latitude'], 19.0760);
    final lon = parseCoord(json['longitude'], 72.8777);

    // Parse facilities/metadata jsonb
    Map<String, int> resources = {};
    List<String> capabilities = [];
    ClinicalUrgency urgency = ClinicalUrgency.urgent;
    String? patientName;
    int? patientAge;
    String? chiefComplaint;
    String? hospitalId;
    String? hospitalName;
    DateTime? expiresAt;
    String? cancellationReason;

    final facilities = json['required_facilities'];
    if (facilities is Map<String, dynamic>) {
      if (facilities['resources'] is Map) {
        resources = Map<String, int>.from(
          (facilities['resources'] as Map).map(
            (k, v) => MapEntry(k.toString(), (v is num) ? v.toInt() : 1),
          ),
        );
      }
      if (facilities['capabilities'] is List) {
        capabilities = (facilities['capabilities'] as List)
            .map((e) => e.toString())
            .toList();
      }
      if (facilities['urgency'] != null) {
        final uStr = facilities['urgency'].toString().toLowerCase();
        if (uStr.contains('critical')) {
          urgency = ClinicalUrgency.critical;
        } else if (uStr.contains('non') || uStr.contains('routine')) {
          urgency = ClinicalUrgency.routine;
        } else {
          urgency = ClinicalUrgency.urgent;
        }
      }
      patientName = facilities['patient_name']?.toString();
      if (facilities['patient_age'] is num) {
        patientAge = (facilities['patient_age'] as num).toInt();
      }
      chiefComplaint = facilities['chief_complaint']?.toString();
      hospitalId = facilities['hospital_id']?.toString();
      hospitalName = facilities['hospital_name']?.toString();
      cancellationReason = facilities['cancellation_reason']?.toString();
      if (facilities['expires_at'] != null) {
        expiresAt = DateTime.tryParse(facilities['expires_at'].toString());
      }
    } else if (facilities is List) {
      capabilities = facilities.map((e) => e.toString()).toList();
    }

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'].toString());
    } catch (_) {
      createdAt = DateTime.now();
    }

    // Default 120s expiry from created_at if not explicitly set
    expiresAt ??= createdAt.add(const Duration(seconds: 120));

    return EmergencyRequest(
      id: json['id']?.toString() ?? '',
      ambulanceId: json['ambulance_id']?.toString() ?? 'AMB-108',
      bedType: json['bed_type']?.toString() ?? 'emergency',
      latitude: lat,
      longitude: lon,
      status: EmergencyRequestStatus.fromDatabaseStatus(
        json['status']?.toString() ?? 'pending',
      ),
      createdAt: createdAt,
      urgency: urgency,
      requiredResources: resources,
      requiredCapabilities: capabilities,
      patientName: patientName,
      patientAge: patientAge,
      chiefComplaint: chiefComplaint,
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      expiresAt: expiresAt,
      cancellationReason: cancellationReason,
    );
  }

  /// Serializer mapping domain request to Supabase PostgREST JSON row.
  Map<String, dynamic> toJson() {
    return {
      'ambulance_id': ambulanceId,
      'bed_type': bedType,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.toDatabaseStatus(),
      'required_facilities': {
        'resources': requiredResources,
        'capabilities': requiredCapabilities,
        'urgency': urgency.name,
        if (patientName != null) 'patient_name': patientName,
        if (patientAge != null) 'patient_age': patientAge,
        if (chiefComplaint != null) 'chief_complaint': chiefComplaint,
        if (hospitalId != null) 'hospital_id': hospitalId,
        if (hospitalName != null) 'hospital_name': hospitalName,
        if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
        if (cancellationReason != null) 'cancellation_reason': cancellationReason,
      },
    };
  }
}
