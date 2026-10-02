import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../documents/data/document_service.dart';
import '../../documents/models/document_models.dart';
import 'shared/admin_web_design.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';
import 'shared/admin_web_topbar.dart';

/// Yönetim > Dosya / Klasör Yönetimi.
///
/// Şimdilik yalnızca PDF yükleme yapılıyor; yüklenen dökümanları listeleme
/// işlemi daha sonra kurgulanacak.
class AdminWebDocumentsPage extends StatefulWidget {
  const AdminWebDocumentsPage({super.key});

  @override
  State<AdminWebDocumentsPage> createState() => _AdminWebDocumentsPageState();
}

class _AdminWebDocumentsPageState extends State<AdminWebDocumentsPage> {
  final DocumentService _service = DocumentService();

  PlatformFile? _picked;

  bool _uploading = false;
  double? _progress;
  DocumentUploadResult? _lastResult;
  String? _errorText;

  /// S3'teki kayıtlı dökümanlar.
  late Future<List<DocumentItem>> _documentsFuture;
  String? _openingKey;

  @override
  void initState() {
    super.initState();
    _documentsFuture = _service.listDocuments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _documentsFuture = _service.listDocuments();
    });
  }

  /// Dökümanı ön imzalı S3 bağlantısıyla yeni sekmede açar.
  Future<void> _openDocument(DocumentItem document) async {
    if (!document.canOpen || _openingKey != null) return;

    final uri = Uri.tryParse(document.url);
    if (uri == null) {
      setState(() => _errorText = 'Döküman bağlantısı geçersiz.');
      return;
    }

    setState(() => _openingKey = document.key);

    try {
      // `externalApplication` tarayıcıda yeni sekme açar.
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        setState(() => _errorText = 'Bağlantı açılamadı: ${document.url}');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorText = 'Bağlantı açılamadı: ${document.url}');
      }
    } finally {
      if (mounted) setState(() => _openingKey = null);
    }
  }

  final TextEditingController _nameController = TextEditingController();

  Future<void> _pick() async {
    setState(() {
      _errorText = null;
      _lastResult = null;
    });

    final files = await DocumentService.pickPdfs();
    if (files.isEmpty) return;

    final file = files.first;

    if (file.size > DocumentService.maxFileSizeBytes) {
      setState(() {
        _picked = null;
        _nameController.clear();
        _errorText = 'Dosya 20 MB sınırını aşıyor (${_readable(file.size)}).';
      });
      return;
    }

    setState(() {
      _picked = file;
      _nameController.text = file.name.replaceFirst(RegExp(r'\.pdf$'), '');
    });
  }

  void _clear() {
    setState(() {
      _picked = null;
      _nameController.clear();
      _lastResult = null;
      _errorText = null;
      _progress = null;
    });
  }

  Future<void> _upload() async {
    final file = _picked;
    if (file == null || _uploading) return;

    setState(() {
      _uploading = true;
      _errorText = null;
      _lastResult = null;
      _progress = 0;
    });

    try {
      final result = await _service
          .uploadPdf(file, documentName: _nameController.text)
          .timeout(const Duration(seconds: 200));

      if (!mounted) return;
      setState(() {
        _uploading = false;
        _progress = 1;
        _lastResult = result;
      });
      // Yeni döküman S3'e düştüğü için listeyi tazele.
      _reload();
    } on DocumentUploadException catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _progress = null;
        _errorText = e.message;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _progress = null;
        _errorText = _describeDioError(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _progress = null;
        // Önceden burası sessizce yutuluyordu; gerçek neden görünmeyince
        // "istek hiç gönderilmiyor" gibi belirsiz durumlar yaşanıyor.
        _errorText = 'Yükleme başlatılamadı: $e';
      });
    }
  }

  /// Sunucudan anlaşılır hata varsa onu, yoksa taşıma katmanı hatasını
  /// gösterir.
  static String _describeDioError(DioException e) {
    final body = e.response?.data;
    if (body is String && body.trim().isNotEmpty) {
      return 'Sunucu reddetti (${e.response?.statusCode}): $body';
    }
    if (body is Map && body['message'] != null) {
      return 'Sunucu reddetti (${e.response?.statusCode}): ${body['message']}';
    }

    switch (e.type) {
      case DioExceptionType.connectionError:
        return 'Sunucuya ulaşılamadı. Adres: ${e.requestOptions.uri}';
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Zaman aşımı: ${e.message ?? e.type.name}';
      case DioExceptionType.badCertificate:
        return 'SSL sertifikası doğrulanamadı.';
      case DioExceptionType.cancel:
        return 'İstek iptal edildi.';
      case DioExceptionType.badResponse:
        return 'Sunucu ${e.response?.statusCode} döndürdü.';
      case DioExceptionType.unknown:
        return 'Bilinmeyen ağ hatası: ${e.message ?? 'tanımsız'}';
    }
  }

  static String _readable(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      dark: true,
      active: AdminNavKey.documents,
      actions: [
        AdminWebActionButton(
          label: 'Yenile',
          icon: Icons.refresh,
          onPressed: _reload,
        ),
        if (_picked != null && !_uploading)
          AdminWebActionButton(
            label: 'Temizle',
            icon: Icons.close,
            onPressed: _clear,
          ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Breadcrumb(),
          const SizedBox(height: 12),
          const _Header(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final picker = _PickerCard(
                file: _picked,
                nameController: _nameController,
                uploading: _uploading,
                onPick: _uploading ? null : _pick,
              );
              final status = _StatusCard(
                uploading: _uploading,
                progress: _progress,
                result: _lastResult,
                errorText: _errorText,
                hasFile: _picked != null,
                onUpload: _upload,
              );

              if (!wide) {
                return Column(
                  children: [
                    picker,
                    const SizedBox(height: 16),
                    status,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: picker),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: status),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _DocumentsCard(
            documentsFuture: _documentsFuture,
            openingKey: _openingKey,
            onOpen: _openDocument,
            onReload: _reload,
          ),
        ],
      ),
    );
  }
}

