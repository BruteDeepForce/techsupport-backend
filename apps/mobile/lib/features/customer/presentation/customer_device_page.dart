import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../../auth/data/token_storage.dart';
import '../../device/data/device_service.dart';
import '../../device/model/device_model.dart';
import 'customer_device_detail_page.dart';
import 'customer_home_page.dart';

class CustomerDevicePage extends StatefulWidget {
  const CustomerDevicePage({super.key});

  @override
  State<CustomerDevicePage> createState() => _CustomerDevicePageState();
}

class _CustomerDevicePageState extends State<CustomerDevicePage> {
  final DeviceService _deviceService = DeviceService();
  final TokenStorage _tokenStorage = TokenStorage();
  late Future<List<DeviceRecord>> _devicesFuture;

  @override
  void initState() {
    super.initState();
    _devicesFuture = _loadDevices();
  }

  void _refreshDevices() {
    setState(() {
      _devicesFuture = _loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'Müşteri',
      subtitle: 'Cihazlar',
      trailing: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        alignment: Alignment.center,
        child: const Text('AM',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600)),
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
        FutureBuilder<List<DeviceRecord>>(
          future: _devicesFuture,
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
                    const Text('Cihazlar yüklenemedi'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refreshDevices,
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              );
            }
            final devices = snapshot.data ?? [];
            if (devices.isEmpty) {
              return const LinearCard(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Kayıtlı cihaz yok'),
                ),
              );
            }

            return Column(
              children: [
                LinearSection(title: 'Cihazlar', count: devices.length),
                LinearCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (int i = 0; i < devices.length; i++)
                        _DeviceRow(
                          device: devices[i],
                          showDivider: i != devices.length - 1,
                          onTap: () => Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  CustomerDeviceDetailPage(
                                      deviceId: devices[i].id),
                              transitionDuration: Duration.zero,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<List<DeviceRecord>> _loadDevices() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) return [];
    final payload = _decodeJwtPayload(token);
    final userId = payload['user_id']?.toString();
    if (userId == null || userId.isEmpty) return [];
    return _deviceService.getCustomerDevices(userId);
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = String.fromCharCodes(base64Url.decode(normalized));
    return decoded.isNotEmpty
        ? jsonDecode(decoded) as Map<String, dynamic>
        : {};
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.device,
    required this.showDivider,
    required this.onTap,
  });

  final DeviceRecord device;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5))
              : null,
        ),
        child: Row(
          children: [
            const Icon(Icons.devices_other_outlined,
                color: AppColors.textTertiary, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${device.brand} ${device.model}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Seri: ${device.serialNumber}',
                      style: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LinearBadge(
                  label: _statusLabel(device.status),
                  color: _statusColor(device.status),
                ),
                const SizedBox(height: 6),
                LinearBadge(
                  label: _warrantyLabel(device),
                  color: _warrantyColor(device),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'inrepair':
      return 'Onarımda';
    case 'inmaintenance':
      return 'Bakımda';
    case 'selled':
      return 'Aktif';
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

bool _isWarrantyCovered(DeviceRecord device) {
  final start = device.warrantyStartAtUtc;
  final end = device.warrantyEndAtUtc;
  if (start == null || end == null) return false;
  return start.isBefore(end);
}

String _warrantyLabel(DeviceRecord device) {
  return _isWarrantyCovered(device)
      ? 'Garanti kapsamındadır'
      : 'Garanti kapsamında değil';
}

Color _warrantyColor(DeviceRecord device) {
  return _isWarrantyCovered(device)
      ? AppColors.statusGreen
      : AppColors.statusRed;
}
