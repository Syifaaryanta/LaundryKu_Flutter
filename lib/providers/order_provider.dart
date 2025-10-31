import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

/// Provider untuk mengelola state Order
/// Menggunakan ChangeNotifier untuk memberitahu UI saat ada perubahan data
class OrderProvider extends ChangeNotifier {
  // Database service instance
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  // List semua orders (state)
  List<Order> _orders = [];

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _errorMessage;

  // Filter state (untuk filter by status)
  OrderStatus? _filterStatus;

  // 🔹 GETTERS: Akses state dari luar (read-only)
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalOrders => _orders.length;
  OrderStatus? get filterStatus => _filterStatus;

  // Filtered orders (berdasarkan status filter)
  List<Order> get filteredOrders {
    if (_filterStatus == null) {
      return _orders; // Tampilkan semua jika tidak ada filter
    }
    return _orders.where((order) => order.status == _filterStatus).toList();
  }

  // Count orders by status
  int get pendingCount => _orders.where((o) => o.status == OrderStatus.terima).length;
  int get washingCount => _orders.where((o) => o.status == OrderStatus.cuci).length;
  int get ironingCount => _orders.where((o) => o.status == OrderStatus.setrika).length;
  int get completedCount => _orders.where((o) => o.status == OrderStatus.selesai).length;

  // 🔹 CONSTRUCTOR: Load data saat provider pertama kali dibuat
  OrderProvider() {
    loadOrders();
  }

  // ==========================================
  // LOAD DATA
  // ==========================================

