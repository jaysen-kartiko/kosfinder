import 'package:flutter/foundation.dart';

import '../models/kos.dart';
import '../repositories/my_kos_repository.dart';

enum MyKosStatus { idle, loading, success, empty, error }

class MyKosProvider extends ChangeNotifier {
  MyKosProvider(this._repository, {required this.ownerId});

  final MyKosRepository _repository;
  final String ownerId;

  MyKosStatus _status = MyKosStatus.idle;
  List<Kos> _items = const [];
  String? _errorMessage;

  MyKosStatus get status => _status;
  List<Kos> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == MyKosStatus.loading;
  bool get hasError => _status == MyKosStatus.error;
  bool get isEmpty => _status == MyKosStatus.empty;

  Future<void> load() async {
    _status = MyKosStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      if (ownerId.trim().isEmpty) {
        throw const MyKosRepositoryException(
          'Sesi pengguna tidak tersedia. Silakan masuk kembali.',
        );
      }
      _items = await _repository.fetchOwnedKos(ownerId);
      _status = _items.isEmpty ? MyKosStatus.empty : MyKosStatus.success;
    } on MyKosRepositoryException catch (error) {
      _items = const [];
      _errorMessage = error.message;
      _status = MyKosStatus.error;
    } finally {
      if (_status == MyKosStatus.loading) {
        _status = MyKosStatus.idle;
      }
      notifyListeners();
    }
  }

  Future<void> retry() => load();
}
