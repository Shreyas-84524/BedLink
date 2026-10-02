import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/domain/models/hospital_match.dart';
import 'package:bedlink/features/matching/domain/repositories/hospital_discovery_repository.dart';

void main() {
  group('Requirement Classification Constants Tests', () {
    test('Supported bed types match verified backend public.beds schema', () {
      expect(kSupportedBedTypes, contains('icu_bed'));
      expect(kSupportedBedTypes, contains('general_bed'));
      expect(kSupportedBedTypes, contains('emergency_bed'));
      expect(kSupportedBedTypes.length, equals(3));
    });

    test('Supported capabilities match facilities array mapping', () {
      expect(kSupportedCapabilities, contains('trauma_care'));
      expect(kSupportedCapabilities, contains('emergency_care'));
      expect(kSupportedCapabilities, contains('icu_care'));
      expect(kSupportedCapabilities.length, equals(3));
    });

    test('Unsupported backend resources include ventilator and oxygen', () {
      expect(kUnsupportedBackendResources, contains('ventilator'));
      expect(kUnsupportedBackendResources, contains('oxygen_bed'));
      expect(kUnsupportedBackendResources, contains('pediatric_icu_bed'));
      expect(kUnsupportedBackendResources, contains('cardiac_care'));
      expect(kUnsupportedBackendResources, contains('burns_care'));
    });
  });

  group('Clinical Fit Evaluation Logic Tests', () {
    test('Hospital with available ICU beds matches ICU requirement', () {
      const hospital = MockHospitalData.kemHospital;
      expect(hospital.getAvailableCount('icu_bed'), greaterThan(0));
      expect(hospital.hasCapability('trauma_care'), isTrue);
    });

    test('Hospital with zero ICU beds fails ICU requirement check', () {
      const hospital = MockHospitalData.tataMemorialHospital;
      expect(hospital.getAvailableCount('icu_bed'), equals(0));
      expect(hospital.recommendationTier, equals(RecommendationTier.incompatible));
    });

    test('Hospital with high occupancy rate is flagged as divert risk', () {
      const hospital = MockHospitalData.sionHospital;
      expect(hospital.occupancyRate, equals(94));
      expect(hospital.recommendationTier, equals(RecommendationTier.divertRisk));
    });
  });
}
