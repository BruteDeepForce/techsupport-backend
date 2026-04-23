import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/design/app_design.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/token_storage.dart';
import '../../operations/data/operation_service.dart';
import '../../operations/models/operation_models.dart';
import '../data/technician_service.dart';
import '../models/technician_models.dart';
import 'technician_payment_page.dart';
import 'technician_operation_detail_page.dart';
import 'technician_stock_page.dart';

class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {
  final OperationService _operationService = OperationService();
  final TechnicianService _technicianService = TechnicianService();
  final TokenStorage _tokenStorage = TokenStorage();
  final ImagePicker _picker = ImagePicker();
  late Future<List<OperationRecord>> _opsFuture;
  late Future<Technician?> _meFuture;

  @override
  void initState() {
    super.initState();
    _opsFuture = _operationService.listOperations();
    _meFuture = _loadMe();
  }

  void _refreshOperations() {
    setState(() {
      _opsFuture = _operationService.listOperations();
    });
  }

  void _refreshMe() {
    setState(() {
      _meFuture = _loadMe();
    });
  }

  Future<Technician?> _loadMe() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) return null;
    final payload = _decodeJwtPayload(token);
    final userId = payload['user_id']?.toString();
    if (userId == null || userId.isEmpty) return null;
    return _technicianService.getTechnician(userId);
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

  String? _pictureUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final base = ApiClient().dio.options.baseUrl;
    if (raw.startsWith('/')) return '$base$raw';
    return '$base/$raw';
  }

  Future<void> _pickAndUploadProfilePicture() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await _technicianService.updateProfile(picturePath: picked.path);
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        _refreshMe();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotoğrafı güncellendi')),
        );
      }
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotoğrafı güncellenemedi')),
        );
      }
    }
  }

  Future<void> _showProfilePhotoDialog(String? imageUrl) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: imageUrl == null
                      ? const Icon(Icons.person_outline,
                          size: 84, color: AppColors.textSecondary)
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_outline,
                            size: 84,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await _pickAndUploadProfilePicture();
                  },
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Fotoğrafı Değiştir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
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
    return LinearPageShell(
      title: 'Teknisyen',
      subtitle: 'Teknisyen Portalı',
      trailing: FutureBuilder<Technician?>(
        future: _meFuture,
        builder: (context, snapshot) {
          final me = snapshot.data;
          final imageUrl = _pictureUrl(me?.pictureUrl);
          return InkWell(
            onTap: () => _showProfilePhotoDialog(imageUrl),
            borderRadius: BorderRadius.circular(22),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.bgElevated,
              child: imageUrl == null
                  ? const Icon(Icons.person_outline,
                      size: 24, color: AppColors.textSecondary)
                  : ClipOval(
                      child: Image.network(
                        imageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_outline,
                          size: 24,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
      tabBar: const LinearTabBar(
        items: [
          LinearTabItem(
              icon: Icons.assignment_outlined,
              label: 'İş Emirleri',
              active: true),
          LinearTabItem(
              icon: Icons.confirmation_number_outlined, label: 'Talepler'),
          LinearTabItem(icon: Icons.devices_other_outlined, label: 'Cihazlar'),
          LinearTabItem(icon: Icons.logout_rounded, label: 'Çıkış'),
        ],
      ),
      children: [
        FutureBuilder<List<OperationRecord>>(
          future: _opsFuture,
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
                    const Text('Operasyonlar yüklenemedi'),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refreshOperations,
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              );
            }
            final ops = snapshot.data ?? [];
            final activeCount = ops
                .where(
                    (o) => o.status != 'Completed' && o.status != 'Delivered')
                .length;
            final doneCount = ops
                .where(
                    (o) => o.status == 'Completed' || o.status == 'Delivered')
                .length;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: LinearStatPill(
                            value: activeCount.toString(),
                            label: 'Aktif',
                            color: AppColors.statusBlue)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: LinearStatPill(
                            value: doneCount.toString(),
                            label: 'Çözülen',
                            color: AppColors.statusGreen)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: LinearCommand(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Cihaz Tara',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearCommand(
                        icon: Icons.playlist_add_check_circle_rounded,
                        label: 'İş Al',
                        onTap: _refreshOperations,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearCommand(
                  icon: Icons.inventory_2_outlined,
                  label: 'Parça Talebi Oluştur',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const TechnicianStockPage()),
                  ),
                ),
                const SizedBox(height: 14),
                const LinearFilterTabs(
                  labels: ['Sıradaki İşler', 'Atanmamış'],
                  selectedIndex: 0,
                ),
                const SizedBox(height: 14),
                if (ops.isEmpty)
                  const LinearCard(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Atanmış iş yok'),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (int i = 0; i < ops.length; i++) ...[
                        _OpCard(
                          operationId: ops[i].id,
                          displayId: _shortId(ops[i].id),
                          title: ops[i].title,
                          subtitle: ops[i].description,
                          customer: _shortId(ops[i].customerName),
                          device: _shortId(ops[i].deviceId),
                          priority: _priorityColor(ops[i].priority),
                          status: _operationStatusLabel(ops[i].status),
                          statusColor: _operationStatusColor(ops[i].status),
                          time: _relativeTime(ops[i].occurredAtUtc),
                        ),
                        if (i != ops.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id;

Color _priorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent':
      return AppColors.statusRed;
    case 'high':
      return AppColors.statusOrange;
    default:
      return AppColors.statusBlue;
  }
}

String _operationStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'diagnosing':
      return 'Teşhis';
    case 'waitingforapproval':
      return 'Onay Bekliyor';
    case 'repairing':
      return 'Onarım';
    case 'testing':
      return 'Test';
    case 'completed':
      return 'Tamamlandı';
    case 'delivered':
      return 'Teslim';
    default:
      return 'Yeni';
  }
}

Color _operationStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'delivered':
      return AppColors.statusGreen;
    case 'waitingforapproval':
      return AppColors.statusOrange;
    case 'repairing':
    case 'testing':
      return AppColors.statusYellow;
    case 'diagnosing':
      return AppColors.statusBlue;
    default:
      return AppColors.statusBlue;
  }
}

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().toLocal().difference(dt.toLocal());
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} dk önce';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} saat önce';
  }
  return '${diff.inDays} gün önce';
}

class _OpCard extends StatelessWidget {
  const _OpCard({
    required this.operationId,
    required this.displayId,
    required this.title,
    required this.subtitle,
    required this.customer,
    required this.device,
    required this.priority,
    required this.status,
    required this.statusColor,
    required this.time,
  });

  final String operationId;
  final String displayId;
  final String title;
  final String subtitle;
  final String customer;
  final String device;
  final Color priority;
  final String status;
  final Color statusColor;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LinearCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LinearPriority(color: priority),
              const SizedBox(width: 8),
              Text(displayId,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textTertiary)),
              const Spacer(),
              LinearBadge(label: status, color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Tag(Icons.devices_other_outlined, device),
              _Tag(Icons.person_outline_rounded, customer),
              Text(time,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textTertiary, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 320;
              final detailButton = OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicianOperationDetailPage(
                        operationId: operationId,
                      ),
                    ),
                  );
                },
                child: const Text('Detay'),
              );
              final completeButton = FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicianPaymentPage(
                        operationId: operationId,
                        title: title,
                      ),
                    ),
                  );
                },
                child: const Text('Tamamla'),
              );
              if (isNarrow) {
                return Column(
                  children: [
                    SizedBox(width: double.infinity, child: detailButton),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: completeButton),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: detailButton),
                  const SizedBox(width: 8),
                  Expanded(child: completeButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
