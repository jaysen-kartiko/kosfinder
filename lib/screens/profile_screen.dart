import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import '../repositories/kos_management_repository.dart';
import '../repositories/my_kos_repository.dart';
import 'about_screen.dart';
import 'my_kos_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.email,
    required this.ownerId,
    required this.provider,
    required this.myKosRepository,
    required this.kosManagementRepository,
  });

  final String? email;
  final String ownerId;
  final AuthProvider provider;
  final MyKosRepository myKosRepository;
  final KosManagementRepository kosManagementRepository;

  Future<void> _signOut(BuildContext context) async {
    final signedOut = await provider.signOut();
    if (signedOut && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedBuilder(
            animation: provider,
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_outlined, size: 56),
                const SizedBox(height: 12),
                Text(email ?? 'Email tidak tersedia'),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  key: const ValueKey('profile-my-kos'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MyKosScreen(
                          ownerId: ownerId,
                          repository: myKosRepository,
                          managementRepository: kosManagementRepository,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.home_work_outlined),
                  label: const Text('Daftar kos saya'),
                ),
                OutlinedButton.icon(
                  key: const ValueKey('profile-about'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AboutScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Tentang KosFinder'),
                ),
                if (provider.errorMessage case final message?) ...[
                  const SizedBox(height: 12),
                  Text(
                    message,
                    key: const ValueKey('profile-error'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('profile-retry-signout'),
                    onPressed: provider.isLoading
                        ? null
                        : () => _signOut(context),
                    child: const Text('Coba lagi'),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  key: const ValueKey('profile-signout'),
                  onPressed: provider.isLoading
                      ? null
                      : () => _signOut(context),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Keluar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
