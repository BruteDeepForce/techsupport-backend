import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../device/data/device_service.dart';
import '../../device/model/device_model.dart';
import 'customer_home_page.dart';

class CustomerDeviceDetailPage extends StatefulWidget {
  const CustomerDeviceDetailPage({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<CustomerDeviceDetailPage> createState() =>
      _CustomerDeviceDetailPageState();
}

class _CustomerDeviceDetailPageState extends State<CustomerDeviceDetailPage> {
  final DeviceService _deviceService = DeviceService();
  late Future<DeviceRecord> _deviceFuture;

  @override
  void initState() {
    super.initState();
    _deviceFuture = _deviceService.getDeviceById(widget.deviceId);
  }

  void _refresh() {
    setState(() {
      _deviceFuture = _deviceService.getDeviceById(widget.deviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'Müşteri',
      subtitle: 'Cihaz Detayı',
      showBack: true,
      trailing: IconButton(
        onPressed: _refresh,
        icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
      ),
      tabBar: LinearTabBar(
        items: [
          LinearTabItem(
            icon: Icons.grid_view_rounded,
            label: 'Ana Sayfa',
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const CustomerHomePage(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
          const LinearTabItem(
              icon: Icons.local_offer_outlined, label: 'Teklifler'),
          const LinearTabItem(
              icon: Icons.devices_other_outlined,
              label: 'Cihazlar',
              active: true),
          const LinearTabItem(icon: Icons.logout_rounded, label: 'Çıkış'),
        ],
      ),
      children: [
        FutureBuilder<DeviceRecord>(
          future: _deviceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return LinearCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cihaz detayı yüklenemedi'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refresh,
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              );
            }
            final device = snapshot.data;
            if (device == null) {
              return const LinearCard(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Kayıt bulunamadı'),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearSection(
                  title: 'Cihaz Özeti',
                  trailing: LinearBadge(
                    label: _statusLabel(device.status),
                    color: _statusColor(device.status),
                  ),
                ),
                LinearCard(
                  child: Column(
                    children: [
                      _InfoRow('Marka', device.brand),
                      _InfoRow('Model', device.model),
                      _InfoRow('Seri No', device.serialNumber),
                      _InfoRow('Barkod', device.barcodeNumber ?? '-'),
                      _InfoRow('Durum', _statusLabel(device.status)),
                      _InfoRow('Aktif', device.isActive ? 'Aktif' : 'Pasif'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                LinearSection(title: 'Garanti'),
                LinearCard(
                  child: Column(
                    children: [
                      _InfoRow(
                        'Garanti Süresi',
                        device.guaranteePeriod == null
                            ? '-'
                            : '${device.guaranteePeriod} ay',
                      ),
                      _InfoRow(
                        'Garanti Başlangıcı',
                        device.warrantyStartAtUtc == null
                            ? '-'
                            : _formatDate(device.warrantyStartAtUtc!),
                      ),
                      _InfoRow(
                        'Garanti Bitiş',
                        device.warrantyEndAtUtc == null
                            ? '-'
                            : _formatDate(device.warrantyEndAtUtc!),
                      ),
                    ],
                  ),
                ),
                if ((device.problemDescription ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  LinearSection(title: 'Problem Açıklaması'),
                  LinearCard(
                    child: Text(
                      device.problemDescription!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
              ],
            );
          },
        ),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 12)),
          ),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600)),
        ],
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

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'inrepair':
      return AppColors.statusOrange;
    case 'inmaintenance':
      return AppColors.statusBlue;
    case 'selled':
      return AppColors.statusGreen;
    case 'returned':
      return AppColors.statusRed;
    default:
      return AppColors.statusYellow;
  }
}
