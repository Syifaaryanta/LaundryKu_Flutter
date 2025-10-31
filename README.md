# LaundryKu - Laundry Service Manager 🧺

Aplikasi manajemen laundry kiloan sederhana yang dibangun dengan Flutter.

## 📱 Fitur Utama

### MODULE 1: ORDER MANAGEMENT ✅
- ✅ **Customer Registration**: Kelola data pelanggan (nama, telepon, alamat)
- ✅ **New Order Entry**: Buat pesanan baru dengan berat, jenis layanan, dan harga
- ✅ **Order Status Tracking**: Workflow status (Terima → Cuci → Setrika → Selesai)
- ✅ **Photo Documentation**: Ambil foto pakaian saat terima pesanan

### MODULE 2: PAYMENT & PICKUP ✅
- ✅ **Payment Recording**: Catat pembayaran dengan berbagai metode (Tunai, Transfer, QRIS, E-Wallet)
- ✅ **Transaction History**: Riwayat transaksi per pelanggan
- ✅ **Pickup Notification**: Notifikasi otomatis saat pesanan selesai
- ✅ **Outstanding Payment Tracking**: Monitor pembayaran yang belum lunas

### MODULE 3: ANALYTICS ✅
- ✅ **Daily Revenue Chart**: Grafik pendapatan harian
- ✅ **Service Type Breakdown**: Analisis per jenis layanan (Kiloan, Satuan, Express)
- ✅ **Customer Frequency Analysis**: Analisis frekuensi pesanan pelanggan
- ✅ **Monthly Summary Report**: Laporan ringkasan bulanan
- ✅ **Export Functionality**: Export data ke CSV (Customers, Orders, Payments, Analytics)

## 🎯 Database Schema

### Customers
- id (INTEGER PRIMARY KEY)
- name (TEXT)
- phone (TEXT)
- address (TEXT)

### Orders
- id (INTEGER PRIMARY KEY)
- customer_id (INTEGER)
- weight (REAL)
- service_type (TEXT: kiloan/satuan/express)
- price (REAL)
- status (TEXT: terima/cuci/setrika/selesai)
- photo_url (TEXT)
- date (TEXT)

### Payments
- id (INTEGER PRIMARY KEY)
- order_id (INTEGER)
- amount (REAL)
- payment_method (TEXT: cash/transfer/qris/ewallet)
- paid_date (TEXT)
- notes (TEXT)

## 🚀 Teknologi yang Digunakan

### Framework & Language
- Flutter SDK (Latest)
- Dart 3.9.2+

### State Management
- Provider 6.1.2

### Database
- SQLite (sqflite 2.3.3+1)
- sqflite_common_ffi 2.3.3 (Desktop support)

### UI & Visualization
- Material Design 3
- fl_chart 0.68.0 (Charts)

### Features
- image_picker 1.1.2 (Camera)
- path_provider 2.1.3 (File storage)
- flutter_local_notifications 17.2.2 (Push notifications)
- csv 6.0.0 (CSV export)
- share_plus 10.1.2 (File sharing)
- intl 0.19.0 (Date formatting)

## 📦 Instalasi

