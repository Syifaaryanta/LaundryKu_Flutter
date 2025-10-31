import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/payment_provider.dart';
import '../providers/order_provider.dart';
import '../providers/customer_provider.dart';
import '../models/order.dart';
import '../models/payment.dart';

/// Screen untuk menampilkan analytics dan laporan
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedPeriod = 30; // Default 30 hari

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.date_range),
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 7,
                child: Text('7 Hari Terakhir'),
              ),
              const PopupMenuItem(
                value: 30,
                child: Text('30 Hari Terakhir'),
              ),
              const PopupMenuItem(
                value: 90,
                child: Text('3 Bulan Terakhir'),
              ),
              const PopupMenuItem(
                value: 365,
                child: Text('1 Tahun Terakhir'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Period Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Periode: ${_selectedPeriod} hari terakhir',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Revenue Overview
            _buildRevenueOverview(),
            const SizedBox(height: 24),

            // Order Statistics
            _buildOrderStatistics(),
            const SizedBox(height: 24),

            // Service Type Distribution
            _buildServiceTypeChart(),
            const SizedBox(height: 24),

            // Payment Method Distribution
            _buildPaymentMethodChart(),
            const SizedBox(height: 24),

            // Monthly Revenue Trend
            _buildRevenueChart(),
            const SizedBox(height: 24),

            // Top Customers
            _buildTopCustomers(),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueOverview() {
    return Consumer<PaymentProvider>(
      builder: (context, provider, child) {
        final periodRevenue = provider.getRevenueInPeriod(_selectedPeriod);
        final todayRevenue = provider.todayRevenue;
        final avgDailyRevenue = periodRevenue / _selectedPeriod;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.monetization_on, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Pendapatan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildRevenueCard(
                        'Hari Ini',
                        todayRevenue,
                        Icons.today,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRevenueCard(
                        'Periode',
                        periodRevenue,
                        Icons.calendar_view_month,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRevenueCard(
                  'Rata-rata Harian',
                  avgDailyRevenue,
                  Icons.trending_up,
                  Colors.orange,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueCard(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Rp ${NumberFormat('#,###').format(amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatistics() {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final orders = provider.getOrdersInPeriod(_selectedPeriod);
        final totalOrders = orders.length;
        final completedOrders = orders.where((o) => o.status == OrderStatus.selesai).length;
        final pendingOrders = orders.where((o) => o.status != OrderStatus.selesai).length;
        final completionRate = totalOrders > 0 ? (completedOrders / totalOrders * 100) : 0.0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Statistik Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Order',
                        totalOrders.toString(),
                        Icons.receipt_long,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Selesai',
                        completedOrders.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        pendingOrders.toString(),
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Tingkat Selesai',
                        '${completionRate.toStringAsFixed(1)}%',
                        Icons.trending_up,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTypeChart() {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final orders = provider.getOrdersInPeriod(_selectedPeriod);
        final serviceTypeCount = <ServiceType, int>{};
        
        for (final order in orders) {
          serviceTypeCount[order.serviceType] = (serviceTypeCount[order.serviceType] ?? 0) + 1;
        }

        if (serviceTypeCount.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.pie_chart, color: Colors.purple[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Distribusi Jenis Layanan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Tidak ada data untuk periode ini'),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.pie_chart, color: Colors.purple[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Distribusi Jenis Layanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: serviceTypeCount.entries.map((entry) {
                        final color = _getServiceTypeColor(entry.key);
                        final percentage = (entry.value / orders.length * 100);
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: '${percentage.toStringAsFixed(1)}%',
                          color: color,
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: serviceTypeCount.entries.map((entry) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: _getServiceTypeColor(entry.key),
                        ),
                        const SizedBox(width: 8),
                        Text('${_getServiceTypeDisplay(entry.key)}: ${entry.value}'),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodChart() {
    return Consumer<PaymentProvider>(
      builder: (context, provider, child) {
        final payments = provider.getPaymentsInPeriod(_selectedPeriod);
        final methodCount = <PaymentMethod, int>{};
        
        for (final payment in payments) {
          methodCount[payment.paymentMethod] = (methodCount[payment.paymentMethod] ?? 0) + 1;
        }

        if (methodCount.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: Colors.teal[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Tidak ada data untuk periode ini'),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, color: Colors.teal[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Metode Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...methodCount.entries.map((entry) {
                  final percentage = (entry.value / payments.length * 100);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          _getPaymentMethodIcon(entry.key),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_getPaymentMethodDisplay(entry.key)),
                        ),
                        Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueChart() {
    return Consumer<PaymentProvider>(
      builder: (context, provider, child) {
        final dailyRevenue = provider.getDailyRevenueInPeriod(_selectedPeriod);
        
        if (dailyRevenue.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.show_chart, color: Colors.indigo[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Tren Pendapatan Harian',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Tidak ada data untuk periode ini'),
                ],
              ),
            ),
          );
        }

        final spots = dailyRevenue.entries.map((entry) {
          final daysSinceStart = DateTime.now().difference(entry.key).inDays;
          return FlSpot(_selectedPeriod - daysSinceStart.toDouble(), entry.value);
        }).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart, color: Colors.indigo[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Tren Pendapatan Harian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final daysAgo = _selectedPeriod - value.toInt();
                              if (daysAgo == 0) return const Text('Hari ini');
                              if (daysAgo == 1) return const Text('Kemarin');
                              return Text('${daysAgo}h');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text('${(value / 1000).toStringAsFixed(0)}K');
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.indigo,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.indigo.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopCustomers() {
    return Consumer2<OrderProvider, CustomerProvider>(
      builder: (context, orderProvider, customerProvider, child) {
        final orders = orderProvider.getOrdersInPeriod(_selectedPeriod);
        final customerOrderCount = <int, int>{};
        final customerRevenue = <int, double>{};
        
        for (final order in orders) {
          customerOrderCount[order.customerId] = (customerOrderCount[order.customerId] ?? 0) + 1;
          customerRevenue[order.customerId] = (customerRevenue[order.customerId] ?? 0) + order.price;
        }

        final topCustomers = customerOrderCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Top Customers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (topCustomers.isEmpty)
                  const Text('Tidak ada data untuk periode ini')
                else
                  ...topCustomers.take(5).map((entry) {
                    final customer = customerProvider.getCustomerById(entry.key);
                    final revenue = customerRevenue[entry.key] ?? 0;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${topCustomers.indexOf(entry) + 1}'),
                      ),
                      title: Text(customer?.name ?? 'Unknown Customer'),
                      subtitle: Text('${entry.value} order • Rp ${NumberFormat('#,###').format(revenue)}'),
                      trailing: customer?.phone != null 
                          ? Text(customer!.phone)
                          : null,
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getServiceTypeColor(ServiceType type) {
    switch (type) {
      case ServiceType.kiloan:
        return Colors.blue;
      case ServiceType.satuan:
        return Colors.green;
      case ServiceType.express:
        return Colors.orange;
    }
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

  String _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return '💵';
      case PaymentMethod.transfer:
        return '🏦';
      case PaymentMethod.qris:
        return '📱';
      case PaymentMethod.eWallet:
        return '💳';
    }
  }
}