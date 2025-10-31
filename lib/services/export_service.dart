import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../models/payment.dart';

/// Service untuk export data ke Excel
class ExportService {
  /// Export semua data ke satu file Excel
  static Future<String> exportAllData({
    required List<Customer> customers,
    required List<Order> orders,
    required List<Payment> payments,
  }) async {
    try {
      // Buat Excel baru
      var excel = Excel.createExcel();
      
      // Buat sheet "Data Lengkap"
      Sheet sheetObject = excel['Data Lengkap'];
      
      int row = 0;
      
      // SECTION 1: CUSTOMERS
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('=== DATA CUSTOMERS ===');
      row++;
      
      // Header Customers
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('ID');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue('Nama');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue('Telepon');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue('Alamat');
      row++;
      
      // Data Customers
      for (var customer in customers) {
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(customer.id?.toString() ?? '0');
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(customer.name);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(customer.phone);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(customer.address);
        row++;
      }
      
      // Spacing
      row++;
      
      // SECTION 2: ORDERS
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('=== DATA ORDERS ===');
      row++;
      
      // Header Orders
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Order ID');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue('Customer');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue('Telepon');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue('Berat (kg)');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue('Jenis Layanan');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = TextCellValue('Harga (Rp)');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = TextCellValue('Status');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value = TextCellValue('Tanggal Order');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value = TextCellValue('Foto');
      row++;
      
      // Data Orders
      for (var order in orders) {
        final customer = customers.firstWhere(
          (c) => c.id == order.customerId,
          orElse: () => Customer(id: 0, name: 'Unknown', phone: '-', address: '-'),
        );
        
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(order.id?.toString() ?? '0');
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(customer.name);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(customer.phone);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(order.weight.toString());
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue(order.serviceTypeDisplay);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = TextCellValue(order.price.toStringAsFixed(0));
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = TextCellValue(order.statusDisplay);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value = TextCellValue(DateFormat('dd/MM/yyyy').format(order.date));
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value = TextCellValue(order.photoUrl != null ? 'Ya' : 'Tidak');
        row++;
      }
      
      // Spacing
      row++;
      
      // SECTION 3: PAYMENTS
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('=== DATA PAYMENTS ===');
      row++;
      
      // Header Payments
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Payment ID');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue('Order ID');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue('Customer');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue('Jumlah (Rp)');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue('Metode Bayar');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = TextCellValue('Tanggal Bayar');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = TextCellValue('Catatan');
      row++;
      
      // Data Payments
      for (var payment in payments) {
        final order = orders.firstWhere(
          (o) => o.id == payment.orderId,
          orElse: () => Order(
            id: 0,
            customerId: 0,
            weight: 0,
            serviceType: ServiceType.kiloan,
            price: 0,
          ),
        );
        
        final customer = customers.firstWhere(
          (c) => c.id == order.customerId,
          orElse: () => Customer(id: 0, name: 'Unknown', phone: '-', address: '-'),
        );
        
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(payment.id?.toString() ?? '0');
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(payment.orderId.toString());
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(customer.name);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(payment.amount.toStringAsFixed(0));
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue(payment.paymentMethodDisplay);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(payment.paidDate));
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = TextCellValue(payment.notes ?? '-');
        row++;
      }
      
      // Spacing
      row++;
      row++;
      
      // SECTION 4: STATISTICS
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('=== STATISTIK & ANALYTICS ===');
      row++;
      row++;
      
      // Total Revenue
      final totalRevenue = payments.fold<double>(
        0.0,
        (sum, payment) => sum + payment.amount,
      );
      
      // Service Type Breakdown
      final serviceBreakdown = <ServiceType, int>{};
      for (var order in orders) {
        serviceBreakdown[order.serviceType] = 
            (serviceBreakdown[order.serviceType] ?? 0) + 1;
      }
      
      // Payment Method Breakdown
      final paymentMethodBreakdown = <PaymentMethod, int>{};
      for (var payment in payments) {
        paymentMethodBreakdown[payment.paymentMethod] = 
            (paymentMethodBreakdown[payment.paymentMethod] ?? 0) + 1;
      }
      
      // Order Status Breakdown
      final statusBreakdown = <OrderStatus, int>{};
      for (var order in orders) {
        statusBreakdown[order.status] = 
            (statusBreakdown[order.status] ?? 0) + 1;
      }
      
      // Customer Order Count
      final customerOrderCount = <int, int>{};
      for (var order in orders) {
        customerOrderCount[order.customerId] = 
            (customerOrderCount[order.customerId] ?? 0) + 1;
      }
      
      // Top Customers
      final sortedCustomers = customerOrderCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      // Ringkasan Umum
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('RINGKASAN UMUM');
      row++;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Total Customers');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(customers.length.toString());
      row++;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Total Orders');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(orders.length.toString());
      row++;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Total Payments');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(payments.length.toString());
      row++;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Total Revenue');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue('Rp ${NumberFormat('#,###').format(totalRevenue)}');
      row++;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Rata-rata Order Value');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(orders.isEmpty ? 'Rp 0' : 'Rp ${NumberFormat('#,###').format(totalRevenue / orders.length)}');
      row++;
      
      row++;
      
      // Breakdown Jenis Layanan
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('BREAKDOWN JENIS LAYANAN');
      row++;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Jenis Layanan');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue('Jumlah Order');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue('Persentase');
      row++;
      
      serviceBreakdown.forEach((type, count) {
        final percentage = orders.isEmpty ? 0.0 : (count / orders.length * 100);
        final typeDisplay = type == ServiceType.kiloan ? 'Kiloan' :
                           type == ServiceType.satuan ? 'Satuan' : 'Express';
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(typeDisplay);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(count.toString());
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue('${percentage.toStringAsFixed(1)}%');
        row++;
      });
      
      row++;
      
      // Breakdown Status Order
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('BREAKDOWN STATUS ORDER');
      row++;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Status');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue('Jumlah Order');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue('Persentase');
      row++;
      
      statusBreakdown.forEach((status, count) {
        final percentage = orders.isEmpty ? 0.0 : (count / orders.length * 100);
        final statusDisplay = status == OrderStatus.terima ? 'Diterima' :
                              status == OrderStatus.cuci ? 'Dicuci' :
                              status == OrderStatus.setrika ? 'Disetrika' : 'Selesai';
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(statusDisplay);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(count.toString());
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue('${percentage.toStringAsFixed(1)}%');
        row++;
      });
      
      row++;
      
      // Breakdown Metode Pembayaran
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('BREAKDOWN METODE PEMBAYARAN');
      row++;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Metode');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue('Jumlah');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue('Persentase');
      row++;
      
      paymentMethodBreakdown.forEach((method, count) {
        final percentage = payments.isEmpty ? 0.0 : (count / payments.length * 100);
        final methodDisplay = method == PaymentMethod.cash ? 'Tunai' :
                              method == PaymentMethod.transfer ? 'Transfer' :
                              method == PaymentMethod.qris ? 'QRIS' : 'E-Wallet';
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(methodDisplay);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(count.toString());
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue('${percentage.toStringAsFixed(1)}%');
        row++;
      });
      
      row++;
      
      // Top 10 Customers
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('TOP 10 CUSTOMERS');
      row++;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Rank');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue('Nama Customer');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue('Telepon');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue('Jumlah Order');
      row++;
      
      int rank = 1;
      for (var entry in sortedCustomers.take(10)) {
        final customer = customers.firstWhere(
          (c) => c.id == entry.key,
          orElse: () => Customer(id: 0, name: 'Unknown', phone: '-', address: '-'),
        );
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(rank.toString());
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(customer.name);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(customer.phone);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(entry.value.toString());
        row++;
        rank++;
      }
      
      // Save to Downloads folder
      final filename = 'LaundryKu_Report_${_getTimestamp()}.xlsx';
      final savedPath = await _saveToDownloads(excel, filename);
      return savedPath;
      
    } catch (e) {
      throw Exception('Gagal export data: $e');
    }
  }
  
  /// Helper: Save Excel file to Downloads folder
  static Future<String> _saveToDownloads(Excel excel, String filename) async {
    try {
      // Get Downloads directory
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Tidak dapat mengakses folder Downloads');
      }
      
      final path = '${directory.path}\\$filename';
      
      // Save to file
      final file = File(path);
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        return path;
      } else {
        throw Exception('Failed to encode Excel file');
      }
    } catch (e) {
      throw Exception('Gagal menyimpan file: $e');
    }
  }

  /// Get timestamp untuk filename
  static String _getTimestamp() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }
}
