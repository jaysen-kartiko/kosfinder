import '../models/kos.dart';
import '../repositories/kos_list_repository.dart';
import 'kos_rows_source.dart';

class SupabaseKosRepository implements KosListRepository {
  SupabaseKosRepository(this._source);

  final KosRowsSource _source;

  @override
  Future<List<KosListItem>> fetchActiveKos() async {
    final rows = await _source.fetchActiveKosRows();
    return rows
        .map(Kos.fromJson)
        .where((kos) => kos.isActive)
        .map(_toListItem)
        .toList(growable: false);
  }

  Future<Kos?> fetchActiveKosById(String id) async {
    final row = await _source.fetchActiveKosRow(id);
    if (row == null) {
      return null;
    }

    final kos = Kos.fromJson(row);
    return kos.isActive ? kos : null;
  }

  static KosListItem _toListItem(Kos kos) {
    return KosListItem(
      id: kos.id,
      name: kos.name,
      address: kos.address,
      monthlyPrice: kos.monthlyPrice.round(),
      isActive: kos.isActive,
      facilities: kos.facilities,
    );
  }
}
