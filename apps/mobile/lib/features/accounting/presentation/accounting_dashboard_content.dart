import 'package:flutter/material.dart';

import 'package:techsupport_mobile/core/design/app_design.dart';

import '../models/accounting_models.dart';

enum AccountingSection { overview, invoices, payments, movements }

class AccountingDashboardContent extends StatefulWidget {
  const AccountingDashboardContent({
    super.key,
    required this.data,
    required this.webLayout,
    required this.onOpenInvoice,
  });

  final AccountingDashboardData data;
  final bool webLayout;
  final Future<void> Function(AccountingInvoice invoice) onOpenInvoice;

  @override
  State<AccountingDashboardContent> createState() =>
      _AccountingDashboardContentState();
}

class _AccountingDashboardContentState
    extends State<AccountingDashboardContent> {
  AccountingSection _section = AccountingSection.overview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryGrid(data: widget.data, webLayout: widget.webLayout),
        const SizedBox(height: 18),
        _SectionSelector(
          selected: _section,
          onChanged: (value) => setState(() => _section = value),
        ),
        const SizedBox(height: 16),
        switch (_section) {
          AccountingSection.overview => _Overview(
              data: widget.data,
              webLayout: widget.webLayout,
              onOpenInvoice: widget.onOpenInvoice,
            ),
          AccountingSection.invoices => _InvoiceList(
              invoices: widget.data.invoices,
              webLayout: widget.webLayout,
              onOpenInvoice: widget.onOpenInvoice,
            ),
          AccountingSection.payments => _PaymentList(
              payments: widget.data.payments,
              webLayout: widget.webLayout,
            ),
          AccountingSection.movements => _MovementList(
              movements: widget.data.movements,
              webLayout: widget.webLayout,
            ),
        },
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.data, required this.webLayout});

  final AccountingDashboardData data;
  final bool webLayout;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MetricCard(
        label: 'Cari Bakiye',
        value: formatMoney(data.totalBalance),
        caption: '${data.accounts.length} aktif hesap',
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFF4F46E5),
      ),
      _MetricCard(
        label: 'Açık Alacak',
        value: formatMoney(data.totalReceivable),
        caption: '${_openInvoiceCount(data.invoices)} açık fatura',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFFF59E0B),
      ),
      _MetricCard(
        label: 'Toplam Tahsilat',
        value: formatMoney(data.collectedAmount),
        caption: '${data.payments.length} ödeme kaydı',
        icon: Icons.payments_outlined,
        color: const Color(0xFF10B981),
      ),
      _MetricCard(
        label: 'Cari Hareket',
        value: '${data.movements.length}',
        caption:
            'Borç ${formatMoney(data.totalDebit)} · Alacak ${formatMoney(data.totalCredit)}',
        icon: Icons.swap_vert_circle_outlined,
        color: const Color(0xFF0EA5E9),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = webLayout && constraints.maxWidth >= 900 ? 4 : 2;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards) SizedBox(width: width, child: card)
          ],
        );
      },
    );
  }

  int _openInvoiceCount(List<AccountingInvoice> invoices) => invoices
      .where((invoice) =>
          invoice.status != 'Paid' && invoice.status != 'Cancelled')
      .length;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: adminAwareSurface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: adminAwareBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 12, color: adminAwareTextSecondary(context))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: adminAwareTextPrimary(context))),
          const SizedBox(height: 5),
          Text(caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11, color: adminAwareTextTertiary(context))),
        ],
      ),
    );
  }
}

class _SectionSelector extends StatelessWidget {
  const _SectionSelector({required this.selected, required this.onChanged});

  final AccountingSection selected;
  final ValueChanged<AccountingSection> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = {
      AccountingSection.overview: 'Genel Bakış',
      AccountingSection.invoices: 'Faturalar',
      AccountingSection.payments: 'Tahsilatlar',
      AccountingSection.movements: 'Cari Hareketler',
    };

