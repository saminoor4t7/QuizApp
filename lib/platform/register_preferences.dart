import 'register_preferences_stub.dart'
    if (dart.library.io) 'register_preferences_io.dart' as platform;

Future<void> registerPreferencesPlatform() =>
    platform.registerPreferencesPlatform();
