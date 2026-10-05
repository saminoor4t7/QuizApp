import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/main.dart';
import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/models/quiz_submission.dart';
import 'package:quiz_app/providers/quiz_providers.dart';
import 'package:quiz_app/repositories/quiz_repository.dart';

import 'fakes/in_memory_quiz_progress_store.dart';

class _FakeQuestionRepository implements QuizRepository {
  List<Question> questions = [
    Question(
      id: '1',
      category: 'Variables and data types',
      prompt: 'Which keyword declares a local variable?',
      options: const ['var', 'final', 'const'],
      answerIndex: 0,
      explanation: 'A var declaration can be reassigned.',
    ),
    Question(
      id: '2',
      category: 'Constants',
      prompt: 'Which keyword declares a compile-time constant?',
      options: const ['final', 'const'],
      answerIndex: 1,
    ),
  ];

  @override
  Future<List<Question>> loadQuestions({String? category}) async =>
      category == null
      ? questions
      : questions.where((question) => question.category == category).toList();

  @override
  Future<QuizSubmission> submitAnswers(List<SubmittedAnswer> answers) async {
    final results = answers.map((answer) {
      final question = questions.firstWhere(
        (question) => question.id == '${answer.questionId}',
      );
      final correct = question.options[question.answerIndex!] == answer.answer;
      return QuestionSubmissionResult(
        questionId: question.id,
        correct: correct,
        correctAnswer: question.options[question.answerIndex!],
        explanation: question.explanation ?? '',
      );
    }).toList();
    final score = results.where((result) => result.correct).length;
    return QuizSubmission(
      attemptId: 1,
      score: score,
      total: results.length,
      percentage: score * 100 / results.length,
      results: results,
    );
  }
}

void main() {
  testWidgets('locks later categories until the previous one is completed', (
    tester,
  ) async {
    final repository = _FakeQuestionRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionRepositoryProvider.overrideWithValue(repository),
          quizProgressStoreProvider.overrideWithValue(
            InMemoryQuizProgressStore(),
          ),
        ],
        child: const QuizApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('THE DAILY QUIZ'), findsOneWidget);
    expect(find.text('YOUR LEARNING PATH'), findsOneWidget);
    expect(find.text('Variables and data types'), findsOneWidget);
    expect(find.text('Constants'), findsOneWidget);

    await tester.tap(find.text('Constants'));
    await tester.pump();
    expect(find.text('Complete the previous category first.'), findsOneWidget);

    await tester.tap(find.text('Variables and data types'));
    await tester.pumpAndSettle();
    expect(
      find.text('Which keyword declares a local variable?'),
      findsOneWidget,
    );

    repository.questions.add(
      Question(
        id: '3',
        category: 'Variables and data types',
        prompt: 'A question added by an administrator',
        options: const ['var', 'dynamic'],
        answerIndex: 0,
      ),
    );
    await tester.tap(find.byTooltip('Refresh questions from the server'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 questions'), findsOneWidget);

    await tester.tap(find.text('Variables and data types'));
    await tester.pumpAndSettle();
    expect(find.text('1 OF 2'), findsOneWidget);
  });
}
