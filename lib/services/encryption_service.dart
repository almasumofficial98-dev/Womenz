import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class EncryptionService {
  static const String _keyPref = 'user_encryption_passphrase';
  static String? _passphrase;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _passphrase = prefs.getString(_keyPref);
    if (_passphrase == null) {
      _passphrase = 'WMZ-KEY-${const Uuid().v4().toUpperCase()}';
      await prefs.setString(_keyPref, _passphrase!);
    }
  }

  static String get passphrase => _passphrase ?? 'WMZ-KEY-DEFAULT-0001';

  /// Derive 32-byte AES key using SHA-256 from user passphrase
  static enc.Key _getDerivedKey() {
    final bytes = utf8.encode(passphrase);
    final digest = sha256.convert(bytes);
    return enc.Key(Uint8List.fromList(digest.bytes));
  }

  /// Encrypt raw JSON payload using AES-256-CBC
  static String encryptPayload(Map<String, dynamic> rawJson) {
    try {
      final jsonString = jsonEncode(rawJson);
      final key = _getDerivedKey();
      final iv = enc.IV.fromLength(16);

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encrypt(jsonString, iv: iv);

      // Package IV + Encrypted Data in base64 format
      final combined = {
        'iv': iv.base64,
        'ciphertext': encrypted.base64,
      };
      return base64Encode(utf8.encode(jsonEncode(combined)));
    } catch (e) {
      return jsonEncode(rawJson);
    }
  }

  /// Decrypt AES-256-CBC base64 blob back to Map
  static Map<String, dynamic>? decryptPayload(String encryptedBlob) {
    try {
      final decodedCombined = jsonDecode(utf8.decode(base64Decode(encryptedBlob)));
      final iv = enc.IV.fromBase64(decodedCombined['iv']);
      final cipherText = enc.Encrypted.fromBase64(decodedCombined['ciphertext']);

      final key = _getDerivedKey();
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      final decryptedString = encrypter.decrypt(cipherText, iv: iv);
      return jsonDecode(decryptedString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
