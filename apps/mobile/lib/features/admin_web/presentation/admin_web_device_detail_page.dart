import 'package:flutter/material.dart';

import '../../device/data/device_service.dart';
import '../../device/model/device_model.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';
import 'shared/admin_web_topbar.dart';

class AdminWebDeviceDetailPage extends StatefulWidget {
  const AdminWebDeviceDetailPage({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  State<AdminWebDeviceDetailPage> createState() =>
      _AdminWebDeviceDetailPageState();
}

class _AdminWebDeviceDetailPageState extends State<AdminWebDeviceDetailPage> {
  final DeviceService _deviceService = DeviceService();
  late Future<DeviceRecord> _deviceFuture;

  @override
  void initState() {
    super.initState();
    _deviceFuture = _deviceService.getDeviceById(
      widget.deviceId,
    );
  }

  void _refresh() {
    setState(() {
      _deviceFuture = _deviceService.getDeviceById(
        widget.deviceId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      active: AdminNavKey.devices,
      actions: [
        AdminWebActionButton(
          label: 'Yenile',
          icon: Icons.refresh,
          onPressed: _refresh,
        ),
      ],
      body: FutureBuilder<DeviceRecord>(
        future: _deviceFuture,
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
                child: Text('Cihaz detayı yüklenemedi'),
              ),
            );
          }
          final device = snapshot.data;
          if (device == null) {
            return const _Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Kayıt bulunamadı'),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Breadcrumb(),
              const SizedBox(height: 12),
              _Header(device: device),
              const SizedBox(height: 16),
              _Card(
                child: Column(
                  children: [
                    _InfoRow('Marka', device.brand),
                    _InfoRow('Model', device.model),
                    _InfoRow('Seri No', device.serialNumber),
                    _InfoRow('Durum', _statusLabel(device.status)),
                    _InfoRow('Aktif', device.isActive ? 'Aktif' : 'Pasif'),
                    _InfoRow('Müşteri', device.customerName ?? '-'),
                    _InfoRow('Barkod', device.barcodeNumber ?? '-'),
                    _InfoRow(
                        'Garanti Süresi',
                        device.guaranteePeriod == null
                            ? '-'
                            : '${device.guaranteePeriod} ay'),
                    _InfoRow(
                        'Garanti Başlangıcı',
                        device.warrantyStartAtUtc == null
                            ? '-'
                            : _formatDate(device.warrantyStartAtUtc!)),
                    _InfoRow(
                        'Garanti Bitiş',
                        device.warrantyEndAtUtc == null
                            ? '-'
                            : _formatDate(device.warrantyEndAtUtc!)),
                    _InfoRow(
                        'Oluşturma',
                        device.createdAtUtc == null
                            ? '-'
                            : _formatDate(device.createdAtUtc!)),
                    _InfoRow(
                        'Güncelleme',
                        device.updatedAtUtc == null
                            ? '-'
                            : _formatDate(device.updatedAtUtc!)),
                    if (device.deactivatedAtUtc != null)
                      _InfoRow('Deaktif', _formatDate(device.deactivatedAtUtc!)),
                  ],
                ),
              ),
              if ((device.problemDescription ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Problem Açıklaması',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        device.problemDescription!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF0F172A),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        Text('Cihaz Yönetimi',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
        SizedBox(width: 6),
        Text('Detay', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.device});

  final DeviceRecord device;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${device.brand} ${device.model}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Seri: ${device.serialNumber}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        _StatusPill(label: _statusLabel(device.status)),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF3B82F6)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final local = dt.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'inrepair':
      return 'Onarımda';
    case 'inmaintenance':
      return 'Bakımda';
    case 'selled':
      return 'Satıldı';
    case 'returned':
      return 'İade';
    default:
      return 'Diğer';
  }
}
