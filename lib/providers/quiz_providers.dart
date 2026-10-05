import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/api_quiz_repository.dart';
import '../repositories/quiz_repository.dart';
import '../services/question_service.dart';
import '../services/quiz_progress_store.dart';
import '../services/quiz_submission_service.dart';
import '../viewmodels/quiz_view_model.dart';

final apiClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final apiBaseUriProvider = Provider<Uri>((ref) {
  return Uri.parse(
    const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000',
    ),
  );
});

final quizProgressStoreProvider = Provider<QuizProgressStore>((ref) {
  return SharedPreferencesQuizProgressStore(SharedPreferencesAsync());
});

final questionServiceProvider = Provider<QuestionService>((ref) {
  return QuestionService(
    client: ref.watch(apiClientProvider),
    baseUri: ref.watch(apiBaseUriProvider),
  );
});

final quizSubmissionServiceProvider = Provider<QuizSubmissionService>((ref) {
  return QuizSubmissionService(
    client: ref.watch(apiClientProvider),
    baseUri: ref.watch(apiBaseUriProvider),
  );
});

final questionRepositoryProvider = Provider<QuizRepository>((ref) {
  return ApiQuizRepository(
    questionService: ref.watch(questionServiceProvider),
    submissionService: ref.watch(quizSubmissionServiceProvider),
  );
});

final quizViewModelProvider = ChangeNotifierProvider<QuizViewModel>((ref) {
  final viewModel = QuizViewModel(
    repository: ref.watch(questionRepositoryProvider),
    progressStore: ref.watch(quizProgressStoreProvider),
  );
  unawaited(viewModel.load(resumeSavedProgress: true));
  return viewModel;
});
