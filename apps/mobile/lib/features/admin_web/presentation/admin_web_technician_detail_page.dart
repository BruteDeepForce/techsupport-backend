import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/network/api_client.dart';
import '../../technician/data/technician_service.dart';
import '../../technician/models/technician_models.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';
import 'shared/admin_web_topbar.dart';

const Color _primary = Color(0xFF2563EB);
const Color _success = Color(0xFF16A34A);
const Color _warning = Color(0xFFD97706);
const Color _danger = Color(0xFFDC2626);
const Color _info = Color(0xFF0EA5E9);
const Color _violet = Color(0xFF7C3AED);
const Color _teal = Color(0xFF0F766E);

class AdminWebTechnicianDetailPage extends StatefulWidget {
  const AdminWebTechnicianDetailPage({super.key, required this.technicianId});

  final String technicianId;

  @override
  State<AdminWebTechnicianDetailPage> createState() =>
      _AdminWebTechnicianDetailPageState();
}

class _AdminWebTechnicianDetailPageState extends State<AdminWebTechnicianDetailPage> {
  final TechnicianService _technicianService = TechnicianService();
  late Future<TechnicianDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _technicianService.getTechnicianDetail(widget.technicianId);
  }

  void _refresh() {
    setState(() {
      _detailFuture = _technicianService.getTechnicianDetail(widget.technicianId);
    });
  }

  String? _fullPictureUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final base = ApiClient().dio.options.baseUrl;
    if (raw.startsWith('/')) return '$base$raw';
    return '$base/$raw';
  }

  Future<void> _showPhotoDialog(String? imageUrl) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 420,
                  color: const Color(0xFFF1F5F9),
                  child: imageUrl == null
                      ? const Icon(
                          Icons.person_outline_rounded,
                          size: 90,
                          color: Color(0xFF64748B),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_outline_rounded,
                            size: 90,
                            color: Color(0xFF64748B),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Kapat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label kopyalandı')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AdminWebShell(
      active: AdminNavKey.team,
      actions: [
        AdminWebActionButton(
          label: 'Yenile',
          icon: Icons.refresh,
          onPressed: _refresh,
        ),
      ],
      body: FutureBuilder<TechnicianDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _Card(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          if (snapshot.hasError) {
            return _Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teknisyen detayı yüklenemedi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Teknisyen bilgilerine ulaşılamadı. Lütfen sayfayı yenileyin veya daha sonra tekrar deneyin.',
                      style: TextStyle(color: Color(0xFF64748B), height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Yeniden Dene'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final detail = snapshot.data;
          if (detail == null) {
            return const _Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Kayıt bulunamadı'),
              ),
            );
          }

          final imageUrl = _fullPictureUrl(detail.pictureUrl);
          final isWide = width >= 1000;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Breadcrumb(),
              const SizedBox(height: 12),
              _ProfileHeader(
                detail: detail,
                imageUrl: imageUrl,
                onPhotoTap: () => _showPhotoDialog(imageUrl),
              ),
              const SizedBox(height: 14),
              _MetricGrid(
                detail: detail,
                columns: width >= 1300 ? 6 : (width >= 1000 ? 3 : 2),
              ),
              const SizedBox(height: 14),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _ContactCard(
                            detail: detail,
                            onCopy: _copyToClipboard,
                          ),
                          const SizedBox(height: 14),
                          _ExpertiseCard(detail: detail),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _WorkloadCard(detail: detail),
                          const SizedBox(height: 14),
                          _RecentOperationsCard(detail: detail),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _ContactCard(detail: detail, onCopy: _copyToClipboard),
                const SizedBox(height: 14),
                _ExpertiseCard(detail: detail),
                const SizedBox(height: 14),
                _WorkloadCard(detail: detail),
                const SizedBox(height: 14),
                _RecentOperationsCard(detail: detail),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.detail,
    required this.imageUrl,
    required this.onPhotoTap,
  });

  final TechnicianDetail detail;
  final String? imageUrl;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onPhotoTap,
            borderRadius: BorderRadius.circular(999),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFE2E8F0),
              child: imageUrl == null
                  ? const Text(
                      'T',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    )
                  : ClipOval(
                      child: Image.network(
                        imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Text(
                          'T',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      detail.name.isEmpty ? 'İsimsiz Teknisyen' : detail.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    _StatusBadge(
                      label: detail.statusLabel,
                      color: detail.isActive ? _success : _danger,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Saha Teknik Servis Teknisyeni',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    _HeaderFact(
                      icon: Icons.alternate_email_rounded,
                      value:
                          detail.email.isEmpty ? 'E-posta belirtilmemiş' : detail.email,
                    ),
                    _HeaderFact(
                      icon: Icons.phone_rounded,
                      value: (detail.phoneNumber ?? '').isEmpty
                          ? 'Telefon belirtilmemiş'
                          : detail.phoneNumber!,
                    ),
                    _HeaderFact(
                      icon: Icons.workspace_premium_outlined,
                      value: '${detail.expertiseCount} uzmanlık alanı',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderFact extends StatelessWidget {
  const _HeaderFact({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.detail, required this.columns});

  final TechnicianDetail detail;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData('Toplam İş', '${detail.assignedOperationCount}',
          Icons.assignment_outlined, _primary),
      _MetricData('Tamamlanan', '${detail.completedOperationCount}',
          Icons.task_alt_rounded, _success),
      _MetricData('Devam Eden', '${detail.ongoingOperationCount}',
          Icons.pending_actions_rounded, _info),
      _MetricData('Yeni Atanan', '${detail.pendingOperationCount}',
          Icons.fiber_new_rounded, _warning),
      _MetricData('Başarı Oranı', '%${_formatRate(detail.completionRate)}',
          Icons.insights_rounded, _violet),
      _MetricData('Uzmanlık', '${detail.expertiseCount}',
          Icons.workspace_premium_outlined, _teal),
    ];

    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.3,
      padding: EdgeInsets.zero,
      children: [
        for (final metric in metrics)
          _MetricCard(
            title: metric.title,
            value: metric.value,
            icon: metric.icon,
            color: metric.color,
          ),
      ],
    );
  }
}

class _MetricData {
  const _MetricData(this.title, this.value, this.icon, this.color);

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.detail, required this.onCopy});

  final TechnicianDetail detail;
  final void Function(String value, String label) onCopy;

  @override
  Widget build(BuildContext context) {
    final months = detail.employmentMonths ?? 0;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'İletişim ve Görev Bilgileri',
            subtitle: 'Personel iletişim, görev başlangıç ve kayıt bilgileri',
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.alternate_email_rounded,
            label: 'Kurumsal E-posta',
            value: detail.email,
            copyable: detail.email.isNotEmpty,
            onCopy: onCopy,
          ),
          _InfoRow(
            icon: Icons.phone_rounded,
            label: 'Telefon Numarası',
            value: (detail.phoneNumber ?? '').isEmpty
                ? 'Belirtilmemiş'
                : detail.phoneNumber!,
            copyable: (detail.phoneNumber ?? '').isNotEmpty,
            onCopy: onCopy,
          ),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'İşe Başlama Tarihi',
            value: detail.employmentStartDate == null
                ? 'Belirtilmemiş'
                : _formatDate(detail.employmentStartDate!),
          ),
          _InfoRow(
            icon: Icons.timelapse_rounded,
            label: 'Toplam Çalışma Süresi',
            value: months <= 0 ? 'Belirtilmemiş' : '$months ay',
          ),
          const _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Görev Tanımı',
            value: 'Saha Teknik Servis Teknisyeni',
          ),
          _InfoRow(
            icon: Icons.how_to_reg_rounded,
            label: 'Kayıt Oluşturma',
            value: detail.createdAt == null
                ? 'Belirtilmemiş'
                : _formatDate(detail.createdAt!),
          ),
          _InfoRow(
            icon: Icons.update_rounded,
            label: 'Son Bilgi Güncelleme',
            value: detail.updatedAt == null
                ? 'Belirtilmemiş'
                : _formatDate(detail.updatedAt!),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ExpertiseCard extends StatelessWidget {
  const _ExpertiseCard({required this.detail});

  final TechnicianDetail detail;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Uzmanlık Alanları',
            subtitle: 'Teknisyenin yetkin olduğu hizmet başlıkları',
          ),
          const SizedBox(height: 14),
          if (detail.specializations.isEmpty)
            const Text(
              'Bu teknisyen için henüz uzmanlık alanı tanımlanmamış.',
              style: TextStyle(color: Color(0xFF94A3B8), height: 1.4),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final specialization in detail.specializations)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 14, color: Color(0xFF2563EB)),
                        const SizedBox(width: 6),
                        Text(
                          specialization,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WorkloadCard extends StatelessWidget {
  const _WorkloadCard({required this.detail});

  final TechnicianDetail detail;

  @override
  Widget build(BuildContext context) {
    final total = detail.assignedOperationCount;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'İş Yükü Özeti',
            subtitle: 'Atanan işlerin durum dağılımı',
          ),
          const SizedBox(height: 16),
          _ProgressRow(
            label: 'Tamamlanan',
            value: detail.completedOperationCount,
            total: total,
            color: _success,
          ),
          const SizedBox(height: 12),
          _ProgressRow(
            label: 'Devam Eden',
            value: detail.ongoingOperationCount,
            total: total,
            color: _info,
          ),
          const SizedBox(height: 12),
          _ProgressRow(
            label: 'Yeni Atanan',
            value: detail.pendingOperationCount,
            total: total,
            color: _warning,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF2563EB)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    total == 0
                        ? 'Bu teknisyene henüz atanmış bir iş kaydı bulunmuyor.'
                        : 'Atanan $total işin %${_formatRate(detail.completionRate)} kadarı tamamlanmış durumda.',
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                      height: 1.4,
                    ),
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

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ),
            Text(
              '$value / $total',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _RecentOperationsCard extends StatelessWidget {
  const _RecentOperationsCard({required this.detail});

  final TechnicianDetail detail;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Son İşlemler',
            subtitle:
                'Teknisyene atanan en güncel ${detail.recentOperations.length} iş kaydı',
          ),
          const SizedBox(height: 12),
          if (detail.recentOperations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Bu teknisyene atanmış iş kaydı bulunmuyor.',
                style: TextStyle(color: Color(0xFF94A3B8), height: 1.4),
              ),
            )
          else
            for (final operation in detail.recentOperations)
              _OperationRow(operation: operation),
        ],
      ),
    );
  }
}

