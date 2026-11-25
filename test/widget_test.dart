// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/models/room_type.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/providers/kos_list_provider.dart';
import 'package:kosfinder/repositories/kos_list_repository.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';

class FakeKosListRepository implements KosListRepository {
  FakeKosListRepository({this.items = const [], this.error});

  List<KosListItem> items;
  Object? error;

  @override
  Future<List<KosListItem>> fetchActiveKos() async {
    if (error != null) {
      throw error!;
    }
    return items;
  }
}

Kos createKos() {
  return Kos(
    id: 'kos-1',
    name: 'Kos Mawar',
    address: 'Jl. Kampus 1',
    phone: '081234567890',
    monthlyPrice: 1250000,
    description: 'Dekat kampus',
    isActive: true,
    createdAt: DateTime.utc(2026, 1, 2),
    facilities: const ['WiFi', 'AC'],
    roomTypes: const [
      RoomType(
        id: 'room-1',
        name: 'Tipe standar',
        monthlyPrice: 1250000,
        status: 'available',
      ),
    ],
  );
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('daftar menampilkan kos aktif dan membuka detail', (
    WidgetTester tester,
  ) async {
    final repository = FakeKosListRepository(
      items: const [
        KosListItem(
          id: 'kos-1',
          name: 'Kos Mawar',
          address: 'Jl. Kampus 1',
          monthlyPrice: 1250000,
          isActive: true,
        ),
      ],
    );
    final provider = KosListProvider(repository);

    await tester.pumpWidget(
      MaterialApp(
        home: KosListScreen(
          provider: provider,
          loadKos: (_) async => createKos(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos Mawar'), findsOneWidget);
    expect(find.text('Jl. Kampus 1'), findsOneWidget);
    expect(find.text('Rp1.250.000,- / bulan'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('kos-kos-1')));
    await tester.pumpAndSettle();

    expect(find.text('Detail Kos'), findsOneWidget);
    expect(find.text('081234567890'), findsOneWidget);
    expect(find.text('Dekat kampus'), findsOneWidget);
    expect(find.text('WiFi, AC'), findsOneWidget);
    expect(find.text('Tersedia'), findsOneWidget);
  });

  testWidgets('daftar kosong menampilkan pesan kosong', (
    WidgetTester tester,
  ) async {
    final provider = KosListProvider(FakeKosListRepository());

    await tester.pumpWidget(
      MaterialApp(
        home: KosListScreen(provider: provider, loadKos: (_) async => null),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada kos yang tersedia.'), findsOneWidget);
  });

  testWidgets('kegagalan koneksi menampilkan retry dan memuat ulang', (
    WidgetTester tester,
  ) async {
    final repository = FakeKosListRepository(error: Exception('offline'));
    final provider = KosListProvider(repository);

    await tester.pumpWidget(
      MaterialApp(
        home: KosListScreen(provider: provider, loadKos: (_) async => null),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Tidak dapat memuat daftar kos. '
        'Periksa koneksi lalu coba lagi.',
      ),
      findsOneWidget,
    );

    repository
      ..error = null
      ..items = const [
        KosListItem(
          id: 'kos-2',
          name: 'Kos Melati',
          address: 'Area kampus',
          monthlyPrice: 900000,
          isActive: true,
        ),
      ];

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Kos Melati'), findsOneWidget);
  });
}
