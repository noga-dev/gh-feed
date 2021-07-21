class Settings {
  Settings({
    this.filterPushEvents = false,
  });

  factory Settings.fromJson(Map<dynamic, dynamic> json) => Settings(
        filterPushEvents: json['filterPushEvents'],
      );

  Settings copyWith({bool? filterPushEvents}) {
    return Settings(
      filterPushEvents: filterPushEvents ?? this.filterPushEvents,
    );
  }

  final bool filterPushEvents;

  Map<String, dynamic> toJson() => {
        'filterPushEvents': filterPushEvents,
      };
}
