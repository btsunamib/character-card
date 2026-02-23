import 'package:equatable/equatable.dart';

class AppConfig extends Equatable {
  final String apiUrl;
  final String? apiKey;
  final String? selectedModel;
  final double temperature;
  final int maxTokens;
  final int nsfwLevel;
  final bool isDarkMode;

  const AppConfig({
    this.apiUrl = '',
    this.apiKey,
    this.selectedModel,
    this.temperature = 0.7,
    this.maxTokens = 4096,
    this.nsfwLevel = 0,
    this.isDarkMode = false,
  });

  bool get isApiConfigured => apiUrl.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'apiUrl': apiUrl,
      'apiKey': apiKey,
      'selectedModel': selectedModel,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'nsfwLevel': nsfwLevel,
      'isDarkMode': isDarkMode,
    };
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      apiUrl: json['apiUrl'] ?? '',
      apiKey: json['apiKey'],
      selectedModel: json['selectedModel'],
      temperature: (json['temperature'] ?? 0.7).toDouble(),
      maxTokens: json['maxTokens'] ?? 4096,
      nsfwLevel: json['nsfwLevel'] ?? 0,
      isDarkMode: json['isDarkMode'] ?? false,
    );
  }

  AppConfig copyWith({
    String? apiUrl,
    String? apiKey,
    String? selectedModel,
    double? temperature,
    int? maxTokens,
    int? nsfwLevel,
    bool? isDarkMode,
  }) {
    return AppConfig(
      apiUrl: apiUrl ?? this.apiUrl,
      apiKey: apiKey ?? this.apiKey,
      selectedModel: selectedModel ?? this.selectedModel,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      nsfwLevel: nsfwLevel ?? this.nsfwLevel,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

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