  /// Load semua orders dari database
  Future<void> loadOrders() async {
    _setLoading(true);
    _setError(null);

    try {
      _orders = await _dbService.getAllOrders();
      notifyListeners(); // Beritahu UI bahwa data sudah berubah
    } catch (e) {
      _setError('Gagal memuat data order: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // ➕ CREATE (Tambah Order Baru)
  // ==========================================

  /// Tambah order baru
  Future<bool> addOrder({
    required int customerId,
    required double weight,
    required ServiceType serviceType,
    required double price,
    String? photoUrl,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validasi input
      if (customerId <= 0) {
        _setError('Customer tidak valid');
        _setLoading(false);
        return false;
      }

      if (weight <= 0) {
        _setError('Berat harus lebih dari 0 kg');
        _setLoading(false);
        return false;
      }

      if (price <= 0) {
        _setError('Harga harus lebih dari 0');
        _setLoading(false);
        return false;
      }

      // Buat order baru (status default: terima)
      final order = Order(
        customerId: customerId,
        weight: weight,
        serviceType: serviceType,
        price: price,
        status: OrderStatus.terima,
        photoUrl: photoUrl,
      );

      // Insert ke database
      final id = await _dbService.insertOrder(order);

      // Tambahkan ke list dengan ID dari database
      _orders.insert(0, order.copyWith(id: id)); // Insert di awal (order terbaru)
      
      notifyListeners(); // Beritahu UI
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menambah order: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // ✏️ UPDATE (Edit Order)
  // ==========================================

  /// Update order yang sudah ada
  Future<bool> updateOrder({
    required int id,
    required int customerId,
    required double weight,
    required ServiceType serviceType,
    required double price,
    required OrderStatus status,
    String? photoUrl,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validasi input
      if (weight <= 0) {
        _setError('Berat harus lebih dari 0 kg');
        _setLoading(false);
        return false;
      }

      if (price <= 0) {
        _setError('Harga harus lebih dari 0');
        _setLoading(false);
        return false;
      }

      // Cari order yang mau diupdate
      final currentOrder = _orders.firstWhere((o) => o.id == id);

      // Update order
      final updatedOrder = currentOrder.copyWith(
        customerId: customerId,
        weight: weight,
        serviceType: serviceType,
        price: price,
        status: status,
        photoUrl: photoUrl,
      );

      // Update di database
      await _dbService.updateOrder(updatedOrder);

      // Update di list
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }

      notifyListeners(); // Beritahu UI
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal update order: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // 🔄 UPDATE STATUS (Workflow)
  // ==========================================

  /// Update status order ke status berikutnya (workflow)
  Future<bool> progressOrderStatus(int orderId) async {
    _setLoading(true);
    _setError(null);

    try {
      // Cari order
      final order = _orders.firstWhere((o) => o.id == orderId);

      // Cek apakah bisa dilanjutkan
      if (!order.canProgressToNext) {
        _setError('Order sudah selesai');
        _setLoading(false);
        return false;
      }

      // Get status berikutnya
      final nextStatus = order.nextStatus;
      if (nextStatus == null) {
        _setError('Tidak ada status berikutnya');
        _setLoading(false);
        return false;
      }

      // Update order dengan status baru
      final updatedOrder = order.copyWith(status: nextStatus);

      // Update di database
      await _dbService.updateOrder(updatedOrder);

      // Update di list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }

      // Kirim notifikasi jika status menjadi selesai
      if (nextStatus == OrderStatus.selesai) {
        try {
          // Get customer name untuk notifikasi
          final customer = await _dbService.getCustomerById(order.customerId);
          if (customer != null) {
            await _notificationService.showPickupReadyNotification(
              orderId: orderId,
              customerName: customer.name,
            );
          }
        } catch (e) {
          debugPrint('Failed to send notification: $e');
          // Don't fail the whole operation if notification fails
        }
      }

      notifyListeners(); // Beritahu UI
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal update status: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Update status order ke status tertentu (manual)
  Future<bool> updateOrderStatus(int orderId, OrderStatus newStatus) async {
    _setLoading(true);
    _setError(null);

    try {
      // Cari order
      final order = _orders.firstWhere((o) => o.id == orderId);

      // Update order dengan status baru
      final updatedOrder = order.copyWith(status: newStatus);

      // Update di database
      await _dbService.updateOrder(updatedOrder);

      // Update di list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }

      notifyListeners(); // Beritahu UI
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal update status: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // 🗑️ DELETE (Hapus Order)
  // ==========================================

  /// Hapus order
  Future<bool> deleteOrder(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      // Hapus dari database
      await _dbService.deleteOrder(id);

      // Hapus dari list
      _orders.removeWhere((o) => o.id == id);

      notifyListeners(); // Beritahu UI
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menghapus order: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // 🔍 FILTER & SEARCH
  // ==========================================

  /// Set filter by status
  void setFilterStatus(OrderStatus? status) {
    _filterStatus = status;
    notifyListeners(); // Beritahu UI untuk update filtered list
  }

  /// Clear filter
  void clearFilter() {
    _filterStatus = null;
    notifyListeners();
  }

  /// Get orders by customer ID
  Future<List<Order>> getOrdersByCustomerId(int customerId) async {
    try {
      return await _dbService.getOrdersByCustomerId(customerId);
    } catch (e) {
      _setError('Gagal mengambil order customer: $e');
      return [];
    }
  }

  /// Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).toList();
  }

  /// Get orders grouped by status
  Map<OrderStatus, List<Order>> get ordersByStatus {
    return {
      OrderStatus.terima: getOrdersByStatus(OrderStatus.terima),
      OrderStatus.cuci: getOrdersByStatus(OrderStatus.cuci),
      OrderStatus.setrika: getOrdersByStatus(OrderStatus.setrika),
      OrderStatus.selesai: getOrdersByStatus(OrderStatus.selesai),
    };
  }

  // ==========================================
  // 📊 STATISTICS & ANALYTICS
  // ==========================================

  /// Get total berat cucian (kg)
  double get totalWeight {
    return _orders.fold(0.0, (sum, order) => sum + order.weight);
  }

  /// Get total revenue dari semua order
  double get totalRevenue {
    return _orders.fold(0.0, (sum, order) => sum + order.price);
  }

  /// Get revenue by service type
  Map<ServiceType, double> get revenueByServiceType {
    Map<ServiceType, double> revenue = {
      ServiceType.kiloan: 0.0,
      ServiceType.satuan: 0.0,
      ServiceType.express: 0.0,
    };

    for (var order in _orders) {
      revenue[order.serviceType] = (revenue[order.serviceType] ?? 0.0) + order.price;
    }

    return revenue;
  }

  /// Get order count by service type
  Map<ServiceType, int> get orderCountByServiceType {
    Map<ServiceType, int> count = {
      ServiceType.kiloan: 0,
      ServiceType.satuan: 0,
      ServiceType.express: 0,
    };

    for (var order in _orders) {
      count[order.serviceType] = (count[order.serviceType] ?? 0) + 1;
    }

    return count;
  }

  // ==========================================
  // 📊 UTILITY METHODS
  // ==========================================

  /// Get order by ID
  Order? getOrderById(int id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Cek apakah customer punya order yang belum selesai
  bool hasActiveOrders(int customerId) {
    return _orders.any(
      (o) => o.customerId == customerId && !o.isCompleted,
    );
  }

  /// Get active orders (belum selesai) by customer
  List<Order> getActiveOrdersByCustomer(int customerId) {
    return _orders.where(
      (o) => o.customerId == customerId && !o.isCompleted,
    ).toList();
  }

  /// Get completed orders by customer
  List<Order> getCompletedOrdersByCustomer(int customerId) {
    return _orders.where(
      (o) => o.customerId == customerId && o.isCompleted,
    ).toList();
  }

  /// Get orders in period (days)
  List<Order> getOrdersInPeriod(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _orders.where((o) => o.date.isAfter(cutoffDate)).toList();
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
    await loadOrders();
  }
}
