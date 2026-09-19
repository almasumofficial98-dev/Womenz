import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cycle_models.dart';
import 'storage_service.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  factory SupabaseService() => instance;
  SupabaseService._internal();

  static const String defaultUrl = 'https://vvzwixqkzuypzymqlpvv.supabase.co';
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2endpeHFrenV5cHp5bXFscHZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk3NzE1MzgsImV4cCI6MjEwNTM0NzUzOH0.CgcLK2b3qOzKSSx7728isde8iDE82vjfE6aV_9aCa7E';

  String _supabaseUrl = defaultUrl;
  String _anonKey = defaultAnonKey;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized && _anonKey.isNotEmpty;
  String get supabaseUrl => _supabaseUrl;
  String get anonKey => _anonKey;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _supabaseUrl = prefs.getString('supabase_url') ?? defaultUrl;
    _anonKey = prefs.getString('supabase_anon_key') ?? defaultAnonKey;

    if (_anonKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: _supabaseUrl,
          anonKey: _anonKey,
        );
        _isInitialized = true;
      } catch (e) {
        debugPrint('Supabase init notice: $e');
      }
    }
  }

  Future<bool> configureCredentials({required String url, required String anonKey}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('supabase_url', url);
    await prefs.setString('supabase_anon_key', anonKey);
    _supabaseUrl = url;
    _anonKey = anonKey;

    try {
      if (!_isInitialized) {
        await Supabase.initialize(
          url: _supabaseUrl,
          anonKey: _anonKey,
        );
        _isInitialized = true;
      }
      return true;
    } catch (e) {
      debugPrint('Supabase configuration error: $e');
      return false;
    }
  }

  Future<bool> syncWithCloud() async {
    if (!isInitialized) return false;

    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) {
        debugPrint('Cloud sync notice: User not logged into Supabase auth yet');
        return false;
      }

      final storage = StorageService.instance;

      // 1. Sync Profile
      await client.from('profiles').upsert({
        'id': user.id,
        'health_condition': storage.profile.healthCondition.dbCode,
        'avg_cycle_length': storage.profile.avgCycleLength,
        'avg_period_length': storage.profile.avgPeriodLength,
        'cycle_variance': storage.profile.cycleVariance,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Push Cycle Logs
      for (final log in storage.cycleLogs) {
        await client.from('cycle_logs').upsert({
          'id': log.id,
          'user_id': user.id,
          'start_date': log.startDate.toIso8601String().split('T')[0],
          'end_date': log.endDate?.toIso8601String().split('T')[0],
          'flow_intensity': log.flow.name,
          'notes': log.notes,
        });
      }

      // 3. Push Symptom Logs
      for (final symptom in storage.symptomLogs) {
        await client.from('symptom_logs').upsert({
          'user_id': user.id,
          'log_date': symptom.date.toIso8601String().split('T')[0],
          'symptoms': symptom.symptoms,
          'moods': symptom.moods,
          'water_glasses': symptom.waterGlasses,
          'sleep_hours': symptom.sleepHours,
          'notes': symptom.notes,
        });
      }

      return true;
    } catch (e) {
      debugPrint('Supabase cloud sync error: $e');
      return false;
    }
  }
}
