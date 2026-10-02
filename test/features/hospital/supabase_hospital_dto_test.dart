import 'package:bedlink/core/theme/semantic_tokens.dart';
import 'package:bedlink/features/hospital/data/models/supabase_hospital_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseHospitalDto Tests (Worker 2)', () {
    test('deserializes complete Mumbai hospital record correctly', () {
      final json = {
        'id': '13f0a0c5-b45b-43fe-8f3e-1d52d6c7e76c',
        'name': 'King Edward Memorial (KEM) Hospital',
        'address': 'Acharya Donde Marg, Parel, Mumbai, Maharashtra 400012',
        'latitude': 18.9984,
        'longitude': 72.8427,
        'hospital_load': 45,
        'facilities': ['Trauma Care', 'Emergency', 'ICU'],
        'is_active': true,
        'created_at': '2026-10-02T08:48:05.902Z',
        'ward_name': 'F/S',
        'hospital_type': 'Municipal',
        'total_beds': 2250,
        'contact': '+91 22 2410 7000',
        'availability_is_simulated': true,
      };

      final dto = SupabaseHospitalDto.fromJson(json);

      expect(dto.id, equals('13f0a0c5-b45b-43fe-8f3e-1d52d6c7e76c'));
      expect(dto.name, equals('King Edward Memorial (KEM) Hospital'));
      expect(dto.address, contains('Parel'));
      expect(dto.latitude, equals(18.9984));
      expect(dto.longitude, equals(72.8427));
      expect(dto.hasCoordinates, isTrue);
      expect(dto.hospitalLoad, equals(45));
      expect(dto.facilities, containsAll(['Trauma Care', 'Emergency', 'ICU']));
      expect(dto.isActive, isTrue);
      expect(dto.wardName, equals('F/S'));
      expect(dto.hospitalType, equals('Municipal'));
      expect(dto.totalBeds, equals(2250));
      expect(dto.contact, equals('+91 22 2410 7000'));
      expect(dto.availabilityIsSimulated, isTrue);
    });

    test('handles NULL coordinates safely with hasCoordinates = false', () {
      final json = {
        'id': '0a8c8557-ddb1-4936-8c4b-105544c0a8fc',
        'name': 'Small Nursing Home',
        'address': 'Dadar West, Mumbai',
        'latitude': null,
        'longitude': null,
        'facilities': <dynamic>[],
        'is_active': true,
      };

      final dto = SupabaseHospitalDto.fromJson(json);

      expect(dto.latitude, isNull);
      expect(dto.longitude, isNull);
      expect(dto.hasCoordinates, isFalse);
    });

    test('handles nullable total_beds, contact, ward_name, and hospital_type without crashing', () {
      final json = {
        'id': 'hosp-002',
        'name': 'Community Clinic',
        'address': 'Kurla, Mumbai',
        'latitude': '19.0728',
        'longitude': '72.8795',
        'total_beds': null,
        'contact': null,
        'ward_name': null,
        'hospital_type': null,
      };

      final dto = SupabaseHospitalDto.fromJson(json);

      expect(dto.latitude, equals(19.0728));
      expect(dto.longitude, equals(72.8795));
      expect(dto.hasCoordinates, isTrue);
      expect(dto.totalBeds, isNull);
      expect(dto.contact, isNull);
      expect(dto.wardName, isNull);
      expect(dto.hospitalType, isNull);
    });

    test('mapSupportedCapabilities strictly maps existing JSONB and does not invent missing capabilities', () {
      const dto = SupabaseHospitalDto(
        id: 'hosp-003',
        name: 'Trauma Specialty Center',
        address: 'Worli, Mumbai',
        facilities: ['Trauma Care', 'Emergency', 'ICU'],
      );

      final capabilities = dto.mapSupportedCapabilities();

      expect(capabilities, contains('trauma_care'));
      expect(capabilities, contains('emergency_care'));
      expect(capabilities, contains('icu_care'));

      // Critical requirement: must NOT invent capabilities not in backend
      expect(capabilities, isNot(contains('cardiac_care')));
      expect(capabilities, isNot(contains('burns_care')));
      expect(capabilities, isNot(contains('pediatric_icu_care')));
      expect(capabilities, isNot(contains('ventilator')));
      expect(capabilities, isNot(contains('oxygen_bed')));
    });

    test('converts to hybrid HospitalMatch domain model preserving real identity and downstream mock values', () {
      const dto = SupabaseHospitalDto(
        id: 'kem_mumbai',
        name: 'KEM Hospital',
        address: 'Parel, Mumbai',
        latitude: 18.9984,
        longitude: 72.8427,
        hospitalLoad: 35,
        facilities: ['ICU', 'Trauma Care'],
        wardName: 'F/S',
        totalBeds: 1800,
        contact: '+91 22 2410 7000',
      );

      final match = dto.toDomainMatch(
        rank: 1,
        defaultDistanceKm: 4.2,
        defaultEtaMinutes: 10,
        defaultScore: 94.0,
      );

      expect(match.id, equals('kem_mumbai'));
      expect(match.name, equals('KEM Hospital'));
      expect(match.address, equals('Parel, Mumbai'));
      expect(match.area, contains('Ward F/S'));
      expect(match.emergencyPhone, equals('+91 22 2410 7000'));
      expect(match.loadState, equals(HospitalLoadState.low));
      expect(match.rank, equals(1));
      expect(match.distanceKm, equals(4.2));
      expect(match.etaMinutes, equals(10));
      expect(match.matchScore, equals(94.0));
      expect(match.supportedCapabilities, containsAll(['icu_care', 'trauma_care']));
      expect(match.availableBedCounts['general_bed'], greaterThan(0));
    });

    test('toJson serialization produces consistent map', () {
      const dto = SupabaseHospitalDto(
        id: 'hosp-004',
        name: 'Hinduja Hospital',
        address: 'Mahim, Mumbai',
        latitude: 19.0330,
        longitude: 72.8397,
        hospitalLoad: 50,
        facilities: ['ICU'],
        isActive: true,
      );

      final map = dto.toJson();

      expect(map['id'], equals('hosp-004'));
      expect(map['name'], equals('Hinduja Hospital'));
      expect(map['latitude'], equals(19.0330));
      expect(map['longitude'], equals(72.8397));
      expect(map['facilities'], contains('ICU'));
      expect(map['is_active'], isTrue);
    });
  });
}
