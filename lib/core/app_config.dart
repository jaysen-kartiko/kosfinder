import 'package:flutter/services.dart';

class AppConfig {
  const AppConfig({required this.supabaseUrl, required this.supabaseAnonKey});

  /// Memuat konfigurasi dari asset `.env` di root proyek.
  /// Format setiap baris: KEY=VALUE. Baris kosong dan diawali `#` diabaikan.
  /// Fallback ke `--dart-define` jika nilai tidak ditemukan di file.
  static Future<AppConfig> load() async {
    String supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    String supabaseAnonKey =
        const String.fromEnvironment('SUPABASE_ANON_KEY');

    try {
      final raw = await rootBundle.loadString('.env');
      for (final line in raw.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final idx = trimmed.indexOf('=');
        if (idx < 1) continue;
        final key = trimmed.substring(0, idx).trim();
        final value = trimmed.substring(idx + 1).trim();
        if (key == 'SUPABASE_URL' && value.isNotEmpty) {
          supabaseUrl = value;
        } else if (key == 'SUPABASE_ANON_KEY' && value.isNotEmpty) {
          supabaseAnonKey = value;
        }
      }
    } catch (_) {
      // .env tidak tersedia sebagai asset — gunakan nilai --dart-define.
    }

    return AppConfig(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );
  }

  final String supabaseUrl;
  final String supabaseAnonKey;

  bool get isValid =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  String get validationMessage {
    if (supabaseUrl.trim().isEmpty) {
      return 'Konfigurasi Supabase URL belum disediakan.';
    }
    if (supabaseAnonKey.trim().isEmpty) {
      return 'Konfigurasi Supabase anon key belum disediakan.';
    }
    return '';
  }
}
