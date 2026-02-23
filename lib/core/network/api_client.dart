import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final http.Client _client;
  String? _baseUrl;
  String? _apiKey;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void configure({required String baseUrl, String? apiKey}) {
    _baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    _apiKey = apiKey;
  }

  bool get isConfigured => _baseUrl != null && _baseUrl!.isNotEmpty;

  Future<bool> testConnection() async {
    if (!isConfigured) return false;

    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/v1/models'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectionTimeout));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getModels() async {
    if (!isConfigured) {
      throw Exception(Exceptions.networkException);
    }

    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/v1/models'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectionTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> models = data['data'] ?? [];
        return models.map((m) => m['id']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      } else if (response.statusCode == 401) {
        throw Exception(Exceptions.apiKeyException);
      } else if (response.statusCode == 429) {
        throw Exception(Exceptions.rateLimitException);
      } else {
        throw Exception(Exceptions.serverException);
      }
    } on SocketException {
      throw Exception(Exceptions.networkException);
    } on FormatException {
      throw Exception(Exceptions.unknownException);
    }
  }

  Future<String> generateContent({
    required String systemPrompt,
    required String userPrompt,
    required String model,
    double temperature = 0.7,
    int maxTokens = 4096,
  }) async {
    if (!isConfigured) {
      throw Exception(Exceptions.networkException);
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/v1/chat/completions'),
            headers: _getHeaders(),
            body: json.encode({
              'model': model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userPrompt},
              ],
              'temperature': temperature,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectionTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices']?[0]?['message']?['content'] ?? '';
        return content.toString();
      } else if (response.statusCode == 401) {
        throw Exception(Exceptions.apiKeyException);
      } else if (response.statusCode == 429) {
        throw Exception(Exceptions.rateLimitException);
      } else {
        throw Exception(Exceptions.serverException);
      }
    } on SocketException {
      throw Exception(Exceptions.networkException);
    } on FormatException {
      throw Exception(Exceptions.unknownException);
    }
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_apiKey';
    }
    return headers;
  }

  void dispose() {
    _client.close();
  }
}
