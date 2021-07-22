const _kFilterPushEvents = 'filterPushEvents';
const _kFilterDeleteEvents = 'filterDeleteEvents';
const _defaultBoolState = false;

class Settings {
  Settings({
    this.filterPushEvents = _defaultBoolState,
    this.filterDeleteEvents = _defaultBoolState,
  });

  factory Settings.fromJson(Map<dynamic, dynamic> json) => Settings(
        filterPushEvents: json[_kFilterPushEvents] ?? _defaultBoolState,
        filterDeleteEvents: json[_kFilterDeleteEvents] ?? _defaultBoolState,
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
        _kFilterPushEvents: filterPushEvents,
        _kFilterDeleteEvents: filterDeleteEvents,
      };
}
