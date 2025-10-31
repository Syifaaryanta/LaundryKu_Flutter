import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/database_service.dart';

/// Provider untuk mengelola state Customer
/// Menggunakan ChangeNotifier untuk memberitahu UI saat ada perubahan data
class CustomerProvider extends ChangeNotifier {
  // Database service instance
  final DatabaseService _dbService = DatabaseService();

  // List semua customers (state)
  List<Customer> _customers = [];

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _errorMessage;

  // 🔹 GETTERS: Akses state dari luar (read-only)
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCustomers => _customers.length;

  // 🔹 CONSTRUCTOR: Load data saat provider pertama kali dibuat
  CustomerProvider() {
    loadCustomers();
  }

  // ==========================================
  // 📋 LOAD DATA
  // ==========================================

  /// Load semua customers dari database
  Future<void> loadCustomers() async {
    _setLoading(true);
    _setError(null);

    try {
      _customers = await _dbService.getAllCustomers();
      notifyListeners(); // Beritahu UI bahwa data sudah berubah
    } catch (e) {
      _setError('Gagal memuat data customer: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // ➕ CREATE (Tambah Customer Baru)
  // ==========================================

  /// Tambah customer baru
  Future<bool> addCustomer({
    required String name,
    required String phone,
    required String address,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validasi input
      if (name.trim().isEmpty) {
        _setError('Nama tidak boleh kosong');
        _setLoading(false);
        return false;
      }

      if (phone.trim().isEmpty) {
        _setError('Nomor telepon tidak boleh kosong');
        _setLoading(false);
        return false;
      }

      if (address.trim().isEmpty) {
        _setError('Alamat tidak boleh kosong');
        _setLoading(false);
        return false;
      }

      // Cek apakah phone sudah terdaftar
      final existingCustomer = _customers.where(
        (c) => c.phone == phone.trim(),
      ).toList();

      if (existingCustomer.isNotEmpty) {
        _setError('Nomor telepon sudah terdaftar');
        _setLoading(false);
        return false;
      }

      // Buat customer baru
      final customer = Customer(
        name: name.trim(),
        phone: phone.trim(),
        address: address.trim(),
      );

      // Insert ke database
      final id = await _dbService.insertCustomer(customer);

      // Tambahkan ke list dengan ID dari database
      _customers.add(customer.copyWith(id: id));
      
      notifyListeners(); // Beritahu UI
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menambah customer: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // ✏️ UPDATE (Edit Customer)
  // ==========================================

  /// Update customer yang sudah ada
  Future<bool> updateCustomer({
    required int id,
    required String name,
    required String phone,
    required String address,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validasi input
      if (name.trim().isEmpty) {
        _setError('Nama tidak boleh kosong');
        _setLoading(false);
        return false;
      }

      if (phone.trim().isEmpty) {
        _setError('Nomor telepon tidak boleh kosong');
        _setLoading(false);
        return false;
      }

      if (address.trim().isEmpty) {
        _setError('Alamat tidak boleh kosong');
        _setLoading(false);
        return false;
      }

      // Cek apakah phone sudah digunakan customer lain
      final existingCustomer = _customers.where(
        (c) => c.phone == phone.trim() && c.id != id,
      ).toList();

      if (existingCustomer.isNotEmpty) {
        _setError('Nomor telepon sudah digunakan customer lain');
        _setLoading(false);
        return false;
      }

      // Update customer
      final updatedCustomer = Customer(
        id: id,
        name: name.trim(),
        phone: phone.trim(),
        address: address.trim(),
      );

      // Update di database
      await _dbService.updateCustomer(updatedCustomer);

      // Update di list
      final index = _customers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
      }

      notifyListeners(); // Beritahu UI
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal update customer: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // 🗑️ DELETE (Hapus Customer)
  // ==========================================

  /// Hapus customer
  Future<bool> deleteCustomer(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      // Hapus dari database
      await _dbService.deleteCustomer(id);

      // Hapus dari list
      _customers.removeWhere((c) => c.id == id);

      notifyListeners(); // Beritahu UI
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menghapus customer: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // 🔍 SEARCH (Cari Customer)
  // ==========================================

  /// Cari customer by nama atau phone
  Future<List<Customer>> searchCustomers(String query) async {
    if (query.trim().isEmpty) {
      return _customers; // Return semua jika query kosong
    }

    try {
      return await _dbService.searchCustomers(query.trim());
    } catch (e) {
      _setError('Gagal mencari customer: $e');
      return [];
    }
  }

  // ==========================================
  // 📊 UTILITY METHODS
  // ==========================================

  /// Get customer by ID
  Customer? getCustomerById(int id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get customer by phone
  Customer? getCustomerByPhone(String phone) {
    try {
      return _customers.firstWhere((c) => c.phone == phone);
    } catch (e) {
      return null;
    }
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
    await loadCustomers();
  }
}
