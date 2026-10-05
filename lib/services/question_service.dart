import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/question.dart';
import 'api_exception.dart';

class QuestionService {
  const QuestionService({required http.Client client, required Uri baseUri})
    : _client = client,
      _baseUri = baseUri;

  final http.Client _client;
  final Uri _baseUri;

  Future<List<Question>> fetchQuestions({String? category}) async {
    final uri = _baseUri
        .resolve('/api/questions/')
        .replace(
          queryParameters: category == null ? null : {'category': category},
        );
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Could not load questions (HTTP ${response.statusCode}).',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException catch (error) {
      throw ApiException('The questions API returned invalid JSON: $error');
    }

    final List<dynamic> rawQuestions;
    if (decoded is List) {
      rawQuestions = decoded;
    } else if (decoded is Map<String, dynamic> &&
        decoded['results'] is List<dynamic>) {
      rawQuestions = decoded['results'] as List<dynamic>;
    } else {
      throw const ApiException(
        'The questions API must return a list of questions.',
      );
    }

    return List<Question>.unmodifiable(
      rawQuestions.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException(
            'Each question in the API response must be a JSON object.',
          );
        }
        return Question.fromJson(item);
      }),
    );
  }
}
