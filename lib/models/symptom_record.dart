enum SymptomSeverity { none, mild, moderate, severe }

extension SymptomSeverityExtension on SymptomSeverity {
  String get displayName {
    switch (this) {
      case SymptomSeverity.none:
        return 'None';
      case SymptomSeverity.mild:
        return 'Mild';
      case SymptomSeverity.moderate:
        return 'Moderate';
      case SymptomSeverity.severe:
        return 'Severe';
    }
  }

  int get scoreValue {
    switch (this) {
      case SymptomSeverity.none:
        return 0;
      case SymptomSeverity.mild:
        return 1;
      case SymptomSeverity.moderate:
        return 2;
      case SymptomSeverity.severe:
        return 3;
    }
  }
}

class SymptomRecord {
  final String id;
  final DateTime date;
  final SymptomSeverity acne;
  final SymptomSeverity hirsutism; // Excess facial / body hair
  final SymptomSeverity hairThinning; // Scalp hair thinning
  final SymptomSeverity pelvicPain;
  final SymptomSeverity fatigue;
  final SymptomSeverity moodSwings;
  final SymptomSeverity breastTenderness;
  final SymptomSeverity headaches;
  final SymptomSeverity skinChanges;
  final SymptomSeverity spotting;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  SymptomRecord({
    required this.id,
    required this.date,
    this.acne = SymptomSeverity.none,
    this.hirsutism = SymptomSeverity.none,
    this.hairThinning = SymptomSeverity.none,
    this.pelvicPain = SymptomSeverity.none,
    this.fatigue = SymptomSeverity.none,
    this.moodSwings = SymptomSeverity.none,
    this.breastTenderness = SymptomSeverity.none,
    this.headaches = SymptomSeverity.none,
    this.skinChanges = SymptomSeverity.none,
    this.spotting = SymptomSeverity.none,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isDeleted = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get hasHyperandrogenicSymptoms =>
      acne != SymptomSeverity.none ||
      hirsutism != SymptomSeverity.none ||
      hairThinning != SymptomSeverity.none;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'acne': acne.name,
      'hirsutism': hirsutism.name,
      'hairThinning': hairThinning.name,
      'pelvicPain': pelvicPain.name,
      'fatigue': fatigue.name,
      'moodSwings': moodSwings.name,
      'breastTenderness': breastTenderness.name,
      'headaches': headaches.name,
      'skinChanges': skinChanges.name,
      'spotting': spotting.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory SymptomRecord.fromMap(Map<String, dynamic> map) {
    SymptomSeverity parseSev(String? key) => SymptomSeverity.values.firstWhere(
          (e) => e.name == key,
          orElse: () => SymptomSeverity.none,
        );

    return SymptomRecord(
      id: map['id'],
      date: DateTime.parse(map['date']),
      acne: parseSev(map['acne']),
      hirsutism: parseSev(map['hirsutism']),
      hairThinning: parseSev(map['hairThinning']),
      pelvicPain: parseSev(map['pelvicPain']),
      fatigue: parseSev(map['fatigue']),
      moodSwings: parseSev(map['moodSwings']),
      breastTenderness: parseSev(map['breastTenderness']),
      headaches: parseSev(map['headaches']),
      skinChanges: parseSev(map['skinChanges']),
      spotting: parseSev(map['spotting']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
