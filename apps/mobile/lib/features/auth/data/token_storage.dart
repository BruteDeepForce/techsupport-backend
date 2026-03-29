import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple token storage using flutter_secure_storage.
class TokenStorage {
  TokenStorage() : _storage = const FlutterSecureStorage();

  static const _keyToken = 'auth_token';

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyToken);
  }
}
