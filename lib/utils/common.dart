import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

const kBoxSharedPrefs = 'kBoxSharedPrefs';
const kBoxKeySecretApi = 'kBoxKeySecretApi';
const kBoxKeyUserJson = 'kBoxKeyUserJson';
const kBoxKeySettings = 'kBoxKeySettings';

const defaultAvatar = 'https://avatars.githubusercontent.com/in/15368?s=64&v=4';

bool get isMobileDevice =>
    !kIsWeb && (Platform.isIOS || Platform.isAndroid || Platform.isFuchsia);
bool get isDesktopDevice =>
    !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
bool get isMobileDeviceOrWeb => kIsWeb || isMobileDevice;
bool get isDesktopDeviceOrWeb => kIsWeb || isDesktopDevice;

enum ScreenSize { small, normal, large, extraLarge }

ScreenSize getSize(BuildContext context) {
  final deviceWidth = MediaQuery.of(context).size.shortestSide;
  if (deviceWidth > 900) return ScreenSize.extraLarge;
  if (deviceWidth > 600) return ScreenSize.large;
  if (deviceWidth > 300) return ScreenSize.normal;
  return ScreenSize.small;
}
