import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quiz_submission.dart';
import 'api_exception.dart';

class QuizSubmissionService {
  const QuizSubmissionService({
    required http.Client client,
    required Uri baseUri,
  }) : _client = client,
       _baseUri = baseUri;

  final http.Client _client;
  final Uri _baseUri;

  Future<QuizSubmission> submitAnswers(List<SubmittedAnswer> answers) async {
    final uri = _baseUri.resolve('/api/quiz/submit/');
    final response = await _client
        .post(
          uri,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'answers': answers.map((answer) => answer.toJson()).toList(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Could not submit quiz answers (HTTP ${response.statusCode}).',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException catch (error) {
      throw ApiException(
        'The quiz submission API returned invalid JSON: $error',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        'The quiz submission API must return a JSON object.',
      );
    }
    return QuizSubmission.fromJson(decoded);
  }
}
