class Question {
  Question({
    required this.id,
    required this.category,
    required this.prompt,
    required this.options,
    this.answerIndex,
    this.explanation,
    this.readingTime = '30 sec',
  }) {
    if (options.length < 2) {
      throw const FormatException('A question must have at least two options.');
    }
    if (answerIndex != null &&
        (answerIndex! < 0 || answerIndex! >= options.length)) {
      throw const FormatException(
        'The correct answer must match one of the available options.',
      );
    }
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final category = json['category'];
    final prompt = json['prompt'];
    final rawOptions = json['options'];
    if (id is! num && id is! String) {
      throw const FormatException('Question id must be a number or string.');
    }
    if (category is! String || category.trim().isEmpty) {
      throw const FormatException('Question category must be a non-empty string.');
    }
    if (prompt is! String || prompt.trim().isEmpty) {
      throw const FormatException('Question prompt must be a non-empty string.');
    }
    if (rawOptions is! List || rawOptions.any((option) => option is! String)) {
      throw const FormatException('Question options must be a list of strings.');
    }

    final options = List<String>.unmodifiable(rawOptions.cast<String>());
    final correctAnswer = json['correctAnswer'];
    final rawAnswerIndex = json['answerIndex'];
    int? answerIndex;
    if (correctAnswer != null) {
      if (correctAnswer is! String) {
        throw const FormatException('correctAnswer must be an option string.');
      }
      answerIndex = options.indexOf(correctAnswer);
      if (answerIndex < 0) {
        throw const FormatException(
          'correctAnswer must exactly match one of the options.',
        );
      }
    } else if (rawAnswerIndex != null) {
      if (rawAnswerIndex is! int) {
        throw const FormatException('answerIndex must be an integer.');
      }
      answerIndex = rawAnswerIndex;
    }

    final explanation = json['explanation'];
    if (explanation != null && explanation is! String) {
      throw const FormatException('Question explanation must be a string.');
    }

    return Question(
      id: id.toString(),
      category: category,
      prompt: prompt,
      options: options,
      answerIndex: answerIndex,
      explanation: explanation as String?,
    );
  }

  final String id;
  final String category;
  final String prompt;
  final List<String> options;
  final int? answerIndex;
  final String? explanation;
  final String readingTime;

  bool? isCorrect(int selectedIndex) {
    final correctIndex = answerIndex;
    return correctIndex == null ? null : selectedIndex == correctIndex;
  }
}
