class Station {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String prefecture;
  final String lineName;
  final double? distance; // 現在地からの距離（メートル）

  const Station({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.prefecture,
    required this.lineName,
    this.distance,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      prefecture: json['prefecture'] as String,
      lineName: json['line_name'] as String,
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'prefecture': prefecture,
      'line_name': lineName,
    };
  }

  Station copyWith({double? distance}) {
    return Station(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      prefecture: prefecture,
      lineName: lineName,
      distance: distance ?? this.distance,
    );
  }
}
