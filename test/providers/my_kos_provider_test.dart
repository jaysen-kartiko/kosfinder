import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/my_kos_provider.dart';
import 'package:kosfinder/repositories/my_kos_repository.dart';

class FakeMyKosRepository implements MyKosRepository {
  FakeMyKosRepository(this.itemsByOwner, {this.error});

  final Map<String, List<Kos>> itemsByOwner;
  final List<String> requestedOwners = [];
  Object? error;

  @override
  Future<List<Kos>> fetchOwnedKos(String ownerId) async {
    requestedOwners.add(ownerId);
    if (error != null) {
      throw error!;
    }
    return itemsByOwner[ownerId] ?? const [];
  }
}

Kos createKos(String id, String name) {
  return Kos(
    id: id,
    name: name,
    address: 'Area $name',
    phone: '081234567890',
    monthlyPrice: 1000000,
    description: 'Dekat kampus',
    isActive: true,
    createdAt: DateTime.utc(2026, 1, 2),
    facilities: const [],
    roomTypes: const [],
  );
}

void main() {
  test('each owner provider requests and receives only its own kos', () async {
    final repository = FakeMyKosRepository({
      'owner-A': [createKos('kos-A', 'Kos A')],
      'owner-B': [createKos('kos-B', 'Kos B')],
    });
    final providerA = MyKosProvider(repository, ownerId: 'owner-A');
    final providerB = MyKosProvider(repository, ownerId: 'owner-B');

    await providerA.load();
    await providerB.load();

    expect(providerA.items.map((kos) => kos.id), ['kos-A']);
    expect(providerB.items.map((kos) => kos.id), ['kos-B']);
    expect(repository.requestedOwners, ['owner-A', 'owner-B']);

    providerA.dispose();
    providerB.dispose();
  });

  test('empty owner results are represented as an empty state', () async {
    final provider = MyKosProvider(
      FakeMyKosRepository(const {}),
      ownerId: 'owner-A',
    );

    await provider.load();

    expect(provider.status, MyKosStatus.empty);
    expect(provider.isEmpty, isTrue);
    expect(provider.items, isEmpty);

    provider.dispose();
  });

  test('repository failures can be retried', () async {
    final repository = FakeMyKosRepository(
      <String, List<Kos>>{},
      error: const MyKosRepositoryException('Gagal memuat.'),
    );
    final provider = MyKosProvider(repository, ownerId: 'owner-A');

    await provider.load();
    expect(provider.status, MyKosStatus.error);
    expect(provider.errorMessage, 'Gagal memuat.');

    repository
      ..error = null
      ..itemsByOwner['owner-A'] = [createKos('kos-A', 'Kos A')];
    await provider.retry();

    expect(provider.status, MyKosStatus.success);
    expect(provider.items.single.id, 'kos-A');

    provider.dispose();
  });
}
