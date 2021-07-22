import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:github/github.dart';

const mockDefaultAvatar =
    'https://avatars.githubusercontent.com/in/15368?s=64&v=4';

final mockRepoResponse = Response(
  requestOptions: RequestOptions(
    path: '',
  ),
  data: jsonDecode(
    jsonEncode(
      Repository(
        name: 'NAME',
        fullName: 'FULLNAME',
        htmlUrl: 'https://google.com',
        owner: UserInformation(
          'LOGIN',
          -111,
          mockDefaultAvatar,
          'htmlUrl',
        ),
        language: 'LANG',
        description: 'DESC',
        watchersCount: -222,
        stargazersCount: -333,
        forksCount: -444,
        subscribersCount: -555,
        openIssuesCount: -666,
      ),
    ),
  ),
);
