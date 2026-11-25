import 'package:flutter/foundation.dart';

import '../repositories/kos_list_repository.dart';

enum KosListStatus { idle, loading, success, empty, error }

class KosListProvider extends ChangeNotifier {
  KosListProvider(this._repository);

  final KosListRepository _repository;

  KosListStatus _status = KosListStatus.idle;
  List<KosListItem> _searchResults = const [];
  List<KosListItem> _items = const [];
  String? _errorMessage;
  String _searchQuery = '';
  Set<String> _selectedFacilities = {};
  int? _minPrice;
  int? _maxPrice;
  KosSortOrder _sortOrder = KosSortOrder.newest;

  KosListStatus get status => _status;
  List<KosListItem> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  Set<String> get selectedFacilities => Set.unmodifiable(_selectedFacilities);
  int? get minPrice => _minPrice;
  int? get maxPrice => _maxPrice;
  KosSortOrder get sortOrder => _sortOrder;
  List<String> get availableFacilities {
    final facilities =
        _searchResults.expand((kos) => kos.facilities).toSet().toList()..sort();
    return List.unmodifiable(facilities);
  }

  bool get hasActiveFilters =>
      _selectedFacilities.isNotEmpty || _minPrice != null || _maxPrice != null;
  bool get isLoading => _status == KosListStatus.loading;
  bool get isEmpty => _status == KosListStatus.empty;
  bool get hasError => _status == KosListStatus.error;

  Future<void> load() => _load();

  Future<void> search(String query) {
    _searchQuery = query.trim();
    return _load();
  }

  void setFilters({
    required Set<String> facilities,
    required int? minPrice,
    required int? maxPrice,
  }) {
    _selectedFacilities = Set.of(facilities);
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedFacilities = {};
    _minPrice = null;
    _maxPrice = null;
    _applyFilters();
    notifyListeners();
  }

  Future<void> resetSearch() {
    _searchQuery = '';
    _selectedFacilities = {};
    _minPrice = null;
    _maxPrice = null;
    return _load();
  }

  void setSortOrder(KosSortOrder order) {
    _sortOrder = order;
    _applyFilters();
    notifyListeners();
  }

  Future<void> _load() async {
    _status = KosListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.searchActiveKos(_searchQuery);
      _searchResults = result.where((item) => item.isActive).toList();
      _applyFilters();
      _status = _items.isEmpty ? KosListStatus.empty : KosListStatus.success;
    } catch (_) {
      _searchResults = const [];
      _items = const [];
      _errorMessage =
          'Tidak dapat memuat daftar kos. Periksa koneksi lalu coba lagi.';
      _status = KosListStatus.error;
    }

    notifyListeners();
  }

  void _applyFilters() {
    final filteredItems = _searchResults
        .where((kos) {
          final matchesPrice =
              (_minPrice == null || kos.monthlyPrice >= _minPrice!) &&
              (_maxPrice == null || kos.monthlyPrice <= _maxPrice!);
          final matchesFacilities = _selectedFacilities.every(
            kos.facilities.contains,
          );
          return matchesPrice && matchesFacilities;
        })
        .toList(growable: false);
    _items = _repository.sortKos(filteredItems, _sortOrder);
    if (_status != KosListStatus.loading && _status != KosListStatus.error) {
      _status = _items.isEmpty ? KosListStatus.empty : KosListStatus.success;
    }
  }

  Future<void> retry() => _load();
}