    return SizedBox(
      height: 39,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final entry in labels.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: selected == entry.key,
                onSelected: (_) => onChanged(entry.key),
                showCheckmark: false,
                selectedColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E3A5F)
                    : const Color(0xFF0F172A),
                backgroundColor: adminAwareSurface(context),
                side: BorderSide(color: adminAwareBorder(context)),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected == entry.key
                      ? Colors.white
                      : (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.data,
    required this.webLayout,
    required this.onOpenInvoice,
  });

  final AccountingDashboardData data;
  final bool webLayout;
  final Future<void> Function(AccountingInvoice invoice) onOpenInvoice;

  @override
  Widget build(BuildContext context) {
    final invoices = data.invoices.take(5).toList();
    final movements = data.movements.take(6).toList();

    if (!webLayout) {
      return Column(
        children: [
          _Panel(
            title: 'Son Faturalar',
            child: _InvoiceList(
              invoices: invoices,
              webLayout: false,
              onOpenInvoice: onOpenInvoice,
              embedded: true,
            ),
          ),
          const SizedBox(height: 14),
          _Panel(
            title: 'Son Cari Hareketler',
            child: _MovementList(
              movements: movements,
              webLayout: false,
              embedded: true,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: _Panel(
            title: 'Son Faturalar',
            child: _InvoiceList(
              invoices: invoices,
              webLayout: true,
              onOpenInvoice: onOpenInvoice,
              embedded: true,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 5,
          child: _Panel(
            title: 'Son Cari Hareketler',
            child: _MovementList(
              movements: movements,
              webLayout: true,
              embedded: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _InvoiceList extends StatelessWidget {
  const _InvoiceList({
    required this.invoices,
    required this.webLayout,
    required this.onOpenInvoice,
    this.embedded = false,
  });

  final List<AccountingInvoice> invoices;
  final bool webLayout;
  final Future<void> Function(AccountingInvoice invoice) onOpenInvoice;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'Henüz fatura kaydı bulunmuyor.',
      );
    }

    final content = webLayout
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 42,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 58,
              columns: const [
                DataColumn(label: Text('Fatura')),
                DataColumn(label: Text('Tarih')),
                DataColumn(label: Text('Durum')),
                DataColumn(label: Text('Toplam'), numeric: true),
                DataColumn(label: Text('Kalan'), numeric: true),
                DataColumn(label: Text('')),
              ],
              rows: [
                for (final invoice in invoices)
                  DataRow(cells: [
                    DataCell(Text(invoice.number,
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(formatDate(invoice.issueDate))),
                    DataCell(_StatusBadge(status: invoice.status)),
                    DataCell(Text(formatMoney(invoice.totalAmount))),
                    DataCell(Text(formatMoney(invoice.remainingAmount))),
                    DataCell(IconButton(
                      tooltip: 'PDF görüntüle',
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 19),
                      onPressed: () => onOpenInvoice(invoice),
                    )),
                  ]),
              ],
            ),
          )
        : Column(
            children: [
              for (var index = 0; index < invoices.length; index++) ...[
                _InvoiceTile(invoice: invoices[index], onOpen: onOpenInvoice),
                if (index != invoices.length - 1) const Divider(height: 1),
              ],
            ],
          );

    return embedded ? content : _Panel(title: 'Faturalar', child: content);
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice, required this.onOpen});

  final AccountingInvoice invoice;
  final Future<void> Function(AccountingInvoice invoice) onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onOpen(invoice),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            const _LeadingIcon(
                icon: Icons.receipt_long_outlined, color: Color(0xFF4F46E5)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invoice.number,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDate(invoice.issueDate)} · Kalan ${formatMoney(invoice.remainingAmount)}',
                    style: TextStyle(
                        fontSize: 11, color: adminAwareTextSecondary(context)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatMoney(invoice.totalAmount),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                _StatusBadge(status: invoice.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentList extends StatelessWidget {
  const _PaymentList({
    required this.payments,
    required this.webLayout,
  });

  final List<AccountingPayment> payments;
  final bool webLayout;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const _EmptyState(
        icon: Icons.payments_outlined,
        message: 'Henüz tahsilat kaydı bulunmuyor.',
      );
    }

    final content = webLayout
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 42,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 58,
              columns: const [
                DataColumn(label: Text('Ödeme No')),
                DataColumn(label: Text('Fatura')),
                DataColumn(label: Text('Yöntem')),
                DataColumn(label: Text('Tarih')),
                DataColumn(label: Text('Durum')),
                DataColumn(label: Text('Tutar'), numeric: true),
              ],
              rows: [
                for (final payment in payments)
                  DataRow(cells: [
                    DataCell(Text(payment.number,
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(payment.invoiceNumber.isEmpty
                        ? '—'
                        : payment.invoiceNumber)),
                    DataCell(Text(paymentMethodLabel(payment.method))),
                    DataCell(Text(formatDate(payment.paymentDate))),
                    DataCell(_StatusBadge(status: payment.status)),
                    DataCell(Text(formatMoney(payment.amount))),
                  ]),
              ],
            ),
          )
        : Column(
            children: [
              for (var index = 0; index < payments.length; index++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Row(
                    children: [
                      const _LeadingIcon(
                          icon: Icons.payments_outlined,
                          color: Color(0xFF10B981)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(paymentLabel(payments[index]),
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                                '${paymentMethodLabel(payments[index].method)} · ${formatDate(payments[index].paymentDate)}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: adminAwareTextSecondary(context))),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatMoney(payments[index].amount),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 5),
                          _StatusBadge(status: payments[index].status),
                        ],
                      ),
                    ],
                  ),
                ),
                if (index != payments.length - 1) const Divider(height: 1),
              ],
            ],
          );

    return _Panel(title: 'Tahsilatlar', child: content);
  }

  String paymentLabel(AccountingPayment payment) =>
      payment.invoiceNumber.isEmpty ? payment.number : payment.invoiceNumber;
}

class _MovementList extends StatelessWidget {
  const _MovementList({
    required this.movements,
    required this.webLayout,
    this.embedded = false,
  });

  final List<AccountingMovement> movements;
  final bool webLayout;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    if (movements.isEmpty) {
      return const _EmptyState(
        icon: Icons.swap_vert_circle_outlined,
        message: 'Henüz cari hareket bulunmuyor.',
      );
    }

    final content = webLayout
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 42,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 58,
              columns: const [
                DataColumn(label: Text('Tarih')),
                DataColumn(label: Text('Açıklama')),
                DataColumn(label: Text('Belge')),
                DataColumn(label: Text('Borç'), numeric: true),
                DataColumn(label: Text('Alacak'), numeric: true),
                DataColumn(label: Text('Bakiye'), numeric: true),
              ],
              rows: [
                for (final movement in movements)
                  DataRow(cells: [
                    DataCell(Text(formatDate(movement.transactionDate))),
                    DataCell(SizedBox(
                      width: 230,
                      child: Text(movement.description,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    )),
                    DataCell(Text(movement.documentNumber.isEmpty
                        ? '—'
                        : movement.documentNumber)),
                    DataCell(Text(movement.debit == 0
                        ? '—'
                        : formatMoney(movement.debit))),
                    DataCell(Text(movement.credit == 0
                        ? '—'
                        : formatMoney(movement.credit))),
                    DataCell(Text(formatMoney(movement.balance))),
                  ]),
              ],
            ),
          )
        : Column(
            children: [
              for (var index = 0; index < movements.length; index++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Row(
                    children: [
                      _LeadingIcon(
                        icon: movements[index].debit > 0
                            ? Icons.arrow_outward_rounded
                            : Icons.south_west_rounded,
                        color: movements[index].debit > 0
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(movements[index].description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(formatDate(movements[index].transactionDate),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: adminAwareTextSecondary(context))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        formatMoney(movements[index].debit > 0
                            ? movements[index].debit
                            : movements[index].credit),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: movements[index].debit > 0
                              ? const Color(0xFFB45309)
                              : const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != movements.length - 1) const Divider(height: 1),
              ],
            ],
          );

    return embedded
        ? content
        : _Panel(title: 'Cari Hareketler', child: content);
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: adminAwareSurface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: adminAwareBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: adminAwareTextPrimary(context))),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statusLabel(status),
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 34, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: adminAwareTextSecondary(context))),
          ],
        ),
      ),
    );
  }
}

