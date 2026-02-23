import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../data/models/app_config_model.dart';
import '../../../domain/repositories/repositories.dart';
import 'config_event.dart';
import 'config_state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  final ConfigRepository configRepository;
  final ApiRepository apiRepository;
  final ApiClient apiClient;

  ConfigBloc({
    required this.configRepository,
    required this.apiRepository,
    required this.apiClient,
  }) : super(const ConfigInitial()) {
    on<LoadConfig>(_onLoadConfig);
    on<SaveConfig>(_onSaveConfig);
    on<TestApiConnection>(_onTestApiConnection);
    on<LoadModels>(_onLoadModels);
  }

  Future<void> _onLoadConfig(LoadConfig event, Emitter<ConfigState> emit) async {
    emit(const ConfigLoading());

    final result = await configRepository.getConfig();
    result.fold(
      (failure) => emit(ConfigError(failure.message)),
      (config) {
        if (config.isApiConfigured) {
          apiClient.configure(baseUrl: config.apiUrl, apiKey: config.apiKey);
        }
        emit(ConfigLoaded(config: config));
      },
    );
  }

  Future<void> _onSaveConfig(SaveConfig event, Emitter<ConfigState> emit) async {
    if (state is ConfigLoaded) {
      final currentState = state as ConfigLoaded;
      final newConfig = currentState.config.copyWith(
        apiUrl: event.apiUrl,
        apiKey: event.apiKey,
        selectedModel: event.selectedModel,
        temperature: event.temperature,
        maxTokens: event.maxTokens,
        nsfwLevel: event.nsfwLevel,
        isDarkMode: event.isDarkMode,
      );

      final result = await configRepository.saveConfig(newConfig);
      result.fold(
        (failure) => emit(ConfigError(failure.message)),
        (_) {
          if (newConfig.isApiConfigured) {
            apiClient.configure(baseUrl: newConfig.apiUrl, apiKey: newConfig.apiKey);
          }
          emit(currentState.copyWith(config: newConfig, errorMessage: null));
        },
      );
    }
  }

  Future<void> _onTestApiConnection(
      TestApiConnection event, Emitter<ConfigState> emit) async {
    if (state is ConfigLoaded) {
      final currentState = state as ConfigLoaded;
      emit(currentState.copyWith(isTesting: true, connectionTestResult: null));

      final result = await apiRepository.testConnection(event.apiUrl, event.apiKey);

      result.fold(
        (failure) => emit(currentState.copyWith(
          isTesting: false,
          connectionTestResult: false,
          errorMessage: failure.message,
        )),
        (success) {
          if (success) {
            final newConfig = currentState.config.copyWith(
              apiUrl: event.apiUrl,
              apiKey: event.apiKey,
            );
            configRepository.saveConfig(newConfig);
            apiClient.configure(baseUrl: event.apiUrl, apiKey: event.apiKey);
            emit(currentState.copyWith(
              config: newConfig,
              isTesting: false,
              connectionTestResult: true,
              errorMessage: null,
            ));
            add(LoadModels(apiUrl: event.apiUrl, apiKey: event.apiKey));
          } else {
            emit(currentState.copyWith(
              isTesting: false,
              connectionTestResult: false,
              errorMessage: '无法连接到API服务器',
            ));
          }
        },
      );
    }
  }

  Future<void> _onLoadModels(LoadModels event, Emitter<ConfigState> emit) async {
    if (state is ConfigLoaded) {
      final currentState = state as ConfigLoaded;
      emit(currentState.copyWith(isTesting: true));

      final result = await apiRepository.getModels(event.apiUrl, event.apiKey);

      result.fold(
        (failure) => emit(currentState.copyWith(
          isTesting: false,
          errorMessage: failure.message,
        )),
        (models) => emit(currentState.copyWith(
          models: models,
          isTesting: false,
        )),
      );
    }
  }
}
