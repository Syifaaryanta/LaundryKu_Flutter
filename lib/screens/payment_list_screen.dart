import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/payment_provider.dart';
import '../providers/order_provider.dart';
import '../providers/customer_provider.dart';
import '../models/payment.dart';
import '../models/order.dart';
import '../models/customer.dart';

// Helper function untuk payment icon
IconData getPaymentIcon(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return Icons.payments;
    case PaymentMethod.transfer:
      return Icons.account_balance;
    case PaymentMethod.qris:
      return Icons.qr_code;
    case PaymentMethod.eWallet:
      return Icons.account_balance_wallet;
  }
}

/// Screen untuk menampilkan daftar payment
class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> with SingleTickerProviderStateMixin {
  PaymentMethod? _filterMethod;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Semua Pembayaran'),
            Tab(icon: Icon(Icons.warning), text: 'Belum Lunas'),
          ],
        ),
        actions: [
          // Filter by Payment Method
          PopupMenuButton<PaymentMethod?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (method) {
              setState(() {
                _filterMethod = method;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Semua Metode'),
              ),
              PopupMenuItem(
                value: PaymentMethod.cash,
                child: Row(
                  children: [
                    Icon(Icons.money, size: 20),
                    SizedBox(width: 8),
                    Text('Tunai'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: PaymentMethod.transfer,
                child: Row(
                  children: [
                    Icon(Icons.account_balance, size: 20),
                    SizedBox(width: 8),
                    Text('Transfer'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: PaymentMethod.qris,
                child: Row(
                  children: [
                    Icon(Icons.qr_code, size: 20),
                    SizedBox(width: 8),
                    Text('QRIS'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: PaymentMethod.eWallet,
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 20),
                    SizedBox(width: 8),
                    Text('E-Wallet'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PaymentProvider>().refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Consumer<PaymentProvider>(
            builder: (context, provider, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Hari Ini',
                        provider.todayRevenue,
                        Colors.green,
                        Icons.today,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Total',
                        provider.currentRevenue,
                        Colors.blue,
                        Icons.monetization_on,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Filter Chip
          if (_filterMethod != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text('Filter: ${_getPaymentMethodDisplay(_filterMethod!)}'),
                    onDeleted: () {
                      setState(() {
                        _filterMethod = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // TabBarView dengan 2 tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Semua Pembayaran
                _buildAllPaymentsTab(),
                
                // Tab 2: Order Belum Lunas
                _buildUnpaidOrdersTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPayment,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentMethodDisplay(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.transfer:
        return 'Transfer';
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
    }
  }

  // Tab 1: Semua Pembayaran
  Widget _buildAllPaymentsTab() {
    return Consumer<PaymentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Error: ${provider.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.clearError();
                    provider.refresh();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        List<Payment> payments = provider.payments;
        if (_filterMethod != null) {
          payments = provider.getPaymentsByMethod(_filterMethod!);
        }

        if (payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _filterMethod != null
                      ? 'Tidak ada payment dengan metode ${_getPaymentMethodDisplay(_filterMethod!)}'
                      : 'Belum ada payment',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Payment akan muncul setelah order dibayar',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            return Consumer2<OrderProvider, CustomerProvider>(
              builder: (context, orderProvider, customerProvider, _) {
                final order = orderProvider.getOrderById(payment.orderId);
                final customer = order != null 
                    ? customerProvider.getCustomerById(order.customerId)
                    : null;
                
                return PaymentCard(
                  payment: payment,
                  order: order,
                  customer: customer,
                  onEdit: () => _showEditPayment(payment),
                  onDelete: () => _showDeleteConfirmation(payment),
                );
              },
            );
          },
        );
      },
    );
  }

  // Tab 2: Order Belum Lunas
  Widget _buildUnpaidOrdersTab() {
    return Consumer3<OrderProvider, PaymentProvider, CustomerProvider>(
      builder: (context, orderProvider, paymentProvider, customerProvider, _) {
        if (orderProvider.isLoading || paymentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get all orders
        final allOrders = orderProvider.orders;
        
        // Filter orders yang belum lunas
        final unpaidOrders = allOrders.where((order) {
          final totalPaid = paymentProvider.getTotalPaidForOrder(order.id!);
          return totalPaid < order.price;
        }).toList();

        if (unpaidOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green[400]),
                const SizedBox(height: 16),
                Text(
                  'Semua Order Sudah Lunas!',
                  style: TextStyle(fontSize: 18, color: Colors.green[600], fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tidak ada order dengan pembayaran yang belum lunas',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: unpaidOrders.length,
          itemBuilder: (context, index) {
            final order = unpaidOrders[index];
            final customer = customerProvider.getCustomerById(order.customerId);
            final totalPaid = paymentProvider.getTotalPaidForOrder(order.id!);
            final remaining = order.price - totalPaid;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.warning, color: Colors.orange, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer?.name ?? 'Customer tidak ditemukan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                order.serviceTypeDisplay,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Payment Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Harga:',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'Rp ${order.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sudah Dibayar:',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'Rp ${totalPaid.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sisa Tagihan:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Rp ${remaining.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddPaymentForOrder(order),
                        icon: const Icon(Icons.payment),
                        label: const Text('Bayar Sekarang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    // Order Details
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(order.date),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.monitor_weight, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${order.weight} kg',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddPaymentForOrder(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPaymentScreen(preSelectedOrder: order),
      ),
    );
  }

  void _showAddPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPaymentScreen(),
      ),
    );
  }

  void _showEditPayment(Payment payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPaymentScreen(payment: payment),
      ),
    );
  }

  void _showDeleteConfirmation(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Payment'),
        content: const Text('Yakin ingin menghapus payment ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<PaymentProvider>();
              final success = await provider.deletePayment(payment.id!);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'Gagal hapus payment'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

/// Widget untuk menampilkan payment card
class PaymentCard extends StatelessWidget {
  final Payment payment;
  final Order? order;
  final Customer? customer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PaymentCard({
    super.key,
    required this.payment,
    this.order,
    this.customer,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  getPaymentIcon(payment.paymentMethod),
                  size: 24,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.formattedAmount,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        payment.paymentMethodDisplay,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Customer & Order Info
            if (customer != null && order != null) ...[
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${customer!.name} - ${order!.serviceTypeDisplay}'),
                ],
              ),
              const SizedBox(height: 4),
            ],

            // Date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(DateFormat('dd MMM yyyy, HH:mm').format(payment.paidDate)),
              ],
            ),

            // Notes
            if (payment.notes != null && payment.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(child: Text(payment.notes!)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Screen untuk tambah payment baru
class AddPaymentScreen extends StatefulWidget {
  final Order? preSelectedOrder;
  
  const AddPaymentScreen({super.key, this.preSelectedOrder});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  Order? _selectedOrder;
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  List<Order> _unpaidOrders = [];

  @override
  void initState() {
    super.initState();
    
    // Set preselected order jika ada
    if (widget.preSelectedOrder != null) {
      _selectedOrder = widget.preSelectedOrder;
      // Akan di-update setelah _loadUnpaidOrders selesai
    }
    
    _loadUnpaidOrders();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadUnpaidOrders() async {
    final paymentProvider = context.read<PaymentProvider>();
    final orderProvider = context.read<OrderProvider>();
    
    // Get all orders
    final allOrders = orderProvider.orders;
    
    // Filter orders yang belum lunas
    final unpaidOrders = allOrders.where((order) {
      final totalPaid = paymentProvider.getTotalPaidForOrder(order.id!);
      return totalPaid < order.price;
    }).toList();
    
    setState(() {
      _unpaidOrders = unpaidOrders;
      
      // Pastikan preSelectedOrder ada di list dan set amount
      if (widget.preSelectedOrder != null) {
        // Cari order yang sama berdasarkan ID
        final existingOrder = _unpaidOrders.firstWhere(
          (o) => o.id == widget.preSelectedOrder!.id,
          orElse: () => widget.preSelectedOrder!,
        );
        _selectedOrder = existingOrder;
        
        // Set amount to remaining balance
        final totalPaid = paymentProvider.getTotalPaidForOrder(_selectedOrder!.id!);
        final remaining = _selectedOrder!.price - totalPaid;
        _amountController.text = remaining.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Payment'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Unpaid Orders Dropdown
              DropdownButtonFormField<int>(
                value: _selectedOrder?.id,
                decoration: const InputDecoration(
                  labelText: 'Pilih Order (Belum Dibayar)',
                  prefixIcon: Icon(Icons.receipt_long),
                  helperText: 'Pilih order yang ingin dibayar',
                ),
                isExpanded: true,
                items: _unpaidOrders.map((order) {
                  return DropdownMenuItem<int>(
                    value: order.id,
                    child: Consumer<CustomerProvider>(
                      builder: (context, provider, _) {
                        final customer = provider.getCustomerById(order.customerId);
                        final totalPaid = context.read<PaymentProvider>().getTotalPaidForOrder(order.id!);
                        final remaining = order.price - totalPaid;
                        
                        return Text(
                          '${customer?.name ?? "Unknown"} - ${order.serviceTypeDisplay} (Sisa: Rp ${remaining.toStringAsFixed(0)})',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        );
                      },
                    ),
                  );
                }).toList(),
                onChanged: (orderId) {
                  final order = _unpaidOrders.firstWhere((o) => o.id == orderId);
                  setState(() {
                    _selectedOrder = order;
                    // Set amount to remaining balance
                    final totalPaid = context.read<PaymentProvider>().getTotalPaidForOrder(order.id!);
                    final remaining = order.price - totalPaid;
                    _amountController.text = remaining.toString();
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih order yang akan dibayar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Info Sisa Tagihan
              if (_selectedOrder != null)
                Consumer<PaymentProvider>(
                  builder: (context, paymentProvider, _) {
                    final totalPaid = paymentProvider.getTotalPaidForOrder(_selectedOrder!.id!);
                    final remaining = _selectedOrder!.price - totalPaid;
                    
                    return Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Informasi Pembayaran',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('Total Harga', _selectedOrder!.price, Colors.grey[700]),
                            const SizedBox(height: 4),
                            _buildInfoRow('Sudah Dibayar', totalPaid, Colors.green[700]),
                            const Divider(height: 16),
                            _buildInfoRow('Sisa Tagihan', remaining, Colors.orange[700], isBold: true, fontSize: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              
              if (_selectedOrder != null) const SizedBox(height: 16),

              // Payment Method
              DropdownButtonFormField<PaymentMethod>(
                value: _selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Metode Pembayaran',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Row(
                      children: [
                        Icon(_getPaymentIcon(method), size: 20),
                        const SizedBox(width: 8),
                        Text(_getPaymentMethodDisplay(method)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (method) {
                  setState(() {
                    _selectedMethod = method!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Bayar',
                  prefixIcon: Icon(Icons.monetization_on),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePayment,
                  child: const Text('Simpan Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentMethodDisplay(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.transfer:
        return 'Transfer Bank';
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
    }
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.transfer:
        return Icons.account_balance;
      case PaymentMethod.qris:
        return Icons.qr_code;
      case PaymentMethod.eWallet:
        return Icons.account_balance_wallet;
    }
  }

  Widget _buildInfoRow(String label, double amount, Color? color, {bool isBold = false, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
        Text(
          'Rp ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  void _savePayment() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<PaymentProvider>();
      final success = await provider.addPayment(
        orderId: _selectedOrder!.id!,
        amount: double.parse(_amountController.text),
        paymentMethod: _selectedMethod,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal menambah payment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Screen untuk edit payment
class EditPaymentScreen extends StatefulWidget {
  final Payment payment;

  const EditPaymentScreen({super.key, required this.payment});

  @override
  State<EditPaymentScreen> createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late PaymentMethod _selectedMethod;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.payment.amount.toString());
    _notesController = TextEditingController(text: widget.payment.notes ?? '');
    _selectedMethod = widget.payment.paymentMethod;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Payment'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Payment Method
              DropdownButtonFormField<PaymentMethod>(
                value: _selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Metode Pembayaran',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Row(
                      children: [
                        Icon(_getPaymentIcon(method), size: 20),
                        const SizedBox(width: 8),
                        Text(_getPaymentMethodDisplay(method)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (method) {
                  setState(() {
                    _selectedMethod = method!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Bayar',
                  prefixIcon: Icon(Icons.monetization_on),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updatePayment,
                  child: const Text('Update Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentMethodDisplay(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.transfer:
        return 'Transfer Bank';
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
    }
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.transfer:
        return Icons.account_balance;
      case PaymentMethod.qris:
        return Icons.qr_code;
      case PaymentMethod.eWallet:
        return Icons.account_balance_wallet;
    }
  }

  void _updatePayment() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<PaymentProvider>();
      final success = await provider.updatePayment(
        id: widget.payment.id!,
        orderId: widget.payment.orderId,
        amount: double.parse(_amountController.text),
        paymentMethod: _selectedMethod,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal update payment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}