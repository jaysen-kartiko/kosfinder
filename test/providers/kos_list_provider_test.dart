import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/kos_list_provider.dart';
import 'package:kosfinder/repositories/kos_list_repository.dart';

class FakeKosListRepository implements KosListRepository {
  FakeKosListRepository({required this.result, this.error});

  List<KosListItem> result;
  Object? error;
  int fetchCount = 0;

  @override
  Future<List<KosListItem>> fetchActiveKos() async {
    fetchCount++;
    if (error != null) {
      throw error!;
    }
    return result;
  }
}

void main() {
  test('provider notifies listeners when loading and when loaded', () async {
    final repository = FakeKosListRepository(
      result: const [
        KosListItem(
          id: '1',
          name: 'Kos Mawar',
          address: 'Dekat kampus',
          monthlyPrice: 1000000,
          isActive: true,
        ),
      ],
    );
    final provider = KosListProvider(repository);
    final notifiedStatuses = <KosListStatus>[];
    provider.addListener(() => notifiedStatuses.add(provider.status));

    final loading = provider.load();

    expect(provider.isLoading, isTrue);
    expect(notifiedStatuses, [KosListStatus.loading]);

    await loading;

    expect(provider.status, KosListStatus.success);
    expect(notifiedStatuses, [KosListStatus.loading, KosListStatus.success]);
  });

  test('US02-AC1: provider menampilkan daftar kos aktif', () async {
    final repository = FakeKosListRepository(
      result: const [
        KosListItem(
          id: '1',
          name: 'Kos Mawar',
          address: 'Dekat kampus',
          monthlyPrice: 1000000,
          isActive: true,
        ),
        KosListItem(
          id: '2',
          name: 'Kos Nonaktif',
          address: 'Alamat lama',
          monthlyPrice: 900000,
          isActive: false,
        ),
      ],
    );
    final provider = KosListProvider(repository);

    await provider.load();

    expect(provider.status, KosListStatus.success);
    expect(provider.items, hasLength(1));
    expect(provider.items.first.name, 'Kos Mawar');
  });

  test('US02-AC2: provider menampilkan state kosong', () async {
    final repository = FakeKosListRepository(result: const []);
    final provider = KosListProvider(repository);

    await provider.load();

    expect(provider.status, KosListStatus.empty);
    expect(provider.isEmpty, isTrue);
    expect(provider.items, isEmpty);
  });

  test('provider searches by name or area and updates its query', () async {
    final provider = KosListProvider(
      FakeKosListRepository(
        result: const [
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
        ],
      ),
    );

    await provider.search('  MAWAR ');

    expect(provider.searchQuery, 'MAWAR');
    expect(provider.items.map((item) => item.id), ['1']);

    await provider.search('kampus');

    expect(provider.searchQuery, 'kampus');
    expect(provider.items.map((item) => item.id), ['2']);

    await provider.search('tidak ada');

    expect(provider.status, KosListStatus.empty);
    expect(provider.items, isEmpty);
  });

  test('reset search clears query and filters then reloads results', () async {
    final repository = FakeKosListRepository(
      result: const [
        KosListItem(
          id: '1',
          name: 'Kos Mawar',
          address: 'Area A',
          monthlyPrice: 1000000,
          isActive: true,
          facilities: ['WiFi'],
        ),
        KosListItem(
          id: '2',
          name: 'Kos Melati',
          address: 'Area B',
          monthlyPrice: 1500000,
          isActive: true,
          facilities: ['AC'],
        ),
      ],
    );
    final provider = KosListProvider(repository);

    await provider.search('Mawar');
    provider.setFilters(
      facilities: {'WiFi'},
      minPrice: 900000,
      maxPrice: 1100000,
    );

    await provider.resetSearch();

    expect(provider.searchQuery, isEmpty);
    expect(provider.hasActiveFilters, isFalse);
    expect(provider.minPrice, isNull);
    expect(provider.maxPrice, isNull);
    expect(provider.selectedFacilities, isEmpty);
    expect(provider.items.map((item) => item.id), ['1', '2']);
    expect(repository.fetchCount, 2);
  });

  test('provider combines price range and all selected facilities', () async {
    final provider = KosListProvider(
      FakeKosListRepository(
        result: const [
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
          KosListItem(
            id: '4',
            name: 'Kos Nonaktif',
            address: 'Area D',
            monthlyPrice: 1000000,
            isActive: false,
            facilities: ['WiFi', 'AC'],
          ),
        ],
      ),
    );

    await provider.load();
    expect(provider.availableFacilities, ['AC', 'WiFi']);

    provider.setFilters(
      facilities: {'WiFi', 'AC'},
      minPrice: 900000,
      maxPrice: 1200000,
    );

    expect(provider.items.map((item) => item.id), ['2']);
    expect(provider.hasActiveFilters, isTrue);

    provider.clearFilters();

    expect(provider.items.map((item) => item.id), ['1', '2', '3']);
    expect(provider.hasActiveFilters, isFalse);
  });

  test('provider switches between newest and cheapest result order', () async {
    final provider = KosListProvider(
      FakeKosListRepository(
        result: const [
          KosListItem(
            id: 'newest',
            name: 'Kos Terbaru',
            address: 'Area A',
            monthlyPrice: 1500000,
            isActive: true,
          ),
          KosListItem(
            id: 'middle',
            name: 'Kos Kedua',
            address: 'Area B',
            monthlyPrice: 1000000,
            isActive: true,
          ),
          KosListItem(
            id: 'cheapest',
            name: 'Kos Termurah',
            address: 'Area C',
            monthlyPrice: 800000,
            isActive: true,
          ),
        ],
      ),
    );

    await provider.load();
    expect(provider.items.map((item) => item.id), [
      'newest',
      'middle',
      'cheapest',
    ]);

    provider.setSortOrder(KosSortOrder.cheapest);
    expect(provider.items.map((item) => item.id), [
      'cheapest',
      'middle',
      'newest',
    ]);

    provider.setSortOrder(KosSortOrder.newest);
    expect(provider.items.map((item) => item.id), [
      'newest',
      'middle',
      'cheapest',
    ]);
  });

  test('US02-AC3: provider menampilkan galat dan retry berhasil', () async {
    final repository = FakeKosListRepository(
      result: const [],
      error: Exception('network unavailable'),
    );
    final provider = KosListProvider(repository);

    await provider.load();

    expect(provider.status, KosListStatus.error);
    expect(provider.hasError, isTrue);
    expect(provider.errorMessage, contains('coba lagi'));

    repository.error = null;
    repository.result = const [
      KosListItem(
        id: '1',
        name: 'Kos Melati',
        address: 'Area kampus',
        monthlyPrice: 850000,
        isActive: true,
      ),
    ];

    await provider.retry();

    expect(provider.status, KosListStatus.success);
    expect(provider.items, hasLength(1));
  });
}
