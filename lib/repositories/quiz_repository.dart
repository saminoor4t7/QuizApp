import '../models/question.dart';
import '../models/quiz_submission.dart';

abstract interface class QuizRepository {
  Future<List<Question>> loadQuestions({String? category});

  Future<QuizSubmission> submitAnswers(List<SubmittedAnswer> answers);
}
