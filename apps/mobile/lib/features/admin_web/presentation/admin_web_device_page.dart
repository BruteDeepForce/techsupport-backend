import 'package:flutter/material.dart';
import './shared/admin_web_design.dart';

import '../../customer/data/customer_service.dart';
import '../../customer/models/customer_models.dart';
import '../../device/data/device_service.dart';
import '../../device/model/device_model.dart';
import '../../stock/data/stock_service.dart';
import '../../stock/models/stock_models.dart';
import 'admin_web_device_detail_page.dart';
import 'shared/admin_web_nav.dart';
import 'shared/admin_web_shell.dart';
import 'shared/admin_web_topbar.dart';

class AdminWebDevicePage extends StatefulWidget {
  const AdminWebDevicePage({super.key});

  @override
  State<AdminWebDevicePage> createState() => _AdminWebDevicePageState();
}

class _AdminWebDevicePageState extends State<AdminWebDevicePage> {
  final CustomerService _customerService = CustomerService();
  final DeviceService _deviceService = DeviceService();
  final StockService _stockService = StockService();
  late Future<List<Customer>> _customersFuture;
  late Future<List<DeviceRecord>> _devicesFuture;
  late Future<List<StockCategory>> _stockCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _customersFuture = _customerService.listCustomers();
    _devicesFuture = _deviceService.getDevices();
    _stockCategoriesFuture = _stockService.listCategories();
  }

  void _showAddDeviceDialog(List<Customer> customers) {
    final formKey = GlobalKey<FormState>();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final serialController = TextEditingController();
    final barcodeController = TextEditingController();
    final customerNameController = TextEditingController();
    final problemController = TextEditingController();
    final guaranteeController = TextEditingController();
    final warrantyStartController = TextEditingController();
    DateTime? warrantyStartDate;
    String? selectedCustomerId;
    String? selectedCustomerUserId;
    String? selectedCustomerName;
    String status = 'Other';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cihaz Ekle',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AdminTechColors.textPrimary),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _DialogField(
                        label: 'Marka',
                        controller: brandController,
                        requiredField: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogField(
                        label: 'Model',
                        controller: modelController,
                        requiredField: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _DialogField(
                  label: 'Seri No',
                  controller: serialController,
                  requiredField: true,
                ),
                const SizedBox(height: 10),
                _DialogField(
                  label: 'Barkod',
                  controller: barcodeController,
                ),
                const SizedBox(height: 10),
                //! burada müşteri selected
                DropdownButtonFormField<String>(
                  value: selectedCustomerId,
                  items: [
                    for (final c in customers)
                      DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                  ],
                  onChanged: (v) {
                    selectedCustomerId = v;
                    //! query for customer by id to map appUserId + name
                    final match = customers.where((e) => e.id == v).toList();
                    if (match.isNotEmpty) {
                      selectedCustomerName = match.first.name;
                      selectedCustomerUserId = match.first.appUserId;
                      customerNameController.text = match.first.name;
                    } else {
                      selectedCustomerName = null;
                      selectedCustomerUserId = null;
                      customerNameController.clear();
                    }
                  },
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Müşteri seçin' : null,
                  decoration: InputDecoration(
                    labelText: 'Müşteri',
                    filled: true,
                    fillColor: AdminTechColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AdminTechColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _DialogField(
                  label: 'Problem Açıklaması',
                  controller: problemController,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DialogField(
                        label: 'Garanti Süresi (Ay)',
                        controller: guaranteeController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogField(
                        label: 'Garanti Başlangıcı (YYYY-MM-DD)',
                        controller: warrantyStartController,
                        readOnly: true,
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: warrantyStartDate ?? now,
                            firstDate: DateTime(now.year - 10),
                            lastDate: DateTime(now.year + 10),
                          );
                          if (picked != null) {
                            warrantyStartDate = picked;
                            final y = picked.year.toString().padLeft(4, '0');
                            final m = picked.month.toString().padLeft(2, '0');
                            final d = picked.day.toString().padLeft(2, '0');
                            warrantyStartController.text = '$y-$m-$d';
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'Other', child: Text('Diğer')),
                    DropdownMenuItem(
                        value: 'InRepair', child: Text('Onarımda')),
                    DropdownMenuItem(
                        value: 'InMaintenance', child: Text('Bakımda')),
                    DropdownMenuItem(
                        value: 'Saleable', child: Text('Satılabilir')),
                    DropdownMenuItem(value: 'Selled', child: Text('Satıldı')),
                    DropdownMenuItem(value: 'Returned', child: Text('İade')),
                  ],
                  onChanged: (v) => status = v ?? 'Other',
                  decoration: InputDecoration(
                    labelText: 'Durum',
                    filled: true,
                    fillColor: AdminTechColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AdminTechColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        if (selectedCustomerId == null ||
                            selectedCustomerId!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Müşteri seçmelisiniz')),
                          );
                          return;
                        }
                        if (selectedCustomerUserId == null ||
                            selectedCustomerUserId!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Müşterinin kullanıcı bilgisi yok')),
                          );
                          return;
                        }
                        Navigator.of(ctx).pop();
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        try {
                          await _deviceService.createDevice(DeviceDTO(
                            brand: brandController.text.trim(),
                            model: modelController.text.trim(),
                            serialNumber: serialController.text.trim(),
                            problemDescription:
                                problemController.text.trim().isEmpty
                                    ? null
                                    : problemController.text.trim(),
                            guaranteePeriod:
                                int.tryParse(guaranteeController.text.trim()),
                            warrantyStartAtUtc: warrantyStartDate,
                            barcodeNumber: barcodeController.text.trim().isEmpty
                                ? null
                                : barcodeController.text.trim(),
                            customerId: selectedCustomerId,
                            appUserId: selectedCustomerUserId,
                            customerName: selectedCustomerName ??
                                (customerNameController.text.trim().isEmpty
                                    ? null
                                    : customerNameController.text.trim()),
                            status: status,
                          ));
                          if (mounted) Navigator.of(context).pop();
                          if (mounted) {
                            _refresh();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cihaz eklendi')),
                            );
                          }
                        } catch (_) {
                          if (mounted) Navigator.of(context).pop();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cihaz eklenemedi')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminTechColors.statusBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Kaydet'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateDealerDeviceDialog(List<StockCategory> categories) {
    final formKey = GlobalKey<FormState>();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final serialController = TextEditingController();
    final skuController = TextEditingController();
    final barcodeController = TextEditingController();
    final salePriceController = TextEditingController();
    final guaranteeController = TextEditingController();
    final warrantyStartController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? warrantyStartDate;
    StockCategory? selectedCategory =
        categories.isNotEmpty ? categories.first : null;
    String productCondition = 'New';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bayi Cihazı Oluştur',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AdminTechColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<StockCategory>(
                    value: selectedCategory,
                    items: [
                      for (final category in categories)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        ),
                    ],
                    onChanged: (v) => selectedCategory = v,
                    validator: (v) => v == null ? 'Kategori seçin' : null,
                    decoration: _dialogDecoration('Kategori'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogField(
                          label: 'Marka',
                          controller: brandController,
                          requiredField: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DialogField(
                          label: 'Model',
                          controller: modelController,
                          requiredField: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogField(
                          label: 'Seri No / IMEI',
                          controller: serialController,
                          requiredField: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: productCondition,
                          items: const [
                            DropdownMenuItem(
                                value: 'New', child: Text('Sıfır')),
                            DropdownMenuItem(
                                value: 'Used', child: Text('İkinci El')),
                            DropdownMenuItem(
                                value: 'Refurbished',
                                child: Text('Yenilenmiş')),
                          ],
                          onChanged: (v) => productCondition = v ?? 'New',
                          decoration: _dialogDecoration('Ürün Durumu'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogField(
                          label: 'SKU',
                          controller: skuController,
                          requiredField: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DialogField(
                          label: 'Barkod',
                          controller: barcodeController,
                          requiredField: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _DialogField(
                    label: 'Satış Fiyatı',
                    controller: salePriceController,
                    requiredField: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogField(
                          label: 'Garanti Süresi (Ay)',
                          controller: guaranteeController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DialogField(
                          label: 'Garanti Başlangıcı',
                          controller: warrantyStartController,
                          readOnly: true,
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: warrantyStartDate ?? now,
                              firstDate: DateTime(now.year - 10),
                              lastDate: DateTime(now.year + 10),
                            );
                            if (picked != null) {
                              warrantyStartDate = picked;
                              final y = picked.year.toString().padLeft(4, '0');
                              final m = picked.month.toString().padLeft(2, '0');
                              final d = picked.day.toString().padLeft(2, '0');
                              warrantyStartController.text = '$y-$m-$d';
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _DialogField(
                    label: 'Açıklama',
                    controller: descriptionController,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('İptal'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          final salePrice = double.tryParse(salePriceController
                              .text
                              .trim()
                              .replaceAll(',', '.'));
                          if (salePrice == null || salePrice <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Geçerli satış fiyatı girin')),
                            );
                            return;
                          }

                          Navigator.of(ctx).pop();
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                                child: CircularProgressIndicator()),
                          );
                          try {
                            await _deviceService.createInventoryDevice(
                              brand: brandController.text.trim(),
                              model: modelController.text.trim(),
                              serialNumber: serialController.text.trim(),
                              categoryId: selectedCategory!.id,
                              sku: skuController.text.trim(),
                              barcodeNumber: barcodeController.text.trim(),
                              currentSalePrice: salePrice,
                              productCondition: productCondition,
                              guaranteePeriod:
                                  int.tryParse(guaranteeController.text.trim()),
                              warrantyStartAtUtc: warrantyStartDate,
                              description:
                                  descriptionController.text.trim().isEmpty
                                      ? null
                                      : descriptionController.text.trim(),
                              unit: 'Adet',
                              quantity: 1,
                            );
                            if (mounted) Navigator.of(context).pop();
                            if (mounted) {
                              _refresh();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Bayi cihazı oluşturuldu')),
                              );
                            }
                          } catch (_) {
                            if (mounted) Navigator.of(context).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Bayi cihazı oluşturulamadı')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTechColors.statusBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Oluştur'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _refresh() {
    setState(() {
      _customersFuture = _customerService.listCustomers();
      _devicesFuture = _deviceService.getDevices();
      _stockCategoriesFuture = _stockService.listCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      dark: true,
      active: AdminNavKey.devices,
      actions: [
        AdminWebActionButton(
          label: 'Yenile',
          icon: Icons.refresh,
          onPressed: _refresh,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Breadcrumb(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: _Header()),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  AdminTechPrimaryButton(
                    label: 'Bayi Cihazı Oluştur',
                    icon: Icons.storefront_outlined,
                    onPressed: () async {
                      try {
                        final categories = await _stockCategoriesFuture;
                        if (!mounted) return;
                        if (categories.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Önce stok kategorisi oluşturun')),
                          );
                          return;
                        }
                        _showCreateDealerDeviceDialog(categories);
                      } catch (_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Stok kategorileri yüklenemedi')),
                        );
                      }
                    },
                  ),
                  AdminTechPrimaryButton(
                    label: 'Cihaz Ekle',
                    icon: Icons.add,
                    onPressed: () async {
                      try {
                        final customers = await _customersFuture;
                        if (!mounted) return;
                        _showAddDeviceDialog(customers);
                      } catch (_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Müşteriler yüklenemedi')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DeviceTableCard(devicesFuture: _devicesFuture),
        ],
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text('Yönetim',
            style:
                TextStyle(fontSize: 12, color: AdminTechColors.textTertiary)),
        SizedBox(width: 6),
        Icon(Icons.chevron_right,
            size: 14, color: AdminTechColors.textTertiary),
        SizedBox(width: 6),
        Text('Cihaz Yönetimi',
            style:
                TextStyle(fontSize: 12, color: AdminTechColors.textSecondary)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cihaz Yönetimi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AdminTechColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Kayıtlı cihazları görüntüleyin',
                style: TextStyle(
                  color: AdminTechColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.label,
    required this.controller,
    this.requiredField = false,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final bool requiredField;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: requiredField
          ? (val) => (val == null || val.trim().isEmpty) ? 'Zorunlu' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AdminTechColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminTechColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminTechColors.border),
        ),
      ),
    );
  }
}

InputDecoration _dialogDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AdminTechColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AdminTechColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AdminTechColors.border),
    ),
  );
}

class _DeviceTableCard extends StatelessWidget {
  const _DeviceTableCard({required this.devicesFuture});

  final Future<List<DeviceRecord>> devicesFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DeviceRecord>>(
      future: devicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Cihazlar yüklenemedi'),
            ),
          );
        }
        final devices = snapshot.data ?? [];
        if (devices.isEmpty) {
          return const _TableCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Kayıt bulunamadı',
                  style: TextStyle(color: AdminTechColors.textTertiary)),
            ),
          );
        }
        return _TableCard(
          child: Column(
            children: [
              const _TableHeader(),
              const Divider(height: 1, color: AdminTechColors.border),
              for (final device in devices)
                _TableRow(
                  device: device,
                  onTap: () => Navigator.of(context).push(
                    adminNavRoute(
                      AdminWebDeviceDetailPage(
                        deviceId: device.id,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminTechColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTechColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final headers = [
      'Marka',
      'Model',
      'Seri No',
      'Müşteri',
      'Durum',
      'Aktif',
      'Tarih',
      'Garanti Bitiş',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminTechColors.border)),
      ),
      child: Row(
        children: headers
            .map(
              (h) => Expanded(
                child: Text(
                  h,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AdminTechColors.textSecondary,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.device, required this.onTap});

  final DeviceRecord device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AdminTechColors.surfaceAlt)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(device.brand)),
            Expanded(child: Text(device.model)),
            Expanded(child: Text(device.serialNumber)),
            Expanded(child: Text(device.customerName ?? '-')),
            Expanded(child: Text(_statusLabel(device.status))),
            Expanded(child: Text(device.isActive ? 'Aktif' : 'Pasif')),
            Expanded(
                child: Text(device.createdAtUtc == null
                    ? '-'
                    : _formatDate(device.createdAtUtc!))),
            Expanded(
                child: Text(device.warrantyEndAtUtc == null
                    ? '-'
                    : _formatDate(device.warrantyEndAtUtc!))),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final local = dt.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'inrepair':
      return 'Onarımda';
    case 'inmaintenance':
      return 'Bakımda';
    case 'saleable':
      return 'Satılabilir';
    case 'selled':
      return 'Satıldı';
    case 'returned':
      return 'İade';
    default:
      return 'Diğer';
  }
}
