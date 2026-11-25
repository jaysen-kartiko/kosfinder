# KosFinder

Aplikasi Flutter untuk pencarian dan pengelolaan kos dengan Supabase.

## Cara menjalankan

Berikan URL proyek Supabase dan anon key saat menjalankan aplikasi menggunakan
`--dart-define`. Contoh berikut memakai nilai palsu; ganti dengan nilai proyek
Anda sendiri:

```powershell
flutter run --dart-define=SUPABASE_URL=supabase-url --dart-define=SUPABASE_ANON_KEY=publishable-key
```

Nilai tersebut dibaca saat build dan tidak disimpan di source code. Jangan
gunakan Supabase `service_role` key pada aplikasi.
