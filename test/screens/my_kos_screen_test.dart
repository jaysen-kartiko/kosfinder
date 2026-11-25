import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/repositories/kos_management_repository.dart';
import 'package:kosfinder/repositories/my_kos_repository.dart';
import 'package:kosfinder/screens/my_kos_screen.dart';

class FakeMyKosRepository implements MyKosRepository {
  FakeMyKosRepository(this.itemsByOwner, {this.error});

  final Map<String, List<Kos>> itemsByOwner;
  Object? error;

  @override
  Future<List<Kos>> fetchOwnedKos(String ownerId) async {
    if (error != null) {
      throw error!;
    }
    return itemsByOwner[ownerId] ?? const [];
  }
}

class FakeKosManagementRepository implements KosManagementRepository {
  Object? hideError;
  final List<String> hiddenKosIds = [];

  @override
  Future<List<KosFacilityOption>> fetchFacilities() async => const [
    KosFacilityOption(id: 'wifi-id', name: 'WiFi'),
  ];

  @override
  Future<void> saveKos({required KosDraft draft, String? kosId}) async {}

  @override
  Future<void> hideKos({
    required String kosId,
    required String ownerId,
  }) async {
    if (hideError case final error?) {
      throw error;
    }
    hiddenKosIds.add(kosId);
  }
}

Kos createKos(String id, String name) {
  return Kos(
    id: id,
    name: name,
    address: 'Area $name',
    phone: '081234567890',
    monthlyPrice: 1250000,
    description: 'Dekat kampus',
    isActive: true,
    createdAt: DateTime.utc(2026, 1, 2),
    facilities: const [],
    roomTypes: const [],
  );
}

void main() {
  testWidgets('screen shows only the requested owner list', (
    WidgetTester tester,
  ) async {
    final repository = FakeMyKosRepository({
      'owner-A': [createKos('kos-A', 'Kos A')],
      'owner-B': [createKos('kos-B', 'Kos B')],
    });
    final managementRepository = FakeKosManagementRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: MyKosScreen(
          ownerId: 'owner-A',
          repository: repository,
          managementRepository: managementRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos A'), findsOneWidget);
    expect(find.text('Area Kos A'), findsOneWidget);
    expect(find.text('Rp1.250.000,- / bulan'), findsOneWidget);
    expect(find.text('Kos B'), findsNothing);
  });

  testWidgets('screen shows an empty state and retries load errors', (
    WidgetTester tester,
  ) async {
    final repository = FakeMyKosRepository(
      const {},
      error: const MyKosRepositoryException('Gagal memuat.'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MyKosScreen(
          ownerId: 'owner-A',
          repository: repository,
          managementRepository: FakeKosManagementRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Gagal memuat.'), findsOneWidget);

    repository.error = null;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada kos milik Anda.'), findsOneWidget);
  });

  testWidgets('hide failure keeps the kos visible and supports retry', (
    WidgetTester tester,
  ) async {
    final items = [createKos('kos-A', 'Kos A')];
    final repository = FakeMyKosRepository({'owner-A': items});
    final managementRepository = FakeKosManagementRepository()
      ..hideError = const KosManagementException(
        'Tidak dapat menyembunyikan kos. Periksa koneksi lalu coba lagi.',
      );

    await tester.pumpWidget(
      MaterialApp(
        home: MyKosScreen(
          ownerId: 'owner-A',
          repository: repository,
          managementRepository: managementRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('kos-actions-kos-A')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sembunyikan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-hide-kos-A')));
    await tester.pumpAndSettle();

    expect(find.text('Kos A'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);
    expect(
      find.text('Tidak dapat menyembunyikan kos. Periksa koneksi lalu coba lagi.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('retry-hide-kos')), findsOneWidget);
    expect(managementRepository.hiddenKosIds, isEmpty);

    managementRepository.hideError = null;
    repository.itemsByOwner['owner-A'] = [
      Kos(
        id: 'kos-A',
        name: 'Kos A',
        address: 'Area Kos A',
        phone: '081234567890',
        monthlyPrice: 1250000,
        description: 'Dekat kampus',
        isActive: false,
        createdAt: DateTime.utc(2026, 1, 2),
        facilities: const [],
        roomTypes: const [],
      ),
    ];

    await tester.tap(find.byKey(const ValueKey('retry-hide-kos')));
    await tester.pumpAndSettle();

    expect(managementRepository.hiddenKosIds, ['kos-A']);
    expect(find.byKey(const ValueKey('kos-action-error')), findsNothing);
    expect(find.text('Nonaktif'), findsOneWidget);
  });

  testWidgets('owner can open edit form from their kos list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MyKosScreen(
          ownerId: 'owner-A',
          repository: FakeMyKosRepository({
            'owner-A': [createKos('kos-A', 'Kos A')],
          }),
          managementRepository: FakeKosManagementRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('kos-actions-kos-A')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ubah'));
    await tester.pumpAndSettle();

    expect(find.text('Ubah Kos'), findsOneWidget);
    expect(find.text('Kos A'), findsOneWidget);
  });

  testWidgets('owner can open add form from their kos list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MyKosScreen(
          ownerId: 'owner-A',
          repository: FakeMyKosRepository(const {}),
          managementRepository: FakeKosManagementRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-kos')));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Kos'), findsOneWidget);
    expect(find.text('WiFi'), findsOneWidget);
  });
}
