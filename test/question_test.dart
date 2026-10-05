import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/models/question.dart';

void main() {
  const questionJson = {
    'id': 16,
    'category': 'Variables and data types',
    'prompt': 'Which keyword declares a local variable?',
    'options': ['var', 'final', 'const', 'static'],
  };

  test('parses the API response without an answer key', () {
    final question = Question.fromJson(questionJson);

    expect(question.id, '16');
    expect(question.category, 'Variables and data types');
    expect(question.options, ['var', 'final', 'const', 'static']);
    expect(question.answerIndex, isNull);
    expect(question.isCorrect(0), isNull);
  });

  test('uses correctAnswer option text for scoring', () {
    final question = Question.fromJson({
      ...questionJson,
      'correctAnswer': 'var',
      'explanation': 'var values can be reassigned.',
    });

    expect(question.answerIndex, 0);
    expect(question.isCorrect(0), isTrue);
    expect(question.isCorrect(1), isFalse);
  });

  test('rejects a correctAnswer that is not one of the options', () {
    expect(
      () => Question.fromJson({...questionJson, 'correctAnswer': 'dynamic'}),
      throwsFormatException,
    );
  });
}
