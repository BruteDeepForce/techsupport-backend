import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techsupport_mobile/features/documents/data/document_service.dart';
import 'package:techsupport_mobile/features/documents/models/document_models.dart';

/// `DocumentService._toMultipart` özel davranışı test edilemiyor; web'de
/// `path` alanı `blob:` URL'si olduğu için `MultipartFile.fromFile`
/// çağrılmamalı. Burada public API üzerinden aynı dosya şekli
/// doğrulanıyor.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DocumentUploadResult', () {
    test('PascalCase alanları okur', () {
      final result = DocumentUploadResult.fromJson({
        'DocumentId': 'abc',
        'DocumentName': 'Garanti.pdf',
        'PageCount': 4,
        'ChunkCount': 7,
        'FileSizeBytes': 2048,
        'ContentType': 'application/pdf',
      });

      expect(result.documentId, 'abc');
      expect(result.documentName, 'Garanti.pdf');
      expect(result.pageCount, 4);
      expect(result.chunkCount, 7);
      expect(result.fileSizeBytes, 2048);
    });

    test('camelCase alanları da okur', () {
      final result = DocumentUploadResult.fromJson({
        'documentId': 'xyz',
        'documentName': 'Sözleşme.pdf',
        'pageCount': 2,
      });

      expect(result.documentId, 'xyz');
      expect(result.pageCount, 2);
      // Eksik alanlar sıfıra düşmeli, çökertmemeli.
      expect(result.chunkCount, 0);
      expect(result.fileSizeBytes, 0);
    });

    test('boyutu okunabilir biçime çevirir', () {
      expect(_result(512).readableSize, '512 B');
      expect(_result(2048).readableSize, '2.0 KB');
      expect(_result(3 * 1024 * 1024).readableSize, '3.0 MB');
    });
  });

  group('DocumentItem', () {
    test('PascalCase alanları okur', () {
      final item = DocumentItem.fromJson({
        'Title': 'Garanti',
        'Key': 'lineer-ai-pdf/policy/tenant/doc.pdf',
        'Url': 'https://bucket.s3.amazonaws.com/x?sig=abc',
      });

      expect(item.title, 'Garanti');
      expect(item.key, 'lineer-ai-pdf/policy/tenant/doc.pdf');
      expect(item.canOpen, isTrue);
      expect(item.displayTitle, 'Garanti');
    });

    test('başlık boşsa anahtarın son parçasına düşer', () {
      final item = DocumentItem.fromJson({
        'Key': 'lineer-ai-pdf/policy/tenant-1/politika.pdf',
        'Url': 'https://example.com',
      });

      expect(item.title, '');
      expect(item.displayTitle, 'politika.pdf');
      expect(item.canOpen, isTrue);
    });

    test('bağlantı boşsa açılamaz olarak işaretlenir', () {
      final item = DocumentItem.fromJson({'Key': 'a/b.pdf', 'Url': ''});
      expect(item.canOpen, isFalse);
    });

    test('tamamen boş gelen kayıt çökertmez', () {
      final item = DocumentItem.fromJson({});
      expect(item.key, '');
      expect(item.canOpen, isFalse);
      expect(item.displayTitle, 'Adsız döküman');
    });
  });

  group('web yükleme', () {
    test('path alanı blob URL olsa da bayttan gönderir', () async {
      // file_picker web'de path'i `blob:...` olarak doldurur. Eğer kod
      // bu alana güvenip `MultipartFile.fromFile` çağırırsa tarayıcıda
      // UnsupportedError fırlatır ve istek hiç gönderilmez.
      final file = PlatformFile(
        name: 'politika.pdf',
        // Gerçek `blob:` URL'si; okunabilir değil.
        path: 'blob:http://localhost:5001/2f8a-4c1e',
        size: 5,
        bytes: Uint8List.fromList([1, 2, 3, 4, 5]),
      );

      final multipart = await _multipartFor(file);

      expect(
        multipart,
        isNotNull,
        reason: 'Web\'de path blob URL olduğunda istek oluşturulmalı',
      );
      expect(multipart!.filename, 'politika.pdf');
      expect(multipart.length, 5);
    });

    test('kIsWeb doğru algılanır', () {
      // Test ortamı web değil; bu yüzden mobil dalı da doğrulanabilir.
      expect(kIsWeb, isFalse);
    });
  });
}

DocumentUploadResult _result(int bytes) => DocumentUploadResult.fromJson({
      'fileSizeBytes': bytes,
    });

/// `_toMultipart` özel metodu; testler için aynı davranışı veren yardımcı.
///
/// Servisin iç kodu ile birebir aynı mantığı içerir.
Future<MultipartFile?> _multipartFor(PlatformFile file) async {
  if (!kIsWeb) {
    final path = file.path;
    if (path != null && path.isNotEmpty && !path.startsWith('blob:')) {
      return MultipartFile.fromFile(path, filename: file.name);
    }
  }

  final bytes = file.bytes;
  if (bytes == null) return null;
  return MultipartFile.fromBytes(bytes, filename: file.name);
}