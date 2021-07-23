import 'package:github/github.dart';

// class UserWrapper extends ChangeNotifier {
//   UserWrapper(this._user);

//   User _user;

//   User getUser() => _user;

//   void setUser(User user) {
//     _user = user;
//     notifyListeners();
//   }
// }

extension UserWrapper on User {
  static User fromJsonHive(Map<dynamic, dynamic> json) => User(
        id: json['id'] as int?,
        login: json['login'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        htmlUrl: json['html_url'] as String?,
        siteAdmin: json['site_admin'] as bool?,
        name: json['name'] as String?,
        company: json['company'] as String?,
        blog: json['blog'] as String?,
        location: json['location'] as String?,
        email: json['email'] as String?,
        hirable: json['hirable'] as bool?,
        bio: json['bio'] as String?,
        publicReposCount: json['public_repos'] as int?,
        publicGistsCount: json['public_gists'] as int?,
        followersCount: json['followers'] as int?,
        followingCount: json['following'] as int?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
      )..twitterUsername = json['twitter_username'] as String?;

  User copyWith({
    id,
    login,
    avatarUrl,
    htmlUrl,
    siteAdmin,
    name,
    company,
    blog,
    location,
    email,
    hirable,
    bio,
    publicReposCount,
    publicGistsCount,
    followersCount,
    followingCount,
    createdAt,
    updatedAt,
  }) =>
      User(
        avatarUrl: avatarUrl ?? this.avatarUrl,
        bio: bio ?? this.bio,
        blog: blog ?? this.blog,
        company: company ?? this.company,
        createdAt: createdAt ?? this.createdAt,
        email: email ?? this.email,
        followersCount: followersCount ?? this.followersCount,
        followingCount: followingCount ?? this.followingCount,
        hirable: hirable ?? this.hirable,
        htmlUrl: htmlUrl ?? this.htmlUrl,
        id: id ?? this.id,
        location: location ?? this.location,
        login: login ?? this.login,
        name: name ?? this.name,
        publicGistsCount: publicGistsCount ?? this.publicGistsCount,
        publicReposCount: publicReposCount ?? this.publicReposCount,
        siteAdmin: siteAdmin ?? this.siteAdmin,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
