import 'package:supabase_flutter/supabase_flutter.dart';

class KosFacilityOption {
  const KosFacilityOption({required this.id, required this.name});

  final String id;
  final String name;
}

class KosDraft {
  const KosDraft({
    required this.name,
    required this.address,
    required this.phone,
    required this.monthlyPrice,
    required this.description,
    required this.isActive,
    required this.facilityIds,
  });

  final String name;
  final String address;
  final String phone;
  final double monthlyPrice;
  final String description;
  final bool isActive;
  final List<String> facilityIds;
}

abstract interface class KosManagementRowsSource {
  Future<List<Map<String, dynamic>>> fetchFacilities();

  Future<void> saveKos({required KosDraft draft, String? kosId});

  Future<bool> hideKos({required String kosId, required String ownerId});
}

class SupabaseKosManagementRowsSource implements KosManagementRowsSource {
  SupabaseKosManagementRowsSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchFacilities() async {
    final rows = await _client
        .from('facilities')
        .select('id,name')
        .order('name');
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<void> saveKos({required KosDraft draft, String? kosId}) async {
    await _client.rpc(
      'save_kos',
      params: {
        'p_name': draft.name,
        'p_address': draft.address,
        'p_phone': draft.phone,
        'p_monthly_price': draft.monthlyPrice,
        'p_description': draft.description,
        'p_is_active': draft.isActive,
        'p_facility_ids': draft.facilityIds,
        'p_kos_id': kosId,
      },
    );
  }

  @override
  Future<bool> hideKos({
    required String kosId,
    required String ownerId,
  }) async {
    final row = await _client
        .from('kos')
        .update({'is_active': false})
        .eq('id', kosId)
        .eq('owner_id', ownerId)
        .select('id')
        .maybeSingle();
    return row != null;
  }
}

abstract interface class KosManagementRepository {
  Future<List<KosFacilityOption>> fetchFacilities();

  Future<void> saveKos({required KosDraft draft, String? kosId});

  Future<void> hideKos({required String kosId, required String ownerId});
}

class KosManagementException implements Exception {
  const KosManagementException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SupabaseKosManagementRepository implements KosManagementRepository {
  SupabaseKosManagementRepository(this._source);

  final KosManagementRowsSource _source;

  @override
  Future<List<KosFacilityOption>> fetchFacilities() async {
    try {
      final rows = await _source.fetchFacilities();
      return rows
          .map(
            (row) => KosFacilityOption(
              id: _requiredString(row, 'id'),
              name: _requiredString(row, 'name'),
            ),
          )
          .toList(growable: false);
    } on PostgrestException {
      throw const KosManagementException(
        'Tidak dapat memuat fasilitas. Periksa koneksi lalu coba lagi.',
      );
    } on FormatException {
      throw const KosManagementException(
        'Data fasilitas tidak dapat dibaca. Silakan coba lagi.',
      );
    } on Exception {
      throw const KosManagementException(
        'Tidak dapat memuat fasilitas. Periksa koneksi lalu coba lagi.',
      );
    }
  }

  @override
  Future<void> saveKos({required KosDraft draft, String? kosId}) async {
    try {
      await _source.saveKos(draft: draft, kosId: kosId);
    } on PostgrestException catch (error) {
      if (error.code == '42501') {
        throw const KosManagementException(
          'Anda tidak memiliki izin untuk mengubah kos ini.',
        );
      }
      throw const KosManagementException(
        'Tidak dapat menyimpan kos. Periksa koneksi lalu coba lagi.',
      );
    } on Exception {
      throw const KosManagementException(
        'Tidak dapat menyimpan kos. Periksa koneksi lalu coba lagi.',
      );
    }
  }

  @override
  Future<void> hideKos({
    required String kosId,
    required String ownerId,
  }) async {
    try {
      final hidden = await _source.hideKos(kosId: kosId, ownerId: ownerId);
      if (!hidden) {
        throw const KosManagementException(
          'Anda tidak memiliki izin untuk mengubah kos ini.',
        );
      }
    } on KosManagementException {
      rethrow;
    } on PostgrestException catch (error) {
      if (error.code == '42501') {
        throw const KosManagementException(
          'Anda tidak memiliki izin untuk mengubah kos ini.',
        );
      }
      throw const KosManagementException(
        'Tidak dapat menyembunyikan kos. Periksa koneksi lalu coba lagi.',
      );
    } on Exception {
      throw const KosManagementException(
        'Tidak dapat menyembunyikan kos. Periksa koneksi lalu coba lagi.',
      );
    }
  }
}

String _requiredString(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Expected a non-empty string for "$key".');
}
