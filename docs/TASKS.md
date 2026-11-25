# Daftar Task KosFinder

Status: `BELUM DIMULAI`.

## Slice 1 - Daftar dan Detail Kos

| ID | Tujuan | Story dan AC terkait | File yang boleh diubah | Cara menguji | Status |
|---|---|---|---|---|---|
| T01 | Menyiapkan struktur Flutter sesuai pola Screen-Provider-Repository-Supabase, konfigurasi `--dart-define`, tema dasar, navigasi, dan halaman About dengan identitas yang diminta | US01-AC3; US02-AC3; US03-AC3 | `pubspec.yaml`, `lib/main.dart`, `lib/app/**`, `lib/core/**`, `test/app_test.dart` | Jalankan dengan URL dan anon key Supabase valid melalui `--dart-define`; aplikasi terbuka, About menampilkan `2415051028 - Jaysen Natanael Kartiko`, dan kegagalan konfigurasi menampilkan pesan yang jelas | BELUM DIMULAI |
| T02 | Menambah model kos dan tipe kamar serta repository baca data aktif dari Supabase untuk digunakan provider | US02-AC1, US02-AC2, US03-AC1, US03-AC2 | `lib/data/**`, `lib/models/**`, `test/data/**` | Jalankan `flutter test`; uji pemetaan data aktif/nonaktif, data kosong, dan kegagalan repository | BELUM DIMULAI |
| T03 | Membuat provider daftar kos beserta state loading, data kosong, galat, dan aksi coba lagi | US02-AC1, US02-AC2, US02-AC3 | `lib/providers/**`, `lib/repositories/**`, `test/providers/**` | Uji provider untuk hasil, kosong, dan jaringan gagal; jalankan aplikasi untuk melihat state yang sesuai | BELUM DIMULAI |
| T04 | Membuat layar daftar kos yang menampilkan nama, harga rupiah, alamat ringkas, dan status aktif; tiap item menuju detail | US02-AC1, US02-AC2, US02-AC3, US03-AC1 | `lib/screens/**`, `lib/widgets/**`, `test/widget_test.dart` | Jalankan aplikasi pada Android; uji daftar berisi, daftar kosong, koneksi gagal, lalu buka satu detail kos | BELUM DIMULAI |
| T05 | Membuat layar detail kos beserta nama, alamat, telepon, harga, deskripsi, fasilitas, tipe kamar, status, dan penanganan kos tidak tersedia | US03-AC1, US03-AC2, US03-AC3 | `lib/screens/**`, `lib/widgets/**`, `lib/providers/**`, `test/screens/**` | Jalankan aplikasi; uji kos aktif, kos tersembunyi/tautan tidak tersedia, dan kegagalan koneksi dengan tombol coba lagi | BELUM DIMULAI |

**Hasil Slice 1:** aplikasi Android dapat dijalankan, menampilkan layar utama, daftar kos aktif, state kosong/gagal, dan detail kos yang dipilih.

## Slice 2 - Pencarian dan Filter

| ID | Tujuan | Story dan AC terkait | File yang boleh diubah | Cara menguji | Status |
|---|---|---|---|---|---|
| T06 | Menambah pencarian nama dan alamat/area pada repository serta provider | US02-AC1, US02-AC2 | `lib/repositories/**`, `lib/providers/**`, `lib/models/**`, `test/**` | Uji pencarian nama yang cocok, area/alamat yang cocok, kata tidak cocok, dan hasil kosong | BELUM DIMULAI |
| T07 | Menambah checkbox fasilitas dan filter rentang atau batas harga pada layar daftar | US02-AC1, US02-AC2 | `lib/screens/**`, `lib/widgets/**`, `lib/providers/**`, `test/**` | Pilih satu/lebih fasilitas, batasi harga, gabungkan filter, lalu pastikan hasil dan pesan kosong akurat | BELUM DIMULAI |
| T08 | Menambah pengurutan harga termurah dan terbaru pada provider/repository | US02-AC1 | `lib/repositories/**`, `lib/providers/**`, `lib/screens/**`, `test/**` | Uji urutan dua kos termurah dan dua kos terbaru; pastikan urutan harga berganti benar | BELUM DIMULAI |
| T09 | Menyempurnakan state pencarian: input, reset, kosong, loading, dan kegagalan koneksi | US02-AC2, US02-AC3 | `lib/screens/**`, `lib/widgets/**`, `lib/providers/**`, `test/**` | Jalankan setiap state pada perangkat; uji reset mengembalikan filter, klik coba lagi memuat ulang data | BELUM DIMULAI |

**Hasil Slice 2:** aplikasi Android dapat dijalankan untuk mencari nama/area, memfilter fasilitas dan harga, mengurutkan hasil, serta menangani data kosong dan jaringan gagal.

## Slice 3 - Login Pemilik

