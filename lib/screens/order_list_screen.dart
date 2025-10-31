import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../providers/customer_provider.dart';
import '../models/order.dart';
import '../models/customer.dart';

/// Screen untuk menampilkan daftar order
class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  OrderStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          // Filter Dropdown
          PopupMenuButton<OrderStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() {
                _filterStatus = status;
              });
              context.read<OrderProvider>().setFilterStatus(status);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Semua Order'),
              ),
              PopupMenuItem(
                value: OrderStatus.terima,
                child: Row(
                  children: [
                    Icon(Icons.inbox, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Diterima'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: OrderStatus.cuci,
                child: Row(
                  children: [
                    Icon(Icons.water_drop, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Dicuci'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: OrderStatus.setrika,
                child: Row(
                  children: [
                    Icon(Icons.iron, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Disetrika'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: OrderStatus.selesai,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Selesai'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrderProvider>().refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter Chips
          if (_filterStatus != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Chip(
                    label: Text('Filter: ${_getStatusDisplayName(_filterStatus!)}'),
                    onDeleted: () {
                      setState(() {
                        _filterStatus = null;
                      });
                      context.read<OrderProvider>().clearFilter();
                    },
                  ),
                ],
              ),
            ),

          // Order List
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, provider, child) {
                // Loading state
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
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

                final orders = provider.filteredOrders;

                // Empty state
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _filterStatus != null
                              ? 'Tidak ada order dengan status ${_getStatusDisplayName(_filterStatus!)}'
                              : 'Belum ada order',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tekan tombol + untuk menambah order',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                // Order List
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Consumer<CustomerProvider>(
                      builder: (context, customerProvider, _) {
                        final customer = customerProvider.getCustomerById(order.customerId);
                        return OrderCard(
                          order: order,
                          customer: customer,
                          onProgressStatus: () => _progressOrderStatus(order),
                          onEdit: () => _showEditOrder(order),
                          onDelete: () => _showDeleteConfirmation(order),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOrder,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.terima:
        return 'Diterima';
      case OrderStatus.cuci:
        return 'Dicuci';
      case OrderStatus.setrika:
        return 'Disetrika';
      case OrderStatus.selesai:
        return 'Selesai';
    }
  }

  void _progressOrderStatus(Order order) async {
    final provider = context.read<OrderProvider>();
    final success = await provider.progressOrderStatus(order.id!);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status order berhasil diupdate ke ${order.nextStatus.toString().split('.').last}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal update status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddOrderScreen(),
      ),
    );
  }

  void _showEditOrder(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrderScreen(order: order),
      ),
    );
  }

  void _showDeleteConfirmation(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Order'),
        content: const Text('Yakin ingin menghapus order ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<OrderProvider>();
              final success = await provider.deleteOrder(order.id!);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'Gagal hapus order'),
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

/// Widget untuk menampilkan order card
class OrderCard extends StatelessWidget {
  final Order order;
  final Customer? customer;
  final VoidCallback? onProgressStatus;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const OrderCard({
    super.key,
    required this.order,
    this.customer,
    this.onProgressStatus,
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
                _buildStatusIcon(),
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
                        order.statusDisplay,
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
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

            // Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.monitor_weight,
                    '${order.weight} kg',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.local_laundry_service,
                    order.serviceTypeDisplay,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.monetization_on,
                    'Rp ${order.price.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.calendar_today,
                    DateFormat('dd MMM yyyy').format(order.date),
                  ),
                ),
                if (order.photoUrl != null)
                  Expanded(
                    child: _buildDetailItem(
                      Icons.photo_camera,
                      'Ada foto',
                    ),
                  ),
              ],
            ),

            // Progress Button
            if (order.canProgressToNext) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onProgressStatus,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text('Lanjutkan ke ${order.nextStatus.toString().split('.').last}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getStatusColor(),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ] else if (order.isCompleted) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Order Selesai',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color = _getStatusColor();

    switch (order.status) {
      case OrderStatus.terima:
        icon = Icons.inbox;
        break;
      case OrderStatus.cuci:
        icon = Icons.water_drop;
        break;
      case OrderStatus.setrika:
        icon = Icons.iron;
        break;
      case OrderStatus.selesai:
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Color _getStatusColor() {
    switch (order.status) {
      case OrderStatus.terima:
        return Colors.orange;
      case OrderStatus.cuci:
        return Colors.blue;
      case OrderStatus.setrika:
        return Colors.purple;
      case OrderStatus.selesai:
        return Colors.green;
    }
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Screen untuk tambah order baru
class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  Customer? _selectedCustomer;
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  ServiceType _selectedServiceType = ServiceType.kiloan;

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Order'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Customer Dropdown
              Consumer<CustomerProvider>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<Customer>(
                    value: _selectedCustomer,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Customer',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: provider.customers.map((customer) {
                      return DropdownMenuItem(
                        value: customer,
                        child: Text('${customer.name} - ${customer.phone}'),
                      );
                    }).toList(),
                    onChanged: (customer) {
                      setState(() {
                        _selectedCustomer = customer;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih customer terlebih dahulu';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Service Type
              DropdownButtonFormField<ServiceType>(
                value: _selectedServiceType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Layanan',
                  prefixIcon: Icon(Icons.local_laundry_service),
                ),
                items: ServiceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getServiceTypeDisplay(type)),
                  );
                }).toList(),
                onChanged: (type) {
                  setState(() {
                    _selectedServiceType = type!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Berat (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Berat tidak boleh kosong';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return 'Berat harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixIcon: Icon(Icons.monetization_on),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Harga harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveOrder,
                  child: const Text('Simpan Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getServiceTypeDisplay(ServiceType type) {
    switch (type) {
      case ServiceType.kiloan:
        return 'Kiloan';
      case ServiceType.satuan:
        return 'Satuan';
      case ServiceType.express:
        return 'Express';
    }
  }

  void _saveOrder() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<OrderProvider>();
      final success = await provider.addOrder(
        customerId: _selectedCustomer!.id!,
        weight: double.parse(_weightController.text),
        serviceType: _selectedServiceType,
        price: double.parse(_priceController.text),
      );

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal menambah order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Screen untuk edit order
class EditOrderScreen extends StatefulWidget {
  final Order order;

  const EditOrderScreen({super.key, required this.order});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  Customer? _selectedCustomer;
  late TextEditingController _weightController;
  late TextEditingController _priceController;
  late ServiceType _selectedServiceType;
  late OrderStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.order.weight.toString());
    _priceController = TextEditingController(text: widget.order.price.toString());
    _selectedServiceType = widget.order.serviceType;
    _selectedStatus = widget.order.status;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Customer Dropdown
              Consumer<CustomerProvider>(
                builder: (context, provider, child) {
                  _selectedCustomer ??= provider.getCustomerById(widget.order.customerId);
                  
                  return DropdownButtonFormField<Customer>(
                    value: _selectedCustomer,
                    decoration: const InputDecoration(
                      labelText: 'Customer',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: provider.customers.map((customer) {
                      return DropdownMenuItem(
                        value: customer,
                        child: Text('${customer.name} - ${customer.phone}'),
                      );
                    }).toList(),
                    onChanged: (customer) {
                      setState(() {
                        _selectedCustomer = customer;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih customer terlebih dahulu';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Service Type
              DropdownButtonFormField<ServiceType>(
                value: _selectedServiceType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Layanan',
                  prefixIcon: Icon(Icons.local_laundry_service),
                ),
                items: ServiceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getServiceTypeDisplay(type)),
                  );
                }).toList(),
                onChanged: (type) {
                  setState(() {
                    _selectedServiceType = type!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<OrderStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status Order',
                  prefixIcon: Icon(Icons.track_changes),
                ),
                items: OrderStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusDisplay(status)),
                  );
                }).toList(),
                onChanged: (status) {
                  setState(() {
                    _selectedStatus = status!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Berat (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Berat tidak boleh kosong';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return 'Berat harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixIcon: Icon(Icons.monetization_on),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Harga harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateOrder,
                  child: const Text('Update Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getServiceTypeDisplay(ServiceType type) {
    switch (type) {
      case ServiceType.kiloan:
        return 'Kiloan';
      case ServiceType.satuan:
        return 'Satuan';
      case ServiceType.express:
        return 'Express';
    }
  }

  String _getStatusDisplay(OrderStatus status) {
    switch (status) {
      case OrderStatus.terima:
        return 'Diterima';
      case OrderStatus.cuci:
        return 'Dicuci';
      case OrderStatus.setrika:
        return 'Disetrika';
      case OrderStatus.selesai:
        return 'Selesai';
    }
  }

  void _updateOrder() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<OrderProvider>();
      final success = await provider.updateOrder(
        id: widget.order.id!,
        customerId: _selectedCustomer!.id!,
        weight: double.parse(_weightController.text),
        serviceType: _selectedServiceType,
        price: double.parse(_priceController.text),
        status: _selectedStatus,
      );

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal update order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}