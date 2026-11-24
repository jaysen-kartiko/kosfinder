# PRD KosFinder - Versi 1

## 1. Masalah dan tujuan yang dapat diukur

Informasi kos tersebar di media sosial, WhatsApp, dan mulut ke mulut, sehingga pencari sulit membandingkan harga dan fasilitas, sedangkan pemilik sulit memperbarui ketersediaan kamar.

**Tujuan:** menyediakan satu aplikasi Android untuk pencarian dan pengelolaan kos secara sederhana.

**Ukuran keberhasilan versi 1:**
- Pencari dapat membuat akun, masuk, mencari, menyaring, dan membuka detail kos.
- Pemilik dapat membuat, mengubah, menghapus tersembunyi, dan melihat daftar kos miliknya sendiri.
- Perubahan status tersedia/penuh dapat dilihat pada hasil pencarian dan detail.
- 95% alur utama dapat diselesaikan tanpa bantuan saat pengujian di Android versi yang didukung.

## 2. Pengguna

- **Pencari kos:** mahasiswa atau masyarakat yang mencari kos di sekitar kampus atau area mana pun. Harus memiliki akun untuk menggunakan aplikasi.
- **Pemilik kos:** pengguna terdaftar yang mempublikasikan dan mengelola kos miliknya. Tidak ada admin atau proses persetujuan kos pada versi 1.

## 3. Scope versi 1

**Masuk:**
- Registrasi dan login pencari/pemilik dengan email dan kata sandi atau akun Google; verifikasi email tidak wajib.
- Logout.
- Pencari melihat daftar, mencari berdasarkan area, menyaring berdasarkan harga dan fasilitas, mengurutkan hasil bila tersedia, dan membuka detail.
- Pemilik menambah kos dengan nama, alamat, kontak telepon, harga bulanan dalam rupiah, deskripsi, dan data fasilitas bila diputuskan.
- Pemilik mengubah atau menghapus tersembunyi kos miliknya; daftar aplikasi hanya menampilkan kos yang belum dihapus tersembunyi.
- Pemilik mengubah status kos menjadi tersedia atau penuh.

**Tidak masuk:**
- Pembayaran online, chat, ulasan/rating, rekomendasi AI, verifikasi identitas pemilik, upload foto, peta, dan dashboard admin.
- Penghapusan permanen atau proses persetujuan kos oleh admin.

## 4. NFR (kriteria uji)

- **Keamanan:** akses kos milik pengguna dilindungi sesi Supabase dan aturan izin backend; endpoint atau tindakan lain tidak boleh mengubah kos milik pengguna lain.
- **Keandalan:** kegagalan jaringan menampilkan pesan yang dapat dimengerti dan opsi coba lagi; data tidak boleh dianggap tersimpan bila operasi backend gagal.
- **Kemudahan pakai:** seluruh alur utama dapat diselesaikan pada Android dari halaman utama dalam maksimal lima tindakan, dengan pesan galat dekat bidang bermasalah.
- **Performa:** daftar awal dan pencarian sederhana menampilkan hasil atau pesan kegagalan dalam 3 detik pada koneksi normal.
- **Privasi:** kata sandi tidak ditampilkan atau disimpan di aplikasi; telepon pemilik hanya ditampilkan pada detail kos kepada pengguna login.
- **Kompatibilitas:** mendukung Android terbaru sebagai target dan Android 8.0 atau lebih baru sebagai minimum, kecuali kebijakan Flutter/Supabase membatasi versi tersebut.

## 5. User stories

### US01 - Registrasi dan login
**Sebagai** pencari atau pemilik, saya ingin mendaftar dan masuk dengan email/kata sandi atau akun Google, agar dapat memakai aplikasi sesuai peran saya.

- **US01-AC1 — registrasi berhasil:** Given pengguna belum login dan memasukkan data registrasi valid, When pengguna memilih daftar, Then akun dibuat dan pengguna masuk tanpa proses verifikasi email.
- **US01-AC2 — data kosong:** Given pengguna membuka formulir registrasi atau login, When pengguna mengirim dengan kolom wajib kosong, Then formulir menolak pengiriman dan menampilkan galat pada kolom terkait.
- **US01-AC3 — koneksi gagal:** Given pengguna mengirim registrasi atau login dengan Supabase tidak dapat dijangkau, When permintaan gagal, Then pengguna melihat pesan kegagalan dan dapat mencoba lagi tanpa data palsu tersimpan.

### US02 - Melihat dan mencari kos
**Sebagai** pencari kos, saya ingin melihat daftar kos, mencari berdasarkan area, menyaring harga dan fasilitas, serta mengurutkan hasil, agar dapat membandingkan pilihan.

- **US02-AC1 — hasil ditemukan:** Given pencarian dan penyaring menghasilkan satu atau lebih kos, When pencarian dijalankan, Then daftar menampilkan kos beserta harga, status ketersediaan, dan data dasar.
- **US02-AC2 — data kosong:** Given tidak ada kos yang cocok atau belum ada kos tersimpan, When pencarian dijalankan, Then aplikasi menampilkan pesan kosong dan tidak menampilkan data palsu.
- **US02-AC3 — koneksi gagal:** Given perangkat tidak dapat terhubung ke backend, When pencarian dijalankan, Then aplikasi menampilkan pesan gagal koneksi dan tombol coba lagi.

