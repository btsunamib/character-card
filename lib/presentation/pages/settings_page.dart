import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../bloc/config/config_bloc.dart';
import '../bloc/config/config_event.dart';
import '../bloc/config/config_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _apiUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: BlocConsumer<ConfigBloc, ConfigState>(
        listener: (context, state) {
          if (state is ConfigLoaded) {
            if (_apiUrlController.text.isEmpty && state.config.apiUrl.isNotEmpty) {
              _apiUrlController.text = state.config.apiUrl;
            }
            if (_apiKeyController.text.isEmpty && state.config.apiKey != null) {
              _apiKeyController.text = state.config.apiKey!;
            }

            if (state.connectionTestResult == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('API连接成功'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state.connectionTestResult == false) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'API连接失败'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is ConfigLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConfigError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ConfigBloc>().add(const LoadConfig());
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          final configState = state is ConfigLoaded ? state : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildApiSection(context, configState),
                const SizedBox(height: 16),
                _buildNsfwSection(context, configState),
                const SizedBox(height: 16),
                _buildAboutSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildApiSection(BuildContext context, ConfigLoaded? configState) {
    final theme = Theme.of(context);
    final isTesting = configState?.isTesting ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.api, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'API配置',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiUrlController,
              decoration: const InputDecoration(
                labelText: 'API地址',
                hintText: '例如: http://localhost:5000',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API密钥 (可选)',
                hintText: '输入API密钥',
                prefixIcon: Icon(Icons.key),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isTesting
                        ? null
                        : () {
                            if (_apiUrlController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('请输入API地址'),
                                ),
                              );
                              return;
                            }
                            context.read<ConfigBloc>().add(TestApiConnection(
                                  apiUrl: _apiUrlController.text.trim(),
                                  apiKey: _apiKeyController.text.trim().isNotEmpty
                                      ? _apiKeyController.text.trim()
                                      : null,
                                ));
                          },
                    icon: isTesting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.wifi_tethering),
                    label: Text(isTesting ? '连接中...' : '测试连接'),
                  ),
                ),
              ],
            ),
            if (configState != null && configState.models.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                '可用模型: ${configState.models.length}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: configState.models
                    .take(10)
                    .map((model) => Chip(
                          label: Text(
                            model,
                            style: const TextStyle(fontSize: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
              if (configState.models.length > 10)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '...还有 ${configState.models.length - 10} 个模型',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNsfwSection(BuildContext context, ConfigLoaded? configState) {
    final theme = Theme.of(context);
    final nsfwLevel = configState?.config.nsfwLevel ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'NSFW内容控制',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(AppConstants.nsfwLevels.length, (index) {
              return RadioListTile<int>(
                title: Text(AppConstants.nsfwLevels[index]),
                subtitle: Text(_getNsfwDescription(index)),
                value: index,
                groupValue: nsfwLevel,
                onChanged: (value) {
                  if (value != null) {
                    context.read<ConfigBloc>().add(SaveConfig(nsfwLevel: value));
                  }
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getNsfwDescription(int level) {
    switch (level) {
      case 0:
        return '严格禁止生成任何NSFW内容';
      case 1:
        return '由AI根据内容上下文自动判断';
      case 2:
        return '允许生成NSFW内容';
      default:
        return '';
    }
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '关于',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.app_settings_alt),
              title: const Text('应用名称'),
              subtitle: const Text(AppConstants.appName),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.numbers),
              title: const Text('版本'),
              subtitle: const Text(AppConstants.appVersion),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'SillyTavern角色卡生成器是一款帮助用户生成符合SillyTavern平台格式的角色JSON文件的应用。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
