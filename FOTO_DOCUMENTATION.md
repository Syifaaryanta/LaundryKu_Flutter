# 📸 Dokumentasi Fitur Upload Foto

## Fitur Upload Foto Dokumentasi Pakaian

LaundryKu dilengkapi dengan fitur **dokumentasi foto pakaian** yang memungkinkan Anda untuk:
- 📷 Mengambil foto langsung menggunakan kamera (jika tersedia)
- 🖼️ Memilih foto dari galeri/file explorer
- 👁️ Melihat preview foto yang sudah diupload
- 🔍 Zoom foto dengan interactive viewer
- 🗑️ Menghapus atau mengganti foto

## Cara Menggunakan

### 1. Menambah Order dengan Foto

Saat menambah order baru:

1. Isi semua data order (Customer, Jenis Layanan, Berat, Harga)
2. Pada bagian **"Foto Dokumentasi Pakaian"**, klik tombol **"Tambah Foto"**
3. Pilih sumber foto:
   - **Kamera** - Untuk mengambil foto langsung (jika kamera tersedia)
   - **Galeri** - Untuk memilih foto dari file explorer
4. Foto akan langsung muncul sebagai preview
5. Klik **"Simpan Order"** untuk menyimpan

### 2. Mengganti Foto

Jika ingin mengganti foto yang sudah diupload:

1. Klik tombol **"Ganti Foto"** di bawah preview foto
2. Pilih sumber foto baru (Kamera atau Galeri)
3. Foto lama akan otomatis terganti

### 3. Menghapus Foto

Jika ingin menghapus foto:

1. Klik tombol **"Hapus"** (berwarna merah) di bawah preview foto
2. Foto akan dihapus dari form

### 4. Melihat Foto di Daftar Order

Pada daftar order:

1. Order yang memiliki foto akan menampilkan ikon 📷 dengan teks **"Lihat foto"**
2. Klik pada ikon tersebut untuk membuka dialog foto
3. Gunakan gesture pinch/zoom untuk memperbesar foto
4. Klik tombol X untuk menutup dialog

## Platform Support

### Windows (Platform Utama)
✅ **Upload dari File Explorer** - Fully supported menggunakan file_picker
⚠️ **Kamera** - Mungkin tidak tersedia di PC tanpa webcam, akan otomatis fallback ke file explorer

### Android/iOS
✅ **Kamera** - Fully supported
✅ **Galeri** - Fully supported

## Format Foto yang Didukung

- JPEG (.jpg, .jpeg)
- PNG (.png)
- GIF (.gif)
- BMP (.bmp)
- WebP (.webp)

## Penyimpanan Foto

Foto disimpan secara lokal di:
```
{ApplicationDocumentsDirectory}/photos/order_{timestamp}.{ext}
```

Setiap foto diberi nama unik berdasarkan timestamp untuk menghindari konflik.

## Optimasi Foto

Foto yang diupload melalui kamera akan otomatis dioptimasi:
- Max Width: 1024px
- Max Height: 1024px
- Quality: 85%

Hal ini untuk menghemat storage dan mempercepat loading.

## Troubleshooting

### Kamera tidak berfungsi di Windows
**Solusi:** Gunakan opsi "Galeri" untuk memilih foto dari file explorer. Ini adalah cara yang direkomendasikan untuk platform Windows.

### Foto tidak muncul
**Solusi:** 
1. Pastikan Anda sudah menekan tombol "Simpan Order"
2. Cek apakah aplikasi memiliki permission untuk mengakses storage
3. Coba refresh halaman order list

### Foto terlalu besar
**Solusi:** Foto dari kamera sudah otomatis dioptimasi. Jika upload dari galeri, pilih foto dengan ukuran yang wajar (< 5MB).

## Tips Penggunaan

1. 📸 **Ambil foto yang jelas** - Pastikan pencahayaan cukup dan fokus pada pakaian
2. 🏷️ **Dokumentasi sebelum dan sesudah** - Foto bisa digunakan untuk membandingkan kondisi pakaian
3. 🗂️ **Satu foto per order** - Sistem mendukung satu foto per order, pastikan foto menampilkan semua item dalam order
4. 💾 **Backup foto penting** - Foto disimpan lokal, jangan lupa backup secara berkala

## Keamanan & Privacy

- Foto hanya disimpan di perangkat lokal
- Tidak ada upload ke cloud/server
- Foto terikat dengan order tertentu
- Jika order dihapus, referensi foto akan hilang (file fisik tetap ada untuk keamanan data)
