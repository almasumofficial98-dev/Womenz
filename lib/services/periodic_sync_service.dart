import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';
import 'google_sheets_service.dart';
import 'local_db_service.dart';

class PeriodicSyncService {
  static const String _lastSyncKey = 'last_encrypted_sync_timestamp';
  static const int syncIntervalDays = 7;

  static DateTime? _lastSyncTime;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isoStr = prefs.getString(_lastSyncKey);
    if (isoStr != null) {
      _lastSyncTime = DateTime.tryParse(isoStr);
    }
  }

  static DateTime? get lastSyncTime => _lastSyncTime;

  static int get daysSinceLastSync {
    if (_lastSyncTime == null) return 7; // Never synced, due for sync
    return DateTime.now().difference(_lastSyncTime!).inDays;
  }

  static int get daysUntilNextSync {
    final remaining = syncIntervalDays - daysSinceLastSync;
    return remaining < 0 ? 0 : remaining;
  }

  static bool get isSyncDue => daysSinceLastSync >= syncIntervalDays;

  /// Check 7-day timer and perform client-side AES-256 encrypted cloud backup
  static Future<bool> performPeriodicSync({bool force = false}) async {
    if (!force && !isSyncDue) {
      debugPrint('Sync skipped: Last synced $daysSinceLastSync days ago. Next auto-sync in $daysUntilNextSync days.');
      return false;
    }

    try {
      debugPrint('Starting 7-Day Encrypted Backup Sync...');

      // 1. Export local SQLite database snapshot
      final snapshot = await LocalDbService.exportFullSnapshot();

      // 2. Encrypt snapshot locally on device using AES-256
      final encryptedBlob = EncryptionService.encryptPayload(snapshot);

      // 3. Upload encrypted blob to Cloud Backup / Google Sheets / Supabase
      final success = await GoogleSheetsService.syncDailyLog(
        date: DateTime.now().toString().split(' ')[0],
        flow: '7_DAY_ENCRYPTED_BACKUP',
        mood: 'AES_256_ENCRYPTED',
        symptoms: ['EncryptedBackupBlob'],
        tookSupplements: true,
        notes: encryptedBlob,
      );

      if (success) {
        _lastSyncTime = DateTime.now();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastSyncKey, _lastSyncTime!.toIso8601String());
        debugPrint('Encrypted 7-day backup completed successfully at $_lastSyncTime');
      }

      return success;
    } catch (e) {
      debugPrint('Periodic Sync Error: $e');
      return false;
    }
  }
}
