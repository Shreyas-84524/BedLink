import 'package:bedlink/core/constants/clinical_codes.dart';
import 'package:bedlink/core/errors/app_exception.dart';
import 'package:bedlink/core/errors/error_codes.dart';
import 'package:bedlink/core/utils/formatters.dart';
import 'package:bedlink/shared/models/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Clinical Codes & ResourceType Tests', () {
    test('Clinical codes contains all 6 countable resources', () {
      expect(ClinicalCodes.allResourceCodes.length, 6);
      expect(ClinicalCodes.allResourceCodes, contains('general_bed'));
      expect(ClinicalCodes.allResourceCodes, contains('emergency_bed'));
      expect(ClinicalCodes.allResourceCodes, contains('icu_bed'));
      expect(ClinicalCodes.allResourceCodes, contains('ventilator'));
      expect(ClinicalCodes.allResourceCodes, contains('oxygen_bed'));
      expect(ClinicalCodes.allResourceCodes, contains('pediatric_icu_bed'));
    });

    test('Clinical codes contains 4 clinical capabilities', () {
      expect(ClinicalCodes.allCapabilityCodes.length, 4);
      expect(ClinicalCodes.allCapabilityCodes, contains('cardiac_care'));
      expect(ClinicalCodes.allCapabilityCodes, contains('trauma_care'));
      expect(ClinicalCodes.allCapabilityCodes, contains('burns_care'));
      expect(ClinicalCodes.allCapabilityCodes, contains('pediatric_icu_care'));
    });

    test('ResourceType fromCode maps canonical strings correctly', () {
      expect(ResourceType.fromCode('icu_bed'), ResourceType.icuBed);
      expect(ResourceType.fromCode('ventilator'), ResourceType.ventilator);
      expect(ResourceType.fromCode('non_existent'), isNull);
    });
  });

  group('Formatters Tests', () {
    test('formatCountdown formats mm:ss correctly', () {
      expect(Formatters.formatCountdown(120), '02:00');
      expect(Formatters.formatCountdown(65), '01:05');
      expect(Formatters.formatCountdown(9), '00:09');
      expect(Formatters.formatCountdown(0), '00:00');
      expect(Formatters.formatCountdown(-5), '00:00');
    });

    test('formatEta formats minutes correctly', () {
      expect(Formatters.formatEta(720), '12 min');
      expect(Formatters.formatEta(60), '1 min');
      expect(Formatters.formatEta(15), '1 min');
      expect(Formatters.formatEta(0), '0 min');
    });

    test('formatDistance formats meters and km correctly', () {
      expect(Formatters.formatDistance(450), '450 m');
      expect(Formatters.formatDistance(1000), '1.0 km');
      expect(Formatters.formatDistance(4200), '4.2 km');
    });
  });

  group('AppException Tests', () {
    test('AppException exposes code and message', () {
      const exception = AppException(
        message: 'Something failed',
        code: ErrorCodes.networkError,
      );
      expect(exception.message, 'Something failed');
      expect(exception.code, ErrorCodes.networkError);
      expect(exception.toString(), contains('NETWORK_ERROR'));
    });

    test('AuthException defaults to authRequired code', () {
      const authException = AuthException('Must be logged in');
      expect(authException.code, ErrorCodes.authRequired);
    });
  });
}
