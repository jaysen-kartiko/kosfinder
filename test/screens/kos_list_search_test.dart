import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/kos_list_provider.dart';
import 'package:kosfinder/repositories/kos_list_repository.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';

class FakeKosListRepository implements KosListRepository {
  FakeKosListRepository({
    this.items = const [],
    this.error,
    this.pendingResult,
  });

  List<KosListItem> items;
  Object? error;
  Completer<List<KosListItem>>? pendingResult;
  int fetchCount = 0;

  @override
  Future<List<KosListItem>> fetchActiveKos() {
    fetchCount++;
    if (pendingResult != null) {
      return pendingResult!.future;
    }
    if (error != null) {
      return Future.error(error!);
    }
    return Future.value(items);
  }
}

const sampleKos = [
  KosListItem(
    id: 'mawar',
    name: 'Kos Mawar',
    address: 'Area A',
    monthlyPrice: 1000000,
    isActive: true,
    facilities: ['WiFi'],
  ),
  KosListItem(
    id: 'melati',
    name: 'Kos Melati',
    address: 'Area B',
    monthlyPrice: 1500000,
    isActive: true,
    facilities: ['AC'],
  ),
];

Future<void> pumpKosList(WidgetTester tester, KosListProvider provider) async {
  await tester.pumpWidget(
    MaterialApp(
      home: KosListScreen(provider: provider, loadKos: (_) async => null),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('search input and reset clear query and all filters', (
    WidgetTester tester,
  ) async {
    final provider = KosListProvider(FakeKosListRepository(items: sampleKos));
    await pumpKosList(tester, provider);

    await tester.enterText(
      find.byKey(const ValueKey('kos-search-input')),
      'Mawar',
    );
    await tester.tap(find.byKey(const ValueKey('kos-search-submit')));
    await tester.pumpAndSettle();
    expect(provider.items.map((item) => item.id), ['mawar']);

    await tester.tap(find.text('Filter harga dan fasilitas'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('min-price-filter')),
      '900000',
    );
    await tester.tap(find.text('Terapkan harga'));
    await tester.pumpAndSettle();
    expect(provider.hasActiveFilters, isTrue);

    await tester.tap(find.byKey(const ValueKey('kos-search-reset')));
    await tester.pumpAndSettle();

    expect(provider.searchQuery, isEmpty);
    expect(provider.hasActiveFilters, isFalse);
    expect(provider.items.map((item) => item.id), ['mawar', 'melati']);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('kos-search-input')))
          .controller!
          .text,
      isEmpty,
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('min-price-filter')))
          .controller!
          .text,
      isEmpty,
    );
  });

  testWidgets('search with no matches shows a distinct empty state', (
    WidgetTester tester,
  ) async {
    final provider = KosListProvider(FakeKosListRepository(items: sampleKos));
    await pumpKosList(tester, provider);

    await tester.enterText(
      find.byKey(const ValueKey('kos-search-input')),
      'Tidak ada',
    );
    await tester.tap(find.byKey(const ValueKey('kos-search-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('Tidak ada kos yang cocok dengan pencarian atau filter ini.'),
      findsOneWidget,
    );
    expect(find.text('Belum ada kos yang tersedia.'), findsNothing);
  });

  testWidgets('loading state is visible while data is pending', (
    WidgetTester tester,
  ) async {
    final pendingResult = Completer<List<KosListItem>>();
    final provider = KosListProvider(
      FakeKosListRepository(pendingResult: pendingResult),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: KosListScreen(provider: provider, loadKos: (_) async => null),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pendingResult.complete(sampleKos);
    await tester.pumpAndSettle();

    expect(find.text('Kos Mawar'), findsOneWidget);
  });

  testWidgets('retry reloads data and preserves the submitted query', (
    WidgetTester tester,
  ) async {
    final repository = FakeKosListRepository(
      items: sampleKos,
      error: Exception('offline'),
    );
    final provider = KosListProvider(repository);
    await pumpKosList(tester, provider);
    expect(repository.fetchCount, 1);

    await tester.enterText(
      find.byKey(const ValueKey('kos-search-input')),
      'Mawar',
    );
    await tester.tap(find.byKey(const ValueKey('kos-search-submit')));
    await tester.pumpAndSettle();
    expect(repository.fetchCount, 2);
    expect(provider.hasError, isTrue);

    repository.error = null;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(repository.fetchCount, 3);
    expect(provider.searchQuery, 'Mawar');
    expect(provider.items.map((item) => item.id), ['mawar']);
  });
}
