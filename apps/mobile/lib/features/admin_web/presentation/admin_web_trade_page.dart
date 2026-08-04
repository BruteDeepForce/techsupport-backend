import 'dart:math';

import 'package:flutter/material.dart';
import 'package:techsupport_mobile/features/customer/data/customer_service.dart';
import 'package:techsupport_mobile/features/customer/models/customer_models.dart';
import 'package:techsupport_mobile/features/device/data/device_service.dart';
import 'package:techsupport_mobile/features/device/model/device_model.dart';
import 'package:techsupport_mobile/features/stock/data/stock_service.dart';
import 'package:techsupport_mobile/features/stock/models/stock_models.dart';
import 'package:techsupport_mobile/features/trade/data/trade_service.dart';
import 'package:techsupport_mobile/features/trade/model/trade_models.dart';

import '../../../core/design/app_design.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';
import 'shared/admin_web_topbar.dart';
import 'package:techsupport_mobile/features/trade/data/realtime_trade_service.dart';

class AdminWebTradePage extends StatefulWidget {
  const AdminWebTradePage({super.key});

  @override
  State<AdminWebTradePage> createState() => _AdminWebTradePageState();
}

class _AdminWebTradePageState extends State<AdminWebTradePage> {
  final TextEditingController _customerController =
      TextEditingController(text: 'Ad Soyad');
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _productController =
      TextEditingController(text: 'Ekran Koruyucu');
  final TextEditingController _emailController =
      TextEditingController(text: 'E-posta');
  final TextEditingController _passwordController =
      TextEditingController(text: 'Şifre');
  final TextEditingController _brandController =
      TextEditingController(text: 'Bosch');
  final TextEditingController _modelController =
      TextEditingController(text: 'Model X');
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _unitPriceController =
      TextEditingController(text: '750');
  final TextEditingController _discountController =
      TextEditingController(text: '0');
  final TextEditingController _barcodeController =
      TextEditingController(text: 'Barkod');
  final TextEditingController _skuController =
      TextEditingController(text: 'SKU');
  final TextEditingController _warrantyMonthsController =
      TextEditingController(text: '12');
  final TextEditingController _warrantyStartController =
      TextEditingController(text: 'GG/AA/YYYY');
  final TextEditingController _noteController = TextEditingController();

  final TradeService _tradeService = TradeService();
  final CustomerService _customerService = CustomerService();
  final DeviceService _deviceService = DeviceService();
  final StockService _stockService = StockService();

  final RealtimeTradeService _realtimeTradeService =
      RealtimeTradeService('http://localhost:5001/trade-status-hub');

  bool isRecordCustomer = false;
  bool isRecordDevice = false;
  Customer? _selectedCustomer;
  DeviceRecord? _selectedDevice;
  StockCategory? _selectedStockCategory;
  late Future<List<Customer>> _customersFuture;
  late Future<List<DeviceRecord>> _devicesFuture;
  late Future<List<StockCategory>> _stockCategoriesFuture;

  List<_RecentTrade> _recentTrades = [];
  bool _recentTradesLoading = false;
  bool _stockCategoriesLoading = false;

  String _generateBarcode() {
    final now = DateTime.now();
    final random = Random().nextInt(9000) + 1000;
    return 'TSI${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}$random';
  }

  String _generateSku() {
    final now = DateTime.now();
    final random = Random().nextInt(9000) + 1000;
    return 'SKU${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}$random';
  }

