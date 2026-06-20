import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../data/technician_service.dart';
import '../models/technician_models.dart';

class TechnicianMyShiftsPage extends StatefulWidget {
  const TechnicianMyShiftsPage({super.key});

  @override
  State<TechnicianMyShiftsPage> createState() => _TechnicianMyShiftsPageState();
}

class _TechnicianMyShiftsPageState extends State<TechnicianMyShiftsPage> {
  final TechnicianService _technicianService = TechnicianService();
  late Future<List<ShiftAssignmentModel>> _shiftsFuture;

  @override
  void initState() {
    super.initState();
    _shiftsFuture = _loadMyShifts();
  }

  Future<List<ShiftAssignmentModel>> _loadMyShifts() {
    return _technicianService.getMyShiftAssignments();
  }

  void _refresh() {
    setState(() {
      _shiftsFuture = _loadMyShifts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'Vardiyalarım',
      subtitle: 'Tüm vardiya geçmişi ve yaklaşan planlar',
      showBack: true,
      tabBar: const SizedBox.shrink(),
      children: [
        FutureBuilder<List<ShiftAssignmentModel>>(
          future: _shiftsFuture,
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
                    const Text('Vardiyalar yüklenemedi'),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refresh,
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              );
            }

            final shifts = snapshot.data ?? [];
            return Column(
              children: [
                if (shifts.isEmpty)
                  const LinearCard(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Atanmış vardiya bulunamadı'),
                    ),
                  )
                else
                  ...shifts.map((shift) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ShiftListCard(shift: shift),
                      )),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ShiftListCard extends StatelessWidget {
  const _ShiftListCard({required this.shift});

  final ShiftAssignmentModel shift;

  @override
  Widget build(BuildContext context) {
    final start = shift.plannedStartTimeUtc.toLocal();
    final end = shift.plannedEndTimeUtc.toLocal();
    return LinearCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 18,
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _shiftLabel(shift),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              LinearBadge(
                label: _shiftStatusText(shift),
                color: _shiftStatusColor(shift),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatDate(start)} • ${_formatTime(start)} - ${_formatTime(end)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

String _shiftLabel(ShiftAssignmentModel shift) {
  final start = shift.plannedStartTimeUtc.toLocal();
  final end = shift.plannedEndTimeUtc.toLocal();
  return '${_formatDate(start)} / ${_formatTime(start)} - ${_formatTime(end)}';
}

String _shiftStatusText(ShiftAssignmentModel shift) {
  if (shift.actualEndTimeUtc != null) {
    return 'Check-out Yapıldı';
  }
  if (shift.actualStartTimeUtc != null) {
    return 'Check-in Yapıldı';
  }
  if (shift.plannedStartTimeUtc.isAfter(DateTime.now().toUtc())) {
    return 'Yaklaşan';
  }
  return 'Check-in Yapılmadı';
}

Color _shiftStatusColor(ShiftAssignmentModel shift) {
  if (shift.actualEndTimeUtc != null) {
    return AppColors.statusGray;
  }
  if (shift.actualStartTimeUtc != null) {
    return AppColors.statusGreen;
  }
  if (shift.plannedStartTimeUtc.isAfter(DateTime.now().toUtc())) {
    return AppColors.statusBlue;
  }
  return AppColors.statusOrange;
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  return '$day.$month.$year';
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
