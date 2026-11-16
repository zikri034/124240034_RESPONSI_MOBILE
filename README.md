# Toko Awikwok - Latihan Responsi Mobile (SI-D)

Aplikasi mobile e-commerce minimalis yang dibangun menggunakan Flutter untuk memenuhi persyaratan **Latihan Responsi Praktikum Pemrograman Bergerak (latres_si-d)**.

Aplikasi ini mengintegrasikan konsumsi REST API publik dari [DummyJSON](https://dummyjson.com/products), manajemen sesi berbasis `shared_preferences`, persistensi keranjang belanja offline per-pengguna menggunakan `hive`, serta arsitektur antarmuka dan manajemen status reaktif menggunakan `get` (GetX).

---

## 🚀 Fitur Utama

1. **Autentikasi & Manajemen Sesi (Session Management)**:
   - Pemeriksaan sesi otomatis saat aplikasi dibuka:
     - Jika sesi pengguna aktif -> Langsung ke **Halaman Utama (Beranda)**.
     - Jika belum ada sesi -> Diarahkan ke **Halaman Login**.
   - Validasi input username dan password (NIM mahasiswa).
   - Penyimpanan sesi pengguna secara persisten menggunakan `shared_preferences`.
   - Logout membersihkan sesi dan mengarahkan kembali ke halaman login.

2. **Katalog Produk (Home / Beranda)**:
   - Sapaan dinamis sesuai akun yang sedang login (*"Hi, [Username]"*).
   - Pengambilan data produk secara asinkron dari API `https://dummyjson.com/products`.
   - Penanganan status *Loading*, *Error* dengan tombol *Retry*, serta *Pull-to-Refresh*.
   - Fitur pencarian produk *real-time*.
   - Badge jumlah keranjang dinamis pada *app bar*.

3. **Detail Produk (Product Detail)**:
   - Tampilan gambar produk beresolusi tinggi, judul, harga, kategori, ulasan/rating, dan status stok.
   - Selektor kuantitas interaktif yang mematuhi batasan logika bisnis: `0 < qty <= totalStok`.
   - Tombol "Tambah ke Keranjang" yang menyimpan data produk langsung ke database lokal Hive.

4. **Keranjang Belanja Terisolasi Per-User (Hive Local Database)**:
   - Data keranjang diisolasi per akun: pengguna hanya melihat barang yang ia tambahkan sendiri.
   - Perhitungan subtotal per produk dan total harga keseluruhan keranjang secara otomatis.
   - Fitur hapus item keranjang dengan dialog konfirmasi.
   - Navigasi mulus ke pembayaran/checkout.

5. **Profil Pengguna & Kesan Pesan (Profile)**:
   - Avatar profil dan nama pengguna yang sedang aktif.
   - Kartu deskripsi berisikan **Kesan** dan **Pesan** selama mengikuti mata kuliah praktikum.
   - Tombol logout berwarna merah (*destructive button*) sesuai spesifikasi desain.

---

## 🎨 Spesifikasi Desain (Minimalist UI/UX)

Sesuai dokumen `design_specification.md`, antarmuka aplikasi mengadopsi tema **Minimalism**:
- **Primary Color:** `#2196F3` (Material Blue) - Aksen tombol utama, active tab, dan harga.
- **Background Color:** `#FAFAFA` (Off-White) - Latar belakang scaffold utama.
- **Surface Color:** `#FFFFFF` (Pure White) - Kartu produk, input fields, bottom navigation.
- **Text Primary:** `#212121` (Dark Grey) - Judul utama dan teks isi.
- **Text Secondary:** `#757575` (Medium Grey) - Subtitle dan teks deskripsi.
- **Error/Destructive:** `#F44336` (Red) - Tombol hapus dan tombol logout.
- **Desain Komponen:** Sudut membulat (*BorderRadius: 8px* untuk tombol & input, *12px* untuk kartu), tanpa drop shadow tebal (*flat design*).

---

## 📁 Struktur Folder Proyek

Proyek ini menggunakan pola arsitektur **Feature-First / Layered Architecture** yang modular, rapi, dan mudah dirawat:

```text
lib/
├── app/
│   ├── data/
│   │   ├── models/
│   │   │   ├── product_model.dart        # Model data produk dari API DummyJSON
│   │   │   └── cart_item_model.dart       # Model & TypeAdapter Hive untuk keranjang
│   │   └── services/
│   │       ├── api_service.dart           # Service HTTP untuk konsumsi DummyJSON API
│   │       ├── session_service.dart       # Service SharedPreferences untuk sesi user
│   │       └── hive_cart_service.dart     # Service Hive untuk operasi CRUD keranjang
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── controllers/
│   │   │   │   └── auth_controller.dart   # State controller login & logout
│   │   │   └── views/
│   │   │       └── login_view.dart        # Halaman autentikasi login
│   │   ├── main/
│   │   │   └── views/
│   │   │       └── main_view.dart         # Container BottomNavigationBar (Home & Profile)
│   │   ├── home/
│   │   │   ├── controllers/
│   │   │   │   └── product_controller.dart# State controller produk & filter pencarian
│   │   │   └── views/
│   │   │       └── home_view.dart         # Halaman katalog produk (Tab 1)
│   │   ├── detail/
│   │   │   ├── controllers/
│   │   │   │   └── detail_controller.dart # State controller kuantitas produk
│   │   │   └── views/
│   │   │       └── detail_view.dart       # Halaman rincian produk
│   │   ├── cart/
│   │   │   ├── controllers/
│   │   │   │   └── cart_controller.dart   # State controller kalkulasi keranjang
│   │   │   └── views/
│   │   │       └── cart_view.dart         # Halaman daftar keranjang belanja
│   │   └── profile/
│   │       └── views/
│   │           └── profile_view.dart      # Halaman profil, kesan & pesan (Tab 2)
│   ├── routes/
│   │   └── app_routes.dart                # Definisi rute navigasi aplikasi
│   └── theme/
│       └── app_theme.dart                 # Konfigurasi tema global sesuai design spec
├── main.dart                              # Inisialisasi Hive, Session, & Entry point
└── test/
    └── app_unit_test.dart                 # Unit testing model, session, & business logic
```

---

## 🛠️ Dependensi & Teknologi

| Paket | Versi | Fungsi |
|---|---|---|
| [flutter](https://flutter.dev) | SDK | Framework utama |
| [get](https://pub.dev/packages/get) | `^4.7.3` | Manajemen status (State Management) & Rute navigasi |
| [http](https://pub.dev/packages/http) | `^1.6.0` | HTTP Client untuk mengambil data dari DummyJSON API |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | `^2.5.6` | Penyimpanan sesi login pengguna lokal |
| [hive](https://pub.dev/packages/hive) | `^2.2.3` | Database NoSQL lokal berkecepatan tinggi |
| [hive_flutter](https://pub.dev/packages/hive_flutter) | `^1.1.0` | Ekstensi Flutter untuk inisialisasi Hive |

---

## 💻 Cara Menjalankan Proyek

1. **Pastikan Flutter SDK terpasang**:
   ```bash
   flutter --version
   ```

2. **Unduh dependensi proyek**:
   ```bash
   flutter pub get
   ```

3. **Jalankan pengujian (Unit Tests)**:
   ```bash
   flutter test
   ```

4. **Jalankan aplikasi**:
   ```bash
   flutter run
   ```

---

## 📝 Catatan Pengumpulan
- Sesuai instruksi tugas, repositori GitHub wajib diberi nama dengan format `nim_latres_D`.
- Pengumpulan menggunakan link repositori GitHub (bukan file `.zip`).
