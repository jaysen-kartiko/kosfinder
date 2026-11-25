import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/app.dart';
import '../core/app_config.dart';
import '../data/supabase_kos_repository.dart';
import '../data/supabase_kos_rows_source.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_list_provider.dart';
import '../repositories/kos_management_repository.dart';
import '../repositories/my_kos_repository.dart';
import '../repositories/auth_repository.dart';
import 'auth_session_gate.dart';
import 'auth_screen.dart';
import 'kos_list_screen.dart';
import 'profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await AppConfig.load();

  if (!config.isValid) {
    runApp(KosFinderConfigErrorApp(message: config.validationMessage));
    return;
  }

  try {
    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabaseAnonKey,
    );
    final client = Supabase.instance.client;
    final repository = SupabaseKosRepository(SupabaseKosRowsSource(client));
    final myKosRepository = SupabaseMyKosRepository(
      SupabaseMyKosRowsSource(client),
    );
    final kosManagementRepository = SupabaseKosManagementRepository(
      SupabaseKosManagementRowsSource(client),
    );
    runApp(
      MaterialApp(
        title: 'KosFinder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: _AuthGate(
          client: client,
          authRepository: SupabaseAuthRepository(client),
          kosRepository: repository,
          myKosRepository: myKosRepository,
          kosManagementRepository: kosManagementRepository,
        ),
      ),
    );
  } catch (_) {
    runApp(
      const KosFinderConfigErrorApp(
        message: 'Tidak dapat terhubung ke Supabase. Periksa URL, anon key, dan koneksi lalu jalankan ulang aplikasi.',
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({
    required this.client,
    required this.authRepository,
    required this.kosRepository,
    required this.myKosRepository,
    required this.kosManagementRepository,
  });

  final SupabaseClient client;
  final AuthRepository authRepository;
  final SupabaseKosRepository kosRepository;
  final MyKosRepository myKosRepository;
  final KosManagementRepository kosManagementRepository;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final AuthProvider _authProvider = AuthProvider(widget.authRepository);
  late final KosListProvider _kosListProvider = KosListProvider(
    widget.kosRepository,
  );

  @override
  void dispose() {
    _authProvider.dispose();
    _kosListProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthSessionGate(
      initiallyAuthenticated: widget.client.auth.currentSession != null,
      sessionChanges: widget.client.auth.onAuthStateChange.map(
        (state) => state.session != null,
      ),
      authenticatedBuilder: (context) => KosListScreen(
        provider: _kosListProvider,
        loadKos: widget.kosRepository.fetchActiveKosById,
        onProfile: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProfileScreen(
                email: widget.client.auth.currentUser?.email,
                ownerId: widget.client.auth.currentSession?.user.id ?? '',
                provider: _authProvider,
                myKosRepository: widget.myKosRepository,
                kosManagementRepository: widget.kosManagementRepository,
              ),
            ),
          );
          if (mounted) {
            await _kosListProvider.load();
          }
        },
      ),
      unauthenticatedBuilder: (context, onAuthenticated) =>
          AuthScreen(provider: _authProvider, onAuthenticated: onAuthenticated),
    );
  }
}
