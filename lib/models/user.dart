import 'package:flutter/material.dart';
import 'package:github/github.dart';

class UserWrapper extends ChangeNotifier {
  UserWrapper(this._user);

  User _user;

  User getUser() => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}

extension UserCopyWith on User {
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
