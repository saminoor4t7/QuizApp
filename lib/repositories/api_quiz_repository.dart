import '../models/question.dart';
import '../models/quiz_submission.dart';
import '../services/question_service.dart';
import '../services/quiz_submission_service.dart';
import 'quiz_repository.dart';

class ApiQuizRepository implements QuizRepository {
  const ApiQuizRepository({
    required QuestionService questionService,
    required QuizSubmissionService submissionService,
  }) : _questionService = questionService,
       _submissionService = submissionService;

  final QuestionService _questionService;
  final QuizSubmissionService _submissionService;

  @override
  Future<List<Question>> loadQuestions({String? category}) =>
      _questionService.fetchQuestions(category: category);

  @override
  Future<QuizSubmission> submitAnswers(List<SubmittedAnswer> answers) =>
      _submissionService.submitAnswers(answers);
}
