import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/repositories/kos_list_repository.dart';

class FakeKosListRepository implements KosListRepository {
  @override
  Future<List<KosListItem>> fetchActiveKos() async => const [];
}

void main() {
  final repository = FakeKosListRepository();
  const newestFirst = [
    KosListItem(
      id: 'newest',
      name: 'Kos Terbaru',
      address: 'Area A',
      monthlyPrice: 1500000,
      isActive: true,
    ),
    KosListItem(
      id: 'older',
      name: 'Kos Lebih Lama',
      address: 'Area B',
      monthlyPrice: 800000,
      isActive: true,
    ),
  ];

  test('sorts by cheapest price ascending', () {
    final result = repository.sortKos(newestFirst, KosSortOrder.cheapest);

    expect(result.map((item) => item.id), ['older', 'newest']);
    expect(newestFirst.first.id, 'newest');
  });

  test('preserves repository newest-first order for newest sorting', () {
    final result = repository.sortKos(newestFirst, KosSortOrder.newest);

    expect(result.map((item) => item.id), ['newest', 'older']);
  });
}
