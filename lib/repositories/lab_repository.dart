import '../models/lab_result.dart';

class LabRepository {
  final List<LabResult> _labResults = [];

  Future<List<LabResult>> getAllLabResults() async {
    return _labResults.where((r) => !r.isDeleted).toList();
  }

  Future<void> saveLabResult(LabResult result) async {
    final idx = _labResults.indexWhere((r) => r.id == result.id);
    if (idx != -1) {
      _labResults[idx] = result;
    } else {
      _labResults.insert(0, result);
    }
  }

  Future<void> softDeleteLabResult(String id) async {
    final idx = _labResults.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final old = _labResults[idx];
      _labResults[idx] = LabResult(
        id: old.id,
        date: old.date,
        testName: old.testName,
        value: old.value,
        unit: old.unit,
        referenceRange: old.referenceRange,
        labName: old.labName,
        reportDate: old.reportDate,
        notes: old.notes,
        attachmentPath: old.attachmentPath,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        isDeleted: true,
      );
    }
  }

  Future<void> clearAll() async {
    _labResults.clear();
  }
}
