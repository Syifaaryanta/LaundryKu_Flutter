# 📋 CHANGELOG - LaundryKu App

## [1.1.0] - 2025-10-31

### ✨ ENHANCED - Fitur Upload Foto

#### Added
- 📸 **Dual upload method untuk foto dokumentasi:**
  - Upload dari **Kamera** (Android/iOS dengan image_picker)
  - Upload dari **Galeri/File Explorer** (semua platform dengan file_picker)
- 🎯 **Dialog pemilihan sumber foto** dengan 2 opsi yang jelas
- 💾 **Auto-save** foto ke local storage dengan nama unik
- 🔍 **Preview foto** dengan kemampuan zoom (InteractiveViewer)
- 🗑️ **Hapus dan ganti foto** dengan mudah
- ✅ **Feedback notification** setelah upload berhasil

#### Changed
- Refactor `_pickImage()` menjadi 2 method terpisah:
  - `_pickImageFromCamera()` - untuk kamera
  - `_pickImageFromGallery()` - untuk galeri/file explorer
- Improve `_saveImage()` untuk menerima path string
- Update UI button dari "Ambil Foto" menjadi "Tambah Foto"
- Tambah error handling yang lebih baik dengan fallback

#### Fixed
- 🐛 **Windows compatibility issue** - Error ImagePicker yang membutuhkan cameraDelegate
- 🐛 **Platform-specific upload** - Sekarang bisa upload dari file explorer di Windows
- ⚡ **Performance** - Optimasi foto dengan max size dan quality

#### Technical Details
```yaml
Dependencies added:
  file_picker: ^8.3.7  # For cross-platform file selection
```

```dart
Key Methods:
- _pickImageFromCamera()     -> Camera capture
- _pickImageFromGallery()    -> File explorer selection  
- _saveImage(String path)    -> Save to local storage
- _showImageSourceDialog()   -> Show selection dialog
- _removePhoto()             -> Remove photo from form
```

#### Files Changed
- `lib/screens/order_list_screen.dart` - Enhanced photo upload
- `pubspec.yaml` - Added file_picker package
- `FOTO_DOCUMENTATION.md` - NEW comprehensive photo documentation
- `COMPLIANCE_CHECK.md` - Updated with enhanced photo features

#### User Experience Improvements
1. **Flexible Upload Options:**
   - User dapat memilih kamera atau galeri
   - Fallback otomatis jika kamera tidak tersedia
   
2. **Better Feedback:**
   - Success notification setelah foto berhasil ditambahkan
   - Error message yang lebih deskriptif
   
3. **Windows Support:**
   - File picker untuk memilih foto dari file explorer
   - Fully compatible dengan desktop environment

4. **Multi-format Support:**
   - JPEG, PNG, GIF, BMP, WebP

---

## [1.0.0] - 2025-10-31

### 🎉 Initial Release

#### Features Implemented (13/13)
1. ✅ Customer Management - CRUD lengkap
2. ✅ Order Management - CRUD dengan status tracking
3. ✅ Payment Management - Multiple payment methods
4. ✅ Status Tracking - Visual workflow
5. ✅ Dashboard - Analytics & charts
6. ✅ State Management - Provider pattern
7. ✅ Local Database - SQLite dengan desktop support
8. ✅ UI/UX - Material Design 3
9. ✅ Photo Documentation - Camera integration
10. ✅ Outstanding Payment - Real-time tracking
11. ✅ Pickup Notification - Auto-trigger
12. ✅ Export Data - CSV export & share
13. ✅ Additional Features - Charts & validations

#### Platform Support
- ✅ Windows (primary)
- ✅ Android
- ✅ iOS
- ✅ Linux
- ✅ macOS

#### Technical Stack
- Flutter SDK 3.9.2+
- Provider State Management
- SQLite Database (sqflite + sqflite_common_ffi)
- Material Design 3
- Local Notifications
- CSV Export
- Charts (fl_chart)

---

## Future Enhancements (Planned)

### Version 1.2.0
- [ ] Cloud backup integration
- [ ] Multi-user support
- [ ] Report generation (PDF)
- [ ] WhatsApp notification integration
- [ ] Barcode/QR code for order tracking

### Version 1.3.0
- [ ] Web dashboard
- [ ] Advanced analytics
- [ ] Customer loyalty program
- [ ] Inventory management

---

**Maintained by:** LaundryKu Development Team  
**License:** Private Project  
**Repository:** Local Development
