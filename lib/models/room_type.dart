class RoomType {
  const RoomType({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.status,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      monthlyPrice: _requiredNumber(json, 'monthly_price'),
      status: _requiredString(json, 'status'),
    );
  }

  final String id;
  final String name;
  final double monthlyPrice;
  final String status;

  bool get isAvailable => status == 'available';
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
