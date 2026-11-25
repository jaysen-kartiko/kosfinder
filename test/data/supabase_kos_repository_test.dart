import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/data/kos_rows_source.dart';
import 'package:kosfinder/data/supabase_kos_repository.dart';
import 'package:kosfinder/models/kos.dart';

class FakeKosRowsSource implements KosRowsSource {
  FakeKosRowsSource({this.rows = const [], this.detailRow, this.error});

  final List<Map<String, dynamic>> rows;
  final Map<String, dynamic>? detailRow;
  final Object? error;

  @override
  Future<List<Map<String, dynamic>>> fetchActiveKosRows() async {
    if (error != null) {
      throw error!;
    }
    return rows;
  }

  @override
  Future<Map<String, dynamic>?> fetchActiveKosRow(String id) async {
    if (error != null) {
      throw error!;
    }
    return detailRow;
  }
}

Map<String, dynamic> kosRow({
  String id = 'kos-1',
  bool isActive = true,
  List<String> facilities = const [],
}) {
  return {
    'id': id,
    'name': 'Kos Mawar',
    'address': 'Jl. Kampus 1',
    'phone': '081234567890',
    'monthly_price': 1250000,
    'description': 'Dekat kampus',
    'is_active': isActive,
    'created_at': '2026-01-02T03:04:05Z',
    'kos_facilities': facilities
        .map(
          (name) => {
            'facilities': {'name': name},
          },
        )
        .toList(),
    'room_types': const [],
  };
}

void main() {
  test('returns only active kos mapped to the T03 list contract', () async {
    final repository = SupabaseKosRepository(
      FakeKosRowsSource(
        rows: [
          kosRow(facilities: ['WiFi', 'AC']),
          kosRow(id: 'kos-hidden', isActive: false),
        ],
      ),
    );

    final result = await repository.fetchActiveKos();

    expect(result, hasLength(1));
    expect(result.single.id, 'kos-1');
    expect(result.single.monthlyPrice, 1250000);
    expect(result.single.facilities, ['WiFi', 'AC']);
  });

  test('returns an empty list when there are no active kos', () async {
    final repository = SupabaseKosRepository(
      FakeKosRowsSource(rows: [kosRow(isActive: false)]),
    );

    expect(await repository.fetchActiveKos(), isEmpty);
  });

  test('propagates data source failures to its caller', () async {
    final repository = SupabaseKosRepository(
      FakeKosRowsSource(error: Exception('offline')),
    );

    expect(repository.fetchActiveKos(), throwsException);
    expect(repository.fetchActiveKosById('kos-1'), throwsException);
  });

  test(
    'loads an active detail and returns null for missing or hidden kos',
    () async {
      final activeRepository = SupabaseKosRepository(
        FakeKosRowsSource(detailRow: kosRow()),
      );
      final hiddenRepository = SupabaseKosRepository(
        FakeKosRowsSource(detailRow: kosRow(isActive: false)),
      );
      final missingRepository = SupabaseKosRepository(FakeKosRowsSource());

      final Kos? active = await activeRepository.fetchActiveKosById('kos-1');

      expect(active?.name, 'Kos Mawar');
      expect(await hiddenRepository.fetchActiveKosById('kos-hidden'), isNull);
      expect(await missingRepository.fetchActiveKosById('missing'), isNull);
    },
  );
}
