import '../models/body_measurement.dart';

class BodyRepository {
  final List<BodyMeasurement> _measurements = [];

  Future<List<BodyMeasurement>> getAllMeasurements() async {
    return _measurements.where((m) => !m.isDeleted).toList();
  }

  Future<BodyMeasurement?> getLatestMeasurement() async {
    final active = await getAllMeasurements();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.date.compareTo(a.date));
    return active.first;
  }

  Future<void> addMeasurement(BodyMeasurement measurement) async {
    _measurements.insert(0, measurement);
  }

  Future<void> softDeleteMeasurement(String id) async {
    final idx = _measurements.indexWhere((m) => m.id == id);
    if (idx != -1) {
      final old = _measurements[idx];
      _measurements[idx] = BodyMeasurement(
        id: old.id,
        date: old.date,
        weightKg: old.weightKg,
        heightCm: old.heightCm,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        isDeleted: true,
      );
    }
  }

  Future<void> clearAll() async {
    _measurements.clear();
  }
}
