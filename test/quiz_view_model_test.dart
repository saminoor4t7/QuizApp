import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/models/quiz_submission.dart';
import 'package:quiz_app/repositories/quiz_repository.dart';
import 'package:quiz_app/viewmodels/quiz_view_model.dart';
import 'package:quiz_app/views/quiz_results_view.dart';

class _FakeQuestionRepository implements QuizRepository {
  final List<String?> requestedCategories = [];
  List<SubmittedAnswer> lastSubmittedAnswers = [];
  int firstCategoryCorrectCount = 2;

  List<Question> get questions => [
    for (var index = 0; index < 5; index++)
      Question(
        id: '$index',
        category: 'Variables and data types',
        prompt: 'Question $index',
        options: const ['correct', 'incorrect'],
        answerIndex: index < firstCategoryCorrectCount ? 0 : 1,
      ),
    Question(
      id: 'second',
      category: 'Constants',
      prompt: 'Compile-time constant?',
      options: const ['final', 'const'],
      answerIndex: 1,
    ),
  ];

  @override
  Future<List<Question>> loadQuestions({String? category}) async {
    requestedCategories.add(category);
    return category == null
        ? questions
        : questions.where((question) => question.category == category).toList();
  }

  @override
  Future<QuizSubmission> submitAnswers(List<SubmittedAnswer> answers) async {
    lastSubmittedAnswers = answers;
    final currentQuestions = questions
        .where(
          (question) => answers.any(
            (answer) => answer.questionId.toString() == question.id,
          ),
        )
        .toList();
    final results = answers.map((answer) {
      final question = currentQuestions.firstWhere(
        (question) => question.id == answer.questionId.toString(),
      );
      return QuestionSubmissionResult(
        questionId: question.id,
        correct: question.options[question.answerIndex!] == answer.answer,
        correctAnswer: question.options[question.answerIndex!],
        explanation: '',
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

Future<void> _answerCategory(QuizViewModel viewModel) async {
  for (var index = 0; index < viewModel.totalQuestions; index++) {
    viewModel.selectAnswer(0);
    await viewModel.nextQuestion();
  }
}

void main() {
  test(
    'requires 60 percent and allows a failed category to be retried',
    () async {
      final repository = _FakeQuestionRepository();
      final viewModel = QuizViewModel(repository: repository);
      addTearDown(viewModel.dispose);

      await viewModel.load();
      expect(viewModel.phase, QuizPhase.categories);
      expect(viewModel.isCategoryUnlocked('Constants'), isFalse);
      await viewModel.openCategory('Constants');
      expect(repository.requestedCategories, [null]);

      await viewModel.openCategory('Variables and data types');
      expect(viewModel.secondsRemaining, 30);
      await _answerCategory(viewModel);
      expect(viewModel.percentage, 40);
      expect(viewModel.passedCurrentCategory, isFalse);
      expect(viewModel.isCategoryUnlocked('Constants'), isFalse);
      expect(viewModel.phase, QuizPhase.complete);

      repository.firstCategoryCorrectCount = 3;
      viewModel.retry();
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.phase, QuizPhase.ready);
      await _answerCategory(viewModel);
      expect(viewModel.percentage, 60);
      expect(viewModel.passedCurrentCategory, isTrue);
      expect(viewModel.isCategoryUnlocked('Constants'), isTrue);

      viewModel.returnToCategories();
      await viewModel.openCategory('Constants');
      expect(repository.requestedCategories.last, 'Constants');
      expect(viewModel.currentQuestion?.prompt, contains('constant'));
      expect(viewModel.secondsRemaining, 30);
    },
  );

  testWidgets('shows the server percentage and retry action after a fail', (
    tester,
  ) async {
    final viewModel = QuizViewModel(repository: _FakeQuestionRepository());
    addTearDown(viewModel.dispose);
    await viewModel.load();
    await viewModel.openCategory('Variables and data types');
    await _answerCategory(viewModel);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ResultsPanel(viewModel: viewModel),
          ),
        ),
      ),
    );

    expect(find.text('40%'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(
      find.text(
        'You need at least 60% to unlock the next category. Try this category again.',
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(viewModel.phase, QuizPhase.ready);
    viewModel.selectAnswer(0);
  });

  test('times out unanswered questions and advances automatically', () async {
    final repository = _FakeQuestionRepository();
    final viewModel = QuizViewModel(
      repository: repository,
      questionTimeLimit: const Duration(seconds: 1),
    );
    addTearDown(viewModel.dispose);

    await viewModel.load();
    await viewModel.openCategory('Variables and data types');
    expect(viewModel.secondsRemaining, 1);
    expect(viewModel.isAnswered, isFalse);

    await Future<void>.delayed(const Duration(milliseconds: 2400));

    expect(viewModel.answerHistory.first, -1);
    expect(viewModel.currentIndex, 1);
    expect(viewModel.timedOut, isFalse);
    expect(viewModel.isAnswered, isFalse);
    expect(viewModel.secondsRemaining, 1);

    for (var index = 1; index < viewModel.totalQuestions; index++) {
      viewModel.selectAnswer(viewModel.questions[index].answerIndex!);
      await viewModel.nextQuestion();
    }
    expect(viewModel.phase, QuizPhase.complete);
    expect(repository.lastSubmittedAnswers.first.answer, isEmpty);
  });
}
