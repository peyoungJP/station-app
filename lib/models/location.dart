enum LocationType { station, event, area }

class Location {
  final String id;
  final LocationType type;
  final String name;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final double? distance;
  final String? prefecture;
  final String? lineName;

  const Location({
    required this.id,
    required this.type,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 500,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.distance,
    this.prefecture,
    this.lineName,
  });

  String get displayTitle => type == LocationType.station ? '$name駅' : name;

  String? get subtitle {
    if (type == LocationType.station) return lineName;
    if (type == LocationType.event) {
      if (startDate != null && endDate != null) {
        final s = startDate!;
        final e = endDate!;
        return '${s.month}/${s.day}〜${e.month}/${e.day}';
      }
    }
    return null;
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      type: LocationType.values.firstWhere(
        (t) => t.name == (json['type'] as String),
        orElse: () => LocationType.station,
      ),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radius_meters'] as num?)?.toInt() ?? 500,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      prefecture: json['prefecture'] as String?,
      lineName: json['line_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      'is_active': isActive,
      if (prefecture != null) 'prefecture': prefecture,
      if (lineName != null) 'line_name': lineName,
    };
  }

  Location copyWith({
    String? id,
    LocationType? type,
    String? name,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    double? distance,
    String? prefecture,
    String? lineName,
  }) {
    return Location(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      distance: distance ?? this.distance,
      prefecture: prefecture ?? this.prefecture,
      lineName: lineName ?? this.lineName,
    );
  }
}
