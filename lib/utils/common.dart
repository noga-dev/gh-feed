import 'dart:io';

import 'package:flutter/foundation.dart';

const kBoxSharedPrefs = 'sharedPrefsBox';
const kBoxKeySecretApi = 'secretKey';
const kBoxKeyUserLogin = 'userLogin';
const kBoxKeySettings = 'settings';

const defaultUserLogin = 'rrousselGit';
const defaultAvatar = 'https://avatars.githubusercontent.com/in/15368?s=64&v=4';

bool get isMobileDevice =>
    !kIsWeb && (Platform.isIOS || Platform.isAndroid || Platform.isFuchsia);
bool get isDesktopDevice =>
    !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
bool get isMobileDeviceOrWeb => kIsWeb || isMobileDevice;
bool get isDesktopDeviceOrWeb => kIsWeb || isDesktopDevice;