class _OperationRow extends StatelessWidget {
  const _OperationRow({required this.operation});

  final TechnicianOperationSummary operation;

  Color _statusColor() {
    switch (operation.status.toLowerCase()) {
      case 'completed':
        return _success;
      case 'accepted':
        return _info;
      case 'rejected':
        return _danger;
      default:
        return _warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(
              color: _statusColor(),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operation.title.isEmpty ? 'İş kaydı' : operation.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if ((operation.operationType ?? '').isNotEmpty)
                      operation.operationType!,
                    if (operation.assignedAtUtc != null)
                      'Atanma: ${_formatDate(operation.assignedAtUtc!)}',
                  ].join(' • '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusBadge(
            label: operation.statusLabel.isEmpty ? 'Bilinmiyor' : operation.statusLabel,
            color: _statusColor(),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

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
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
    this.copyable = false,
    this.onCopy,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  final bool copyable;
  final void Function(String value, String label)? onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9)),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (copyable)
            IconButton(
              tooltip: 'Kopyala',
              onPressed: () => onCopy?.call(value, label),
              icon: const Icon(
                Icons.copy_rounded,
                size: 15,
                color: Color(0xFF94A3B8),
              ),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text('Yönetim', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Ekip Yönetimi', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Teknisyen Detayı',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$d.$m.$y';
}

String _formatRate(double value) {
  if (value % 1 == 0) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}
