import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/question.dart';
import '../models/quiz_submission.dart';
import '../repositories/quiz_repository.dart';

enum QuizPhase { loading, categories, ready, submitting, complete, error }

const categoryPassingPercentage = 60;
const defaultQuestionTimeLimit = Duration(seconds: 30);
const timeUpFeedbackDuration = Duration(milliseconds: 1200);

abstract class QuizViewModelBase extends ChangeNotifier {
  Future<void> load({String? category});
  Future<void> openCategory(String category);
  void selectAnswer(int index);
  Future<void> nextQuestion();
  void refreshCategories();
  void retry();
  void returnToCategories();
}

class QuizViewModel extends QuizViewModelBase {
  QuizViewModel({
    required QuizRepository repository,
    Duration questionTimeLimit = defaultQuestionTimeLimit,
  }) : _repository = repository,
       _questionTimeLimit = questionTimeLimit;

  final QuizRepository _repository;
  final Duration _questionTimeLimit;
  final StreamController<int> _scoreController =
      StreamController<int>.broadcast();
  final Map<int, int> _answers = {};
  final Set<int> _correctQuestions = {};
  final Set<String> _completedCategories = {};
  final List<int> _answerHistory = [];
  late DateTime _startedAt;
  List<Question> _catalogQuestions = const [];
  List<Question> _questions = const [];
  List<String> _categories = const [];
  String? _selectedCategory;
  int _currentIndex = 0;
  int? _selectedIndex;
  QuizSubmission? _submission;
  bool _submissionFailed = false;
  bool _timedOut = false;
  int _secondsRemaining = defaultQuestionTimeLimit.inSeconds;
  Timer? _questionTimer;
  Timer? _timeoutAdvanceTimer;
  QuizPhase _phase = QuizPhase.loading;
  Object? _error;
  bool _disposed = false;
  int _loadGeneration = 0;

