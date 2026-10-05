import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/quiz_progress.dart';

abstract interface class QuizProgressStore {
  Future<QuizProgress?> load();
  Future<void> save(QuizProgress progress);
  Future<void> clear();
}

class SharedPreferencesQuizProgressStore implements QuizProgressStore {
  SharedPreferencesQuizProgressStore(this._preferences);

  static const _progressKey = 'quiz_progress';

  final SharedPreferencesAsync _preferences;

  @override
  Future<QuizProgress?> load() async {
    final encoded = await _preferences.getString(_progressKey);
    if (encoded == null) return null;

    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Saved quiz progress must be a JSON object.');
    }
    return QuizProgress.fromJson(decoded);
  }

  @override
  Future<void> save(QuizProgress progress) =>
      _preferences.setString(_progressKey, jsonEncode(progress.toJson()));

  @override
  Future<void> clear() => _preferences.remove(_progressKey);
}
