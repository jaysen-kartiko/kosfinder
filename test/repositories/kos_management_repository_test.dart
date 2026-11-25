import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/repositories/kos_management_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeKosManagementRowsSource implements KosManagementRowsSource {
  List<Map<String, dynamic>> facilityRows = const [
    {'id': 'wifi-id', 'name': 'WiFi'},
  ];
  Object? fetchFacilitiesError;
  Object? saveError;
  Object? hideError;
  KosDraft? savedDraft;
  String? savedKosId;
  String? hiddenKosId;
  String? hiddenOwnerId;
  bool hideResult = true;

  @override
  Future<List<Map<String, dynamic>>> fetchFacilities() async {
    if (fetchFacilitiesError case final error?) {
      throw error;
    }
    return facilityRows;
  }

  @override
  Future<void> saveKos({required KosDraft draft, String? kosId}) async {
    if (saveError case final error?) {
      throw error;
    }
    savedDraft = draft;
    savedKosId = kosId;
  }

  @override
  Future<bool> hideKos({
    required String kosId,
    required String ownerId,
  }) async {
    if (hideError case final error?) {
      throw error;
    }
    hiddenKosId = kosId;
    hiddenOwnerId = ownerId;
    return hideResult;
  }
}

void main() {
  test('maps facilities and delegates add/edit with selected facilities', () async {
    final source = FakeKosManagementRowsSource();
    final repository = SupabaseKosManagementRepository(source);
    const draft = KosDraft(
      name: 'Kos',
      address: 'Jalan',
      phone: '081234567890',
      monthlyPrice: 1000000,
      description: 'Dekat kampus',
      isActive: true,
      facilityIds: ['wifi-id'],
    );

    expect((await repository.fetchFacilities()).single.name, 'WiFi');
    await repository.saveKos(draft: draft);
    await repository.saveKos(draft: draft, kosId: 'kos-id');

    expect(source.savedDraft, draft);
    expect(source.savedKosId, 'kos-id');
  });

  test('hiding is owner-scoped and rejects a row not returned by the backend', () async {
    final source = FakeKosManagementRowsSource();
    final repository = SupabaseKosManagementRepository(source);

    await repository.hideKos(kosId: 'kos-id', ownerId: 'owner-A');
    expect(source.hiddenKosId, 'kos-id');
    expect(source.hiddenOwnerId, 'owner-A');

    source.hideResult = false;
    await expectLater(
      repository.hideKos(kosId: 'kos-id', ownerId: 'owner-B'),
      throwsA(
        isA<KosManagementException>().having(
          (error) => error.message,
          'message',
          'Anda tidak memiliki izin untuk mengubah kos ini.',
        ),
      ),
    );
  });

  test('malformed facility data is surfaced as a repository error', () async {
    final source = FakeKosManagementRowsSource()
      ..facilityRows = const [
        {'id': '', 'name': 'WiFi'},
      ];
    final repository = SupabaseKosManagementRepository(source);

    await expectLater(
      repository.fetchFacilities(),
      throwsA(isA<KosManagementException>()),
    );
  });

  test('maps 42501 RLS errors to permission message on save and hide', () async {
    final source = FakeKosManagementRowsSource()
      ..saveError = const PostgrestException(message: 'forbidden', code: '42501')
      ..hideError = const PostgrestException(message: 'forbidden', code: '42501');
    final repository = SupabaseKosManagementRepository(source);
    const draft = KosDraft(
      name: 'Kos',
      address: 'Jalan',
      phone: '081234567890',
      monthlyPrice: 1000000,
      description: 'Dekat kampus',
      isActive: true,
      facilityIds: [],
    );

    await expectLater(
      repository.saveKos(draft: draft, kosId: 'kos-other'),
      throwsA(
        isA<KosManagementException>().having(
          (error) => error.message,
          'message',
          'Anda tidak memiliki izin untuk mengubah kos ini.',
        ),
      ),
    );
    await expectLater(
      repository.hideKos(kosId: 'kos-other', ownerId: 'owner-B'),
      throwsA(
        isA<KosManagementException>().having(
          (error) => error.message,
          'message',
          'Anda tidak memiliki izin untuk mengubah kos ini.',
        ),
      ),
    );
  });

  test('maps connection failures to retryable repository errors', () async {
    final source = FakeKosManagementRowsSource()
      ..fetchFacilitiesError = const SocketException('offline')
      ..saveError = const SocketException('offline')
      ..hideError = const SocketException('offline');
    final repository = SupabaseKosManagementRepository(source);
    const draft = KosDraft(
      name: 'Kos',
      address: 'Jalan',
      phone: '081234567890',
      monthlyPrice: 1000000,
      description: 'Dekat kampus',
      isActive: true,
      facilityIds: [],
    );

    await expectLater(
      repository.fetchFacilities(),
      throwsA(
        isA<KosManagementException>().having(
          (error) => error.message,
          'message',
          'Tidak dapat memuat fasilitas. Periksa koneksi lalu coba lagi.',
        ),
      ),
    );
    await expectLater(
      repository.saveKos(draft: draft),
      throwsA(
        isA<KosManagementException>().having(
          (error) => error.message,
          'message',
          'Tidak dapat menyimpan kos. Periksa koneksi lalu coba lagi.',
        ),
      ),
    );
    await expectLater(
      repository.hideKos(kosId: 'kos-id', ownerId: 'owner-A'),
      throwsA(
        isA<KosManagementException>().having(
          (error) => error.message,
          'message',
          'Tidak dapat menyembunyikan kos. Periksa koneksi lalu coba lagi.',
        ),
      ),
    );
  });
}
