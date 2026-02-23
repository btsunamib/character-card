import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../models/app_config_model.dart';
import '../models/character_card_model.dart';
import '../sources/local_data_source.dart';
import '../../domain/repositories/repositories.dart';
import '../../core/constants/app_constants.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final LocalDataSource localDataSource;

  ConfigRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, AppConfig>> getConfig() async {
    try {
      final config = await localDataSource.getConfig();
      return Right(config);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveConfig(AppConfig config) async {
    try {
      await localDataSource.saveConfig(config);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

class CharacterRepositoryImpl implements CharacterRepository {
  final LocalDataSource localDataSource;
  final ApiClient apiClient;

  CharacterRepositoryImpl({
    required this.localDataSource,
    required this.apiClient,
  });

  @override
  Future<Either<Failure, CharacterCard>> generateCharacterCard({
    required String characterInfo,
    required String model,
    required double temperature,
    required int maxTokens,
    required int nsfwLevel,
  }) async {
    try {
      final systemPrompt = _buildSystemPrompt(nsfwLevel);
      final userPrompt = _buildUserPrompt(characterInfo);

      final response = await apiClient.generateContent(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        model: model,
        temperature: temperature,
        maxTokens: maxTokens,
      );

      final card = _parseCharacterCard(response);
      return Right(card);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _buildSystemPrompt(int nsfwLevel) {
    final nsfwPrompt = AppConstants.nsfwSystemPrompts['$nsfwLevel'] ??
        AppConstants.nsfwSystemPrompts['0']!;
    return '${AppConstants.characterCardSystemPrompt}\n\n$nsfwPrompt';
  }

  String _buildUserPrompt(String characterInfo) {
    return '''请根据以下信息生成SillyTavern角色卡：

$characterInfo

请直接返回JSON格式的角色卡，不要包含其他说明文字。''';
  }

  CharacterCard _parseCharacterCard(String response) {
    try {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch == null) {
        throw Exception('无法解析JSON响应');
      }

      final jsonStr = jsonMatch.group(0)!;
      final Map<String, dynamic> json = _parseJson(jsonStr);

      final card = CharacterCard.fromJson(json);
      return card;
    } catch (e) {
      throw Exception('角色卡解析失败: $e');
    }
  }

  Map<String, dynamic> _parseJson(String jsonStr) {
    jsonStr = jsonStr.trim();
    if (jsonStr.startsWith('```json')) {
      jsonStr = jsonStr.substring(7);
    } else if (jsonStr.startsWith('```')) {
      jsonStr = jsonStr.substring(3);
    }
    if (jsonStr.endsWith('```')) {
      jsonStr = jsonStr.substring(0, jsonStr.length - 3);
    }
    jsonStr = jsonStr.trim();

    return Map<String, dynamic>.from(
      json.decode(jsonStr) as Map,
    );
  }

  @override
  Future<Either<Failure, List<CharacterCard>>> getHistory() async {
    try {
      final history = await localDataSource.getHistory();
      return Right(history);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveToHistory(CharacterCard card) async {
    try {
      await localDataSource.saveToHistory(card);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFromHistory(String id) async {
    try {
      await localDataSource.deleteFromHistory(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await localDataSource.clearHistory();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

class ApiRepositoryImpl implements ApiRepository {
  final ApiClient apiClient;

  ApiRepositoryImpl({required this.apiClient});

  ApiClient get apiClientInstance => apiClient;

  @override
  Future<Either<Failure, bool>> testConnection(String apiUrl, String? apiKey) async {
    try {
      apiClient.configure(baseUrl: apiUrl, apiKey: apiKey);
      final result = await apiClient.testConnection();
      return Right(result);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getModels(String apiUrl, String? apiKey) async {
    try {
      apiClient.configure(baseUrl: apiUrl, apiKey: apiKey);
      final models = await apiClient.getModels();
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
