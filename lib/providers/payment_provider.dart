import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../models/order.dart';
import '../services/database_service.dart';

/// Provider untuk mengelola state Payment
/// Menggunakan ChangeNotifier untuk memberitahu UI saat ada perubahan data
class PaymentProvider extends ChangeNotifier {
  // Database service instance
  final DatabaseService _dbService = DatabaseService();

  // List semua payments (state)
  List<Payment> _payments = [];

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _errorMessage;

  // 🔹 GETTERS: Akses state dari luar (read-only)
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalPayments => _payments.length;

  /// Get total pembayaran untuk order tertentu
  double getTotalPaidForOrder(int orderId) {
    return _payments
        .where((payment) => payment.orderId == orderId)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get daftar payments untuk order tertentu
  List<Payment> getPaymentsForOrder(int orderId) {
    return _payments.where((payment) => payment.orderId == orderId).toList();
  }

  // 🔹 CONSTRUCTOR: Load data saat provider pertama kali dibuat
  PaymentProvider() {
    loadPayments();
  }

  // ==========================================
  // LOAD DATA
  // ==========================================

  /// Load semua payments dari database
  Future<void> loadPayments() async {
    _setLoading(true);
    _setError(null);

    try {
      _payments = await _dbService.getAllPayments();
      notifyListeners(); // Beritahu UI bahwa data sudah berubah
    } catch (e) {
      _setError('Gagal memuat data payment: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // ➕ CREATE (Tambah Payment Baru)
  // ==========================================

  /// Tambah payment baru
  Future<bool> addPayment({
    required int orderId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? notes,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validasi input
      if (orderId <= 0) {
        _setError('Order tidak valid');
        _setLoading(false);
        return false;
      }

      if (amount <= 0) {
        _setError('Jumlah pembayaran harus lebih dari 0');
        _setLoading(false);
        return false;
      }

      // Cek apakah order sudah dibayar
      final existingPayment = _payments.where(
        (p) => p.orderId == orderId,
      ).toList();

      if (existingPayment.isNotEmpty) {
        _setError('Order sudah dibayar');
        _setLoading(false);
        return false;
      }

      // Buat payment baru
      final payment = Payment(
        orderId: orderId,
        amount: amount,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      // Insert ke database
      final id = await _dbService.insertPayment(payment);

      // Tambahkan ke list dengan ID dari database
      _payments.insert(0, payment.copyWith(id: id)); // Insert di awal (payment terbaru)
      
      notifyListeners(); // Beritahu UI
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menambah payment: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // ✏️ UPDATE (Edit Payment)
  // ==========================================

  /// Update payment yang sudah ada
  Future<bool> updatePayment({
    required int id,
    required int orderId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? notes,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validasi input
      if (amount <= 0) {
        _setError('Jumlah pembayaran harus lebih dari 0');
        _setLoading(false);
        return false;
      }

      // Cari payment yang mau diupdate
      final currentPayment = _payments.firstWhere((p) => p.id == id);

      // Update payment
      final updatedPayment = currentPayment.copyWith(
        orderId: orderId,
        amount: amount,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      // Update di database
      await _dbService.updatePayment(updatedPayment);

      // Update di list
      final index = _payments.indexWhere((p) => p.id == id);
      if (index != -1) {
        _payments[index] = updatedPayment;
      }

      notifyListeners(); // Beritahu UI
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal update payment: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // 🗑️ DELETE (Hapus Payment)
  // ==========================================

  /// Hapus payment
  Future<bool> deletePayment(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      // Hapus dari database
      await _dbService.deletePayment(id);

      // Hapus dari list
      _payments.removeWhere((p) => p.id == id);

      notifyListeners(); // Beritahu UI
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menghapus payment: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // 🔍 QUERY & FILTER
  // ==========================================

  /// Get payments by order ID
  List<Payment> getPaymentsByOrderId(int orderId) {
    return _payments.where((p) => p.orderId == orderId).toList();
  }

  /// Get payments by payment method
  List<Payment> getPaymentsByMethod(PaymentMethod method) {
    return _payments.where((p) => p.paymentMethod == method).toList();
  }

  /// Get payments by date range
  List<Payment> getPaymentsByDateRange(DateTime start, DateTime end) {
    return _payments.where((p) {
      return p.paidDate.isAfter(start) && p.paidDate.isBefore(end);
    }).toList();
  }

  /// Cek apakah order sudah dibayar
  bool isOrderPaid(int orderId) {
    return _payments.any((p) => p.orderId == orderId);
  }

  /// Get payment by order ID
  Payment? getPaymentByOrderId(int orderId) {
    try {
      return _payments.firstWhere((p) => p.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // 📊 ANALYTICS & STATISTICS
  // ==========================================

  /// Get total revenue (semua pembayaran)
  Future<double> getTotalRevenue() async {
    try {
      return await _dbService.getTotalRevenue();
    } catch (e) {
      _setError('Gagal mengambil total revenue: $e');
      return 0.0;
    }
  }

  /// Get revenue by date range
  Future<double> getRevenueByDateRange(DateTime start, DateTime end) async {
    try {
      return await _dbService.getRevenueByDateRange(start, end);
    } catch (e) {
      _setError('Gagal mengambil revenue: $e');
      return 0.0;
    }
  }

  /// Get revenue from loaded payments (tidak perlu query database)
  double get currentRevenue {
    return _payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get revenue by payment method
  Map<PaymentMethod, double> get revenueByPaymentMethod {
    Map<PaymentMethod, double> revenue = {
      PaymentMethod.cash: 0.0,
      PaymentMethod.transfer: 0.0,
      PaymentMethod.qris: 0.0,
      PaymentMethod.eWallet: 0.0,
    };

    for (var payment in _payments) {
      revenue[payment.paymentMethod] = 
          (revenue[payment.paymentMethod] ?? 0.0) + payment.amount;
    }

    return revenue;
  }

  /// Get payment count by method
  Map<PaymentMethod, int> get paymentCountByMethod {
    Map<PaymentMethod, int> count = {
      PaymentMethod.cash: 0,
      PaymentMethod.transfer: 0,
      PaymentMethod.qris: 0,
      PaymentMethod.eWallet: 0,
    };

    for (var payment in _payments) {
      count[payment.paymentMethod] = 
          (count[payment.paymentMethod] ?? 0) + 1;
    }

    return count;
  }

  /// Get daily revenue (hari ini)
  double get todayRevenue {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _payments.where((p) {
      return p.paidDate.isAfter(startOfDay) && p.paidDate.isBefore(endOfDay);
    }).fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get weekly revenue (7 hari terakhir)
  double get weeklyRevenue {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));

    return _payments.where((p) {
      return p.paidDate.isAfter(weekAgo);
    }).fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get monthly revenue (bulan ini)
  double get monthlyRevenue {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return _payments.where((p) {
      return p.paidDate.isAfter(startOfMonth);
    }).fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get payments today
  List<Payment> get todayPayments {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _payments.where((p) {
      return p.paidDate.isAfter(startOfDay) && p.paidDate.isBefore(endOfDay);
    }).toList();
  }

  /// Get average payment amount
  double get averagePayment {
    if (_payments.isEmpty) return 0.0;
    return currentRevenue / _payments.length;
  }

  // ==========================================
  // OUTSTANDING PAYMENTS (Belum Dibayar)
  // ==========================================

  /// Get unpaid orders (orders yang belum ada payment-nya)
  Future<List<Order>> getUnpaidOrders() async {
    try {
      return await _dbService.getUnpaidOrders();
    } catch (e) {
      _setError('Gagal mengambil unpaid orders: $e');
      return [];
    }
  }

  /// Get total outstanding amount (total order yang belum dibayar)
  Future<double> getTotalOutstanding() async {
    try {
      final unpaidOrders = await _dbService.getUnpaidOrders();
      double total = 0.0;
      for (var order in unpaidOrders) {
        total += order.price;
      }
      return total;
    } catch (e) {
      _setError('Gagal mengambil total outstanding: $e');
      return 0.0;
    }
  }

  // ==========================================
  // 📊 UTILITY METHODS
  // ==========================================

  /// Get payment by ID
  Payment? getPaymentById(int id) {
    try {
      return _payments.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get latest payments (N pembayaran terakhir)
  List<Payment> getLatestPayments(int count) {
    if (_payments.length <= count) {
      return _payments;
    }
    return _payments.sublist(0, count);
  }

  /// Get revenue in period (days)
  double getRevenueInPeriod(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _payments
        .where((p) => p.paidDate.isAfter(cutoffDate))
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get payments in period (days)
  List<Payment> getPaymentsInPeriod(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _payments.where((p) => p.paidDate.isAfter(cutoffDate)).toList();
  }

  /// Get daily revenue in period
  Map<DateTime, double> getDailyRevenueInPeriod(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final Map<DateTime, double> dailyRevenue = {};
    
    for (final payment in _payments) {
      if (payment.paidDate.isAfter(cutoffDate)) {
        final dateKey = DateTime(
          payment.paidDate.year,
          payment.paidDate.month,
          payment.paidDate.day,
        );
        dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0.0) + payment.amount;
      }
    }
    
    return dailyRevenue;
  }

  // ==========================================
  // 🔧 PRIVATE HELPER METHODS
  // ==========================================

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? message) {
    _errorMessage = message;
    if (message != null) {
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==========================================
  // 🔄 REFRESH
  // ==========================================

  /// Refresh data (reload dari database)
  Future<void> refresh() async {
    await loadPayments();
  }
}