### US03 - Melihat detail kos
**Sebagai** pencari kos, saya ingin membuka detail kos, agar dapat menilai kos sebelum menghubungi pemilik.

- **US03-AC1 — detail tersedia:** Given pengguna login memilih kos yang aktif, When halaman detail dibuka, Then nama, alamat, telepon, harga bulanan, deskripsi, fasilitas, dan status tersedia/penuh ditampilkan.
- **US03-AC2 — kos tidak tersedia:** Given kos telah dihapus tersembunyi atau tidak lagi dapat diakses, When pengguna membuka tautannya, Then aplikasi menampilkan pesan kos tidak tersedia dan kembali ke daftar.
- **US03-AC3 — koneksi gagal:** Given detail kos belum dimuat dan koneksi gagal, When halaman dibuka, Then pengguna melihat pesan gagal koneksi dan dapat mencoba lagi.

### US04 - Menambah kos
**Sebagai** pemilik, saya ingin menambah kos, agar kos saya dapat dilihat pencari.

- **US04-AC1 — penambahan berhasil:** Given pemilik login memasukkan nama, alamat, telepon, harga bulanan, deskripsi, dan status, When pemilik menyimpan, Then kos tersimpan atas pemilik tersebut dan dapat ditemukan.
- **US04-AC2 — data kosong atau tidak valid:** Given pemilik tidak mengisi kolom wajib atau memasukkan harga tidak valid, When pemilik menyimpan, Then penyimpanan ditolak dan semua bidang bermasalah ditandai.
- **US04-AC3 — koneksi gagal:** Given backend tidak dapat dijangkau saat penyimpanan, When pemilik menyimpan, Then kos tidak ditampilkan sebagai tersimpan dan pengguna dapat mencoba lagi.

### US05 - Mengubah dan menghapus kos
**Sebagai** pemilik, saya ingin mengubah atau menghapus tersembunyi kos milik saya, agar data tetap akurat tanpa merusak relasi.

- **US05-AC1 — pemilik mengubah kos miliknya:** Given pemilik login memiliki kos aktif, When pemilik mengubah data atau status tersedia/penuh lalu menyimpan, Then perubahan tersimpan dan tampil pada detail.
- **US05-AC2 — pemilik mencoba mengubah kos milik orang lain:** Given pemilik mencoba mengakses atau mengirim perubahan untuk kos milik pengguna lain, When permintaan diproses, Then backend menolak permintaan dan aplikasi menampilkan pesan tidak memiliki izin.
- **US05-AC3 — penghapusan tersembunyi:** Given pemilik login memiliki kos aktif, When pemilik menghapus kos, Then kos tidak terlihat pada pencarian tetapi relasi data tetap utuh.
- **US05-AC4 — koneksi gagal:** Given perubahan atau penghapusan gagal dikirim, When permintaan backend gagal, Then aplikasi mempertahankan data lama dan memberi opsi coba lagi.

## Pertanyaan yang masih ambigu

1. Daftar fasilitas kos mana yang boleh dipilih atau dicari, dan apakah fasilitas wajib dicatat saat menambah kos? 
Jawaban: fasilitas kos bisa dicatat ketika menambah kos, bisa difilter (gunakan checkbox untuk fasilitas)
2. Urutan hasil yang tersedia apa saja, misalnya harga termurah atau terbaru; apakah pencarian nama kos termasuk dalam pencarian?
Jawaban: Urutan harga termurah dan terbaru. pencarian nama kos termasuk dalam pencarian.
3. Berapa versi Android minimum yang harus dipastikan, mengingat Android 8.0 hanya dugaan kompatibilitas dan belum disepakati?
Jawaban: jika android 8.0 memang standar android minimum, gunakan itu.
4. Apakah aplikasi sudah boleh memakai Supabase Auth untuk email/kata sandi dan Google pada Android, termasuk nama penyedia dan konfigurasi OAuth?
Jawaban: Bisa
5. Format nilai harga, deskripsi, alamat, dan batas panjang nomor telepon apa yang dianggap valid?
Jawaban: Format nilai harga Rp10.000,- (contoh). Dekripsi batasnya sampai 1024 huruf, alamat sampai 256 huruf, nomor telefon batasnya sampai 12 angka dengan format 08xxxxx
6. Apakah pemilik hanya boleh memiliki satu kos atau beberapa kos, dan apakah satu kos dapat punya beberapa status ketersediaan kamar?
Jawaban: pemilik bisa memiliki beberapa kos, satu kos dapat punya status ketersediaan kamar per tipe kamar
7. Apakah "menghapus tersembunyi" cukup mengubah status menjadi tidak aktif, atau perlu data khusus agar dapat dipulihkan nanti?
Jawaban: status saja.