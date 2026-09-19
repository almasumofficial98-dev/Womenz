import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service powering cloud synchronization directly via Supabase.
/// Replaces legacy Google Sheets webhook with real-time PostgreSQL on Supabase.
class GoogleSheetsService {
  static const String supabaseUrl = 'https://vvzwixqkzuypzymqlpvv.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2endpeHFrenV5cHp5bXFscHZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk3NzE1MzgsImV4cCI6MjEwNTM0NzUzOH0.CgcLK2b3qOzKSSx7728isde8iDE82vjfE6aV_9aCa7E';

  static String _currentEndpoint = supabaseUrl;
  static String? _userId;
  static bool _isSupabaseInitialized = false;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentEndpoint = prefs.getString('supabase_url') ?? supabaseUrl;

    _userId = prefs.getString('user_id');
    if (_userId == null) {
      _userId = const Uuid().v4(); // Standard UUID for Supabase
      await prefs.setString('user_id', _userId!);
    }

    try {
      if (!_isSupabaseInitialized) {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: anonKey,
        );
        _isSupabaseInitialized = true;
      }
    } catch (e) {
      debugPrint('Supabase init notice: $e');
    }
  }

  static String get userId => _userId ?? '00000000-0000-0000-0000-000000000001';

  static Future<void> setWebhookUrl(String url) async {
    _currentEndpoint = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('supabase_url', url);
  }

  static String get webhookUrl => _currentEndpoint;
  static bool get isConnected => true;

  /// Sync User Profile data to Supabase
  static Future<bool> syncUserProfile({
    required String userName,
    required int cycleLength,
    required int periodDuration,
  }) async {
    try {
      // 1. Direct Supabase Client attempt
      try {
        final client = Supabase.instance.client;
        await client.from('profiles').upsert({
          'id': userId,
          'avg_cycle_length': cycleLength,
          'avg_period_length': periodDuration,
          'updated_at': DateTime.now().toIso8601String(),
        });
        return true;
      } catch (_) {}

      // 2. Fallback direct Supabase REST API call
      final url = Uri.parse('$supabaseUrl/rest/v1/profiles');
      final response = await http.post(
        url,
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/json',
          'Prefer': 'resolution=merge-duplicates',
        },
        body: jsonEncode({
          'id': userId,
          'avg_cycle_length': cycleLength,
          'avg_period_length': periodDuration,
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      debugPrint('Supabase profile sync error: $e');
      return false;
    }
  }

  /// Sync Daily Symptom Log to Supabase
  static Future<bool> syncDailyLog({
    required String date,
    required String flow,
    required String mood,
    required List<String> symptoms,
    required bool tookSupplements,
    String? notes,
  }) async {
    try {
      final logDate = date.split(' ')[0];

      // 1. Direct Supabase Client attempt
      try {
        final client = Supabase.instance.client;
        await client.from('symptom_logs').upsert({
          'user_id': userId,
          'log_date': logDate,
          'symptoms': symptoms,
          'moods': [mood],
          'notes': notes ?? '',
        });
        return true;
      } catch (_) {}

      // 2. Fallback direct Supabase REST API call
      final url = Uri.parse('$supabaseUrl/rest/v1/symptom_logs');
      final response = await http.post(
        url,
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/json',
          'Prefer': 'resolution=merge-duplicates',
        },
        body: jsonEncode({
          'user_id': userId,
          'log_date': logDate,
          'symptoms': symptoms,
          'moods': [mood],
          'notes': notes ?? '',
        }),
      );

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      debugPrint('Supabase daily log sync error: $e');
      return false;
    }
  }

  /// Sync Historical Period Entry to Supabase
  static Future<bool> syncHistoryEntry({
    required String startDate,
    required String endDate,
    required int durationDays,
    required String flowIntensity,
    required String notes,
  }) async {
    try {
      final sDate = startDate.split(' ')[0];
      final eDate = endDate.split(' ')[0];

      // 1. Direct Supabase Client attempt
      try {
        final client = Supabase.instance.client;
        await client.from('cycle_logs').upsert({
          'user_id': userId,
          'start_date': sDate,
          'end_date': eDate,
          'flow_intensity': flowIntensity.toLowerCase(),
          'notes': notes,
        });
        return true;
      } catch (_) {}

      // 2. Fallback direct Supabase REST API call
      final url = Uri.parse('$supabaseUrl/rest/v1/cycle_logs');
      final response = await http.post(
        url,
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/json',
          'Prefer': 'resolution=merge-duplicates',
        },
        body: jsonEncode({
          'user_id': userId,
          'start_date': sDate,
          'end_date': eDate,
          'flow_intensity': flowIntensity.toLowerCase(),
          'notes': notes,
        }),
      );

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      debugPrint('Supabase history sync error: $e');
      return false;
    }
  }

  /// Fetch all historical cycles from Supabase to fill data
  static Future<List<Map<String, dynamic>>> fetchHistoryEntries() async {
    try {
      final url = Uri.parse('$supabaseUrl/rest/v1/cycle_logs?user_id=eq.$userId&order=start_date.desc');
      final response = await http.get(
        url,
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
      );

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(list);
      }
    } catch (e) {
      debugPrint('Supabase fetch history error: $e');
    }
    return [];
  }

  /// Fetch all daily symptom logs from Supabase to fill data
  static Future<List<Map<String, dynamic>>> fetchDailyLogs() async {
    try {
      final url = Uri.parse('$supabaseUrl/rest/v1/symptom_logs?user_id=eq.$userId&order=log_date.desc');
      final response = await http.get(
        url,
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
      );

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(list);
      }
    } catch (e) {
      debugPrint('Supabase fetch daily logs error: $e');
    }
    return [];
  }
}