  List<Question> get questions => _questions;
  List<String> get categories => _categories;
  Set<String> get completedCategories => Set.unmodifiable(_completedCategories);
  String? get selectedCategory => _selectedCategory;
  int get currentIndex => _currentIndex;
  int get totalQuestions => _questions.length;
  int get submittedTotal => _submission?.total ?? totalQuestions;
  int get gradedQuestionCount =>
      _questions.where((question) => question.answerIndex != null).length;
  int? get selectedIndex => _selectedIndex;
  QuizPhase get phase => _phase;
  Object? get error => _error;
  int get score => _submission?.score ?? _correctQuestions.length;
  int get percentage =>
      _submission?.percentage.round() ??
      (_questions.isEmpty ? 0 : (score * 100 / _questions.length).round());
  bool get passedCurrentCategory =>
      _submission != null &&
      _submission!.percentage >= categoryPassingPercentage;
  bool get hasUnscoredQuestions =>
      _submission == null &&
      _questions.any((question) => question.answerIndex == null);
  int get answeredCount => _answers.length;
  double get progress =>
      _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;
  Question? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_currentIndex];
  bool get isAnswered => _selectedIndex != null;
  bool get timedOut => _timedOut;
  int get secondsRemaining => _secondsRemaining;
  String get questionTimeRemaining =>
      '00:${_secondsRemaining.toString().padLeft(2, '0')}';
  bool? get isCorrect {
    final question = currentQuestion;
    if (question == null) return null;
    return _submission?.resultFor(question.id)?.correct ??
        question.isCorrect(_selectedIndex ?? -1);
  }

  bool get isLastQuestion =>
      _questions.isNotEmpty && _currentIndex == _questions.length - 1;
  String get elapsedTime {
    final elapsed = DateTime.now().difference(_startedAt);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Stream<int> get scoreUpdates => _scoreController.stream;
  List<int> get answerHistory => List.unmodifiable(_answerHistory);
  QuestionSubmissionResult? resultForQuestion(String questionId) =>
      _submission?.resultFor(questionId);

  int? correctAnswerIndexFor(Question question) {
    final result = resultForQuestion(question.id);
    if (result != null) {
      final index = question.options.indexOf(result.correctAnswer);
      return index < 0 ? null : index;
    }
    return question.answerIndex;
  }

  int questionCountFor(String category) => _catalogQuestions
      .where((question) => question.category == category)
      .length;

  bool isCategoryCompleted(String category) =>
      _completedCategories.contains(category);

  bool isCategoryUnlocked(String category) {
    final index = _categories.indexOf(category);
    return index >= 0 &&
        _categories.take(index).every(_completedCategories.contains);
  }

  @override
  Future<void> load({String? category}) async {
    _stopQuestionTimers();
    final generation = ++_loadGeneration;
    _selectedCategory = category;
    if (category != null) _completedCategories.remove(category);
    _phase = QuizPhase.loading;
    _error = null;
    notifyListeners();
    try {
      final questions = await _repository.loadQuestions(category: category);
      if (_disposed || generation != _loadGeneration) return;
      if (questions.isEmpty) {
        throw StateError(
          category == null
              ? 'The quiz has no questions.'
              : 'There are no questions in the "$category" category.',
        );
      }

      _resetCurrentQuiz();
      if (category == null) {
        _catalogQuestions = questions;
        _categories = List.unmodifiable(
          questions.map((question) => question.category).toSet(),
        );
        _completedCategories.removeWhere(
          (completed) => !_categories.contains(completed),
        );
        _phase = QuizPhase.categories;
      } else {
        _questions = questions;
        _phase = QuizPhase.ready;
        _startQuestionTimer();
      }
      _startedAt = DateTime.now();
    } catch (error) {
      if (_disposed || generation != _loadGeneration) return;
      _error = error;
      _phase = QuizPhase.error;
    }
    if (!_disposed) notifyListeners();
  }

  @override
  Future<void> openCategory(String category) async {
    if (!isCategoryUnlocked(category)) return;
    await load(category: category);
  }

  @override
  void selectAnswer(int index) {
    final question = currentQuestion;
    if (_phase != QuizPhase.ready || question == null || isAnswered) return;
    if (index < 0 || index >= question.options.length) return;
    _selectedIndex = index;
    _timedOut = false;
    _questionTimer?.cancel();
    _answers[_currentIndex] = index;
    _answerHistory.add(index);
    if (question.isCorrect(index) == true) {
      _correctQuestions.add(_currentIndex);
    }
    _scoreController.add(score);
    notifyListeners();
  }

  @override
  Future<void> nextQuestion() async {
    if (_phase != QuizPhase.ready || !isAnswered) return;
    _stopQuestionTimers();
    if (isLastQuestion) {
      await _submitCurrentAnswers();
    } else {
      _currentIndex++;
      _selectedIndex = _answers[_currentIndex];
      _timedOut = false;
      _startQuestionTimer();
      notifyListeners();
    }
  }

  @override
  void refreshCategories() {
    unawaited(load());
  }

  @override
  void retry() {
    if (_submissionFailed) {
      unawaited(_submitCurrentAnswers());
    } else {
      unawaited(load(category: _selectedCategory));
    }
  }

  @override
  void returnToCategories() {
    if (_phase != QuizPhase.complete || !passedCurrentCategory) return;
    _selectedCategory = null;
    _phase = QuizPhase.categories;
    notifyListeners();
  }

  Future<void> _submitCurrentAnswers() async {
    final category = _selectedCategory;
    if (category == null) return;
    final generation = ++_loadGeneration;
    _phase = QuizPhase.submitting;
    _error = null;
    _submissionFailed = false;
    notifyListeners();
    try {
      final answers = <SubmittedAnswer>[];
      for (var index = 0; index < _questions.length; index++) {
        final selected = _answers[index];
        if (selected == null) {
          throw StateError(
            'Every question must be answered before submission.',
          );
        }
        final questionId = int.tryParse(_questions[index].id);
        if (questionId == null) {
          throw FormatException(
            'Question id "${_questions[index].id}" must be an integer to submit.',
          );
        }
        answers.add(
          SubmittedAnswer(
            questionId: questionId,
            answer: selected < 0 ? '' : _questions[index].options[selected],
          ),
        );
      }

      final submission = await _repository.submitAnswers(answers);
      if (_disposed || generation != _loadGeneration) return;
      _submission = submission;
      if (submission.percentage >= categoryPassingPercentage) {
        _completedCategories.add(category);
      } else {
        _completedCategories.remove(category);
      }
      _phase = QuizPhase.complete;
      _scoreController.add(submission.score);
    } catch (error) {
      if (_disposed || generation != _loadGeneration) return;
      _error = error;
      _submissionFailed = true;
      _phase = QuizPhase.error;
    }
    if (!_disposed) notifyListeners();
  }

  void _resetCurrentQuiz() {
    _stopQuestionTimers();
    _answers.clear();
    _correctQuestions.clear();
    _answerHistory.clear();
    _currentIndex = 0;
    _selectedIndex = null;
    _timedOut = false;
    _secondsRemaining = _questionTimeLimit.inSeconds;
    _submission = null;
    _submissionFailed = false;
    _questions = const [];
    _scoreController.add(0);
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _timeoutAdvanceTimer?.cancel();
    _secondsRemaining = _questionTimeLimit.inSeconds;
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed || _phase != QuizPhase.ready || isAnswered) {
        timer.cancel();
        return;
      }
      _secondsRemaining--;
      if (_secondsRemaining <= 0) {
        timer.cancel();
        _recordTimedOutAnswer();
        return;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void _recordTimedOutAnswer() {
    if (_phase != QuizPhase.ready || isAnswered) return;
    _selectedIndex = -1;
    _timedOut = true;
    _answers[_currentIndex] = -1;
    _answerHistory.add(-1);
    _scoreController.add(score);
    notifyListeners();
    _timeoutAdvanceTimer = Timer(timeUpFeedbackDuration, () {
      if (!_disposed && _phase == QuizPhase.ready && isAnswered) {
        unawaited(nextQuestion());
      }
    });
  }

  void _stopQuestionTimers() {
    _questionTimer?.cancel();
    _questionTimer = null;
    _timeoutAdvanceTimer?.cancel();
    _timeoutAdvanceTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _loadGeneration++;
    _stopQuestionTimers();
    unawaited(_scoreController.close());
    super.dispose();
  }
}
