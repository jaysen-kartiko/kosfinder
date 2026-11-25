import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kos.dart';

abstract interface class MyKosRowsSource {
  Future<List<Map<String, dynamic>>> fetchKosRowsForOwner(String ownerId);
}

class SupabaseMyKosRowsSource implements MyKosRowsSource {
  SupabaseMyKosRowsSource(this._client);

  static const _select =
      'id,name,address,phone,monthly_price,description,is_active,created_at,'
      'kos_facilities(facilities(name)),'
      'room_types(id,name,monthly_price,status)';

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchKosRowsForOwner(
    String ownerId,
  ) async {
    if (ownerId.trim().isEmpty) {
      throw ArgumentError.value(ownerId, 'ownerId', 'Must not be empty.');
    }

    final rows = await _client
        .from('kos')
        .select(_select)
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }
}

abstract interface class MyKosRepository {
  Future<List<Kos>> fetchOwnedKos(String ownerId);
}

class MyKosRepositoryException implements Exception {
  const MyKosRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SupabaseMyKosRepository implements MyKosRepository {
  SupabaseMyKosRepository(this._source);

  final MyKosRowsSource _source;

  @override
  Future<List<Kos>> fetchOwnedKos(String ownerId) async {
    try {
      final rows = await _source.fetchKosRowsForOwner(ownerId);
      return rows.map(Kos.fromJson).toList(growable: false);
    } on PostgrestException {
      throw const MyKosRepositoryException(
        'Tidak dapat memuat daftar kos milik Anda. Periksa koneksi lalu coba lagi.',
      );
    } on FormatException {
      throw const MyKosRepositoryException(
        'Data kos tidak dapat dibaca. Silakan coba lagi.',
      );
    }
  }
}
