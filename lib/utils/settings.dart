class Settings {
  Settings({
    this.filterPushEvents = false,
    this.filterDeleteEvents = false,
  });

  factory Settings.fromJson(Map<dynamic, dynamic> json) => Settings(
        filterPushEvents: json['filterPushEvents'] ?? false,
        filterDeleteEvents: json['filterDeleteEvents'] ?? false,
      );

  Settings copyWith({
    bool? filterPushEvents,
    bool? filterDeleteEvents,
  }) {
    return Settings(
      filterPushEvents: filterPushEvents ?? this.filterPushEvents,
      filterDeleteEvents: filterDeleteEvents ?? this.filterDeleteEvents,
    );
  }

  final bool filterPushEvents;
  final bool filterDeleteEvents;

  Map<String, dynamic> toJson() => {
        'filterPushEvents': filterPushEvents,
        'filterDeleteEvents': filterDeleteEvents,
      };
}
