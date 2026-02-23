import 'package:flutter_test/flutter_test.dart';
import 'package:sillytavern_card_generator/data/models/app_config_model.dart';

void main() {
  group('AppConfig', () {
    test('should create AppConfig with default values', () {
      const config = AppConfig();

      expect(config.apiUrl, '');
      expect(config.apiKey, isNull);
      expect(config.selectedModel, isNull);
      expect(config.temperature, 0.7);
      expect(config.maxTokens, 4096);
      expect(config.nsfwLevel, 0);
      expect(config.isDarkMode, false);
      expect(config.isApiConfigured, false);
    });

    test('should create AppConfig from JSON', () {
      final json = {
        'apiUrl': 'http://localhost:5000',
        'apiKey': 'test-key',
        'selectedModel': 'gpt-3.5-turbo',
        'temperature': 0.8,
        'maxTokens': 2048,
        'nsfwLevel': 2,
        'isDarkMode': true,
      };

      final config = AppConfig.fromJson(json);

      expect(config.apiUrl, 'http://localhost:5000');
      expect(config.apiKey, 'test-key');
      expect(config.selectedModel, 'gpt-3.5-turbo');
      expect(config.temperature, 0.8);
      expect(config.maxTokens, 2048);
      expect(config.nsfwLevel, 2);
      expect(config.isDarkMode, true);
    });

    test('should convert AppConfig to JSON', () {
      const config = AppConfig(
        apiUrl: 'http://localhost:5000',
        apiKey: 'test-key',
        selectedModel: 'gpt-3.5-turbo',
        temperature: 0.8,
        maxTokens: 2048,
        nsfwLevel: 2,
        isDarkMode: true,
      );

      final json = config.toJson();

      expect(json['apiUrl'], 'http://localhost:5000');
      expect(json['apiKey'], 'test-key');
      expect(json['selectedModel'], 'gpt-3.5-turbo');
      expect(json['temperature'], 0.8);
      expect(json['maxTokens'], 2048);
      expect(json['nsfwLevel'], 2);
      expect(json['isDarkMode'], true);
    });

    test('should copy AppConfig with new values', () {
      const config = AppConfig(
        apiUrl: 'http://localhost:5000',
        temperature: 0.7,
      );

      final newConfig = config.copyWith(
        apiUrl: 'http://localhost:8080',
        temperature: 0.9,
      );

      expect(newConfig.apiUrl, 'http://localhost:8080');
      expect(newConfig.temperature, 0.9);
      expect(newConfig.maxTokens, config.maxTokens);
    });

    test('isApiConfigured should return true when apiUrl is not empty', () {
      const config = AppConfig(apiUrl: 'http://localhost:5000');

      expect(config.isApiConfigured, true);
    });

    test('isApiConfigured should return false when apiUrl is empty', () {
      const config = AppConfig();

      expect(config.isApiConfigured, false);
    });
  });
}
