import 'package:flutter/material.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/data/hr_services.dart';
import 'package:techsupport_mobile/features/admin_web/presentation/HR/model/hr_models.dart';

class AdminWebHROptionsSection extends StatefulWidget {
  const AdminWebHROptionsSection({super.key});

  @override
  State<AdminWebHROptionsSection> createState() =>
      _AdminWebHROptionsSectionState();
}

class _AdminWebHROptionsSectionState extends State<AdminWebHROptionsSection> {
  final HRService _hrService = HRService();
  late Future<List<HRPositionResponse>> _positionsFuture;

  @override
  void initState() {
    super.initState();
    _positionsFuture = _fetchPositions();
  }

  Future<List<HRPositionResponse>> _fetchPositions() async {
    try {
      return await _hrService.getPositions();
    } catch (_) {
      return [];
    }
  }

  Future<void> _showCreatePositionDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _CreatePositionDialog(hrService: _hrService),
    );

    if (created == true && mounted) {
      setState(() {
        _positionsFuture = _fetchPositions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FBFF), Color(0xFFF1F5F9)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'İnsan kaynakları modülüne ait genel ayarlar ve konfigürasyonlar bu bölümde yer alır. '
              'Pozisyon yönetimi, izin ayarları ve disiplin ayarları gibi temel yapılandırmalar buradan yapılabilir.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 18),
          _SettingsSectionShell(
            title: 'Pozisyon Ayarları',
            subtitle:
                'Pozisyonları görüntüleyin, yönetin ve yeni pozisyon ekleyin.',
            action: OutlinedButton.icon(
              onPressed: _showCreatePositionDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Yeni Pozisyon'),
            ),
            child: FutureBuilder<List<HRPositionResponse>>(
              future: _positionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Pozisyonlar yüklenemedi: ${snapshot.error}'),
                  );
                }

                final positions = snapshot.data ?? const <HRPositionResponse>[];
                if (positions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Henüz pozisyon kaydı bulunmuyor.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  );
                }

                return Column(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Pozisyon',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Açıklama',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Durum',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Oluşturulma Tarihi',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    for (var i = 0; i < positions.length; i++) ...[
                      _PositionRow(position: positions[i]),
                      if (i != positions.length - 1)
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          const _SettingsSectionShell(
            title: 'İzin Ayarları',
            subtitle:
                'İzin türleri, kesinti kuralları ve işleyiş ayarları bu bölümde yer alacak.',
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'İzin ayarları bölümü bir sonraki adımda genişletilecek.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _SettingsSectionShell(
            title: 'Disiplin Ayarları',
            subtitle:
                'Disiplin kategorileri, aksiyon tipleri ve kurallar bu bölümde yer alacak.',
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Disiplin ayarları bölümü bir sonraki adımda genişletilecek.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePositionDialog extends StatefulWidget {
  const _CreatePositionDialog({required this.hrService});

  final HRService hrService;

  @override
  State<_CreatePositionDialog> createState() => _CreatePositionDialogState();
}

class _CreatePositionDialogState extends State<_CreatePositionDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isActive = true;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pozisyon adı zorunludur.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.hrService.createPosition(
        HRCreatePositionRequest(
          name: name,
          description: description.isEmpty ? null : description,
          isActive: _isActive,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pozisyon başarıyla oluşturuldu.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pozisyon oluşturulurken hata: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 760,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF8FBFF), Color(0xFFF1F5F9)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yeni Pozisyon',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'İnsan kaynakları modülünde kullanılacak yeni pozisyon kaydını oluşturun.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    _MiniPill(
                      label: _isActive ? 'Aktif' : 'Pasif',
                      color: _isActive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                                'Pozisyon Adı', 'Örn. Kıdemli Teknisyen'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Durum',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Pozisyon kaydı aktif olarak açılsın',
                                        style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isActive,
                                  onChanged: _isSubmitting
                                      ? null
                                      : (value) =>
                                          setState(() => _isActive = value),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        'Açıklama',
                        'Pozisyonun sorumlulukları veya kısa açıklaması',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Pozisyonu Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }
}

class _SettingsSectionShell extends StatelessWidget {
  const _SettingsSectionShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          child,
        ],
      ),
    );
  }
}

class _PositionRow extends StatelessWidget {
  const _PositionRow({required this.position});

  final HRPositionResponse position;

  @override
  Widget build(BuildContext context) {
    final badgeColor =
        position.isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE0EAFF), Color(0xFFF1F5F9)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    position.name.isNotEmpty
                        ? position.name.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              position.description.isNotEmpty
                  ? position.description
                  : 'Açıklama girilmemiş.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _MiniPill(
                label: position.isActive ? 'Aktif' : 'Pasif',
                color: badgeColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _formatDate(position.createdAtUtc),
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
