import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/repositories/kos_management_repository.dart';
import 'package:kosfinder/screens/kos_form_screen.dart';

class FakeKosManagementRepository implements KosManagementRepository {
  final List<KosFacilityOption> facilities = const [
    KosFacilityOption(id: 'wifi-id', name: 'WiFi'),
    KosFacilityOption(id: 'ac-id', name: 'AC'),
  ];
  Object? fetchError;
  Object? saveError;
  KosDraft? savedDraft;
  String? savedKosId;

  @override
  Future<List<KosFacilityOption>> fetchFacilities() async {
    if (fetchError case final error?) {
      throw error;
    }
    return facilities;
  }

  @override
  Future<void> saveKos({required KosDraft draft, String? kosId}) async {
    if (saveError case final error?) {
      throw error;
    }
    savedDraft = draft;
    savedKosId = kosId;
  }

  @override
  Future<void> hideKos({
    required String kosId,
    required String ownerId,
  }) async {}
}

void main() {
  testWidgets('form shows facility checkboxes and rejects invalid input', (
    WidgetTester tester,
  ) async {
    final repository = FakeKosManagementRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: KosFormScreen(repository: repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tambah Kos'), findsOneWidget);
    expect(find.text('WiFi'), findsOneWidget);
    expect(find.text('AC'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byKey(const ValueKey('kos-active'))).value,
      isTrue,
    );

    await tester.ensureVisible(find.byKey(const ValueKey('kos-save')));
    await tester.tap(find.byKey(const ValueKey('kos-save')));
    await tester.pumpAndSettle();

    expect(find.text('Nama kos wajib diisi.'), findsOneWidget);
    expect(find.text('Gunakan nomor 08 dengan maksimal 12 angka.'), findsOneWidget);
    expect(repository.savedDraft, isNull);
  });

  testWidgets('valid form saves and returns to the previous screen', (
    WidgetTester tester,
  ) async {
    final repository = FakeKosManagementRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                key: const ValueKey('open-form'),
                onPressed: () {
                  Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => KosFormScreen(repository: repository),
                    ),
                  );
                },
                child: const Text('Buka form'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('open-form')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('kos-name')), 'Kos Baru');
    await tester.enterText(
      find.byKey(const ValueKey('kos-address')),
      'Jalan Baru',
    );
    await tester.enterText(
      find.byKey(const ValueKey('kos-phone')),
      '081234567890',
    );
    await tester.enterText(find.byKey(const ValueKey('kos-price')), '1250000');
    await tester.enterText(
      find.byKey(const ValueKey('kos-description')),
      'Dekat kampus',
    );
    await tester.tap(find.byKey(const ValueKey('facility-wifi-id')));
    await tester.ensureVisible(find.byKey(const ValueKey('kos-save')));
    await tester.tap(find.byKey(const ValueKey('kos-save')));
    await tester.pumpAndSettle();

    expect(repository.savedDraft?.name, 'Kos Baru');
    expect(repository.savedDraft?.facilityIds, ['wifi-id']);
    expect(find.text('Buka form'), findsOneWidget);
  });

  testWidgets('edit mode pre-fills data, shows errors, and allows retry', (
    WidgetTester tester,
  ) async {
    final repository = FakeKosManagementRepository()
      ..saveError = const KosManagementException(
        'Anda tidak memiliki izin untuk mengubah kos ini.',
      );
    final existingKos = Kos(
      id: 'kos-1',
      name: 'Kos Lama',
      address: 'Jalan Lama',
      phone: '081234567890',
      monthlyPrice: 1500000,
      description: 'Deskripsi lama',
      isActive: true,
      createdAt: DateTime.utc(2026, 1, 1),
      facilities: const ['AC'],
      roomTypes: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                key: const ValueKey('open-edit-form'),
                onPressed: () {
                  Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => KosFormScreen(
                        repository: repository,
                        kos: existingKos,
                      ),
                    ),
                  );
                },
                child: const Text('Buka edit'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('open-edit-form')));
    await tester.pumpAndSettle();

    expect(find.text('Ubah Kos'), findsOneWidget);
    expect(find.text('Kos Lama'), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(find.byKey(const ValueKey('facility-ac-id')))
          .value,
      isTrue,
    );

    await tester.enterText(
      find.byKey(const ValueKey('kos-name')),
      'Kos Update',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('kos-save')));
    await tester.tap(find.byKey(const ValueKey('kos-save')));
    await tester.pumpAndSettle();

    expect(
      find.text('Anda tidak memiliki izin untuk mengubah kos ini.'),
      findsOneWidget,
    );
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(repository.savedDraft, isNull);

    repository.saveError = null;
    await tester.ensureVisible(find.byKey(const ValueKey('kos-save')));
    await tester.tap(find.byKey(const ValueKey('kos-save')));
    await tester.pumpAndSettle();

    expect(repository.savedKosId, 'kos-1');
    expect(repository.savedDraft?.name, 'Kos Update');
    expect(find.text('Buka edit'), findsOneWidget);
  });
}
