import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_list_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_management_repository.dart';
import 'package:kosfinder/repositories/kos_list_repository.dart';
import 'package:kosfinder/repositories/my_kos_repository.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';
import 'package:kosfinder/screens/profile_screen.dart';

class FakeKosListRepository implements KosListRepository {
  @override
  Future<List<KosListItem>> fetchActiveKos() async => const [];
}

class FakeAuthRepository implements AuthRepository {
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
  Future<void> signOut() async {}
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
  testWidgets('list opens profile and back returns to the list', (
    WidgetTester tester,
  ) async {
    final authProvider = AuthProvider(FakeAuthRepository());
    final kosProvider = KosListProvider(FakeKosListRepository());

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => KosListScreen(
            provider: kosProvider,
            loadKos: (_) async => null,
            onProfile: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProfileScreen(
                    email: 'user@example.com',
                    ownerId: 'owner-A',
                    provider: authProvider,
                    myKosRepository: FakeMyKosRepository(),
                    kosManagementRepository: FakeKosManagementRepository(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('open-profile')));
    await tester.pumpAndSettle();
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Kos'), findsOneWidget);

    authProvider.dispose();
    kosProvider.dispose();
  });
}
