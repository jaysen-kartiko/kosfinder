import 'package:supabase_flutter/supabase_flutter.dart';

import 'kos_rows_source.dart';

class SupabaseKosRowsSource implements KosRowsSource {
  SupabaseKosRowsSource(this._client);

  static const _select =
      'id,name,address,phone,monthly_price,description,is_active,created_at,'
      'kos_facilities(facilities(name)),'
      'room_types(id,name,monthly_price,status)';

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchActiveKosRows() async {
    final rows = await _client
        .from('kos')
        .select(_select)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<Map<String, dynamic>?> fetchActiveKosRow(String id) async {
    final row = await _client
        .from('kos')
        .select(_select)
        .eq('id', id)
        .eq('is_active', true)
        .maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row);
  }
}
