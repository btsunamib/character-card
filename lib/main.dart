import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'data/repositories/repository_impl.dart';
import 'data/sources/local_data_source.dart';
import 'presentation/bloc/config/config_bloc.dart';
import 'presentation/bloc/generate/generate_bloc.dart';
import 'presentation/bloc/history/history_bloc.dart';
import 'presentation/pages/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final localDataSource = LocalDataSourceImpl(prefs);
  final apiClient = ApiClient();

  final configRepository = ConfigRepositoryImpl(localDataSource: localDataSource);
  final characterRepository = CharacterRepositoryImpl(
    localDataSource: localDataSource,
    apiClient: apiClient,
  );
  final apiRepository = ApiRepositoryImpl(apiClient: apiClient);

  runApp(
    SillyTavernApp(
      configRepository: configRepository,
      characterRepository: characterRepository,
      apiRepository: apiRepository,
    ),
  );
}

class SillyTavernApp extends StatelessWidget {
  final ConfigRepositoryImpl configRepository;
  final CharacterRepositoryImpl characterRepository;
  final ApiRepositoryImpl apiRepository;

  const SillyTavernApp({
    super.key,
    required this.configRepository,
    required this.characterRepository,
    required this.apiRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConfigBloc>(
          create: (context) => ConfigBloc(
            configRepository: configRepository,
            apiRepository: apiRepository,
            apiClient: apiRepository.apiClientInstance,
          ),
        ),
        BlocProvider<GenerateBloc>(
          create: (context) => GenerateBloc(
            characterRepository: characterRepository,
          ),
        ),
        BlocProvider<HistoryBloc>(
          create: (context) => HistoryBloc(
            characterRepository: characterRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SillyTavern角色卡生成器',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const MainScreen(),
      ),
    );
  }
}
