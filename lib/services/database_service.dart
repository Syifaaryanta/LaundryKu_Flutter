import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../models/payment.dart';

/// Service untuk mengelola database SQLite
/// Menggunakan Singleton Pattern agar hanya ada 1 instance database
class DatabaseService {
  // 🔹 SINGLETON PATTERN
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Database instance
  static Database? _database;

  // Nama database dan versi
  static const String _databaseName = 'laundry_ku.db';
  static const int _databaseVersion = 1;

  // Nama tabel
  static const String tableCustomers = 'customers';
  static const String tableOrders = 'orders';
  static const String tablePayments = 'payments';

  // 🔹 GETTER: Akses database (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 🔹 INISIALISASI DATABASE
  Future<Database> _initDatabase() async {
    // Dapatkan path untuk menyimpan database
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    // Buka/buat database
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // 🔹 BUAT TABEL SAAT DATABASE PERTAMA KALI DIBUAT
  Future<void> _onCreate(Database db, int version) async {
    // Tabel Customers
    await db.execute('''
      CREATE TABLE $tableCustomers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL
      )
    ''');

    // Tabel Orders
    await db.execute('''
      CREATE TABLE $tableOrders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        service_type TEXT NOT NULL,
        price REAL NOT NULL,
        status TEXT NOT NULL,
        photo_url TEXT,
        date TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES $tableCustomers (id) ON DELETE CASCADE
      )
    ''');

    // Tabel Payments
    await db.execute('''
      CREATE TABLE $tablePayments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        paid_date TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (order_id) REFERENCES $tableOrders (id) ON DELETE CASCADE
      )
    ''');

    print('Database tables created successfully');
  }

  // UPGRADE DATABASE (jika ada perubahan skema di versi baru)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Untuk future updates
    // Contoh: if (oldVersion < 2) { ... }
  }

  // ==========================================
  // CUSTOMER OPERATIONS (CRUD)
  // ==========================================

  /// CREATE: Tambah customer baru
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert(tableCustomers, customer.toMap());
  }

  /// READ: Ambil semua customers
  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableCustomers);
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  /// READ: Ambil customer by ID
  Future<Customer?> getCustomerById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableCustomers,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  /// UPDATE: Update customer
  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      tableCustomers,
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  /// DELETE: Hapus customer
  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete(
      tableCustomers,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// SEARCH: Cari customer by name atau phone
  Future<List<Customer>> searchCustomers(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableCustomers,
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // ==========================================
  // ORDER OPERATIONS (CRUD)
  // ==========================================

  /// CREATE: Tambah order baru
  Future<int> insertOrder(Order order) async {
    final db = await database;
    return await db.insert(tableOrders, order.toMap());
  }

  /// READ: Ambil semua orders
  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableOrders,
      orderBy: 'date DESC', // Urutkan dari yang terbaru
    );
    return List.generate(maps.length, (i) => Order.fromMap(maps[i]));
  }

  /// READ: Ambil order by ID
  Future<Order?> getOrderById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableOrders,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Order.fromMap(maps.first);
  }

  /// READ: Ambil orders by customer ID
  Future<List<Order>> getOrdersByCustomerId(int customerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableOrders,
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Order.fromMap(maps[i]));
  }

  /// READ: Ambil orders by status
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    final db = await database;
    final statusStr = status.toString().split('.').last;
    final List<Map<String, dynamic>> maps = await db.query(
      tableOrders,
      where: 'status = ?',
      whereArgs: [statusStr],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Order.fromMap(maps[i]));
  }

  /// UPDATE: Update order
  Future<int> updateOrder(Order order) async {
    final db = await database;
    return await db.update(
      tableOrders,
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  /// DELETE: Hapus order
  Future<int> deleteOrder(int id) async {
    final db = await database;
    return await db.delete(
      tableOrders,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // PAYMENT OPERATIONS (CRUD)
  // ==========================================

  /// CREATE: Tambah payment baru
  Future<int> insertPayment(Payment payment) async {
    final db = await database;
    return await db.insert(tablePayments, payment.toMap());
  }

  /// READ: Ambil semua payments
  Future<List<Payment>> getAllPayments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePayments,
      orderBy: 'paid_date DESC',
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  /// READ: Ambil payment by ID
  Future<Payment?> getPaymentById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePayments,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Payment.fromMap(maps.first);
  }

  /// READ: Ambil payments by order ID
  Future<List<Payment>> getPaymentsByOrderId(int orderId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePayments,
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'paid_date DESC',
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  /// UPDATE: Update payment
  Future<int> updatePayment(Payment payment) async {
    final db = await database;
    return await db.update(
      tablePayments,
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  /// DELETE: Hapus payment
  Future<int> deletePayment(int id) async {
    final db = await database;
    return await db.delete(
      tablePayments,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // 📊 ANALYTICS & REPORTING
  // ==========================================

  /// GET: Total revenue (semua pembayaran)
  Future<double> getTotalRevenue() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM $tablePayments');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// GET: Revenue by date range
  Future<double> getRevenueByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $tablePayments WHERE paid_date BETWEEN ? AND ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// GET: Count orders by service type
  Future<Map<String, int>> getOrderCountByServiceType() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT service_type, COUNT(*) as count FROM $tableOrders GROUP BY service_type',
    );
    
    Map<String, int> counts = {
      'kiloan': 0,
      'satuan': 0,
      'express': 0,
    };
    
    for (var row in result) {
      final serviceType = row['service_type'] as String;
      final count = row['count'] as int;
      counts[serviceType] = count;
    }
    
    return counts;
  }

  /// GET: Outstanding payments (orders belum dibayar)
  Future<List<Order>> getUnpaidOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT o.* FROM $tableOrders o
      LEFT JOIN $tablePayments p ON o.id = p.order_id
      WHERE p.id IS NULL
      ORDER BY o.date DESC
    ''');
    return List.generate(maps.length, (i) => Order.fromMap(maps[i]));
  }

  // ==========================================
  // 🧹 UTILITY FUNCTIONS
  // ==========================================

  /// CLEAR: Hapus semua data (untuk testing/reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(tablePayments);
    await db.delete(tableOrders);
    await db.delete(tableCustomers);
    print('All data cleared');
  }

  /// CLOSE: Tutup database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
