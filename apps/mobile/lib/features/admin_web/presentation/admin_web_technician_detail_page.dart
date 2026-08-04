import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../technician/data/technician_service.dart';
import '../../technician/models/technician_models.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';
import 'shared/admin_web_topbar.dart';

class AdminWebTechnicianDetailPage extends StatefulWidget {
  const AdminWebTechnicianDetailPage({super.key, required this.technicianId});

  final String technicianId;

  @override
  State<AdminWebTechnicianDetailPage> createState() =>
      _AdminWebTechnicianDetailPageState();
}

class _AdminWebTechnicianDetailPageState
    extends State<AdminWebTechnicianDetailPage> {
  final TechnicianService _technicianService = TechnicianService();
  late Future<Technician> _technicianFuture;

  @override
  void initState() {
    super.initState();
    _technicianFuture = _technicianService.getTechnician(widget.technicianId);
  }

  void _refresh() {
    setState(() {
      _technicianFuture = _technicianService.getTechnician(widget.technicianId);
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

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      active: AdminNavKey.team,
      actions: [
        AdminWebActionButton(
          label: 'Yenile',
          icon: Icons.refresh,
          onPressed: _refresh,
        ),
      ],
      body: FutureBuilder<Technician>(
        future: _technicianFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          if (snapshot.hasError) {
            return const _Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Teknisyen detayı yüklenemedi'),
              ),
            );
          }
          final technician = snapshot.data;
          if (technician == null) {
            return const _Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Kayıt bulunamadı'),
              ),
            );
          }
          final imageUrl = _fullPictureUrl(technician.pictureUrl);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Breadcrumb(),
              const SizedBox(height: 12),
              const Text(
                'Teknisyen Detayı',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Seçilen teknisyenin profil bilgileri',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              _Card(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: InkWell(
                        onTap: () => _showPhotoDialog(imageUrl),
                        child: imageUrl == null
                            ? const Icon(Icons.person_outline_rounded,
                                size: 30, color: Color(0xFF64748B))
                            : ClipOval(
                                child: Image.network(
                                  imageUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person_outline_rounded,
                                    size: 30,
                                    color: Color(0xFF64748B),
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
                          Text(
                            technician.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            technician.email,
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    _StatusPill(
                      label: technician.isActive == true ? 'Aktif' : 'Pasif',
                      color: technician.isActive == true
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Card(
                child: Column(
                  children: [
                    _InfoRow(label: 'User Id', value: technician.userId),
                    _InfoRow(label: 'Tenant Id', value: technician.tenantId),
                    _InfoRow(
                      label: 'Telefon',
                      value: (technician.phoneNumber ?? '').isEmpty
                          ? '-'
                          : technician.phoneNumber!,
                    ),
                    _InfoRow(
                      label: 'Uzmanlıklar',
                      value: (technician.specializations ?? []).isEmpty
                          ? '-'
                          : (technician.specializations ?? []).join(', '),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text('Yönetim',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Personel Yönetimi',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Detay', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9)),
              ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
