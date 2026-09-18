import '../models/cycle_record.dart';

class CycleRepository {
  final List<CycleRecord> _records = [];

  Future<List<CycleRecord>> getAllRecords() async {
    return _records.where((r) => !r.isDeleted).toList();
  }

  Future<void> addRecord(CycleRecord record) async {
    _records.insert(0, record);
  }

  Future<void> updateRecord(CycleRecord record) async {
    final idx = _records.indexWhere((r) => r.id == record.id);
    if (idx != -1) {
      _records[idx] = record;
    }
  }

  /// Soft delete with restore support
  Future<void> softDeleteRecord(String id) async {
    final idx = _records.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final existing = _records[idx];
      _records[idx] = CycleRecord(
        id: existing.id,
        startDate: existing.startDate,
        endDate: existing.endDate,
        flowLevel: existing.flowLevel,
        isSpotting: existing.isSpotting,
        notes: existing.notes,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
        isDeleted: true,
      );
    }
  }

  /// Restores a soft-deleted record
  Future<void> restoreRecord(String id) async {
    final idx = _records.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final existing = _records[idx];
      _records[idx] = CycleRecord(
        id: existing.id,
        startDate: existing.startDate,
        endDate: existing.endDate,
        flowLevel: existing.flowLevel,
        isSpotting: existing.isSpotting,
        notes: existing.notes,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: null,
        isDeleted: false,
      );
    }
  }

  Future<void> clearAll() async {
    _records.clear();
  }
}
