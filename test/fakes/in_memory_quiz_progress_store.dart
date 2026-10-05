import 'package:quiz_app/models/quiz_progress.dart';
import 'package:quiz_app/services/quiz_progress_store.dart';

class InMemoryQuizProgressStore implements QuizProgressStore {
  QuizProgress? progress;

  @override
  Future<void> clear() async {
    progress = null;
  }

  @override
  Future<QuizProgress?> load() async => progress;

  @override
  Future<void> save(QuizProgress progress) async {
    this.progress = progress;
  }
}
