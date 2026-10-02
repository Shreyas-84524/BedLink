/// Biological sex classification for clinical triage and bed matching.
enum BiologicalSex {
  male('Male', 'M'),
  female('Female', 'F'),
  other('Other', 'O');

  const BiologicalSex(this.label, this.shortCode);

  final String label;
  final String shortCode;

  static BiologicalSex fromString(String? value) {
    if (value == null) return BiologicalSex.male;
    final normalized = value.toLowerCase().trim();
    if (normalized.startsWith('m')) return BiologicalSex.male;
    if (normalized.startsWith('f')) return BiologicalSex.female;
    return BiologicalSex.other;
  }
}
