# Arsitektur KosFinder - Versi 1

## 1. Komponen aplikasi

Aplikasi menggunakan pola **Screen - Provider - Repository - Supabase** agar kode sederhana dan dependency terarah.

| Komponen | Tugas | Story |
|---|---|---|
| **Screen** | Menampilkan UI Flutter, validasi input dasar, loading, data kosong, dan pesan koneksi gagal | US01-US05 |
| **Provider** | Menyimpan state layar, memanggil repository, dan memberi tahu UI hasil operasi | US01-US05 |
| **Repository** | Satu pintu untuk query/mutation Supabase, pemetaan model, dan aturan alur data | US01-US05 |
| **Supabase Auth** | Registrasi/login email-password dan Google, sesi pengguna, serta identitas `auth.uid()` | US01 |
| **Supabase Database** | Menyimpan profil, kos, fasilitas, tipe kamar, dan status ketersediaan | US02-US05 |
| **Row Level Security (RLS)** | Membatasi bacaan dan mencegah pemilik mengubah kos milik pengguna lain | US03-US05 |

**Alur data:** Screen -> Provider -> Repository -> Supabase. Provider hanya menerima model/hasil dan tidak membentuk query SQL. Pemetaan data database ke model Dart dilakukan Repository.

## 2. Layar dan navigasi

| Screen | Fungsi | Story |
|---|---|---|
| Login/Register | Masuk atau daftar email-password atau Google | US01 |
| Daftar Kos | Daftar kos aktif, pencarian nama/area, filter harga/fasilitas, serta urut termurah/terbaru | US02 |
| Detail Kos | Nama, alamat, telepon, harga, deskripsi, fasilitas, tipe kamar, dan status | US03 |
| Profil/Pemilik | Logout dan navigasi ke daftar kos milik pengguna | US01, US05 |
| Form Kos | Tambah atau ubah nama, alamat, telepon, harga, deskripsi, fasilitas, dan tipe kamar | US04, US05 |
| About | Menampilkan `241501028 - Jaysen Natanael Kartiko` | Tidak terkait story fungsional |

**Navigasi dasar:**
1. Pengguna mulai di Login/Register bila sesi belum ada.
2. Setelah login, pengguna membuka Daftar Kos.
3. Daftar Kos -> Detail Kos atau Profil.
4. Profil -> Daftar Kos Milik Saya -> Form Kos untuk tambah/ubah.
5. Penghapusan dilakukan sebagai penetapan `status aktif=false`/kos tersembunyi, tanpa menghapus row.
6. Satu kos dapat muncul beberapa tipe kamar dan pemilik dapat mengelola beberapa kos.

## 3. Rencana database dan hak akses

### Tabel minimum

| Tabel | Kolom utama |
|---|---|
| `profiles` | `id uuid` relasi ke `auth.users(id)`, `role` teks, `created_at timestamptz` |
| `kos` | `id uuid`, `owner_id uuid`, `name text`, `address text <=256`, `phone text <=12 angka`, `monthly_price numeric(12,2)`, `description text <=1024`, `is_active boolean`, `created_at timestamptz`, `updated_at timestamptz` |
| `facilities` | `id uuid`, `name text` |
| `kos_facilities` | `kos_id uuid`, `facility_id uuid` sebagai pasangan unik |
| `room_types` | `id uuid`, `kos_id uuid`, `name text`, `monthly_price numeric(12,2)`, `status text` bernilai `available` atau `full` |

Relasi: `profiles.id -> auth.users.id`, `kos.owner_id -> profiles.id`, `kos_facilities.kos_id -> kos.id`, `kos_facilities.facility_id -> facilities.id`, dan `room_types.kos_id -> kos.id`.

Kolom harga kos dan tipe kamar menggunakan tipe angka Supabase `numeric`, bukan teks. Format tampil memakai `Rp10.000,-`; data input disimpan sebagai angka.

### Aturan akses

| Operasi | Pencari login | Pemilik |
|---|---|---|
| Melihat kos aktif dan tipe kamar aktif | Ya | Ya |
| Menambah kos | Tidak | Ya, dengan `owner_id = auth.uid()` |
| Mengubah kos | Tidak | Hanya row `kos.owner_id = auth.uid()` |
| Mengubah status/tipe kamar kos | Tidak | Hanya kos miliknya |
| Menghapus tersembunyi kos | Tidak | Hanya kos miliknya; update `is_active=false` |
| Melihat fasilitas | Ya | Ya |

RLS mengaktifkan `SELECT` pada kos aktif, `INSERT` pada kos milik pengguna, serta `UPDATE` berdasarkan `owner_id`. Penghapusan permanen tidak disediakan; `DELETE` tidak diperlukan pada tabel kos versi 1. RLS tabel fasilitas dan `kos_facilities` disesuaikan dengan kepemilikan kos; tabel master fasilitas boleh dibaca pengguna login dan tidak dapat diubah pengguna biasa.

## 4. Konfigurasi Supabase

URL proyek dan anon key dibaca melalui `String.fromEnvironment` pada `--dart-define`:

```text
--dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

Nilai tidak ditulis di source atau commit. Anon key dapat dikirim ke aplikasi, tetapi `service_role` key tidak pernah dipakai atau disertakan. Konfigurasi Google OAuth dilakukan pada Supabase dan konsol Android; redirect/deep link ditambahkan hanya bila Google Sign-In native membutuhkannya.

## 5. Cara rilis

1. Atur konfigurasi Supabase dengan `--dart-define`.
2. Pastikan `flutter analyze` bersih dan `flutter test` lulus.
3. Bangun APK rilis: `flutter build apk --release --dart-define=...`
4. Uji APK pada Android 8.0 dan perangkat Android yang tersedia.
5. Buat GitHub Release pada repository, lampirkan APK rilis dan catatan versi singkat.

Android 8.0 menjadi minimum target pengujian. GitHub Release hanya menyertakan APK dan informasi rilis, bukan anon key atau credential.

## 6. Package

| Package | Alasan sederhana | Story |
|---|---|---|
| `provider` | State management resmi yang dipakai pola Provider dan kebutuhan state versi 1 masih sederhana | US01-US05 |
| `supabase_flutter` | Autentikasi, database, dan sesi Supabase dengan satu client resmi | US01-US05 |
| `google_sign_in` | Mendukung login Google native pada Android melalui Supabase Auth | US01 |
| `flutter_test` (dev) | Menguji unit/provider/repository minimal yang tersedia dari Flutter SDK | US01-US05 |

Tidak ada package map, chat, media, rekomendasi, atau state management tambahan pada versi 1.
