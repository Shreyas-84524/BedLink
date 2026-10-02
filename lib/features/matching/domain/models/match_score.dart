import 'package:flutter/foundation.dart';

/// Clinical multi-criteria match score breakdown adhering to BedLink Architecture.
@immutable
class MatchScoreBreakdown {
  const MatchScoreBreakdown({
    required this.clinicalFitScore,
    required this.travelTimeScore,
    required this.freshnessScore,
    required this.loadScore,
    required this.totalScore,
  });

  /// Clinical resource compatibility score (0..40 points).
  final double clinicalFitScore;

  /// Road travel time / ETA score (0..30 points).
  final double travelTimeScore;

  /// Data freshness and recency score (0..15 points).
  final double freshnessScore;

  /// Department occupancy and load score (0..15 points).
  final double loadScore;

  /// Aggregate multi-criteria match score (0..100 points).
  final double totalScore;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchScoreBreakdown &&
        other.clinicalFitScore == clinicalFitScore &&
        other.travelTimeScore == travelTimeScore &&
        other.freshnessScore == freshnessScore &&
        other.loadScore == loadScore &&
        other.totalScore == totalScore;
  }

  @override
  int get hashCode => Object.hash(
        clinicalFitScore,
        travelTimeScore,
        freshnessScore,
        loadScore,
        totalScore,
      );

  @override
  String toString() =>
      'MatchScoreBreakdown(fit: $clinicalFitScore, eta: $travelTimeScore, freshness: $freshnessScore, load: $loadScore, total: $totalScore)';
}
