# AGENTS.md

## Konteks proyek

KosFinder adalah aplikasi pencarian dan pengelolaan kos berbasis Android yang dibangun dengan Flutter dan Supabase. Gunakan dokumen berikut sebagai acuan:

- [docs/PRD.md](docs/PRD.md): kebutuhan produk, pengguna, scope, NFR, dan acceptance criteria.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): arsitektur teknis dan struktur implementasi.
- [docs/TASKS.md](docs/TASKS.md): daftar tugas, urutan kerja, status, dan ID task.

Jika perintah pengguna bertentangan dengan dokumen acuan, perintah tersebut harus dikonfirmasi sebelum pelaksanaan.

## Cara kerja

- Kerjakan satu task per permintaan dan kaitkan perubahan dengan ID task yang relevan.
- Jangan mengubah file di luar batas task yang diberikan.
- Untuk perubahan besar atau lintas beberapa komponen, buat rencana singkat dan dapatkan persetujuan sebelum mengubah kode.
- Pilih solusi paling sederhana yang memenuhi kebutuhan dan acceptance criteria.
- Jangan menambah package atau dependency baru tanpa persetujuan pengguna.
- Jalankan pemeriksaan terkecil yang relevan setelah perubahan; jangan mengasumsikan perubahan berhasil tanpa verifikasi.

## Teknologi

- Flutter untuk aplikasi Android.
- Provider untuk state management.
- Supabase untuk autentikasi, database, storage, dan layanan backend yang diperlukan.

## Keamanan

- Jangan menyimpan API key, password, secret, atau kredensial lain di source code atau repository.
- Gunakan konfigurasi lingkungan yang aman dan pastikan nilai rahasia tidak masuk ke commit.
- Jangan pernah memakai atau mengirim Supabase `service_role` key ke aplikasi Flutter.
- Tegakkan hak akses menggunakan Supabase Row Level Security (RLS) untuk semua operasi yang membutuhkan otorisasi.
- Semua operasi terhadap kos milik pemilik harus memastikan pemilik hanya dapat mengubah atau menghapus kos miliknya sendiri.

## Git

- Satu task menghasilkan satu commit, kecuali pengguna meminta pembagian commit yang berbeda.
- Pesan commit harus menyebut ID task, misalnya `feat(TASK-01): ...` atau format yang konsisten dengan aturan task.
- Jangan commit perubahan yang bukan bagian dari task.

## Definition of Done

- `flutter analyze` berjalan bersih tanpa issue.
- `flutter test` lulus.
- Aplikasi dijalankan dan diuji pada device yang tersedia.
- Laporkan secara jelas bagian yang belum diuji, diblokir, atau belum dapat diverifikasi.

## Informasi identitas aplikasi

- Tampilkan identitas berikut pada halaman About:
  - `241501028 - Jaysen Natanael Kartiko`
