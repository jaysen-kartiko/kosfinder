class AppConfig {
  const AppConfig({required this.supabaseUrl, required this.supabaseAnonKey});

  const AppConfig.fromEnvironment()
    : supabaseUrl = const String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

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
