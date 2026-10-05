import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_app/platform/register_preferences.dart';

void main() {
  test(
    'registers the Windows shared-preferences implementation at startup',
    () async {
      if (defaultTargetPlatform != TargetPlatform.windows) return;

      await registerPreferencesPlatform();

      expect(() => SharedPreferencesAsync(), returnsNormally);
    },
  );
}
