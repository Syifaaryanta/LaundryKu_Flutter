/// Model untuk data Order/Pesanan Laundry
/// Merepresentasikan tabel 'orders' di database

// 🔹 ENUM: Status Order (Workflow)
enum OrderStatus {
  terima, // Pakaian baru diterima
  cuci, // Sedang dalam proses pencucian
  setrika, // Sedang dalam proses penyetrikaan
  selesai, // Sudah selesai, siap diambil
}

// 🔹 ENUM: Jenis Layanan Laundry
enum ServiceType {
  kiloan, // Laundry per kilogram
  satuan, // Laundry per item (selimut, boneka, dll)
  express, // Layanan cepat (1 hari)
}

class Order {
  // Properties/Atribut
  final int? id; // ID auto-increment dari database
  final int customerId; // Foreign key ke tabel customers
  final double weight; // Berat cucian (kg)
  final ServiceType serviceType; // Jenis layanan (kiloan/satuan/express)
  final double price; // Harga total
  final OrderStatus status; // Status pesanan saat ini
  final String? photoUrl; // Path foto dokumentasi pakaian
  final DateTime date; // Tanggal order dibuat

  // Constructor
  Order({
    this.id,
    required this.customerId,
    required this.weight,
    required this.serviceType,
    required this.price,
    this.status = OrderStatus.terima, // Default status: terima
    this.photoUrl,
    DateTime? date,
  }) : date = date ?? DateTime.now(); // Default date: sekarang

  // 🔹 FACTORY CONSTRUCTOR: Konversi dari Map (Database) ke Object Order
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      weight: (map['weight'] as num).toDouble(),
      serviceType: _serviceTypeFromString(map['service_type'] as String),
      price: (map['price'] as num).toDouble(),
      status: _statusFromString(map['status'] as String),
      photoUrl: map['photo_url'] as String?,
      date: DateTime.parse(map['date'] as String),
    );
  }

  // 🔹 METHOD: Konversi dari Object Order ke Map (Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'weight': weight,
      'service_type': _serviceTypeToString(serviceType),
      'price': price,
      'status': _statusToString(status),
      'photo_url': photoUrl,
      'date': date.toIso8601String(),
    };
  }

  // 🔹 METHOD: Copy object dengan nilai baru
  Order copyWith({
    int? id,
    int? customerId,
    double? weight,
    ServiceType? serviceType,
    double? price,
    OrderStatus? status,
    String? photoUrl,
    DateTime? date,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      weight: weight ?? this.weight,
      serviceType: serviceType ?? this.serviceType,
      price: price ?? this.price,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      date: date ?? this.date,
    );
  }

  // 🔹 HELPER: Konversi String ke OrderStatus
  static OrderStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'terima':
        return OrderStatus.terima;
      case 'cuci':
        return OrderStatus.cuci;
      case 'setrika':
        return OrderStatus.setrika;
      case 'selesai':
        return OrderStatus.selesai;
      default:
        return OrderStatus.terima;
    }
  }

  // 🔹 HELPER: Konversi OrderStatus ke String
  static String _statusToString(OrderStatus status) {
    return status.toString().split('.').last; // Ambil nama enum saja
  }

  // 🔹 HELPER: Konversi String ke ServiceType
  static ServiceType _serviceTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'kiloan':
        return ServiceType.kiloan;
      case 'satuan':
        return ServiceType.satuan;
      case 'express':
        return ServiceType.express;
      default:
        return ServiceType.kiloan;
    }
  }

  // 🔹 HELPER: Konversi ServiceType ke String
  static String _serviceTypeToString(ServiceType type) {
    return type.toString().split('.').last; // Ambil nama enum saja
  }

  // 🔹 METHOD: Get status display name (untuk UI)
  String get statusDisplay {
    switch (status) {
      case OrderStatus.terima:
        return 'Diterima';
      case OrderStatus.cuci:
        return 'Sedang Dicuci';
      case OrderStatus.setrika:
        return 'Sedang Disetrika';
      case OrderStatus.selesai:
        return 'Selesai';
    }
  }

  // 🔹 METHOD: Get service type display name (untuk UI)
  String get serviceTypeDisplay {
    switch (serviceType) {
      case ServiceType.kiloan:
        return 'Kiloan';
      case ServiceType.satuan:
        return 'Satuan';
      case ServiceType.express:
        return 'Express';
    }
  }

  // 🔹 METHOD: Cek apakah order sudah selesai
  bool get isCompleted => status == OrderStatus.selesai;

  // 🔹 METHOD: Cek apakah order bisa dilanjutkan ke status berikutnya
  bool get canProgressToNext => status != OrderStatus.selesai;

  // 🔹 METHOD: Get status berikutnya dalam workflow
  OrderStatus? get nextStatus {
    switch (status) {
      case OrderStatus.terima:
        return OrderStatus.cuci;
      case OrderStatus.cuci:
        return OrderStatus.setrika;
      case OrderStatus.setrika:
        return OrderStatus.selesai;
      case OrderStatus.selesai:
        return null; // Sudah selesai, tidak ada status berikutnya
    }
  }

  // 🔹 METHOD: ToString untuk debugging
  @override
  String toString() {
    return 'Order(id: $id, customerId: $customerId, weight: $weight kg, '
        'serviceType: ${serviceTypeDisplay}, price: Rp $price, '
        'status: ${statusDisplay}, date: $date)';
  }
}
