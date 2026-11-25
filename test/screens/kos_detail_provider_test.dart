import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_detail_provider.dart';

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
    facilities: const [],
    roomTypes: const [],
  );
}

void main() {
  test('loads an active kos into the loaded state', () async {
    final provider = KosDetailProvider((_) async => activeKos());

    await provider.load('kos-1');

    expect(provider.status, KosDetailStatus.loaded);
    expect(provider.kos?.name, 'Kos Mawar');
    provider.dispose();
  });

  test('marks a missing or inactive kos as unavailable', () async {
    final provider = KosDetailProvider((_) async => null);

    await provider.load('missing');

    expect(provider.status, KosDetailStatus.unavailable);
    expect(provider.kos, isNull);
    provider.dispose();
  });

  test('reports load errors and retry can recover', () async {
    var shouldFail = true;
    final provider = KosDetailProvider((_) async {
      if (shouldFail) {
        throw Exception('offline');
      }
      return activeKos();
    });

    await provider.load('kos-1');

    expect(provider.status, KosDetailStatus.error);
    expect(provider.errorMessage, contains('coba lagi'));

    shouldFail = false;
    await provider.retry('kos-1');

    expect(provider.status, KosDetailStatus.loaded);
    expect(provider.kos?.name, 'Kos Mawar');
    provider.dispose();
  });
}
