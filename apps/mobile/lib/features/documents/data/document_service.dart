import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/network/api_client.dart';
import '../models/document_models.dart';

/// Politika dökümanı yükleme servisi.
class DocumentService {
  DocumentService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  /// Backend'in kabul ettiği en büyük dosya boyutu (20 MB).
  static const int maxFileSizeBytes = 20 * 1024 * 1024;

  static const List<String> allowedExtensions = ['pdf'];

  /// Yalnızca PDF seçen dosya seçiciyi açar.
  ///
  /// [withData] açık: içerik belleğe alınır. Web'de gönderim yalnızca bu
  /// baytlarla mümkün, çünkü `file_picker` yol olarak yalnızca `blob:`
  /// URL'si verir.
  static Future<List<PlatformFile>> pickPdfs() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
      withData: true,
    );
    return result?.files ?? const [];
  }

  /// Dosyayı `multipart/form-data` olarak yükler.
  Future<DocumentUploadResult> uploadPdf(
    PlatformFile file, {
    String? documentName,
  }) async {
    final name = (documentName?.trim().isNotEmpty == true
            ? documentName!.trim()
            : file.name)
        .trim();

    final form = FormData.fromMap({
      'DocumentName': name,
      'File': await _toMultipart(file),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/ai/documents/upload',
      data: form,
      options: Options(
        // Çıkarım ve gömme (embedding) süreci dosya boyutuna göre
        // uzayabilir; varsayılan 15 sn yetersiz kalıyor.
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 180),
      ),
    );

    final data = response.data;
    if (data == null) {
      throw const DocumentUploadException('Sunucu boş yanıt döndü.');
    }

    return DocumentUploadResult.fromJson(data);
  }

  /// S3'teki dökümanları getirir.
  ///
  /// Backend liste boşken `BadRequest` döndürüyor ("No documents found in
  /// S3"). Bu bir hata değil, henüz döküman yüklenmemiş anlamına geldiği
  /// için boş liste olarak karşılanıyor.
  Future<List<DocumentItem>> listDocuments() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/api/ai/documents/list',
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      final items = response.data ?? const [];
      return items
          .map((e) => DocumentItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (_isEmptyListResponse(e)) return const [];

      final body = e.response?.data;
      if (body is String && body.trim().isNotEmpty) {
        throw DocumentUploadException(body);
      }
      rethrow;
    }
  }

  /// Backend'in boş liste için döndüğü `400` durumunu ayırt eder.
  static bool _isEmptyListResponse(DioException e) {
    if (e.response?.statusCode != 400) return false;

    final body = e.response?.data;
    final text = body is String
        ? body
        : (body is Map && body['message'] != null
            ? body['message'].toString()
            : '');

    return text.toLowerCase().contains('no documents');
  }

  Future<MultipartFile> _toMultipart(PlatformFile file) async {
    final filename = file.name;

    // Web'de `path` boş değil; `file_picker` `blob:` URL'si üretir.
    // `MultipartFile.fromFile` `dart:io`'ya dayandığı için tarayıcıda
    // UnsupportedError fırlatır ve istek hiç gönderilmez. Bu yüzden web'de
    // doğrudan baytlar kullanılır.
    if (!kIsWeb) {
      final path = file.path;
      if (path != null && path.isNotEmpty) {
        return MultipartFile.fromFile(path, filename: filename);
      }
    }

    final bytes = file.bytes;
    if (bytes == null) {
      throw const DocumentUploadException('Dosya içeriği okunamadı.');
    }

    return MultipartFile.fromBytes(bytes, filename: filename);
  }
}

/// Sunucudan anlaşılır hata mesajı gelirse o gösterilir.
class DocumentUploadException implements Exception {
  const DocumentUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}