  DateTime? _parseWarrantyStartDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'GG/AA/YYYY') return null;

    final parts = trimmed.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;

    try {
      return DateTime.utc(year, month, day);
    } catch (_) {
      return null;
    }
  }

  Future<List<Customer>> _fetchCustomerSuggestions() async {
    try {
      final customers = await _customerService.listCustomers();
      return customers.toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DeviceRecord>> _fetchDeviceList() async {
    try {
      final devices = await _deviceService.getDevices();
      return devices.toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<StockCategory>> _fetchStockCategories() async {
    try {
      return await _stockService.listCategories();
    } catch (e) {
      return [];
    }
  }

  Future<List<_RecentTrade>> _fetchRecentTrades() async {
    try {
      final trades = await _tradeService.getTrades(1, 10);

      return trades
          .map((trade) => _RecentTrade(
                customer: trade.customerName ?? 'Bilinmeyen Müşteri',
                product: trade.deviceName ?? 'Bilinmeyen Cihaz',
                amount: trade.totalAmount ?? 0,
                payment: trade.paymentMethod ?? 'Bilinmeyen',
                status: trade.status ?? 'Bilinmeyen',
                time: trade.createdAt != null
                    ? TimeOfDay.fromDateTime(trade.createdAt!).format(context)
                    : 'N/A',
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _loadRecentTrades() async {
    setState(() => _recentTradesLoading = true);
    final trades = await _fetchRecentTrades();
    setState(() {
      _recentTrades = trades;
      _recentTradesLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _customersFuture = _fetchCustomerSuggestions();
    _devicesFuture = _fetchDeviceList();
    _stockCategoriesFuture = _fetchStockCategories();
    _loadRecentTrades();
  }

  void _toggleRecordedCustomer(bool value) {
    setState(() {
      isRecordCustomer = value;
      if (!value) {
        _selectedCustomer = null;
        _customerController.text = 'Ad Soyad';
        _phoneController.clear();
        _emailController.text = 'E-posta';
        _passwordController.text = 'Şifre';
      }
    });
  }

  void _selectCustomer(Customer? customer) {
    setState(() {
      _selectedCustomer = customer;
      if (customer == null) {
        _customerController.text = 'Ad Soyad';
        _phoneController.clear();
        _emailController.text = 'E-posta';
        return;
      }

      _customerController.text = customer.name;
      _phoneController.text = customer.phoneNumber ?? '';
      _emailController.text = customer.email;
      _passwordController.clear();
    });
  }

  void _toggleRecordedDevice(bool value) {
    setState(() {
      isRecordDevice = value;
      if (!value) {
        _selectedDevice = null;
        _brandController.text = 'Bosch';
        _modelController.text = 'Model X';
        _serialController.clear();
        _barcodeController.text = 'Barkod';
        _skuController.text = 'SKU';
        _warrantyMonthsController.text = '12';
        _warrantyStartController.text = 'GG/AA/YYYY';
      }
    });
  }

  void _selectDevice(DeviceRecord? device) {
    setState(() {
      _selectedDevice = device;
      if (device == null) {
        _brandController.text = 'Bosch';
        _modelController.text = 'Model X';
        _serialController.clear();
        _barcodeController.text = 'Barkod';
        _warrantyMonthsController.text = '12';
        _warrantyStartController.text = 'GG/AA/YYYY';
        return;
      }

      _brandController.text = device.brand;
      _modelController.text = device.model;
      _serialController.text = device.serialNumber;
      _barcodeController.text = device.barcodeNumber ?? '';
      _warrantyMonthsController.text =
          (device.guaranteePeriod ?? 12).toString();
      _warrantyStartController.text = device.warrantyStartAtUtc != null
          ? '${device.warrantyStartAtUtc!.day.toString().padLeft(2, '0')}/${device.warrantyStartAtUtc!.month.toString().padLeft(2, '0')}/${device.warrantyStartAtUtc!.year}'
          : 'GG/AA/YYYY';
    });
  }

  void _handleTradeTypeChanged(String value) {
    setState(() {
      _tradeType = value;
      if (value != 'Alış') {
        _selectedStockCategory = null;
      }
    });
  }

  void _selectStockCategory(StockCategory? category) {
    setState(() {
      _selectedStockCategory = category;
    });
  }

  Future<void> _startTrade() async {
    final isPurchase = _tradeType == 'Alış';
    final barcodeValue = isPurchase
        ? _barcodeController.text.trim().isNotEmpty
            ? _barcodeController.text.trim()
            : _generateBarcode()
        : _barcodeController.text.trim();
    final skuValue = isPurchase
        ? _skuController.text.trim().isNotEmpty
            ? _skuController.text.trim()
            : _generateSku()
        : null;

    if (isPurchase && _selectedStockCategory == null) {
      return;
    }

    final request = StartTradeRequest(
      existingCustomerId: isRecordCustomer ? _selectedCustomer?.id : null,
      existingCustomerName:
          isRecordCustomer ? _selectedCustomer?.name : _customerController.text,
      existingCusomerAppUserId:
          isRecordCustomer ? _selectedCustomer?.appUserId : null,
      existingDeviceId: isRecordDevice ? _selectedDevice?.id : null,
      categoryId: isPurchase ? _selectedStockCategory?.id : null,
      customer: isRecordCustomer
          ? null
          : StartTradeCustomerPayload(
              name: _customerController.text,
              phoneNumber: _phoneController.text,
              email: _emailController.text,
              temporaryPassword: _passwordController.text,
            ),
      device: StartTradeDevicePayload(
        brand: _brandController.text,
        model: _modelController.text,
        customerName: _customerController.text,
        serialNumber: _serialController.text,
        sku: isPurchase ? skuValue : null,
        barcodeNumber: barcodeValue,
        problemDescription: _noteController.text,
        guaranteePeriod: int.tryParse(_warrantyMonthsController.text) ?? 0,
        warrantyStartAtUtc:
            _parseWarrantyStartDate(_warrantyStartController.text),
      ),
      type: _tradeType == 'Satış' ? TradeType.sale : TradeType.purchase,
      paymentMethod: _paymentType == 'Nakit'
          ? TradePaymentMethod.cash
          : _paymentType == 'Kart'
              ? TradePaymentMethod.card
              : TradePaymentMethod.transfer,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      unitPrice: double.tryParse(_unitPriceController.text) ?? 0,
      totalAmount: ((double.tryParse(_unitPriceController.text) ?? 0) *
              (int.tryParse(_quantityController.text) ?? 1) -
          (double.tryParse(_discountController.text) ?? 0)),
      costPrice: double.tryParse(_unitPriceController.text) ?? 0,
      paidAmount: double.tryParse(_unitPriceController.text) ?? 0,
      imeiOrSerial:
          _serialController.text.isNotEmpty ? _serialController.text : null,
      notes: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    try {
      final response = await _tradeService.startTrade(request);
      final tradeId = response.tradeId;
      await _realtimeTradeService.connect();
      _realtimeTradeService.subscribeToTradeUpdates((args) {
        _realtimeTradeService.unsubscribeFromTradeUpdates();
        final data = args?.first as Map;
        final status = data['status']?.toString() ?? '';
        _showTradeStatusPopUp(status);
        _realtimeTradeService.disconnect();
        _clearForm();
        _loadRecentTrades();
      });
      await _realtimeTradeService.joinTradeGroup(tradeId);
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi verilebilir
    }
  }

  void _showTradeStatusPopUp(String status) {
    if (!mounted) return;
    final isSuccess = status.toLowerCase() == 'completed';
    final isError = status.toLowerCase() == 'failed';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSuccess
            ? 'İşlem Tamamlandı'
            : isError
                ? 'İşlem Başarısız'
                : 'Güncelleme'),
        content: Text(
            'İşlem Sonucu: ${isSuccess ? "Başarılı" : isError ? "Başarısız" : status}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  String _tradeType = 'Satış';
  String _paymentType = 'Nakit';
  bool _sendReceipt = true;

  @override
  void dispose() {
    _customerController.dispose();
    _phoneController.dispose();
    _productController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _discountController.dispose();
    _skuController.dispose();
    _warrantyMonthsController.dispose();
    _warrantyStartController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int get _quantity => int.tryParse(_quantityController.text) ?? 1;
  double get _unitPrice => double.tryParse(_unitPriceController.text) ?? 0;
  double get _discount => double.tryParse(_discountController.text) ?? 0;
  double get _transactionTotal =>
      ((_quantity * _unitPrice) - _discount).clamp(0, double.infinity);

  Future<void> _pickWarrantyStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );

    if (picked == null) return;

    final day = picked.day.toString().padLeft(2, '0');
    final month = picked.month.toString().padLeft(2, '0');
    final year = picked.year.toString();

    setState(() {
      _warrantyStartController.text = '$day/$month/$year';
    });
  }

  void _clearForm() {
    setState(() {
      _customerController.text = 'Ad Soyad';
      _phoneController.clear();
      _productController.text = 'Ekran Koruyucu';
      _emailController.text = 'E-posta';
      _passwordController.text = 'Şifre';
      _brandController.text = 'Bosch';
      _modelController.text = 'Model X';
      _serialController.clear();
      _barcodeController.text = 'Barkod';
      _quantityController.text = '1';
      _unitPriceController.text = '750';
      _discountController.text = '0';
      _warrantyMonthsController.text = '12';
      _warrantyStartController.text = 'GG/AA/YYYY';
      _noteController.clear();
      _selectedCustomer = null;
      _selectedDevice = null;
      _selectedStockCategory = null;
      _customersFuture = _fetchCustomerSuggestions();
      _devicesFuture = _fetchDeviceList();
      _stockCategoriesFuture = _fetchStockCategories();
      _tradeType = 'Satış';
      _paymentType = 'Nakit';
      _sendReceipt = true;
      isRecordCustomer = false;
      isRecordDevice = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final twoColumn = width >= 1280;

    return AdminWebShell(
      active: AdminNavKey.home,
      actions: [
        AdminWebActionButton(
          label: 'Formu Temizle',
          icon: Icons.refresh_rounded,
          onPressed: _clearForm,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TradeBreadcrumb(),
          const SizedBox(height: 12),
          const _TradeHeader(),
          const SizedBox(height: 18),
          if (twoColumn)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: _TradeEntryPanel(
                    customerController: _customerController,
                    phoneController: _phoneController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    isRecordedCustomer: isRecordCustomer,
                    selectedCustomer: _selectedCustomer,
                    customersFuture: _customersFuture,
                    onRecordedCustomerChanged: _toggleRecordedCustomer,
                    onCustomerSelected: _selectCustomer,
                    isRecordedDevice: isRecordDevice,
                    selectedDevice: _selectedDevice,
                    devicesFuture: _devicesFuture,
                    onRecordedDeviceChanged: _toggleRecordedDevice,
                    onDeviceSelected: _selectDevice,
                    productController: _productController,
                    brandController: _brandController,
                    modelController: _modelController,
                    barcodeController: _barcodeController,
                    skuController: _skuController,
                    serialController: _serialController,
                    quantityController: _quantityController,
                    unitPriceController: _unitPriceController,
                    discountController: _discountController,
                    warrantyMonthsController: _warrantyMonthsController,
                    warrantyStartController: _warrantyStartController,
                    onWarrantyStartTap: _pickWarrantyStartDate,
                    noteController: _noteController,
                    tradeType: _tradeType,
                    paymentType: _paymentType,
                    sendReceipt: _sendReceipt,
                    onTradeTypeChanged: _handleTradeTypeChanged,
                    onPaymentTypeChanged: (value) =>
                        setState(() => _paymentType = value),
                    onSendReceiptChanged: (value) =>
                        setState(() => _sendReceipt = value),
                    onValuesChanged: () => setState(() {}),
                    selectedStockCategory: _selectedStockCategory,
                    stockCategoriesFuture: _stockCategoriesFuture,
                    onStockCategoryChanged: _selectStockCategory,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  flex: 5,
                  child: _TradeSummaryPanel(
                    tradeType: _tradeType,
                    paymentType: _paymentType,
                    quantity: _quantity,
                    unitPrice: _unitPrice,
                    discount: _discount,
                    total: _transactionTotal,
                    sendReceipt: _sendReceipt,
                    customerName: _customerController.text,
                    productName: _productController.text,
                    onComplete: _startTrade,
                  ),
                ),
              ],
            )
          else ...[
            _TradeEntryPanel(
              customerController: _customerController,
              phoneController: _phoneController,
              emailController: _emailController,
              passwordController: _passwordController,
              isRecordedCustomer: isRecordCustomer,
              selectedCustomer: _selectedCustomer,
              customersFuture: _customersFuture,
              onRecordedCustomerChanged: _toggleRecordedCustomer,
              onCustomerSelected: _selectCustomer,
              isRecordedDevice: isRecordDevice,
              selectedDevice: _selectedDevice,
              devicesFuture: _devicesFuture,
              onRecordedDeviceChanged: _toggleRecordedDevice,
              onDeviceSelected: _selectDevice,
              productController: _productController,
              brandController: _brandController,
              modelController: _modelController,
              barcodeController: _barcodeController,
              skuController: _skuController,
              serialController: _serialController,
              quantityController: _quantityController,
              unitPriceController: _unitPriceController,
              discountController: _discountController,
              warrantyMonthsController: _warrantyMonthsController,
              warrantyStartController: _warrantyStartController,
              onWarrantyStartTap: _pickWarrantyStartDate,
              noteController: _noteController,
              tradeType: _tradeType,
              paymentType: _paymentType,
              sendReceipt: _sendReceipt,
              onTradeTypeChanged: _handleTradeTypeChanged,
              onPaymentTypeChanged: (value) =>
                  setState(() => _paymentType = value),
              onSendReceiptChanged: (value) =>
                  setState(() => _sendReceipt = value),
              onValuesChanged: () => setState(() {}),
              selectedStockCategory: _selectedStockCategory,
              stockCategoriesFuture: _stockCategoriesFuture,
              onStockCategoryChanged: _selectStockCategory,
            ),
            const SizedBox(height: 18),
            _TradeSummaryPanel(
              tradeType: _tradeType,
              paymentType: _paymentType,
              quantity: _quantity,
              unitPrice: _unitPrice,
              discount: _discount,
              total: _transactionTotal,
              sendReceipt: _sendReceipt,
              customerName: _customerController.text,
              productName: _productController.text,
              onComplete: _startTrade,
            ),
          ],
          const SizedBox(height: 18),
          _recentTradesLoading
              ? const Center(child: CircularProgressIndicator())
              : _RecentTradesSection(recentTrades: _recentTrades),
        ],
      ),
    );
  }
}

class _TradeBreadcrumb extends StatelessWidget {
  const _TradeBreadcrumb();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          'Yönetim',
          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
        SizedBox(width: 6),
        Icon(Icons.chevron_right, size: 14, color: AppColors.textTertiary),
        SizedBox(width: 6),
        Text(
          'Hızlı Alım/Satım Modülü',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _TradeHeader extends StatelessWidget {
  const _TradeHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hızlı Alım/Satım Modülü',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Cihaz ve araçların hızlı alım/satım akışlarını tek ekranda yönetin.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TradeEntryPanel extends StatelessWidget {
  const _TradeEntryPanel({
    required this.customerController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.isRecordedCustomer,
    required this.selectedCustomer,
    required this.customersFuture,
    required this.onRecordedCustomerChanged,
    required this.onCustomerSelected,
    required this.isRecordedDevice,
    required this.selectedDevice,
    required this.devicesFuture,
    required this.onRecordedDeviceChanged,
    required this.onDeviceSelected,
    required this.productController,
    required this.brandController,
    required this.modelController,
    required this.serialController,
    required this.barcodeController,
    required this.skuController,
    required this.quantityController,
    required this.unitPriceController,
    required this.discountController,
    required this.warrantyMonthsController,
    required this.warrantyStartController,
    required this.onWarrantyStartTap,
    required this.noteController,
    required this.tradeType,
    required this.paymentType,
    required this.sendReceipt,
    required this.onTradeTypeChanged,
    required this.onPaymentTypeChanged,
    required this.onSendReceiptChanged,
    required this.onValuesChanged,
    required this.selectedStockCategory,
    required this.stockCategoriesFuture,
    required this.onStockCategoryChanged,
  });

  final TextEditingController customerController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isRecordedCustomer;
  final Customer? selectedCustomer;
  final Future<List<Customer>> customersFuture;
  final ValueChanged<bool> onRecordedCustomerChanged;
  final ValueChanged<Customer?> onCustomerSelected;
  final bool isRecordedDevice;
  final DeviceRecord? selectedDevice;
  final Future<List<DeviceRecord>> devicesFuture;
  final ValueChanged<bool> onRecordedDeviceChanged;
  final ValueChanged<DeviceRecord?> onDeviceSelected;
  final TextEditingController productController;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController serialController;
  final TextEditingController barcodeController;
  final TextEditingController skuController;
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;
  final TextEditingController discountController;
  final TextEditingController warrantyMonthsController;
  final TextEditingController warrantyStartController;
  final VoidCallback onWarrantyStartTap;
  final TextEditingController noteController;
  final String tradeType;
  final String paymentType;
  final bool sendReceipt;
  final ValueChanged<String> onTradeTypeChanged;
  final ValueChanged<String> onPaymentTypeChanged;
  final ValueChanged<bool> onSendReceiptChanged;
  final VoidCallback onValuesChanged;
  final StockCategory? selectedStockCategory;
  final Future<List<StockCategory>> stockCategoriesFuture;
  final ValueChanged<StockCategory?> onStockCategoryChanged;

  String generateBarcodeNumber() {
    final now = DateTime.now();
    final random = Random().nextInt(9000) + 1000; // 4 basamaklı rastgele sayı
    final barcode =
        'TSI${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}$random';
    return barcode;
  }

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LinearSection(
            title: 'MÜŞTERİ VE İŞLEM BİLGİLERİ',
            trailing: LinearBadge(
              label: 'Anında İşlem',
              color: AppColors.statusBlue,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Switch(
                value: isRecordedCustomer,
                activeThumbColor: AppColors.accent,
                onChanged: onRecordedCustomerChanged,
              ),
              const SizedBox(width: 8),
              Text(
                isRecordedCustomer
                    ? 'Kayıtlı müşteri seçim'
                    : 'Müşteri bilgileri giriş',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isRecordedCustomer) ...[
            FutureBuilder<List<Customer>>(
              future: customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final customers = snapshot.data ?? const <Customer>[];
                return DropdownButtonFormField<String>(
                  initialValue: selectedCustomer?.id,
                  items: customers
                      .map(
                        (customer) => DropdownMenuItem<String>(
                          value: customer.id,
                          child: Text(customer.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    Customer? customer;
                    for (final item in customers) {
                      if (item.id == value) {
                        customer = item;
                        break;
                      }
                    }
                    onCustomerSelected(customer);
                  },
                  decoration: InputDecoration(
                    labelText: 'Kayıtlı Müşteri',
                    filled: true,
                    fillColor: AppColors.bg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                );
              },
            ),
            if (selectedCustomer != null) ...[
              const SizedBox(height: 12),
              _SelectedCustomerInfo(customer: selectedCustomer!),
            ],
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    label: 'Müşteri Adı ve Soyadı',
                    controller: customerController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'Telefon',
                    controller: phoneController,
                    hint: '05xx xxx xx xx',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'E-posta',
                    controller: emailController,
                    hint: 'E-Posta',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'Geçici Şifre',
                    controller: passwordController,
                    hint: 'Şifre',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SelectField(
                  label: 'İşlem Tipi',
                  value: tradeType,
                  items: const ['Satış', 'Alış'],
                  onChanged: onTradeTypeChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectField(
                  label: 'Ödeme Tipi',
                  value: paymentType,
                  items: const ['Nakit', 'Kart', 'Transfer'],
                  onChanged: onPaymentTypeChanged,
                ),
              ),
            ],
          ),
          if (tradeType == 'Alış') ...[
            const SizedBox(height: 12),
            FutureBuilder<List<StockCategory>>(
              future: stockCategoriesFuture,
              builder: (context, snapshot) {
                final categories = snapshot.data ?? const <StockCategory>[];
                return _CategorySelectField(
                  label: 'Stok Kategorisi',
                  value: selectedStockCategory?.id,
                  categories: categories,
                  onChanged: onStockCategoryChanged,
                );
              },
            ),
          ],
          const SizedBox(height: 18),
          const LinearSection(title: 'ÜRÜN / CİHAZ DETAYI'),
          const SizedBox(height: 8),
          Row(
            children: [
              Switch(
                value: isRecordedDevice,
                activeThumbColor: AppColors.accent,
                onChanged: onRecordedDeviceChanged,
              ),
              const SizedBox(width: 8),
              Text(
                isRecordedDevice
                    ? 'Kayıtlı cihaz seçim'
                    : 'Cihaz bilgileri giriş',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isRecordedDevice) ...[
            FutureBuilder<List<DeviceRecord>>(
              future: devicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final devices = snapshot.data ?? const <DeviceRecord>[];
                return DropdownButtonFormField<String>(
                  initialValue: selectedDevice?.id,
                  items: devices
                      .map(
                        (device) => DropdownMenuItem<String>(
                          value: device.id,
                          child: Text(
                            '${device.brand} ${device.model} - ${device.serialNumber}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    DeviceRecord? device;
                    for (final item in devices) {
                      if (item.id == value) {
                        device = item;
                        break;
                      }
                    }
                    onDeviceSelected(device);
                  },
                  decoration: InputDecoration(
                    labelText: 'Kayıtlı Cihaz',
                    filled: true,
                    fillColor: AppColors.bg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                );
              },
            ),
            if (selectedDevice != null) ...[
              const SizedBox(height: 12),
              _SelectedDeviceInfo(device: selectedDevice!),
            ],
          ] else ...[
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _FormField(
                    label: 'Ürün / Hizmet',
                    controller: productController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'Marka',
                    controller: brandController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'Model',
                    controller: modelController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _FormField(
                  label: 'Seri/IMEI No',
                  controller: serialController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormField(
                  label: 'Barkod No',
                  controller: barcodeController,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      barcodeController.text =
                          'TSI${DateTime.now().millisecondsSinceEpoch}';
                    },
                    icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                    label: const Text('Barkod Üret'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormField(
                  label: 'SKU',
                  controller: skuController,
                  readOnly: true,
                  hint: 'Otomatik SKU',
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      skuController.text =
                          'SKU${DateTime.now().millisecondsSinceEpoch}';
                    },
                    icon: const Icon(Icons.label_rounded, size: 18),
                    label: const Text('SKU Üret'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    label: 'Adet',
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => onValuesChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'Birim Fiyat',
                    controller: unitPriceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => onValuesChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'İndirim',
                    controller: discountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => onValuesChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    label: 'Garanti Süresi (Ay)',
                    controller: warrantyMonthsController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'Garanti Başlangıç Tarihi',
                    controller: warrantyStartController,
                    hint: 'GG/AA/YYYY',
                    readOnly: true,
                    suffixIcon: Icons.calendar_month_outlined,
                    onTap: onWarrantyStartTap,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          const LinearSection(title: 'NOTLAR VE TESLİMAT'),
          const SizedBox(height: 8),
          _FormField(
            label: 'İşlem Notu',
            controller: noteController,
            maxLines: 4,
            hint: 'Garanti notu, teslim detayları veya müşteri açıklaması',
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.accentBg,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: sendReceipt,
                  fillColor:
                      const WidgetStatePropertyAll<Color>(AppColors.accent),
                  onChanged: (value) => onSendReceiptChanged(value ?? false),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Faturayı Otomatik İlet',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'İşlem tamamlandığında SMS veya e-posta gönderimi için işaretleyin.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeSummaryPanel extends StatelessWidget {
  const _TradeSummaryPanel({
    required this.tradeType,
    required this.paymentType,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.total,
    required this.sendReceipt,
    required this.customerName,
    required this.productName,
    required this.onComplete,
  });

  final String tradeType;
  final String paymentType;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double total;
  final bool sendReceipt;
  final String customerName;
  final String productName;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LinearSection(
            title: 'İŞLEM ÖZETİ',
            trailing: LinearBadge(
              label: 'Tek Kayıt',
              color: AppColors.statusBlue,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            children: [
              _QuickStatChip(
                icon: Icons.swap_horiz_rounded,
                label: 'İşlem',
                value: tradeType,
              ),
              _QuickStatChip(
                icon: Icons.payments_rounded,
                label: 'Ödeme',
                value: paymentType,
              ),
              _QuickStatChip(
                icon: Icons.confirmation_num_outlined,
                label: 'Adet',
                value: '$quantity',
              ),
              _QuickStatChip(
                icon: Icons.receipt_long_outlined,
                label: 'Fiş/Fatura',
                value: sendReceipt ? 'Aktif' : 'Kapalı',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Müşteri',
            value: customerName.trim().isEmpty ? '-' : customerName.trim(),
          ),
          _SummaryRow(
            label: 'Ürün/Hizmet',
            value: productName.trim().isEmpty ? '-' : productName.trim(),
          ),
          _SummaryRow(
            label: 'Birim Fiyat',
            value: '₺${unitPrice.toStringAsFixed(2)}',
          ),
          const Divider(color: AppColors.border),
          _SummaryRow(
            label: 'İndirim',
            value: '- ₺${discount.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: _SummaryRow(
              label: 'Toplam',
              value: '₺${total.toStringAsFixed(2)}',
              emphasize: true,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.point_of_sale_rounded, size: 18),
              label: const Text('İşlemi Tamamla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatChip extends StatelessWidget {
  const _QuickStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedCustomerInfo extends StatelessWidget {
  const _SelectedCustomerInfo({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        runSpacing: 10,
        spacing: 18,
        children: [
          _InfoLabel(title: 'Müşteri', value: customer.name),
          _InfoLabel(title: 'E-posta', value: customer.email),
          _InfoLabel(
            title: 'Telefon',
            value: customer.phoneNumber?.isNotEmpty == true
                ? customer.phoneNumber!
                : '-',
          ),
        ],
      ),
    );
  }
}

class _SelectedDeviceInfo extends StatelessWidget {
  const _SelectedDeviceInfo({required this.device});

  final DeviceRecord device;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        runSpacing: 10,
        spacing: 18,
        children: [
          _InfoLabel(title: 'Marka', value: device.brand),
          _InfoLabel(title: 'Model', value: device.model),
          _InfoLabel(title: 'Seri No', value: device.serialNumber),
          _InfoLabel(
            title: 'Barkod',
            value: device.barcodeNumber?.isNotEmpty == true
                ? device.barcodeNumber!
                : '-',
          ),
          _InfoLabel(
            title: 'Garanti',
            value: device.guaranteePeriod != null
                ? '${device.guaranteePeriod} ay'
                : '-',
          ),
          _InfoLabel(title: 'Durum', value: device.status),
        ],
      ),
    );
  }
}

class _InfoLabel extends StatelessWidget {
  const _InfoLabel({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecentTradesSection extends StatelessWidget {
  const _RecentTradesSection({required this.recentTrades});

  final List<_RecentTrade> recentTrades;

  @override
  Widget build(BuildContext context) {
    return LinearCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LinearSection(
            title: 'SON HAREKETLER',
            trailing: Text(
              'Bugün',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(height: 8),
          ...recentTrades.asMap().entries.map(
                (entry) => _RecentTradeRow(
                  trade: entry.value,
                  showDivider: entry.key != recentTrades.length - 1,
                ),
              ),
        ],
      ),
    );
  }
}

class _RecentTradeRow extends StatelessWidget {
  const _RecentTradeRow({
    required this.trade,
    required this.showDivider,
  });

  final _RecentTrade trade;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final completed = trade.status == 'Completed';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.borderSubtle),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.statusGreenBg
                  : AppColors.statusYellowBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              completed ? Icons.check_rounded : Icons.schedule_rounded,
              color: completed ? AppColors.statusGreen : AppColors.statusYellow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trade.customer,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  trade.product,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₺${trade.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${trade.payment} • ${trade.time}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          LinearBadge(
            label: trade.status,
            color: completed ? AppColors.statusGreen : AppColors.statusYellow,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: emphasize ? 14 : 13,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              color:
                  emphasize ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: emphasize ? 16 : 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          onTap: onTap,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, size: 18, color: AppColors.textTertiary)
                : null,
            filled: true,
            fillColor: AppColors.bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
        ),
      ],
    );
  }
}

class _CategorySelectField extends StatelessWidget {
  const _CategorySelectField({
    required this.label,
    required this.value,
    required this.categories,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<StockCategory> categories;
  final ValueChanged<StockCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    final uniqueCategories = <String, StockCategory>{
      for (final category in categories) category.id: category,
    }.values.toList();

    final validValue =
        uniqueCategories.any((category) => category.id == value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey<String?>(validValue),
          initialValue: validValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
          items: uniqueCategories
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                ),
              )
              .toList(),
          onChanged: (next) {
            if (next == null) {
              onChanged(null);
              return;
            }

            final selected = uniqueCategories.cast<StockCategory?>().firstWhere(
                  (category) => category?.id == next,
                  orElse: () => null,
                );
            onChanged(selected);
          },
        ),
      ],
    );
  }
}

class _RecentTrade {
  const _RecentTrade({
    required this.customer,
    required this.product,
    required this.amount,
    required this.payment,
    required this.status,
    required this.time,
  });

  final String customer;
  final String product;
  final double amount;
  final String payment;
  final String status;
  final String time;
}
