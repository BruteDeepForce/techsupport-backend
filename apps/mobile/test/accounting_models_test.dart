import 'package:flutter_test/flutter_test.dart';
import 'package:techsupport_mobile/features/accounting/models/accounting_models.dart';
import 'package:techsupport_mobile/features/accounting/presentation/accounting_dashboard_content.dart';

void main() {
  test('accounting models parse API payload and calculate dashboard totals',
      () {
    final account = AccountingAccount.fromJson({
      'id': 'account-1',
      'accountNumber': 'ACC-1',
      'name': 'Genel Cari Hesap',
      'status': 'Active',
      'balance': 700.50,
      'totalBorc': 1000,
      'totalAlacak': 299.50,
    });
    final invoice = AccountingInvoice.fromJson({
      'id': 'invoice-1',
      'invoiceNumber': 'INV-1',
      'status': 'PartiallyPaid',
      'type': 'Standard',
      'issueDate': '2026-09-27T10:00:00Z',
      'dueDate': '2026-10-27T10:00:00Z',
      'totalAmount': 1000,
      'paidAmount': 300,
    });
    final payment = AccountingPayment.fromJson({
      'id': 'payment-1',
      'paymentNumber': 'PAY-1',
      'invoiceNumber': 'INV-1',
      'method': 'Nakit',
      'status': 'Tamamlandi',
      'amount': 300,
    });

    final dashboard = AccountingDashboardData(
      accounts: [account],
      invoices: [invoice],
      payments: [payment],
      movements: const [],
      totalReceivable: 700,
    );

    expect(account.balance, 700.50);
    expect(invoice.remainingAmount, 700);
    expect(dashboard.totalBalance, 700.50);
    expect(dashboard.totalDebit, 1000);
    expect(dashboard.totalCredit, 299.50);
    expect(dashboard.collectedAmount, 300);
  });

  test('Turkish money and status labels are formatted for the UI', () {
    expect(formatMoney(1234567.5), '1.234.567,50 ₺');
    expect(formatMoney(-75), '-75,00 ₺');
    expect(statusLabel('PartiallyPaid'), 'Kısmi Ödendi');
    expect(paymentMethodLabel('KrediKarti'), 'Kredi Kartı');
  });
}
