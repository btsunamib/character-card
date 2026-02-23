import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/app_config_model.dart';
import '../models/character_card_model.dart';

abstract class ConfigRepository {
  Future<Either<Failure, AppConfig>> getConfig();
  Future<Either<Failure, void>> saveConfig(AppConfig config);
}

abstract class CharacterRepository {
  Future<Either<Failure, CharacterCard>> generateCharacterCard({
    required String characterInfo,
    required String model,
    required double temperature,
    required int maxTokens,
    required int nsfwLevel,
  });

  Future<Either<Failure, List<CharacterCard>>> getHistory();
  Future<Either<Failure, void>> saveToHistory(CharacterCard card);
  Future<Either<Failure, void>> deleteFromHistory(String id);
  Future<Either<Failure, void>> clearHistory();
}

abstract class ApiRepository {
  Future<Either<Failure, bool>> testConnection(String apiUrl, String? apiKey);
  Future<Either<Failure, List<String>>> getModels(String apiUrl, String? apiKey);
}
