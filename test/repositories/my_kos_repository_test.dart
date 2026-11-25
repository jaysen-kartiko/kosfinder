import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/repositories/my_kos_repository.dart';

class FakeMyKosRowsSource implements MyKosRowsSource {
  FakeMyKosRowsSource(this.rowsByOwner);

  final Map<String, List<Map<String, dynamic>>> rowsByOwner;
  final List<String> requestedOwners = [];

  @override
  Future<List<Map<String, dynamic>>> fetchKosRowsForOwner(
    String ownerId,
  ) async {
    requestedOwners.add(ownerId);
    return rowsByOwner[ownerId] ?? const [];
  }
}

Map<String, dynamic> kosRow(String id, String name) {
  return {
    'id': id,
    'name': name,
    'address': 'Area $name',
    'phone': '081234567890',
    'monthly_price': 1000000,
    'description': 'Dekat kampus',
    'is_active': true,
    'created_at': '2026-01-02T03:04:05Z',
    'kos_facilities': const [],
    'room_types': const [],
  };
}

void main() {
  test('fetches and maps rows for the requested owner only', () async {
    final source = FakeMyKosRowsSource({
      'owner-A': [kosRow('kos-A', 'Kos A')],
      'owner-B': [kosRow('kos-B', 'Kos B')],
    });
    final repository = SupabaseMyKosRepository(source);

    final ownerAItems = await repository.fetchOwnedKos('owner-A');
    final ownerBItems = await repository.fetchOwnedKos('owner-B');

    expect(ownerAItems.map((kos) => kos.id), ['kos-A']);
    expect(ownerBItems.map((kos) => kos.id), ['kos-B']);
    expect(source.requestedOwners, ['owner-A', 'owner-B']);
  });

  test('returns an empty result for an owner with no kos', () async {
    final repository = SupabaseMyKosRepository(FakeMyKosRowsSource(const {}));

    expect(await repository.fetchOwnedKos('owner-A'), isEmpty);
  });
}
