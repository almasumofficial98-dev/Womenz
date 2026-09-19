import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cycle_models.dart';

class StorageService extends ChangeNotifier {
  static final StorageService instance = StorageService._internal();
  factory StorageService() => instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  UserProfile _profile = UserProfile();
  List<CycleLog> _cycleLogs = [];
  List<SymptomLog> _symptomLogs = [];

  UserProfile get profile => _profile;
  List<CycleLog> get cycleLogs => List.unmodifiable(_cycleLogs);
  List<SymptomLog> get symptomLogs => List.unmodifiable(_symptomLogs);

  // Check if data is completely NIL (fresh start)
  bool get isNilState => _cycleLogs.isEmpty && _profile.lastPeriodStart == null;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Load profile
    final profileStr = _prefs?.getString('user_profile');
    if (profileStr != null) {
      try {
        _profile = UserProfile.fromJson(jsonDecode(profileStr));
      } catch (e) {
        _profile = UserProfile();
      }
    } else {
      _profile = UserProfile();
    }

    // Load cycle logs (starts NIL if empty)
    final cyclesStr = _prefs?.getString('cycle_logs');
    if (cyclesStr != null) {
      try {
        final List list = jsonDecode(cyclesStr);
        _cycleLogs = list.map((e) => CycleLog.fromJson(e)).toList();
      } catch (e) {
        _cycleLogs = [];
      }
    } else {
      _cycleLogs = [];
    }

    // Load symptom logs
    final symptomsStr = _prefs?.getString('symptom_logs');
    if (symptomsStr != null) {
      try {
        final List list = jsonDecode(symptomsStr);
        _symptomLogs = list.map((e) => SymptomLog.fromJson(e)).toList();
      } catch (e) {
        _symptomLogs = [];
      }
    } else {
      _symptomLogs = [];
    }

    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await _prefs?.setString('user_profile', jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> addCycleLog(CycleLog log) async {
    // Check if updating existing or inserting
    final index = _cycleLogs.indexWhere((e) => e.id == log.id);
    if (index >= 0) {
      _cycleLogs[index] = log;
    } else {
      _cycleLogs.add(log);
    }

    // Sort by start date descending
    _cycleLogs.sort((a, b) => b.startDate.compareTo(a.startDate));

    // Update profile last period start date if newer
    if (_cycleLogs.isNotEmpty) {
      _profile = _profile.copyWith(lastPeriodStart: _cycleLogs.first.startDate);
      await saveProfile(_profile);
    }

    await _saveCycleLogs();
    notifyListeners();
  }

  Future<void> deleteCycleLog(String id) async {
    _cycleLogs.removeWhere((e) => e.id == id);
    if (_cycleLogs.isNotEmpty) {
      _profile = _profile.copyWith(lastPeriodStart: _cycleLogs.first.startDate);
    } else {
      _profile = _profile.copyWith(lastPeriodStart: null);
    }
    await saveProfile(_profile);
    await _saveCycleLogs();
    notifyListeners();
  }

  Future<void> saveSymptomLog(SymptomLog log) async {
    final index = _symptomLogs.indexWhere(
      (e) => _isSameDay(e.date, log.date),
    );
    if (index >= 0) {
      _symptomLogs[index] = log;
    } else {
      _symptomLogs.add(log);
    }
    await _saveSymptomLogs();
    notifyListeners();
  }

  SymptomLog? getSymptomLogForDate(DateTime date) {
    try {
      return _symptomLogs.firstWhere((e) => _isSameDay(e.date, date));
    } catch (_) {
      return null;
    }
  }

  Future<void> resetAllDataToNil() async {
    _cycleLogs = [];
    _symptomLogs = [];
    _profile = UserProfile();
    await _prefs?.remove('user_profile');
    await _prefs?.remove('cycle_logs');
    await _prefs?.remove('symptom_logs');
    notifyListeners();
  }

  Future<void> _saveCycleLogs() async {
    final list = _cycleLogs.map((e) => e.toJson()).toList();
    await _prefs?.setString('cycle_logs', jsonEncode(list));
  }

  Future<void> _saveSymptomLogs() async {
    final list = _symptomLogs.map((e) => e.toJson()).toList();
    await _prefs?.setString('symptom_logs', jsonEncode(list));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
