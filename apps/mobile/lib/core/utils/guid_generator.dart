import 'dart:math';

/// RFC 4122 sürüm 4 biçiminde benzersiz GUID üretir.
///
/// Backend tarafında `Guid` olarak parse edildiği için format
/// `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx` olmak zorunda.
class GuidGenerator {
  GuidGenerator._internal() : _random = Random.secure();

  static final GuidGenerator _instance = GuidGenerator._internal();

  factory GuidGenerator() => _instance;

  final Random _random;

  static String newGuid() => _instance._generate();

  String _generate() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));

    // version 4
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // variant 10xx
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
