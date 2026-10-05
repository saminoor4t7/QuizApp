class QuizProgress {
  const QuizProgress({
    required this.category,
    required this.currentQuestionId,
    required this.answers,
    required this.secondsRemaining,
    required this.elapsedMilliseconds,
    required this.savedAtMilliseconds,
    required this.completedCategories,
  });

  factory QuizProgress.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final currentQuestionId = json['currentQuestionId'];
    final rawAnswers = json['answers'];
    final secondsRemaining = json['secondsRemaining'];
    final elapsedMilliseconds = json['elapsedMilliseconds'];
    final savedAtMilliseconds = json['savedAtMilliseconds'];
    final rawCompletedCategories = json['completedCategories'];

    if (category != null && category is! String ||
        currentQuestionId != null && currentQuestionId is! String ||
        rawAnswers is! Map<String, dynamic> ||
        rawAnswers.values.any((answer) => answer is! int) ||
        secondsRemaining is! int ||
        elapsedMilliseconds is! int ||
        savedAtMilliseconds is! int ||
        rawCompletedCategories is! List ||
        rawCompletedCategories.any((item) => item is! String)) {
      throw const FormatException('Saved quiz progress is invalid.');
    }

    return QuizProgress(
      category: category as String?,
      currentQuestionId: currentQuestionId as String?,
      answers: Map.unmodifiable(
        rawAnswers.map(
          (questionId, answer) =>
              MapEntry(questionId, answer as int),
        ),
      ),
      secondsRemaining: secondsRemaining,
      elapsedMilliseconds: elapsedMilliseconds,
      savedAtMilliseconds: savedAtMilliseconds,
      completedCategories: List.unmodifiable(
        rawCompletedCategories.cast<String>(),
      ),
    );
  }

  final String? category;
  final String? currentQuestionId;
  final Map<String, int> answers;
  final int secondsRemaining;
  final int elapsedMilliseconds;
  final int savedAtMilliseconds;
  final List<String> completedCategories;

  Map<String, Object?> toJson() => {
    'category': category,
    'currentQuestionId': currentQuestionId,
    'answers': answers,
    'secondsRemaining': secondsRemaining,
    'elapsedMilliseconds': elapsedMilliseconds,
    'savedAtMilliseconds': savedAtMilliseconds,
    'completedCategories': completedCategories,
  };
}
