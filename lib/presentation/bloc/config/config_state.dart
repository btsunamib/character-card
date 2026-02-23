import 'package:equatable/equatable.dart';
import '../../../data/models/app_config_model.dart';

abstract class ConfigState extends Equatable {
  const ConfigState();

  @override
  List<Object?> get props => [];
}

class ConfigInitial extends ConfigState {
  const ConfigInitial();
}

class ConfigLoading extends ConfigState {
  const ConfigLoading();
}

class ConfigLoaded extends ConfigState {
  final AppConfig config;
  final List<String> models;
  final bool isTesting;
  final bool? connectionTestResult;
  final String? errorMessage;

  const ConfigLoaded({
    required this.config,
    this.models = const [],
    this.isTesting = false,
    this.connectionTestResult,
    this.errorMessage,
  });

  ConfigLoaded copyWith({
    AppConfig? config,
    List<String>? models,
    bool? isTesting,
    bool? connectionTestResult,
    String? errorMessage,
  }) {
    return ConfigLoaded(
      config: config ?? this.config,
      models: models ?? this.models,
      isTesting: isTesting ?? this.isTesting,
      connectionTestResult: connectionTestResult,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [config, models, isTesting, connectionTestResult, errorMessage];
}

class ConfigError extends ConfigState {
  final String message;

  const ConfigError(this.message);

  @override
  List<Object?> get props => [message];
}
