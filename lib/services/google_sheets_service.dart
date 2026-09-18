import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class GoogleSheetsService {
  // Target User Google Sheet ID & URL
  static const String targetSheetId = '1lW1-0qdECQZFOl1knroVzJzkmzYLO9A_tV1BIxXbsAE';
  static const String targetSheetUrl =
      'https://docs.google.com/spreadsheets/d/$targetSheetId/edit?usp=sharing';

  // Apps Script WebApp Endpoint bound to target sheet
  static const String defaultWebhookUrl =
      'https://script.google.com/macros/s/AKfycbx_WomenzAppSheets_$targetSheetId/exec';

  static String _currentWebhookUrl = defaultWebhookUrl;
  static String? _userId;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentWebhookUrl = prefs.getString('google_sheets_url') ?? defaultWebhookUrl;

    _userId = prefs.getString('user_id');
    if (_userId == null) {
      _userId = 'WMZ-${const Uuid().v4().substring(0, 8).toUpperCase()}';
      await prefs.setString('user_id', _userId!);
    }
  }

  static String get userId => _userId ?? 'WMZ-USER-001';

  static Future<void> setWebhookUrl(String url) async {
    _currentWebhookUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('google_sheets_url', url);
  }

  static String get webhookUrl => _currentWebhookUrl;

  /// Sync User Profile data to Google Sheet
  static Future<bool> syncUserProfile({
    required String userName,
    required int cycleLength,
    required int periodDuration,
  }) async {
    final payload = {
      'action': 'SYNC_USER',
      'sheetId': targetSheetId,
      'userId': userId,
      'userName': userName.isEmpty ? 'User' : userName,
      'cycleLength': cycleLength,
      'periodDuration': periodDuration,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return _sendToGoogleSheets(payload);
  }

  /// Sync Daily Symptom Log to Google Sheet
  static Future<bool> syncDailyLog({
    required String date,
    required String flow,
    required String mood,
    required List<String> symptoms,
    required bool tookSupplements,
    String? notes,
  }) async {
    final payload = {
      'action': 'LOG_DAILY_SYMPTOMS',
      'sheetId': targetSheetId,
      'userId': userId,
      'date': date,
      'flow': flow,
      'mood': mood,
      'symptoms': symptoms.join(', '),
      'tookSupplements': tookSupplements ? 'Yes' : 'No',
      'notes': notes ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    };
    return _sendToGoogleSheets(payload);
  }

  /// Sync Historical Period Entry to Google Sheet
  static Future<bool> syncHistoryEntry({
    required String startDate,
    required String endDate,
    required int durationDays,
    required String flowIntensity,
    required String notes,
  }) async {
    final payload = {
      'action': 'LOG_HISTORY',
      'sheetId': targetSheetId,
      'userId': userId,
      'startDate': startDate,
      'endDate': endDate,
      'durationDays': durationDays,
      'flowIntensity': flowIntensity,
      'notes': notes,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return _sendToGoogleSheets(payload);
  }

  static Future<bool> _sendToGoogleSheets(Map<String, dynamic> payload) async {
    try {
      if (_currentWebhookUrl.isEmpty) return false;

      final response = await http.post(
        Uri.parse(_currentWebhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      debugPrint('Google Sheet Sync to $targetSheetId Status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      debugPrint('Google Sheet Sync Error: $e');
      return false;
    }
  }

  /// Ready-to-use Google Apps Script Code snippet for your Google Sheet
  static String get appsScriptTemplateCode => '''
// Copy and Paste this code in Google Sheets -> Extensions -> Apps Script
// Target Sheet: $targetSheetUrl

function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);
    var ss = SpreadsheetApp.getActiveSpreadsheet();
    
    if (data.action === "SYNC_USER") {
      var sheet = getOrCreateSheet(ss, "Users");
      sheet.appendRow([data.timestamp, data.userId, data.userName, data.cycleLength, data.periodDuration]);
    } else if (data.action === "LOG_DAILY_SYMPTOMS") {
      var sheet = getOrCreateSheet(ss, "DailyLogs");
      sheet.appendRow([data.timestamp, data.userId, data.date, data.flow, data.mood, data.symptoms, data.tookSupplements, data.notes]);
    } else if (data.action === "LOG_HISTORY") {
      var sheet = getOrCreateSheet(ss, "CycleHistory");
      sheet.appendRow([data.timestamp, data.userId, data.startDate, data.endDate, data.durationDays, data.flowIntensity, data.notes]);
    }
    
    return ContentService.createTextOutput(JSON.stringify({"result": "success"}))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({"result": "error", "message": error.toString()}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

function getOrCreateSheet(ss, name) {
  var sheet = ss.getSheetByName(name);
  if (!sheet) {
    sheet = ss.insertSheet(name);
    if (name === "Users") {
      sheet.appendRow(["Timestamp", "User ID", "User Name", "Cycle Length", "Period Duration"]);
    } else if (name === "DailyLogs") {
      sheet.appendRow(["Timestamp", "User ID", "Date", "Flow", "Mood", "Symptoms", "Supplements", "Notes"]);
    } else if (name === "CycleHistory") {
      sheet.appendRow(["Timestamp", "User ID", "Start Date", "End Date", "Duration Days", "Flow Intensity", "Notes"]);
    }
  }
  return sheet;
}
''';
}
