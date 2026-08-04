import 'package:flutter/material.dart';

import '../../../core/design/app_design.dart';
import '../data/technician_service.dart';
import '../models/technician_models.dart';

class TechnicianHrProfilePage extends StatelessWidget {
  const TechnicianHrProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TechnicianService();

    return LinearPageShell(
      title: 'Bilgilerim',
      subtitle: 'Personel kayıt detayları',
      showBack: true,
      tabBar: LinearTabBar(
        items: [
          LinearTabItem(
            icon: Icons.assignment_outlined,
            label: 'İş Emirleri',
            onTap: () => Navigator.of(context).pop(),
          ),
          const LinearTabItem(
            icon: Icons.confirmation_number_outlined,
            label: 'Talepler',
          ),
          const LinearTabItem(
            icon: Icons.badge_outlined,
            label: 'Özlük',
            active: true,
          ),
          const LinearTabItem(
            icon: Icons.logout_rounded,
            label: 'Çıkış',
          ),
        ],
      ),
      children: [
        FutureBuilder<TechnicianEmployeeProfile>(
          future: service.getEmployeeProfileByClaimUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _ProfileLoadingCard();
            }
            if (snapshot.hasError) {
              return const _ProfileMessageCard(
                text: 'Personel bilgileri yüklenemedi.',
              );
            }
            if (!snapshot.hasData) {
              return const _ProfileMessageCard(
                text: 'Personel detayı bulunamadı.',
              );
            }

            final profile = snapshot.data!;
            return Column(
              children: [
                _ProfileHeroCard(profile: profile),
                const SizedBox(height: 12),
                _ProfileStatsRow(profile: profile),
                const SizedBox(height: 12),
                _ProfileInfoCard(
                  title: 'Kimlik Bilgileri',
                  items: _identityItems(profile),
                ),
                const SizedBox(height: 10),
                _ProfileInfoCard(
                  title: 'Çalışma Bilgileri',
                  items: _employmentItems(profile),
                ),
                const SizedBox(height: 10),
                _ProfileInfoCard(
                  title: 'Kayıt Özeti',
                  items: _recordItems(profile),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.profile});

  final TechnicianEmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fallback(profile.fullName),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _fallback(profile.email),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              LinearBadge(
                label: _formatStatus(profile.status),
                color: profile.status.toLowerCase() == 'active'
                    ? AppColors.statusGreen
                    : AppColors.statusGray,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow({required this.profile});

  final TechnicianEmployeeProfile profile;

  @override
  Widget build(BuildContext context) {
    final latestSalary = _latestSalary(profile.employeeSalaries);

    return Row(
      children: [
        Expanded(
          child: _ProfileStatCard(
            label: 'İzin',
            value: profile.employeeLeaves.length.toString(),
            accentColor: AppColors.statusBlue,
            helper: 'Toplam kayıt',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ProfileStatCard(
            label: 'Avans',
            value: profile.employeeAdvances.length.toString(),
            accentColor: AppColors.statusOrange,
            helper: 'Toplam talep',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ProfileStatCard(
            label: 'Maaş',
            value: latestSalary?.netSalary != null
                ? _formatCompactCurrency(latestSalary!.netSalary!)
                : '-',
            accentColor: AppColors.statusGreen,
            helper: 'Net maaş',
          ),
        ),
      ],
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.helper,
  });

  final String label;
  final String value;
  final Color accentColor;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_ProfileInfoItemData> items;

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          for (int index = 0; index < items.length; index++)
            _ProfileInfoRow(
              item: items[index],
              showDivider: index != items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.item,
    required this.showDivider,
  });

  final _ProfileInfoItemData item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.borderSubtle),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              item.value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLoadingCard extends StatelessWidget {
  const _ProfileLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const LinearCard(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(width: 12),
            Text('Personel detayları yükleniyor...'),
          ],
        ),
      ),
    );
  }
}

class _ProfileMessageCard extends StatelessWidget {
  const _ProfileMessageCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoItemData {
  const _ProfileInfoItemData({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

List<_ProfileInfoItemData> _identityItems(TechnicianEmployeeProfile profile) {
  return [
    _ProfileInfoItemData(label: 'Ad Soyad', value: _fallback(profile.fullName)),
    _ProfileInfoItemData(
      label: 'Personel No',
      value: _fallback(profile.employeeNo),
    ),
    _ProfileInfoItemData(label: 'E-posta', value: _fallback(profile.email)),
    _ProfileInfoItemData(label: 'Telefon', value: _fallback(profile.phone)),
    _ProfileInfoItemData(
      label: 'Profil Fotoğrafı',
      value: (profile.profileImageUrl?.isNotEmpty ?? false)
          ? 'Tanımlı'
          : 'Tanımlanmadı',
    ),
  ];
}

List<_ProfileInfoItemData> _employmentItems(TechnicianEmployeeProfile profile) {
  return [
    _ProfileInfoItemData(label: 'Durum', value: _formatStatus(profile.status)),
    _ProfileInfoItemData(
      label: 'Pozisyon',
      value: _fallback(profile.positionName ?? profile.positionId),
    ),
    _ProfileInfoItemData(
      label: 'İşe Başlama',
      value: _formatDate(profile.jobsStartDateUtc),
    ),
    _ProfileInfoItemData(
      label: 'İşten Ayrılma',
      value: _formatDate(profile.jobsEndDateUtc),
    ),
    _ProfileInfoItemData(
      label: 'Kayıt Oluşturma',
      value: _formatDate(profile.createdAtUtc, withTime: true),
    ),
    _ProfileInfoItemData(
      label: 'Son Güncelleme',
      value: _formatDate(profile.updatedAtUtc, withTime: true),
    ),
  ];
}

List<_ProfileInfoItemData> _recordItems(TechnicianEmployeeProfile profile) {
  final latestSalary = _latestSalary(profile.employeeSalaries);
  return [
    _ProfileInfoItemData(
      label: 'İzin Kayıt Sayısı',
      value: profile.employeeLeaves.length.toString(),
    ),
    _ProfileInfoItemData(
      label: 'Avans Kayıt Sayısı',
      value: profile.employeeAdvances.length.toString(),
    ),
    _ProfileInfoItemData(
      label: 'Disiplin Kayıt Sayısı',
      value: profile.disciplineEmployeeRecords.length.toString(),
    ),
    _ProfileInfoItemData(
      label: 'Ödül Kayıt Sayısı',
      value: profile.rewardEmployeeRecords.length.toString(),
    ),
    _ProfileInfoItemData(
      label: 'Maaş Kayıt Sayısı',
      value: profile.employeeSalaries.length.toString(),
    ),
    _ProfileInfoItemData(
      label: 'Son Net Maaş',
      value: latestSalary?.netSalary != null
          ? _formatCurrency(latestSalary!.netSalary!)
          : 'Tanımlanmadı',
    ),
    _ProfileInfoItemData(
      label: 'Son Brüt Maaş',
      value: latestSalary?.grossSalary != null
          ? _formatCurrency(latestSalary!.grossSalary!)
          : 'Tanımlanmadı',
    ),
    _ProfileInfoItemData(
      label: 'Maaş Başlangıç',
      value: latestSalary != null
          ? _formatDate(latestSalary.effectiveFrom)
          : 'Tanımlanmadı',
    ),
  ];
}

TechnicianEmployeeSalary? _latestSalary(
    List<TechnicianEmployeeSalary> salaries) {
  if (salaries.isEmpty) return null;
  final items = [...salaries];
  items.sort((a, b) {
    final aDate = a.effectiveFrom ?? a.createdAtUtc ?? DateTime(1900);
    final bDate = b.effectiveFrom ?? b.createdAtUtc ?? DateTime(1900);
    return bDate.compareTo(aDate);
  });
  return items.first;
}

String _formatStatus(String value) {
  switch (value.toLowerCase()) {
    case 'active':
      return 'Aktif';
    case 'passive':
      return 'Pasif';
    default:
      return value;
  }
}

String _formatDate(DateTime? value, {bool withTime = false}) {
  if (value == null) return 'Tanımlanmadı';
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  if (!withTime) return '$day.$month.$year';
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day.$month.$year $hour:$minute';
}

String _formatCurrency(double value) {
  final fixed = value.toStringAsFixed(2).replaceAll('.', ',');
  return '₺$fixed';
}

String _formatCompactCurrency(double value) {
  if (value >= 1000000) {
    return '₺${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '₺${(value / 1000).toStringAsFixed(1)}K';
  }
  return '₺${value.toStringAsFixed(0)}';
}

String _fallback(String? value) {
  if (value == null || value.trim().isEmpty || value == 'null') {
    return 'Tanımlanmadı';
  }
  return value;
}
