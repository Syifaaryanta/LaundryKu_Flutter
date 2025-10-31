/// Model untuk data Customer/Pelanggan
/// Merepresentasikan tabel 'customers' di database
class Customer {
  // Properties/Atribut
  final int? id; // ID auto-increment dari database (nullable karena baru dibuat belum punya ID)
  final String name; // Nama pelanggan
  final String phone; // Nomor telepon
  final String address; // Alamat pelanggan

  // Constructor
  Customer({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  // 🔹 FACTORY CONSTRUCTOR: Konversi dari Map (Database) ke Object Customer
  // Digunakan saat membaca data dari database SQLite
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
    );
  }

  // 🔹 METHOD: Konversi dari Object Customer ke Map (Database)
  // Digunakan saat menyimpan data ke database SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  // 🔹 METHOD: Copy object dengan nilai baru (immutable pattern)
  // Berguna saat update data
  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  // 🔹 METHOD: ToString untuk debugging
  @override
  String toString() {
    return 'Customer(id: $id, name: $name, phone: $phone, address: $address)';
  }
}
