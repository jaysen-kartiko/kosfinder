import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_management_repository.dart';
import 'package:kosfinder/repositories/my_kos_repository.dart';
import 'package:kosfinder/screens/profile_screen.dart';

class FakeAuthRepository implements AuthRepository {
  Object? signOutError;
  int signOutCalls = 0;

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (signOutError case final error?) {
      throw error;
    }
  }
}

class FakeMyKosRepository implements MyKosRepository {
  @override
  Future<List<Kos>> fetchOwnedKos(String ownerId) async => const [];
}

class FakeKosManagementRepository implements KosManagementRepository {
  @override
  Future<List<KosFacilityOption>> fetchFacilities() async => const [];

  @override
  Future<void> saveKos({required KosDraft draft, String? kosId}) async {}

  @override
  Future<void> hideKos({
    required String kosId,
    required String ownerId,
  }) async {}
}

void main() {
  testWidgets('profile shows email and logs out', (WidgetTester tester) async {
    final repository = FakeAuthRepository();
    final provider = AuthProvider(repository);

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          email: 'user@example.com',
          ownerId: 'owner-A',
          provider: provider,
          myKosRepository: FakeMyKosRepository(),
          kosManagementRepository: FakeKosManagementRepository(),
        ),
      ),
    );

    expect(find.text('user@example.com'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('profile-signout')));
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 1);
    expect(provider.status, AuthStatus.idle);

    provider.dispose();
  });

  testWidgets('profile navigates to my kos and About then returns', (
    WidgetTester tester,
  ) async {
    final provider = AuthProvider(FakeAuthRepository());
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          email: 'user@example.com',
          ownerId: 'owner-A',
          provider: provider,
          myKosRepository: FakeMyKosRepository(),
          kosManagementRepository: FakeKosManagementRepository(),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('profile-my-kos')));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Kos Saya'), findsOneWidget);
    expect(find.text('Belum ada kos milik Anda.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Profil'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile-about')));
    await tester.pumpAndSettle();
    expect(find.text('About'), findsOneWidget);
    expect(find.text('241501028 - Jaysen Natanael Kartiko'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Profil'), findsOneWidget);

    provider.dispose();
  });

  testWidgets('sign-out failure offers a retry', (WidgetTester tester) async {
    final repository = FakeAuthRepository()
      ..signOutError = const AuthFailure.connection();
    final provider = AuthProvider(repository);

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          email: 'user@example.com',
          ownerId: 'owner-A',
          provider: provider,
          myKosRepository: FakeMyKosRepository(),
          kosManagementRepository: FakeKosManagementRepository(),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('profile-signout')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Tidak dapat terhubung ke server. '
        'Periksa koneksi lalu coba lagi.',
      ),
      findsOneWidget,
    );

    repository.signOutError = null;
    await tester.tap(find.byKey(const ValueKey('profile-retry-signout')));
    await tester.pumpAndSettle();
    expect(repository.signOutCalls, 2);

    provider.dispose();
  });
}