/// S3'te kayıtlı dökümanların listesi.
class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard({
    required this.documentsFuture,
    required this.openingKey,
    required this.onOpen,
    required this.onReload,
  });

  final Future<List<DocumentItem>> documentsFuture;
  final String? openingKey;
  final void Function(DocumentItem) onOpen;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            title: 'Yüklenen Dökümanlar',
            subtitle: '',
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<DocumentItem>>(
            future: documentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return _MessageBlock(
                  icon: Icons.cloud_off_outlined,
                  color: AdminTechColors.statusRed,
                  title: 'Liste alınamadı',
                  body: '${snapshot.error}',
                );
              }

              final documents = snapshot.data ?? const [];
              if (documents.isEmpty) {
                return _MessageBlock(
                  icon: Icons.folder_open_outlined,
                  color: AdminTechColors.textTertiary,
                  title: 'Henüz döküman yok',
                  body:
                      'Yukarıdan yüklediğiniz PDF dosyaları burada listelenir.',
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < documents.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _DocumentRow(
                      document: documents[i],
                      isOpening: openingKey == documents[i].key,
                      anyOpening: openingKey != null,
                      onTap: () => onOpen(documents[i]),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Tek döküman satırı; tıklanabilir.
class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.document,
    required this.isOpening,
    required this.anyOpening,
    required this.onTap,
  });

  final DocumentItem document;
  final bool isOpening;
  final bool anyOpening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: document.canOpen && !anyOpening ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AdminTechColors.surfaceRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOpening
                  ? AdminTechColors.cyan
                  : AdminTechColors.borderSubtle,
              width: isOpening ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AdminTechColors.statusRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: Color.fromARGB(255, 50, 133, 250),
                  size: 17,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AdminTechColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isOpening)
                const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 15,
                  color: AdminTechColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text('Yönetim',
            style:
                TextStyle(fontSize: 12, color: AdminTechColors.textTertiary)),
        SizedBox(width: 6),
        Icon(Icons.chevron_right,
            size: 14, color: AdminTechColors.textTertiary),
        SizedBox(width: 6),
        Text('Dosya / Klasör Yönetimi',
            style:
                TextStyle(fontSize: 12, color: AdminTechColors.textSecondary)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dosya / Klasör Yönetimi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AdminTechColors.textPrimary,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Yüklenen Dökümanlar AI tarafından işlenecektir',
          style: TextStyle(color: AdminTechColors.textSecondary),
        ),
      ],
    );
  }
}

/// Dosya seçme ve ad verme alanı.
class _PickerCard extends StatelessWidget {
  const _PickerCard({
    required this.file,
    required this.nameController,
    required this.uploading,
    required this.onPick,
  });

