import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/models/room_type.dart';

void main() {
  test('maps kos, numeric price, facilities, and room types', () {
    final kos = Kos.fromJson({
      'id': 'kos-1',
      'name': 'Kos Mawar',
      'address': 'Jl. Kampus 1',
      'phone': '081234567890',
      'monthly_price': '1250000.00',
      'description': 'Dekat kampus',
      'is_active': true,
      'created_at': '2026-01-02T03:04:05Z',
      'kos_facilities': [
        {
          'facilities': {'name': 'WiFi'},
        },
      ],
      'room_types': [
        {
          'id': 'room-1',
          'name': 'Tipe standar',
          'monthly_price': 1250000,
          'status': 'available',
        },
      ],
    });

    expect(kos.id, 'kos-1');
    expect(kos.monthlyPrice, 1250000);
    expect(kos.facilities, ['WiFi']);
    expect(kos.roomTypes.single.name, 'Tipe standar');
    expect(kos.roomTypes.single.isAvailable, isTrue);
  });

  test('maps missing related rows to empty collections', () {
    final kos = Kos.fromJson({
      'id': 'kos-2',
      'name': 'Kos Melati',
      'address': 'Jl. Melati',
      'phone': '081234567890',
      'monthly_price': 900000,
      'description': 'Kos tenang',
      'is_active': false,
      'created_at': '2026-01-02T03:04:05Z',
    });

    expect(kos.isActive, isFalse);
    expect(kos.facilities, isEmpty);
    expect(kos.roomTypes, isEmpty);
  });

  test('rejects invalid required data instead of silently defaulting', () {
    expect(
      () => Kos.fromJson({
        'id': 'kos-3',
        'name': 'Kos',
        'address': 'Alamat',
        'phone': '081234567890',
        'monthly_price': 'not-a-price',
        'description': 'Deskripsi',
        'is_active': true,
        'created_at': '2026-01-02T03:04:05Z',
      }),
      throwsFormatException,
    );
  });

  test('room type accepts numeric string prices', () {
    final room = RoomType.fromJson({
      'id': 'room-2',
      'name': 'Tipe AC',
      'monthly_price': '1500000',
      'status': 'full',
    });

    expect(room.monthlyPrice, 1500000);
    expect(room.isAvailable, isFalse);
  });
}
