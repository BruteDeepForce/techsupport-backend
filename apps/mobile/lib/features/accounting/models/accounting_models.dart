class AccountingDashboardData {
  const AccountingDashboardData({
    required this.accounts,
    required this.invoices,
    required this.payments,
    required this.movements,
    required this.totalReceivable,
  });

  final List<AccountingAccount> accounts;
  final List<AccountingInvoice> invoices;
  final List<AccountingPayment> payments;
  final List<AccountingMovement> movements;
  final double totalReceivable;

  double get totalBalance =>
      accounts.fold(0, (total, account) => total + account.balance);
  double get totalDebit =>
      accounts.fold(0, (total, account) => total + account.totalDebit);
  double get totalCredit =>
      accounts.fold(0, (total, account) => total + account.totalCredit);
  double get collectedAmount => payments
      .where((payment) => payment.status.toLowerCase() == 'tamamlandi')
      .fold(0, (total, payment) => total + payment.amount);
}

class AccountingAccount {
  const AccountingAccount({
    required this.id,
    required this.number,
    required this.name,
    required this.status,
    required this.balance,
    required this.totalDebit,
    required this.totalCredit,
  });

  final String id;
  final String number;
  final String name;
  final String status;
  final double balance;
  final double totalDebit;
  final double totalCredit;

  factory AccountingAccount.fromJson(Map<String, dynamic> json) {
    return AccountingAccount(
      id: _text(json, 'id'),
      number: _text(json, 'accountNumber'),
      name: _text(json, 'name'),
      status: _text(json, 'status'),
      balance: _number(json, 'balance'),
      totalDebit: _number(json, 'totalBorc'),
      totalCredit: _number(json, 'totalAlacak'),
    );
  }
}

class AccountingInvoice {
  const AccountingInvoice({
    required this.id,
    required this.number,
    required this.accountName,
    required this.status,
    required this.type,
    required this.issueDate,
    required this.dueDate,
    required this.totalAmount,
    required this.paidAmount,
  });

  final String id;
  final String number;
  final String accountName;
  final String status;
  final String type;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final double totalAmount;
  final double paidAmount;

  double get remainingAmount => totalAmount - paidAmount;

  factory AccountingInvoice.fromJson(Map<String, dynamic> json) {
    return AccountingInvoice(
      id: _text(json, 'id'),
      number: _text(json, 'invoiceNumber'),
      accountName: _text(json, 'accountName'),
      status: _text(json, 'status'),
      type: _text(json, 'type'),
      issueDate: _date(json, 'issueDate'),
      dueDate: _date(json, 'dueDate'),
      totalAmount: _number(json, 'totalAmount'),
      paidAmount: _number(json, 'paidAmount'),
    );
  }
}

class AccountingPayment {
  const AccountingPayment({
    required this.id,
    required this.number,
    required this.accountName,
    required this.invoiceNumber,
    required this.method,
    required this.status,
    required this.amount,
    required this.paymentDate,
  });

  final String id;
  final String number;
  final String accountName;
  final String invoiceNumber;
  final String method;
  final String status;
  final double amount;
  final DateTime? paymentDate;

  factory AccountingPayment.fromJson(Map<String, dynamic> json) {
    return AccountingPayment(
      id: _text(json, 'id'),
      number: _text(json, 'paymentNumber'),
      accountName: _text(json, 'accountName'),
      invoiceNumber: _text(json, 'invoiceNumber'),
      method: _text(json, 'method'),
      status: _text(json, 'status'),
      amount: _number(json, 'amount'),
      paymentDate: _date(json, 'paymentDate'),
    );
  }
}

class AccountingMovement {
  const AccountingMovement({
    required this.id,
    required this.customerId,
    required this.invoiceNumber,
    required this.paymentNumber,
    required this.type,
    required this.debit,
    required this.credit,
    required this.balance,
    required this.description,
    required this.documentNumber,
    required this.transactionDate,
  });

  final String id;
  final String customerId;
  final String invoiceNumber;
  final String paymentNumber;
  final String type;
  final double debit;
  final double credit;
  final double balance;
  final String description;
  final String documentNumber;
  final DateTime? transactionDate;

  factory AccountingMovement.fromJson(Map<String, dynamic> json) {
    return AccountingMovement(
      id: _text(json, 'id'),
      customerId: _text(json, 'customerId'),
      invoiceNumber: _text(json, 'invoiceNumber'),
      paymentNumber: _text(json, 'paymentNumber'),
      type: _text(json, 'hareketTipi'),
      debit: _number(json, 'borc'),
      credit: _number(json, 'alacak'),
      balance: _number(json, 'bakiye'),
      description: _text(json, 'aciklama'),
      documentNumber: _text(json, 'belgeNumarasi'),
      transactionDate: _date(json, 'islemTarihi'),
    );
  }
}

String _text(Map<String, dynamic> json, String key) =>
    (json[key] ?? json[_pascal(key)] ?? '').toString();

double _number(Map<String, dynamic> json, String key) {
  final value = json[key] ?? json[_pascal(key)];
  return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}

DateTime? _date(Map<String, dynamic> json, String key) {
  final value = json[key] ?? json[_pascal(key)];
  return value == null ? null : DateTime.tryParse(value.toString());
}

String _pascal(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