  final PlatformFile? file;
  final TextEditingController nameController;
  final bool uploading;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            title: 'Döküman Yükle',
            subtitle: 'Yalnızca PDF, en fazla 20 MB',
          ),
          const SizedBox(height: 16),
          _DropZone(file: file, uploading: uploading, onTap: onPick),
          const SizedBox(height: 16),
          Text(
            'Döküman adı',
            style: TextStyle(
              fontSize: 12.5,
              color: AdminTechColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            enabled: !uploading,
            style: const TextStyle(
              color: AdminTechColors.textPrimary,
              fontSize: 13.5,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AdminTechColors.surfaceRaised,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              hintText: 'Örn. Garanti Şartları',
              hintStyle: const TextStyle(
                color: AdminTechColors.textTertiary,
                fontSize: 13.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AdminTechColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AdminTechColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AdminTechColors.cyan),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AdminTechColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tıklanabilir bırakma alanı.
class _DropZone extends StatelessWidget {
  const _DropZone({
    required this.file,
    required this.uploading,
    required this.onTap,
  });

  final PlatformFile? file;
  final bool uploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final picked = file;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
        decoration: BoxDecoration(
          color: AdminTechColors.surfaceRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: picked == null
                ? AdminTechColors.border
                : AdminTechColors.cyan.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: (picked == null
                        ? AdminTechColors.cyan
                        : AdminTechColors.statusGreen)
                    .withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                picked == null
                    ? Icons.cloud_upload_outlined
                    : Icons.picture_as_pdf_outlined,
                color: picked == null
                    ? AdminTechColors.cyan
                    : AdminTechColors.statusGreen,
                size: 24,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              picked == null ? 'PDF dosyası seçin' : picked.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AdminTechColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              picked == null
                  ? 'Dosyayı seçmek için tıklayın'
                  : '${_AdminWebDocumentsPageState._readable(picked.size)} · Değiştirmek için tıklayın',
              style: const TextStyle(
                color: AdminTechColors.textTertiary,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yükleme durumu, ilerleme ve sonuç.
class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.uploading,
    required this.progress,
    required this.result,
    required this.errorText,
    required this.hasFile,
    required this.onUpload,
  });

  final bool uploading;
  final double? progress;
  final DocumentUploadResult? result;
  final String? errorText;
  final bool hasFile;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardTitle(
            title: 'Yükleme Durumu',
            subtitle: 'Sunucuya gönderiliyor',
          ),
          const SizedBox(height: 16),
          if (uploading)
            _UploadingBlock(progress: progress)
          else if (errorText != null)
            _MessageBlock(
              icon: Icons.error_outline,
              color: AdminTechColors.statusRed,
              title: 'Yükleme başarısız',
              body: errorText!,
            )
          else if (result != null)
            _ResultBlock(result: result!)
          else
            const _MessageBlock(
              icon: Icons.inbox_outlined,
              color: AdminTechColors.textTertiary,
              title: 'Henüz dosya yok',
              body: 'Soldaki alandan bir PDF seçin ve yükleyin.',
            ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: hasFile && !uploading ? onUpload : null,
            style: FilledButton.styleFrom(
              backgroundColor: AdminTechColors.cyan,
              foregroundColor: const Color(0xFF04222B),
              disabledBackgroundColor: AdminTechColors.surfaceRaised,
              disabledForegroundColor: AdminTechColors.textTertiary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              uploading ? 'Yükleniyor...' : 'Yükle',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadingBlock extends StatelessWidget {
  const _UploadingBlock({required this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    final value = progress ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Döküman işleniyor...',
                style: TextStyle(
                  color: AdminTechColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                color: AdminTechColors.cyan,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AdminTechColors.surfaceRaised,
            color: AdminTechColors.cyan,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Metin çıkarımı ve gömme (embedding) adımı birkaç saniye sürebilir.',
          style: TextStyle(
            color: AdminTechColors.textTertiary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ResultBlock extends StatelessWidget {
  const _ResultBlock({required this.result});

  final DocumentUploadResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MessageBlock(
          icon: Icons.check_circle_outline,
          color: AdminTechColors.statusGreen,
          title: 'Yükleme tamamlandı',
          body: result.documentName.isEmpty
              ? 'Döküman işlendi.'
              : '"${result.documentName}" işlendi.',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _Stat(label: 'Sayfa', value: '${result.pageCount}'),
            const SizedBox(width: 10),
            _Stat(label: 'Parça', value: '${result.chunkCount}'),
            const SizedBox(width: 10),
            _Stat(label: 'Boyut', value: result.readableSize),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AdminTechColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AdminTechColors.textTertiary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AdminTechColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: AdminTechColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminTechColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTechColors.border),
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: AdminTechColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12.5,
            color: AdminTechColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