| ID | Tujuan | Story dan AC terkait | File yang boleh diubah | Cara menguji | Status |
|---|---|---|---|---|---|
| T10 | Menambahkan provider autentikasi dan layar login/registrasi email-password dengan validasi kolom kosong | US01-AC1, US01-AC2, US01-AC3 | `lib/providers/**`, `lib/repositories/**`, `lib/screens/**`, `lib/widgets/**`, `test/**`, `pubspec.yaml` | Uji registrasi/login valid, kolom kosong, akun salah, dan kegagalan koneksi; email tidak boleh mewajibkan verifikasi | BELUM DIMULAI |
| T11 | Menambahkan login Google dan pemulihan sesi saat aplikasi dibuka kembali | US01-AC1, US01-AC3 | `lib/providers/**`, `lib/repositories/**`, `lib/screens/**`, `test/**`, `pubspec.yaml`, konfigurasi Android yang dibutuhkan | Uji Google sukses/gagal pada Android, sesi tersimpan, aplikasi terbuka kembali sebagai pengguna login, dan logout menghapus sesi | BELUM DIMULAI |
| T12 | Menambah halaman Profil/Pemilik, logout, navigasi daftar kos milik pengguna, dan halaman About | US01-AC1, US01-AC3 | `lib/screens/**`, `lib/widgets/**`, `lib/providers/**`, `test/**` | Uji logout, sesi hilang, profil terbuka, dan navigasi kembali ke daftar/daftar milik pemilik | BELUM DIMULAI |

**Hasil Slice 3:** aplikasi Android dapat dijalankan dengan registrasi/login email-password atau Google, pemulihan sesi, logout, dan profil pemilik.

## Slice 4 - CRUD Kos Milik Sendiri

| ID | Tujuan | Story dan AC terkait | File yang boleh diubah | Cara menguji | Status |
|---|---|---|---|---|---|
| T13 | Membuat halaman daftar kos milik pemilik dan repository baca kos miliknya | US05-AC1 | `lib/screens/**`, `lib/widgets/**`, `lib/providers/**`, `lib/repositories/**`, `test/**` | Uji pemilik A melihat hanya kos miliknya, pemilik B tidak melihat kos milik A dalam daftar miliknya, dan data kosong ditangani | BELUM DIMULAI |
| T14 | Menambahkan form tambah kos dengan nama, alamat <=256, telepon 08xxxxx <=12 digit, harga angka, deskripsi <=1024, fasilitas checkbox, dan status aktif awal | US04-AC1, US04-AC2, US04-AC3 | `lib/screens/**`, `lib/widgets/**`, `lib/providers/**`, `lib/repositories/**`, `test/**` | Uji form sukses, kolom kosong, alamat/deskripsi terlalu panjang, telepon salah, harga negatif/bukan angka, dan kegagalan koneksi | BELUM DIMULAI |
| T15 | Menambahkan ubah kos milik sendiri dan menolak perubahan kos milik pengguna lain melalui UI/RLS | US05-AC1, US05-AC2, US05-AC4 | `lib/screens/**`, `lib/widgets/**`, `lib/providers/**`, `lib/repositories/**`, `test/**`, `supabase/migrations/**` | Uji pemilik mengubah kosnya; uji pemilik B mengubah kos A ditolak backend dan pesan tidak memiliki izin tampil | BELUM DIMULAI |
| T16 | Menambahkan penghapusan tersembunyi dengan update `is_active=false` tanpa menghapus relasi | US05-AC3, US05-AC4 | `lib/screens/**`, `lib/widgets/**`, `lib/providers/**`, `lib/repositories/**`, `test/**` | Uji kos tersembunyi hilang dari pencarian tetapi masih utuh di database; uji kegagalan koneksi menjaga tampilan lama | BELUM DIMULAI |

**Hasil Slice 4:** aplikasi Android dapat dijalankan untuk pemilik menambah, mengubah, dan menyembunyikan beberapa kos miliknya sendiri dengan proteksi RLS.

## Slice 5 - Ketersediaan Kamar (Bonus)

| ID | Tujuan | Story dan AC terkait | File yang boleh diubah | Cara menguji | Status |
|---|---|---|---|---|---|
| T17 | Menambahkan tipe kamar dan status tersedia/penuh pada form kos serta data repository | US04-AC1, US05-AC1 | `lib/screens/**`, `lib/widgets/**`, `lib/providers/**`, `lib/repositories/**`, `lib/models/**`, `test/**` | Uji beberapa tipe kamar tersimpan, harga bertipe angka, status hanya `available/full`, dan hasil tampil di detail | BELUM DIMULAI |
| T18 | Menambahkan pembaruan status tersedia/penuh per tipe kamar milik pemilik dan integrasi detail kos | US05-AC1, US05-AC2, US05-AC4, US03-AC1 | `lib/screens/**`, `lib/widgets/**`, `lib/providers/**`, `lib/repositories/**`, `test/**`, `supabase/migrations/**` | Uji pemilik mengubah status miliknya, pemilik lain ditolak RLS, status terbaru tampil di detail, dan kegagalan koneksi tidak dianggap sukses | BELUM DIMULAI |

**Hasil Slice 5:** aplikasi Android dapat dijalankan untuk mengelola beberapa tipe kamar dan status tersedia/penuh per tipe pada kos milik pemilik.
