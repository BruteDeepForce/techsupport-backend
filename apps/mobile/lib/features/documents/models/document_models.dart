/// Backend `S3Service.PolicyDocument` kaydını döndürür.
class DocumentItem {
  const DocumentItem({
    required this.title,
    required this.key,
    required this.url,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      title: _readString(json, ['Title', 'title']),
      key: _readString(json, ['Key', 'key']),
      url: _readString(json, ['Url', 'url']),
    );
  }

  final String title;
  final String key;

  /// S3 ön imzalı (presigned) bağlantı. Süreli olduğu için her açılışta
  /// backend'den tazelenmesi gerekir.
  final String url;

  bool get canOpen => url.trim().isNotEmpty;

  /// `Title` boş gelirse anahtarın son parçasına düşülür.
  String get displayTitle {
    if (title.trim().isNotEmpty) return title.trim();

    final fileName = key.split('/').last;
    return fileName.isEmpty ? 'Adsız döküman' : fileName;
  }
}

/// Yüklenen politika dökümanının backend yanıtı.
///
/// Şimdilik yalnızca yükleme testi yapılıyor; liste işlemleri daha sonra
/// kurgulanacak.
class DocumentUploadResult {
  const DocumentUploadResult({
    required this.documentId,
    required this.documentName,
    required this.pageCount,
    required this.chunkCount,
    required this.fileSizeBytes,
    required this.contentType,
  });

  factory DocumentUploadResult.fromJson(Map<String, dynamic> json) {
    return DocumentUploadResult(
      documentId: _readId(json, ['documentId', 'DocumentId', 'id', 'Id']),
      documentName:
          _readString(json, ['documentName', 'DocumentName', 'name', 'Name']),
      pageCount: _readInt(json, ['pageCount', 'PageCount']),
      chunkCount: _readInt(json, ['chunkCount', 'ChunkCount']),
      fileSizeBytes:
          _readInt(json, ['fileSizeBytes', 'FileSizeBytes', 'size', 'Size']),
      contentType: _readString(
          json, ['contentType', 'ContentType', 'mimeType', 'MimeType']),
    );
  }

  final String documentId;
  final String documentName;
  final int pageCount;
  final int chunkCount;
  final int fileSizeBytes;
  final String contentType;

  /// Bayt değerini okunabilir biçime çevirir.
  String get readableSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Backend alan adları PascalCase geliyor; iki biçimi de kabul ediyoruz.
dynamic _readValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) return value;
  }
  return null;
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  final value = _readValue(json, keys);
  return value?.toString() ?? '';
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  final value = _readValue(json, keys);
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _readId(Map<String, dynamic> json, List<String> keys) =>
    _readString(json, keys);