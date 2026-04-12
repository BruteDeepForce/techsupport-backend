import 'package:flutter/material.dart';
import '../../../core/design/app_design.dart';
import '../../technician/data/technician_service.dart';
import '../../technician/models/technician_models.dart';

class TechnicianDetailPage extends StatefulWidget {
  const TechnicianDetailPage({super.key, required this.id});

  final String id;

  @override
  State<TechnicianDetailPage> createState() => _TechnicianDetailPageState();
}

class _TechnicianDetailPageState extends State<TechnicianDetailPage> {
  final TechnicianService _service = TechnicianService();
  Technician? _tech;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() => _loading = true);
      final t = await _service.getTechnician(widget.id);
      setState(() => _tech = t);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Teknisyen yüklenemedi')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'Teknisyen Detayı',
      subtitle: 'Bilgiler',
      trailing: Container(width: 26, height: 26),
      tabBar: const LinearTabBar(items: []),
      children: [
        if (_loading)
          const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('Yükleniyor...')))
        else if (_tech == null)
          const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('Teknisyen bulunamadı')))
        else
          LinearCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_tech!.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('E-posta: ${_tech!.email}'),
                const SizedBox(height: 6),
                Text('Telefon: ${_tech!.phoneNumber ?? '-'}'),
                const SizedBox(height: 8),
                if (_tech!.specializations != null &&
                    _tech!.specializations!.isNotEmpty)
                  Text(
                      'Uzmanlık: ${_tech!.specializations!.join(', ')}'),
                if (_tech!.isActive != null) ...[
                  const SizedBox(height: 6),
                  Text('Durum: ${_tech!.isActive! ? 'Aktif' : 'Pasif'}'),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
