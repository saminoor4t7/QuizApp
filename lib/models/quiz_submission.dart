class SubmittedAnswer {
  const SubmittedAnswer({required this.questionId, required this.answer});

  final int questionId;
  final String answer;

  Map<String, Object> toJson() => {'question_id': questionId, 'answer': answer};
}

class QuestionSubmissionResult {
  const QuestionSubmissionResult({
    required this.questionId,
    required this.correct,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuestionSubmissionResult.fromJson(Map<String, dynamic> json) {
    final questionId = json['question_id'];
    final correct = json['correct'];
    final correctAnswer = json['correct_answer'];
    final explanation = json['explanation'];
    if (questionId is! num && questionId is! String) {
      throw const FormatException('Submission result question_id is invalid.');
    }
    if (correct is! bool ||
        correctAnswer is! String ||
        explanation is! String) {
      throw const FormatException('Submission result fields are invalid.');
    }
    return QuestionSubmissionResult(
      questionId: questionId.toString(),
      correct: correct,
      correctAnswer: correctAnswer,
      explanation: explanation,
    );
  }

  final String questionId;
  final bool correct;
  final String correctAnswer;
  final String explanation;
}

class QuizSubmission {
  const QuizSubmission({
    required this.attemptId,
    required this.score,
    required this.total,
    required this.percentage,
    required this.results,
  });

  factory QuizSubmission.fromJson(Map<String, dynamic> json) {
    final attemptId = json['attempt_id'];
    final score = json['score'];
    final total = json['total'];
    final percentage = json['percentage'];
    final rawResults = json['results'];
    if (attemptId is! num ||
        score is! int ||
        total is! int ||
        percentage is! num ||
        rawResults is! List) {
      throw const FormatException('Quiz submission response is invalid.');
    }
    final results = rawResults
        .map((result) {
          if (result is! Map<String, dynamic>) {
            throw const FormatException(
              'Each submission result must be a JSON object.',
            );
          }
          return QuestionSubmissionResult.fromJson(result);
        })
        .toList(growable: false);
    return QuizSubmission(
      attemptId: attemptId.toInt(),
      score: score,
      total: total,
      percentage: percentage.toDouble(),
      results: List.unmodifiable(results),
    );
  }

  final int attemptId;
  final int score;
  final int total;
  final double percentage;
  final List<QuestionSubmissionResult> results;

  QuestionSubmissionResult? resultFor(String questionId) {
    for (final result in results) {
      if (result.questionId == questionId) return result;
    }
    return null;
  }
}
