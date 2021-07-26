const _defaultBoolState = false;

class Settings {
  Settings({
    this.filterCommitCommentEvent = _defaultBoolState,
    this.filterCreateEvent = _defaultBoolState,
    this.filterDeleteEvent = _defaultBoolState,
    this.filterForkEvent = _defaultBoolState,
    this.filterGollumEvent = _defaultBoolState,
    this.filterIssueCommentEvent = _defaultBoolState,
    this.filterIssuesEvent = _defaultBoolState,
    this.filterMemberEvent = _defaultBoolState,
    this.filterPublicEvent = _defaultBoolState,
    this.filterPullRequestEvent = _defaultBoolState,
    this.filterPullRequestReviewCommentEvent = _defaultBoolState,
    this.filterPullRequestReviewEvent = _defaultBoolState,
    this.filterPushEvent = _defaultBoolState,
    this.filterReleaseEvent = _defaultBoolState,
    this.filterSponsorshipEvent = _defaultBoolState,
    this.filterWatchEvent = _defaultBoolState,
  });

  factory Settings.fromJson(Map<dynamic, dynamic> json) => Settings(
        filterPushEvent: json[kFilterPushEvent] ?? _defaultBoolState,
        filterCreateEvent: json[kFilterCreateEvent] ?? _defaultBoolState,
        filterForkEvent: json[kFilterForkEvent] ?? _defaultBoolState,
        filterGollumEvent: json[kFilterGollumEvent] ?? _defaultBoolState,
        filterIssuesEvent: json[kFilterIssuesEvent] ?? _defaultBoolState,
        filterMemberEvent: json[kFilterMemberEvent] ?? _defaultBoolState,
        filterPublicEvent: json[kFilterPublicEvent] ?? _defaultBoolState,
        filterReleaseEvent: json[kFilterReleaseEvent] ?? _defaultBoolState,
        filterDeleteEvent: json[kFilterDeleteEvent] ?? _defaultBoolState,
        filterWatchEvent: json[kFilterWatchEvent] ?? _defaultBoolState,
        filterCommitCommentEvent:
            json[kFilterCommitCommentEvent] ?? _defaultBoolState,
        filterIssueCommentEvent:
            json[kFilterIssueCommentEvent] ?? _defaultBoolState,
        filterPullRequestEvent:
            json[kFilterPullRequestEvent] ?? _defaultBoolState,
        filterPullRequestReviewEvent:
            json[kFilterPullRequestReviewEvent] ?? _defaultBoolState,
        filterSponsorshipEvent:
            json[kFilterSponsorshipEvent] ?? _defaultBoolState,
        filterPullRequestReviewCommentEvent:
            json[kFilterPullRequestReviewCommentEvent] ?? _defaultBoolState,
      );

  Settings copyWith({
    bool? filterPushEvent,
    bool? filterCreateEvent,
    bool? filterDeleteEvent,
    bool? filterForkEvent,
    bool? filterGollumEvent,
    bool? filterIssueCommentEvent,
    bool? filterCommitCommentEvent,
    bool? filterIssuesEvent,
    bool? filterMemberEvent,
    bool? filterPublicEvent,
    bool? filterPullRequestEvent,
    bool? filterPullRequestReviewCommentEvent,
    bool? filterPullRequestReviewEvent,
    bool? filterReleaseEvent,
    bool? filterSponsorshipEvent,
    bool? filterWatchEvent,
  }) {
    return Settings(
      filterCreateEvent: filterCreateEvent ?? this.filterCreateEvent,
      filterDeleteEvent: filterDeleteEvent ?? this.filterDeleteEvent,
      filterForkEvent: filterForkEvent ?? this.filterForkEvent,
      filterGollumEvent: filterGollumEvent ?? this.filterGollumEvent,
      filterIssuesEvent: filterIssuesEvent ?? this.filterIssuesEvent,
      filterMemberEvent: filterMemberEvent ?? this.filterMemberEvent,
      filterPublicEvent: filterPublicEvent ?? this.filterPublicEvent,
      filterPushEvent: filterPushEvent ?? this.filterPushEvent,
      filterReleaseEvent: filterReleaseEvent ?? this.filterReleaseEvent,
      filterWatchEvent: filterWatchEvent ?? this.filterWatchEvent,
      filterCommitCommentEvent:
          filterCommitCommentEvent ?? this.filterCommitCommentEvent,
      filterIssueCommentEvent:
          filterIssueCommentEvent ?? this.filterIssueCommentEvent,
      filterPullRequestEvent:
          filterPullRequestEvent ?? this.filterPullRequestEvent,
      filterPullRequestReviewCommentEvent:
          filterPullRequestReviewCommentEvent ??
              this.filterPullRequestReviewCommentEvent,
      filterPullRequestReviewEvent:
          filterPullRequestReviewEvent ?? this.filterPullRequestReviewEvent,
      filterSponsorshipEvent:
          filterSponsorshipEvent ?? this.filterSponsorshipEvent,
    );
  }

