import 'package:equatable/equatable.dart';

abstract class ConfigEvent extends Equatable {
  const ConfigEvent();

  @override
  List<Object?> get props => [];
}

class LoadConfig extends ConfigEvent {
  const LoadConfig();
}

class SaveConfig extends ConfigEvent {
  final String? apiUrl;
  final String? apiKey;
  final String? selectedModel;
  final double? temperature;
  final int? maxTokens;
  final int? nsfwLevel;
  final bool? isDarkMode;

  const SaveConfig({
    this.apiUrl,
    this.apiKey,
    this.selectedModel,
    this.temperature,
    this.maxTokens,
    this.nsfwLevel,
    this.isDarkMode,
  });

  @override
  List<Object?> get props => [
        apiUrl,
        apiKey,
        selectedModel,
        temperature,
        maxTokens,
        nsfwLevel,
        isDarkMode,
      ];
}

class TestApiConnection extends ConfigEvent {
  final String apiUrl;
  final String? apiKey;

  const TestApiConnection({required this.apiUrl, this.apiKey});

  @override
  List<Object?> get props => [apiUrl, apiKey];
}

class LoadModels extends ConfigEvent {
  final String apiUrl;
  final String? apiKey;

  const LoadModels({required this.apiUrl, this.apiKey});

  @override
  List<Object?> get props => [apiUrl, apiKey];
}
