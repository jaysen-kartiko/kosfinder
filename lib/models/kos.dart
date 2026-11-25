import 'room_type.dart';

class Kos {
  const Kos({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.monthlyPrice,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.facilities,
    required this.roomTypes,
  });

  factory Kos.fromJson(Map<String, dynamic> json) {
    final activeValue = json['is_active'];
    if (activeValue is! bool) {
      throw const FormatException('Expected a boolean for "is_active".');
    }

    return Kos(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      address: _requiredString(json, 'address'),
      phone: _requiredString(json, 'phone'),
      monthlyPrice: _requiredNumber(json, 'monthly_price'),
      description: _requiredString(json, 'description'),
      isActive: activeValue,
      createdAt: DateTime.parse(_requiredString(json, 'created_at')),
      facilities: _parseFacilities(json['kos_facilities']),
      roomTypes: _parseRoomTypes(json['room_types']),
    );
  }

  final String id;
  final String name;
  final String address;
  final String phone;
  final double monthlyPrice;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final List<String> facilities;
  final List<RoomType> roomTypes;

  static List<String> _parseFacilities(Object? value) {
    if (value == null) {
      return const [];
    }
    if (value is! List) {
      throw const FormatException('Expected a list for "kos_facilities".');
    }

    return value
        .map((entry) {
          final join = _asMap(entry, 'kos_facilities entry');
          final facility = join['facilities'];
          if (facility == null) {
            throw const FormatException('Missing joined facility.');
          }
          return _requiredString(_asMap(facility, 'facility'), 'name');
        })
        .toList(growable: false);
  }

  static List<RoomType> _parseRoomTypes(Object? value) {
    if (value == null) {
      return const [];
    }
    if (value is! List) {
      throw const FormatException('Expected a list for "room_types".');
    }

    return value
        .map((entry) => RoomType.fromJson(_asMap(entry, 'room_types entry')))
        .toList(growable: false);
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Expected a non-empty string for "$key".');
}

double _requiredNumber(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  throw FormatException('Expected a number for "$key".');
}

Map<String, dynamic> _asMap(Object? value, String description) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  throw FormatException('Expected a map for $description.');
}
