/// Model untuk data Payment/Pembayaran
/// Merepresentasikan tabel 'payments' di database

// 🔹 ENUM: Metode Pembayaran
enum PaymentMethod {
  cash, // Tunai
  transfer, // Transfer bank
  qris, // QRIS (scan QR)
  eWallet, // E-Wallet (GoPay, OVO, Dana, dll)
}

class Payment {
  // Properties/Atribut
  final int? id; // ID auto-increment dari database
  final int orderId; // Foreign key ke tabel orders
  final double amount; // Jumlah yang dibayar
  final PaymentMethod paymentMethod; // Metode pembayaran
  final DateTime paidDate; // Tanggal pembayaran
  final String? notes; // Catatan tambahan (opsional)

  // Constructor
  Payment({
    this.id,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    DateTime? paidDate,
    this.notes,
  }) : paidDate = paidDate ?? DateTime.now(); // Default: sekarang

  // 🔹 FACTORY CONSTRUCTOR: Konversi dari Map (Database) ke Object Payment
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      orderId: map['order_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: _paymentMethodFromString(map['payment_method'] as String),
      paidDate: DateTime.parse(map['paid_date'] as String),
      notes: map['notes'] as String?,
    );
  }

  // 🔹 METHOD: Konversi dari Object Payment ke Map (Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'amount': amount,
      'payment_method': _paymentMethodToString(paymentMethod),
      'paid_date': paidDate.toIso8601String(),
      'notes': notes,
    };
  }

  // 🔹 METHOD: Copy object dengan nilai baru
  Payment copyWith({
    int? id,
    int? orderId,
    double? amount,
    PaymentMethod? paymentMethod,
    DateTime? paidDate,
    String? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidDate: paidDate ?? this.paidDate,
      notes: notes ?? this.notes,
    );
  }

  // 🔹 HELPER: Konversi String ke PaymentMethod
  static PaymentMethod _paymentMethodFromString(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'transfer':
        return PaymentMethod.transfer;
      case 'qris':
        return PaymentMethod.qris;
      case 'ewallet':
        return PaymentMethod.eWallet;
      default:
        return PaymentMethod.cash;
    }
  }

  // 🔹 HELPER: Konversi PaymentMethod ke String
  static String _paymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.transfer:
        return 'transfer';
      case PaymentMethod.qris:
        return 'qris';
      case PaymentMethod.eWallet:
        return 'ewallet';
    }
  }

  // 🔹 METHOD: Get payment method display name (untuk UI)
  String get paymentMethodDisplay {
    switch (paymentMethod) {
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

  // 🔹 METHOD: Format amount ke Rupiah
  String get formattedAmount {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  // METHOD: Get icon name berdasarkan payment method
  String get paymentIconName {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'payments';
      case PaymentMethod.transfer:
        return 'account_balance';
      case PaymentMethod.qris:
        return 'qr_code';
      case PaymentMethod.eWallet:
        return 'account_balance_wallet';
    }
  }

  // 🔹 METHOD: ToString untuk debugging
  @override
  String toString() {
    return 'Payment(id: $id, orderId: $orderId, amount: ${formattedAmount}, '
        'method: ${paymentMethodDisplay}, paidDate: $paidDate)';
  }
}
