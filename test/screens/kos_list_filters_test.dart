import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/kos_list_provider.dart';
import 'package:kosfinder/repositories/kos_list_repository.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';

class FakeKosListRepository implements KosListRepository {
  FakeKosListRepository(this.items);

  final List<KosListItem> items;

  @override
  Future<List<KosListItem>> fetchActiveKos() async => items;
}

void main() {
  testWidgets('checkbox and price range filters combine on the kos list', (
    WidgetTester tester,
  ) async {
    final provider = KosListProvider(
      FakeKosListRepository(const [
        KosListItem(
          id: '1',
          name: 'Kos A',
          address: 'Area A',
          monthlyPrice: 800000,
          isActive: true,
          facilities: ['WiFi'],
        ),
        KosListItem(
          id: '2',
          name: 'Kos B',
          address: 'Area B',
          monthlyPrice: 1000000,
          isActive: true,
          facilities: ['WiFi', 'AC'],
        ),
        KosListItem(
          id: '3',
          name: 'Kos C',
          address: 'Area C',
          monthlyPrice: 1500000,
          isActive: true,
          facilities: ['AC'],
        ),
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: KosListScreen(provider: provider, loadKos: (_) async => null),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filter harga dan fasilitas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('facility-WiFi')));
    await tester.tap(find.byKey(const ValueKey('facility-AC')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('min-price-filter')),
      '900000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('max-price-filter')),
      '1100000',
    );
    await tester.ensureVisible(find.text('Terapkan harga'));
    await tester.tap(find.text('Terapkan harga'));
    await tester.pumpAndSettle();

    expect(provider.items.map((item) => item.id), ['2']);
    expect(find.text('Kos B'), findsOneWidget);
    expect(find.text('Kos A'), findsNothing);
    expect(find.text('Kos C'), findsNothing);
  });

  testWidgets('invalid price range is rejected without changing results', (
    WidgetTester tester,
  ) async {
    final provider = KosListProvider(
      FakeKosListRepository(const [
        KosListItem(
          id: '1',
          name: 'Kos A',
          address: 'Area A',
          monthlyPrice: 1000000,
          isActive: true,
          facilities: ['WiFi'],
        ),
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: KosListScreen(provider: provider, loadKos: (_) async => null),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filter harga dan fasilitas'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('min-price-filter')),
      '1200000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('max-price-filter')),
      '900000',
    );
    await tester.ensureVisible(find.text('Terapkan harga'));
    await tester.tap(find.text('Terapkan harga'));
    await tester.pumpAndSettle();

    expect(
      find.text('Harga minimum tidak boleh melebihi maksimum.'),
      findsOneWidget,
    );
    expect(provider.items.map((item) => item.id), ['1']);
  });
}
