import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/models/room_type.dart';
import 'package:kosfinder/providers/kos_detail_provider.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';

Kos activeKos() {
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
      RoomType(
        id: 'room-2',
        name: 'Tipe besar',
        monthlyPrice: 1750000,
        status: 'full',
      ),
    ],
  );
}

void main() {
  testWidgets('US03-AC1: detail kos aktif menampilkan informasi lengkap', (
    WidgetTester tester,
  ) async {
    final provider = KosDetailProvider((_) async => activeKos());

    await tester.pumpWidget(
      MaterialApp(
        home: KosDetailScreen(kosId: 'kos-1', provider: provider),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos Mawar'), findsOneWidget);
    expect(find.text('Jl. Kampus 1'), findsOneWidget);
    expect(find.text('081234567890'), findsOneWidget);
    expect(find.text('Rp1.250.000,- / bulan'), findsNWidgets(2));
    expect(find.text('Dekat kampus'), findsOneWidget);
    expect(find.text('WiFi, AC'), findsOneWidget);
    expect(find.text('Tipe standar'), findsOneWidget);
    expect(find.text('Tipe besar'), findsOneWidget);
    expect(find.text('Tersedia'), findsOneWidget);
    expect(find.text('Penuh'), findsOneWidget);
  });

  testWidgets('US03-AC2: kos tidak tersedia dapat kembali ke daftar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => KosDetailScreen(
                      kosId: 'hidden-kos',
                      provider: KosDetailProvider((_) async => null),
                    ),
                  ),
                );
              },
              child: const Text('Daftar kos'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Daftar kos'));
    await tester.pumpAndSettle();

    expect(find.text('Kos tidak tersedia.'), findsOneWidget);

    await tester.tap(find.text('Kembali ke daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Daftar kos'), findsOneWidget);
  });

  testWidgets('US03-AC3: kegagalan koneksi menyediakan retry', (
    WidgetTester tester,
  ) async {
    var shouldFail = true;
    final provider = KosDetailProvider((_) async {
      if (shouldFail) {
        throw Exception('offline');
      }
      return activeKos();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: KosDetailScreen(kosId: 'kos-1', provider: provider),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Gagal memuat detail kos. Periksa koneksi lalu coba lagi.'),
      findsOneWidget,
    );

    shouldFail = false;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Kos Mawar'), findsOneWidget);
  });
}