String formatMoney(double value) {
  final negative = value < 0;
  final fixed = value.abs().toStringAsFixed(2).split('.');
  final chars = fixed.first.split('').reversed.toList();
  final groups = <String>[];
  for (var index = 0; index < chars.length; index += 3) {
    groups.add(chars.skip(index).take(3).toList().reversed.join());
  }
  final whole = groups.reversed.join('.');
  return '${negative ? '-' : ''}$whole,${fixed.last} ₺';
}

String formatDate(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
}

String statusLabel(String status) => switch (status.toLowerCase()) {
      'draft' => 'Taslak',
      'issued' => 'Kesildi',
      'paid' => 'Ödendi',
      'overdue' => 'Gecikmiş',
      'cancelled' => 'İptal',
      'partiallypaid' => 'Kısmi Ödendi',
      'pendingpayment' => 'Ödeme Bekliyor',
      'tamamlandi' => 'Tamamlandı',
      'beklemede' => 'Beklemede',
      'islemede' => 'İşleniyor',
      'basarisiz' => 'Başarısız',
      'iadeedildi' => 'İade',
      _ => status.isEmpty ? 'Bilinmiyor' : status,
    };

Color statusColor(String status) => switch (status.toLowerCase()) {
      'paid' || 'tamamlandi' => const Color(0xFF059669),
      'partiallypaid' ||
      'pendingpayment' ||
      'beklemede' =>
        const Color(0xFFD97706),
      'overdue' || 'basarisiz' => const Color(0xFFDC2626),
      'cancelled' || 'iadeedildi' => const Color(0xFF64748B),
      _ => const Color(0xFF4F46E5),
    };

String paymentMethodLabel(String method) => switch (method.toLowerCase()) {
      'nakit' => 'Nakit',
      'kredikarti' => 'Kredi Kartı',
      'bankahavalesi' => 'Banka Havalesi',
      'cek' => 'Çek',
      'senet' => 'Senet',
      _ => method.isEmpty ? 'Diğer' : method,
    };
