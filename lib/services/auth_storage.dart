import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores and retrieves all Deriv OAuth tokens securely.
/// Uses Android Keystore on Android and Keychain on iOS.
class AuthStorage {
  const AuthStorage._();
  static const AuthStorage instance = AuthStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Keys ──────────────────────────────────────────────────────────────────
  static const _kAccessToken = 'deriv_access_token';
  static const _kRefreshToken = 'deriv_refresh_token';
  static const _kIdToken = 'deriv_id_token';
  static const _kExpiresAt = 'deriv_expires_at';
  static const _kAccount = 'deriv_account';
  static const _kName = 'deriv_name';
  static const _kEmail = 'deriv_email';

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required int expiresIn, // seconds from now
    String? refreshToken,
    String? idToken,
  }) async {
    final expiresAt = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .toIso8601String();

    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kExpiresAt, value: expiresAt),
      if (refreshToken != null)
        _storage.write(key: _kRefreshToken, value: refreshToken),
      if (idToken != null) _storage.write(key: _kIdToken, value: idToken),
    ]);
  }

  Future<void> saveProfile({
    required String account,
    required String name,
    required String email,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccount, value: account),
      _storage.write(key: _kName, value: name),
      _storage.write(key: _kEmail, value: email),
    ]);
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<String?> get accessToken => _storage.read(key: _kAccessToken);
  Future<String?> get refreshToken => _storage.read(key: _kRefreshToken);
  Future<String?> get idToken => _storage.read(key: _kIdToken);
  Future<String?> get account => _storage.read(key: _kAccount);
  Future<String?> get name => _storage.read(key: _kName);
  Future<String?> get email => _storage.read(key: _kEmail);

  Future<bool> get isAccessTokenValid async {
    final raw = await _storage.read(key: _kExpiresAt);
    if (raw == null) return false;
    return DateTime.parse(raw).isAfter(DateTime.now());
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  Future<void> clearAll() => _storage.deleteAll();
}
