import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../bloc/config/config_bloc.dart';
import '../bloc/config/config_event.dart';
import '../bloc/config/config_state.dart';
import '../bloc/generate/generate_bloc.dart';
import '../bloc/generate/generate_event.dart';
import '../bloc/generate/generate_state.dart';
import '../widgets/json_preview_widget.dart';
import '../widgets/character_edit_dialog.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final _formKey = GlobalKey<FormState>();
  final _characterInfoController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _personalityController = TextEditingController();

  String? _selectedModel;
  double _temperature = 0.7;
  int _maxTokens = 4096;
  int _nsfwLevel = 0;

  bool get _isFormValid => _characterInfoController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _characterInfoController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _personalityController.dispose();
    super.dispose();
  }

  void _loadConfig(ConfigLoaded configState) {
    if (_selectedModel == null && configState.config.selectedModel != null) {
      _selectedModel = configState.config.selectedModel;
    }
    _temperature = configState.config.temperature;
    _maxTokens = configState.config.maxTokens;
    _nsfwLevel = configState.config.nsfwLevel;
  }

  void _generateCard() {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入角色信息')),
      );
      return;
    }

    if (_selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在设置中配置API并选择模型')),
      );
      return;
    }

    context.read<GenerateBloc>().add(GenerateCharacterCard(
          characterInfo: _characterInfoController.text,
          model: _selectedModel!,
          temperature: _temperature,
          maxTokens: _maxTokens,
          nsfwLevel: _nsfwLevel,
        ));
  }

  void _regenerateCard() {
    _generateCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('生成角色卡'),
        centerTitle: true,
        actions: [
          BlocBuilder<GenerateBloc, GenerateState>(
            builder: (context, state) {
              if (state is GenerateSuccess) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: '编辑',
                      onPressed: () => _showEditDialog(state),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: '复制JSON',
                      onPressed: () => _copyJson(state),
                    ),
                    IconButton(
                      icon: Icon(
                        state.isSaved ? Icons.save : Icons.save_outlined,
                        color: state.isSaved ? Colors.green : null,
                      ),
                      tooltip: '保存到历史',
                      onPressed: state.isSaved
                          ? null
                          : () {
                              context
                                  .read<GenerateBloc>()
                                  .add(const SaveCharacterCard());
                            },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ConfigBloc, ConfigState>(
        builder: (context, configState) {
          if (configState is ConfigLoaded) {
            _loadConfig(configState);
          }

          return BlocConsumer<GenerateBloc, GenerateState>(
            listener: (context, state) {
              if (state is GenerateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '角色卡已生成${state.isSaved ? "并保存到历史" : ""}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is GenerateError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('生成失败: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, generateState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputSection(configState),
                    const SizedBox(height: 16),
                    _buildNsfwSelector(),
                    const SizedBox(height: 16),
                    _buildGenerateButton(generateState),
                    const SizedBox(height: 16),
                    if (generateState is GenerateLoading)
                      _buildLoadingIndicator(generateState),
                    if (generateState is GenerateSuccess ||
                        generateState is GenerateError)
                      _buildPreviewSection(generateState),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInputSection(ConfigState configState) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '角色信息',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (configState is ConfigLoaded &&
                configState.models.isNotEmpty) ...[
              _buildModelSelector(configState),
              const SizedBox(height: 12),
              _buildParameterSliders(),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _characterInfoController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: '角色描述',
                hintText: '请详细描述角色的外貌、性格、背景故事等信息...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSelector(ConfigState configState) {
    final models = configState is ConfigLoaded ? configState.models : <String>[];
    return DropdownButtonFormField<String>(
      value: _selectedModel,
      decoration: const InputDecoration(
        labelText: '选择AI模型',
        border: OutlineInputBorder(),
      ),
      items: models
          .map((model) => DropdownMenuItem(
                value: model,
                child: Text(model, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedModel = value;
        });
        if (value != null) {
          context.read<ConfigBloc>().add(SaveConfig(selectedModel: value));
        }
      },
    );
  }

  Widget _buildParameterSliders() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _temperature,
                min: 0.1,
                max: 2.0,
                divisions: 19,
                label: 'Temperature: ${_temperature.toStringAsFixed(1)}',
                onChanged: (value) {
                  setState(() {
                    _temperature = value;
                  });
                },
                onChangeEnd: (value) {
                  context
                      .read<ConfigBloc>()
                      .add(SaveConfig(temperature: value));
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _maxTokens.toDouble(),
                min: 512,
                max: 8192,
                divisions: 15,
                label: 'Max Tokens: $_maxTokens',
                onChanged: (value) {
                  setState(() {
                    _maxTokens = value.toInt();
                  });
                },
                onChangeEnd: (value) {
                  context
                      .read<ConfigBloc>()
                      .add(SaveConfig(maxTokens: value.toInt()));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNsfwSelector() {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NSFW内容控制',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('严格')),
                ButtonSegment(value: 1, label: Text('自动')),
                ButtonSegment(value: 2, label: Text('允许')),
              ],
              selected: {_nsfwLevel},
              onSelectionChanged: (Set<int> selection) {
                setState(() {
                  _nsfwLevel = selection.first;
                });
                context.read<ConfigBloc>().add(SaveConfig(nsfwLevel: selection.first));
              },
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.nsfwLevels[_nsfwLevel],
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(GenerateState state) {
    final isLoading = state is GenerateLoading;
    final hasPreviousCard = state is GenerateError && state.previousCard != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: isLoading ? null : _generateCard,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(isLoading ? '生成中...' : '生成角色卡'),
        ),
        if (hasPreviousCard) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: isLoading ? null : _regenerateCard,
            icon: const Icon(Icons.refresh),
            label: const Text('重新生成（保留配置）'),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(GenerateLoading state) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              state.message ?? '正在生成...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(GenerateState state) {
    String jsonStr = '';
    if (state is GenerateSuccess) {
      jsonStr = const JsonEncoder.withIndent('  ').convert(state.card.toJson());
    } else if (state is GenerateError && state.previousCard != null) {
      jsonStr = const JsonEncoder.withIndent('  ')
          .convert(state.previousCard!.toJson());
    }

    return JsonPreviewWidget(jsonContent: jsonStr);
  }

  void _showEditDialog(GenerateSuccess state) {
    showDialog(
      context: context,
      builder: (context) => CharacterEditDialog(
        card: state.card,
        onSave: (updatedCard) {
          context.read<GenerateBloc>().add(UpdateCharacterCard(updatedCard));
        },
      ),
    );
  }

  void _copyJson(GenerateSuccess state) {
    final jsonStr =
        const JsonEncoder.withIndent('  ').convert(state.card.toJson());
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON已复制到剪贴板')),
    );
  }
}
