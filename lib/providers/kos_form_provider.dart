import 'package:flutter/foundation.dart';

import '../models/kos.dart';
import '../repositories/kos_management_repository.dart';

class KosFormData {
  const KosFormData({
    required this.name,
    required this.address,
    required this.phone,
    required this.monthlyPrice,
    required this.description,
    required this.isActive,
  });

  final String name;
  final String address;
  final String phone;
  final String monthlyPrice;
  final String description;
  final bool isActive;
}

Map<String, String> validateKosForm(KosFormData data) {
  final errors = <String, String>{};
  if (data.name.trim().isEmpty) {
    errors['name'] = 'Nama kos wajib diisi.';
  }
  if (data.address.trim().isEmpty) {
    errors['address'] = 'Alamat wajib diisi.';
  } else if (data.address.trim().length > 256) {
    errors['address'] = 'Alamat maksimal 256 karakter.';
  }
  if (!RegExp(r'^08[0-9]{6,10}$').hasMatch(data.phone.trim())) {
    errors['phone'] = 'Gunakan nomor 08 dengan maksimal 12 angka.';
  }
  final price = double.tryParse(data.monthlyPrice.trim());
  if (price == null || !price.isFinite || price < 0) {
    errors['monthlyPrice'] = 'Harga harus berupa angka nol atau lebih.';
  }
  if (data.description.trim().isEmpty) {
    errors['description'] = 'Deskripsi wajib diisi.';
  } else if (data.description.trim().length > 1024) {
    errors['description'] = 'Deskripsi maksimal 1024 karakter.';
  }
  return errors;
}

class KosFormProvider extends ChangeNotifier {
  KosFormProvider(this._repository, {this.initialKos});

  final KosManagementRepository _repository;
  final Kos? initialKos;

  List<KosFacilityOption> _facilities = const [];
  Set<String> _selectedFacilityIds = {};
  Map<String, String> _fieldErrors = const {};
  bool _isLoadingFacilities = true;
  bool _isSaving = false;
  bool _hasLoadError = false;
  bool _isSaved = false;
  String? _errorMessage;

  List<KosFacilityOption> get facilities => List.unmodifiable(_facilities);
  Set<String> get selectedFacilityIds => Set.unmodifiable(_selectedFacilityIds);
  Map<String, String> get fieldErrors => Map.unmodifiable(_fieldErrors);
  bool get isLoadingFacilities => _isLoadingFacilities;
  bool get isSaving => _isSaving;
  bool get hasLoadError => _hasLoadError;
  bool get isSaved => _isSaved;
  String? get errorMessage => _errorMessage;

  Future<void> loadFacilities() async {
    _isLoadingFacilities = true;
    _hasLoadError = false;
    _errorMessage = null;
    notifyListeners();
    try {
      _facilities = await _repository.fetchFacilities();
      final names = initialKos?.facilities.toSet() ?? const <String>{};
      _selectedFacilityIds = {
        for (final facility in _facilities)
          if (names.contains(facility.name)) facility.id,
      };
    } on KosManagementException catch (error) {
      _hasLoadError = true;
      _errorMessage = error.message;
    } finally {
      _isLoadingFacilities = false;
      notifyListeners();
    }
  }

  void toggleFacility(String id, bool selected) {
    if (selected) {
      _selectedFacilityIds.add(id);
    } else {
      _selectedFacilityIds.remove(id);
    }
    notifyListeners();
  }

  void clearFieldError(String field) {
    if (!_fieldErrors.containsKey(field)) {
      return;
    }
    _fieldErrors = Map.of(_fieldErrors)..remove(field);
    notifyListeners();
  }

  Future<bool> save(KosFormData data) async {
    _fieldErrors = validateKosForm(data);
    if (_fieldErrors.isNotEmpty) {
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _isSaved = false;
    notifyListeners();
    try {
      await _repository.saveKos(
        draft: KosDraft(
          name: data.name.trim(),
          address: data.address.trim(),
          phone: data.phone.trim(),
          monthlyPrice: double.parse(data.monthlyPrice.trim()),
          description: data.description.trim(),
          isActive: data.isActive,
          facilityIds: _selectedFacilityIds.toList(growable: false),
        ),
        kosId: initialKos?.id,
      );
      _isSaved = true;
      return true;
    } on KosManagementException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
