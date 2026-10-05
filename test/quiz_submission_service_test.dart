import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quiz_app/models/quiz_submission.dart';
import 'package:quiz_app/services/quiz_submission_service.dart';

void main() {
  test('submits selected answers and parses backend grading', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/quiz/submit/');
      expect(jsonDecode(request.body), {
        'answers': [
          {'question_id': 16, 'answer': 'var'},
          {'question_id': 17, 'answer': 'const'},
        ],
      });
      return http.Response(
        jsonEncode({
          'attempt_id': 5,
          'score': 1,
          'total': 2,
          'percentage': 50.0,
          'results': [
            {
              'question_id': 16,
              'correct': true,
              'correct_answer': 'var',
              'explanation': '',
            },
            {
              'question_id': 17,
              'correct': false,
              'correct_answer': 'bool',
              'explanation': '',
            },
          ],
        }),
        200,
      );
    });
    final service = QuizSubmissionService(
      client: client,
      baseUri: Uri.parse('http://localhost:8000'),
    );

    final result = await service.submitAnswers(const [
      SubmittedAnswer(questionId: 16, answer: 'var'),
      SubmittedAnswer(questionId: 17, answer: 'const'),
    ]);

    expect(result.attemptId, 5);
    expect(result.score, 1);
    expect(result.total, 2);
    expect(result.percentage, 50);
    expect(result.resultFor('17')?.correct, isFalse);
    expect(result.resultFor('17')?.correctAnswer, 'bool');
    client.close();
  });
}
