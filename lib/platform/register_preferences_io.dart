import 'dart:io';

import 'package:shared_preferences_windows/shared_preferences_windows.dart';

Future<void> registerPreferencesPlatform() async {
  if (Platform.isWindows) {
    SharedPreferencesWindows.registerWith();
  }
}
