import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quiz_app/services/api_exception.dart';
import 'package:quiz_app/services/question_service.dart';

void main() {
  test('fetches and parses questions from the configured endpoint', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/questions/');
      expect(request.url.queryParameters['category'], 'Null safety');
      return http.Response(
        jsonEncode([
          {
            'id': 16,
            'category': 'Variables and data types',
            'prompt': 'Which keyword can be reassigned?',
            'options': ['var', 'final', 'const'],
            'correctAnswer': 'var',
          },
        ]),
        200,
      );
    });
    final service = QuestionService(
      client: client,
      baseUri: Uri.parse('http://localhost:8000'),
    );

    final questions = await service.fetchQuestions(category: 'Null safety');

    expect(questions, hasLength(1));
    expect(questions.single.id, '16');
    expect(questions.single.answerIndex, 0);
    client.close();
  });

  test('reports unsuccessful API responses', () async {
    final client = MockClient((_) async => http.Response('Unavailable', 503));
    final service = QuestionService(
      client: client,
      baseUri: Uri.parse('http://localhost:8000'),
    );

    await expectLater(
      service.fetchQuestions(),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          contains('HTTP 503'),
        ),
      ),
    );
    client.close();
  });

}
