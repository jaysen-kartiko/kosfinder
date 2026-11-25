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
  testWidgets('sort selection updates the displayed order', (
    WidgetTester tester,
  ) async {
    final provider = KosListProvider(
      FakeKosListRepository(const [
        KosListItem(
          id: 'newest',
          name: 'Kos Terbaru',
          address: 'Area A',
          monthlyPrice: 1500000,
          isActive: true,
        ),
        KosListItem(
          id: 'cheapest',
          name: 'Kos Termurah',
          address: 'Area B',
          monthlyPrice: 800000,
          isActive: true,
        ),
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: KosListScreen(
          provider: provider,
          loadKos: (_) async => null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(provider.items.first.id, 'newest');
    await tester.tap(find.byKey(const ValueKey('kos-sort-order')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Harga termurah').last);
    await tester.pumpAndSettle();

    expect(provider.items.first.id, 'cheapest');
    expect(find.text('Harga termurah'), findsOneWidget);
  });
}