1. **Clone repository**
   ```bash
   git clone https://github.com/Syifaaryanta/Study-Tracker.git
   cd laundry_ku
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi**
   ```bash
   # Android
   flutter run

   # Windows
   flutter run -d windows

   # iOS
   flutter run -d ios
   ```

## 📖 Cara Menggunakan

### 1. Kelola Customer
- Tap "Customers" di bottom navigation
- Tap tombol `+` untuk menambah customer baru
- Isi nama, telepon, dan alamat
- Gunakan search untuk mencari customer

### 2. Buat Order Baru
- Tap "Orders" di bottom navigation
- Tap tombol `+` untuk membuat order
- Pilih customer dari dropdown
- Pilih jenis layanan (Kiloan/Satuan/Express)
- Masukkan berat dan harga
- **Ambil foto pakaian** untuk dokumentasi
- Tap "Simpan Order"

### 3. Lihat Foto Order
- Buka daftar "Orders"
- Pada order yang memiliki foto, tap "Lihat foto"
- Foto akan ditampilkan fullscreen dengan zoom

### 4. Update Status Order
- Di daftar "Orders", tap tombol "Lanjutkan ke [status]"
- Status akan berubah: Terima → Cuci → Setrika → Selesai
- Saat status menjadi "Selesai", notifikasi otomatis terkirim

### 5. Catat Pembayaran
- Tap "Payments" di bottom navigation
- Tap tombol `+` untuk catat pembayaran
- Pilih order yang akan dibayar
- Masukkan jumlah pembayaran
- Pilih metode pembayaran (Tunai/Transfer/QRIS/E-Wallet)
- Tambahkan catatan (opsional)

### 6. Monitor Outstanding Payment
- Buka daftar "Orders"
- Lihat badge pembayaran di setiap order card:
  - 🟢 **Hijau (Lunas)**: Pembayaran sudah penuh
  - 🟠 **Orange (Belum Lunas)**: Ada sisa pembayaran
- Badge menampilkan: "Rp [dibayar] / Rp [total]"

### 7. Lihat Analytics
- Tap "Analytics" di bottom navigation
- Pilih periode: 7/30/90/365 hari
- Lihat grafik revenue harian
- Lihat breakdown per jenis layanan
- Lihat top customers

### 8. Export Data
- Buka "Analytics"
- Tap icon Download (⬇️) di AppBar
- Pilih jenis export:
  - **Export Customers**: Data semua pelanggan
  - **Export Orders**: Data semua pesanan
  - **Export Payments**: Data semua pembayaran
  - **Export Analytics**: Laporan ringkasan analytics
- File CSV akan dibuat dan bisa di-share via WhatsApp, Email, dll

## 🎨 Screenshots

### Dashboard
Tampilan dashboard dengan statistik real-time dan quick actions.

### Orders dengan Photo
Order list menampilkan status, berat, harga, dan indikator foto.

### Payment Status
Visual indicator menampilkan status pembayaran (Lunas/Belum Lunas) dengan detail.

### Analytics Charts
Grafik revenue harian dan breakdown jenis layanan dengan pie chart.

## 🏗️ Arsitektur

```
lib/
├── main.dart                 # Entry point & navigation
├── models/                   # Data models
│   ├── customer.dart
│   ├── order.dart
│   └── payment.dart
├── providers/                # State management
│   ├── customer_provider.dart
│   ├── order_provider.dart
│   └── payment_provider.dart
├── screens/                  # UI screens
│   ├── customer_list_screen.dart
│   ├── order_list_screen.dart
│   ├── payment_list_screen.dart
│   └── analytics_screen.dart
└── services/                 # Business logic
    ├── database_service.dart
    ├── notification_service.dart
    └── export_service.dart
```

## 🔔 Notifications Setup

### Android
Notifikasi sudah otomatis berjalan di Android 12 ke bawah.

Untuk Android 13+:
1. Permission otomatis diminta saat pertama kali
2. Atau buka Settings → Apps → LaundryKu → Notifications → Allow

### iOS
1. Permission otomatis diminta saat pertama kali
2. Tap "Allow" untuk mengaktifkan notifikasi

## 📤 Export Format

### Customers CSV
```
ID,Nama,Telepon,Alamat
1,John Doe,08123456789,Jl. Merdeka No. 1
```

### Orders CSV
```
Order ID,Customer,Berat (kg),Jenis Layanan,Harga,Status,Tanggal,Foto
1,John Doe,5.5,Kiloan,55000,Selesai,31/10/2025,Ya
```

### Payments CSV
```
Payment ID,Order ID,Customer,Jumlah,Metode,Tanggal,Catatan
1,1,John Doe,55000,Tunai,31/10/2025 14:30,Lunas
```

### Analytics Report CSV
```
LAPORAN ANALYTICS LAUNDRYKU
Generated:,31 Oktober 2025 14:30

RINGKASAN
Total Orders,150
Total Revenue,Rp 7500000
Total Customers,50

BREAKDOWN JENIS LAYANAN
Jenis Layanan,Jumlah Order
Kiloan,100
Satuan,30
Express,20
```

## 🎯 Compliance Status

✅ **100% Compliant** dengan semua requirement:
- ✅ 3 Modul Inti Complete
- ✅ 13/13 Fitur Implemented
- ✅ Database Schema Sesuai
- ✅ Technical Stack Complete

Lihat [COMPLIANCE_CHECK.md](COMPLIANCE_CHECK.md) untuk detail lengkap.

## 👨‍💻 Developer

**Syifaaryanta**
- GitHub: [@Syifaaryanta](https://github.com/Syifaaryanta)

## 📝 License

This project is for educational purposes.

## 🙏 Acknowledgments

- Flutter Team untuk framework yang luar biasa
- Community packages contributors
- Material Design Team untuk design system

---

**LaundryKu** - Solusi Modern untuk Manajemen Laundry Anda! 🧺✨
