import '../models/symptom_record.dart';

class SymptomRepository {
  final List<SymptomRecord> _symptoms = [];

  Future<List<SymptomRecord>> getAllSymptoms() async {
    return _symptoms.where((s) => !s.isDeleted).toList();
  }

  Future<void> saveSymptom(SymptomRecord symptom) async {
    final idx = _symptoms.indexWhere((s) => s.id == symptom.id);
    if (idx != -1) {
      _symptoms[idx] = symptom;
    } else {
      _symptoms.insert(0, symptom);
    }
  }

  Future<void> softDeleteSymptom(String id) async {
    final idx = _symptoms.indexWhere((s) => s.id == id);
    if (idx != -1) {
      final old = _symptoms[idx];
      _symptoms[idx] = SymptomRecord(
        id: old.id,
        date: old.date,
        acne: old.acne,
        hirsutism: old.hirsutism,
        hairThinning: old.hairThinning,
        pelvicPain: old.pelvicPain,
        fatigue: old.fatigue,
        moodSwings: old.moodSwings,
        breastTenderness: old.breastTenderness,
        headaches: old.headaches,
        skinChanges: old.skinChanges,
        spotting: old.spotting,
        notes: old.notes,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        isDeleted: true,
      );
    }
  }

  Future<void> clearAll() async {
    _symptoms.clear();
  }
}
