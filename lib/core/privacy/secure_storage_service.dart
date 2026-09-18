import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const String _pinHashKey = 'womenz_hashed_pin';
  static const String _pinEnabledKey = 'womenz_pin_enabled';

  /// Hashes PIN with SHA-256 before storing to ensure PIN is never saved in plain text
  static String hashPin(String plainPin) {
    final bytes = utf8.encode('womenz_salt_$plainPin');
    return sha256.convert(bytes).toString();
  }

  /// Sets hashed PIN securely
  static Future<void> saveHashedPin(String plainPin) async {
    final prefs = await SharedPreferences.getInstance();
    final hashed = hashPin(plainPin);
    await prefs.setString(_pinHashKey, hashed);
    await prefs.setBool(_pinEnabledKey, true);
  }

  /// Verifies entered PIN against stored hash
  static Future<bool> verifyPin(String enteredPin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_pinHashKey);
    if (storedHash == null) return false;

    final enteredHash = hashPin(enteredPin);
    return storedHash == enteredHash;
  }

  /// Checks if PIN lock is enabled
  static Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinEnabledKey) ?? false;
  }

  /// Disables PIN lock
  static Future<void> disablePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinEnabledKey, false);
    await prefs.remove(_pinHashKey);
  }
}
