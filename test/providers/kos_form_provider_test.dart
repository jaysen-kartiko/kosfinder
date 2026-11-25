import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_form_provider.dart';
import 'package:kosfinder/repositories/kos_management_repository.dart';

class FakeKosManagementRepository implements KosManagementRepository {
  FakeKosManagementRepository({this.error});

  final List<KosFacilityOption> facilities = const [
    KosFacilityOption(id: 'wifi-id', name: 'WiFi'),
    KosFacilityOption(id: 'ac-id', name: 'AC'),
  ];
  Object? error;
  KosDraft? savedDraft;
  String? savedKosId;

  @override
  Future<List<KosFacilityOption>> fetchFacilities() async {
    if (error != null) {
      throw error!;
    }
    return facilities;
  }

  @override
  Future<void> saveKos({required KosDraft draft, String? kosId}) async {
    if (error != null) {
      throw error!;
    }
    savedDraft = draft;
    savedKosId = kosId;
  }

  @override
  Future<void> hideKos({
    required String kosId,
    required String ownerId,
  }) async {}
}

Kos createKos() => Kos(
  id: 'kos-id',
  name: 'Kos Lama',
  address: 'Area lama',
  phone: '081234567890',
  monthlyPrice: 1000000,
  description: 'Deskripsi lama',
  isActive: true,
  createdAt: DateTime.utc(2026, 1, 1),
  facilities: const ['AC'],
  roomTypes: const [],
);

KosFormData validFormData({
  String address = 'Jalan Baru',
  String description = 'Dekat kampus',
  String phone = '081234567890',
  String price = '1250000',
}) => KosFormData(
  name: 'Kos Baru',
  address: address,
  phone: phone,
  monthlyPrice: price,
  description: description,
  isActive: true,
);

void main() {
  test('validates required fields, limits, phone format, and price', () {
    final errors = validateKosForm(
      KosFormData(
        name: '',
        address: 'a' * 257,
        phone: '08123abc',
        monthlyPrice: '-1',
        description: 'd' * 1025,
        isActive: true,
      ),
    );

    expect(errors.keys, {
      'name',
      'address',
      'phone',
      'monthlyPrice',
      'description',
    });
  });

  test('accepts a valid 12-digit phone and numeric price', () {
    expect(validateKosForm(validFormData()), isEmpty);
    expect(
      validateKosForm(validFormData(phone: '081234567890', price: '99.50')),
      isEmpty,
    );
  });

  test('loads facility selections and sends the edit id when saving', () async {
    final repository = FakeKosManagementRepository();
    final provider = KosFormProvider(repository, initialKos: createKos());

    await provider.loadFacilities();
    expect(provider.selectedFacilityIds, {'ac-id'});
    provider.toggleFacility('wifi-id', true);

    expect(await provider.save(validFormData()), isTrue);
    expect(repository.savedKosId, 'kos-id');
    expect(repository.savedDraft?.name, 'Kos Baru');
    expect(repository.savedDraft?.monthlyPrice, 1250000);
    expect(repository.savedDraft?.facilityIds.toSet(), {'wifi-id', 'ac-id'});
    expect(provider.isSaved, isTrue);

    provider.dispose();
  });

  test('invalid input and backend failure are not reported as saved', () async {
    final repository = FakeKosManagementRepository();
    final provider = KosFormProvider(repository);

    expect(
      await provider.save(validFormData(address: 'a' * 257)),
      isFalse,
    );
    expect(provider.fieldErrors['address'], isNotNull);
    expect(repository.savedDraft, isNull);

    repository.error = const KosManagementException('Gagal menyimpan.');
    expect(await provider.save(validFormData()), isFalse);
    expect(provider.isSaved, isFalse);
    expect(provider.errorMessage, 'Gagal menyimpan.');

    provider.dispose();
  });

  test('validates boundary lengths, phone rules, and non-numeric price', () {
    expect(
      validateKosForm(
        validFormData(
          address: 'a' * 256,
          description: 'd' * 1024,
          phone: '08123456',
          price: '0',
        ),
      ),
      isEmpty,
    );

    final errors = validateKosForm(
      validFormData(phone: '0712345678', price: 'abc'),
    );
    expect(errors.keys, {'phone', 'monthlyPrice'});

    final tooShortPhone = validateKosForm(validFormData(phone: '08123'));
    expect(tooShortPhone.keys, {'phone'});

    final tooLongPhone = validateKosForm(
      validFormData(phone: '0812345678901'),
    );
    expect(tooLongPhone.keys, {'phone'});

    final nanPrice = validateKosForm(validFormData(price: 'NaN'));
    expect(nanPrice.keys, {'monthlyPrice'});
  });

  test('facility load failure sets error and recovers on retry', () async {
    final repository = FakeKosManagementRepository()
      ..error = const KosManagementException('Koneksi gagal.');
    final provider = KosFormProvider(repository);

    await provider.loadFacilities();
    expect(provider.hasLoadError, isTrue);
    expect(provider.errorMessage, 'Koneksi gagal.');
    expect(provider.isLoadingFacilities, isFalse);

    repository.error = null;
    await provider.loadFacilities();
    expect(provider.hasLoadError, isFalse);
    expect(provider.errorMessage, isNull);
    expect(provider.facilities, hasLength(2));

    provider.dispose();
  });
}
