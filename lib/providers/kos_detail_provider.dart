import 'package:flutter/foundation.dart';

import '../models/kos.dart';

typedef KosDetailLoader = Future<Kos?> Function(String id);

enum KosDetailStatus { idle, loading, loaded, unavailable, error }

class KosDetailProvider extends ChangeNotifier {
  KosDetailProvider(this._loadKos);

  final KosDetailLoader _loadKos;

  KosDetailStatus _status = KosDetailStatus.idle;
  Kos? _kos;
  String? _errorMessage;

  KosDetailStatus get status => _status;
  Kos? get kos => _kos;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == KosDetailStatus.loading;
  bool get isUnavailable => _status == KosDetailStatus.unavailable;
  bool get hasError => _status == KosDetailStatus.error;

  Future<void> load(String id) async {
    _status = KosDetailStatus.loading;
    _kos = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _loadKos(id);
      if (result == null || !result.isActive) {
        _status = KosDetailStatus.unavailable;
      } else {
        _kos = result;
        _status = KosDetailStatus.loaded;
      }
    } catch (_) {
      _errorMessage =
          'Gagal memuat detail kos. Periksa koneksi lalu coba lagi.';
      _status = KosDetailStatus.error;
    }

    notifyListeners();
  }

  Future<void> retry(String id) => load(id);
}
