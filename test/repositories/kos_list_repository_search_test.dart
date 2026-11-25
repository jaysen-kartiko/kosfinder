import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/repositories/kos_list_repository.dart';

class FakeKosListRepository implements KosListRepository {
  FakeKosListRepository(this.items);

  final List<KosListItem> items;

  @override
  Future<List<KosListItem>> fetchActiveKos() async => items;
}

void main() {
  final repository = FakeKosListRepository(const [
    KosListItem(
      id: '1',
      name: 'Kos Mawar',
      address: 'Jalan Melati',
      monthlyPrice: 1000000,
      isActive: true,
    ),
    KosListItem(
      id: '2',
      name: 'Kos Anggrek',
      address: 'Area Kampus Utara',
      monthlyPrice: 900000,
      isActive: true,
    ),
  ]);

  test('searches kos names case-insensitively', () async {
    final result = await repository.searchActiveKos(' maWAR ');

    expect(result.map((kos) => kos.id), ['1']);
  });

  test('searches addresses or areas case-insensitively', () async {
    final result = await repository.searchActiveKos('KAMPUS');

    expect(result.map((kos) => kos.id), ['2']);
  });

  test('returns an empty result when the query does not match', () async {
    final result = await repository.searchActiveKos('tidak ditemukan');

    expect(result, isEmpty);
  });

  test('returns all kos for an empty query', () async {
    final result = await repository.searchActiveKos('   ');

    expect(result, hasLength(2));
  });
}