  static const kFilterCommitCommentEvent = 'CommitCommentEvent';
  static const kFilterCreateEvent = 'CreateEvent';
  static const kFilterForkEvent = 'ForkEvent';
  static const kFilterGollumEvent = 'GollumEvent';
  static const kFilterIssueCommentEvent = 'IssueCommentEvent';
  static const kFilterIssuesEvent = 'IssuesEvent';
  static const kFilterMemberEvent = 'MemberEvent';
  static const kFilterPublicEvent = 'PublicEvent';
  static const kFilterPullRequestEvent = 'PullRequestEvent';
  static const kFilterPushEvent = 'PushEvent';
  static const kFilterPullRequestReviewEvent = 'PullRequestReviewEvent';
  static const kFilterReleaseEvent = 'ReleaseEvent';
  static const kFilterSponsorshipEvent = 'SponsorshipEvent';
  static const kFilterDeleteEvent = 'DeleteEvent';
  static const kFilterWatchEvent = 'WatchEvent';
  static const kFilterPullRequestReviewCommentEvent =
      'PullRequestReviewCommentEvent';

  final bool filterCommitCommentEvent;
  final bool filterCreateEvent;
  final bool filterForkEvent;
  final bool filterGollumEvent;
  final bool filterIssueCommentEvent;
  final bool filterIssuesEvent;
  final bool filterMemberEvent;
  final bool filterPublicEvent;
  final bool filterPullRequestEvent;
  final bool filterPushEvent;
  final bool filterPullRequestReviewEvent;
  final bool filterReleaseEvent;
  final bool filterPullRequestReviewCommentEvent;
  final bool filterSponsorshipEvent;
  final bool filterDeleteEvent;
  final bool filterWatchEvent;

  Map<String, dynamic> toJson() => {
        kFilterCommitCommentEvent: filterCommitCommentEvent,
        kFilterCreateEvent: filterCreateEvent,
        kFilterForkEvent: filterForkEvent,
        kFilterGollumEvent: filterGollumEvent,
        kFilterIssueCommentEvent: filterIssueCommentEvent,
        kFilterIssuesEvent: filterIssuesEvent,
        kFilterMemberEvent: filterMemberEvent,
        kFilterPublicEvent: filterPublicEvent,
        kFilterPullRequestEvent: filterPullRequestEvent,
        kFilterPushEvent: filterPushEvent,
        kFilterPullRequestReviewEvent: filterPullRequestReviewEvent,
        kFilterReleaseEvent: filterReleaseEvent,
        kFilterSponsorshipEvent: filterSponsorshipEvent,
        kFilterDeleteEvent: filterDeleteEvent,
        kFilterWatchEvent: filterWatchEvent,
        kFilterPullRequestReviewCommentEvent:
            filterPullRequestReviewCommentEvent,
      };
}
