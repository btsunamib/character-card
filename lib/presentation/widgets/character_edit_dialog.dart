import 'package:flutter/material.dart';
import '../../data/models/character_card_model.dart';

class CharacterEditDialog extends StatefulWidget {
  final CharacterCard card;
  final Function(CharacterCard) onSave;

  const CharacterEditDialog({
    super.key,
    required this.card,
    required this.onSave,
  });

  @override
  State<CharacterEditDialog> createState() => _CharacterEditDialogState();
}

class _CharacterEditDialogState extends State<CharacterEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _personalityController;
  late TextEditingController _scenarioController;
  late TextEditingController _firstMessageController;
  late TextEditingController _exampleDialogueController;
  late List<WorldbookEntry> _worldbook;
  late String? _avatar;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card.name);
    _descriptionController = TextEditingController(text: widget.card.description);
    _personalityController = TextEditingController(text: widget.card.personality);
    _scenarioController = TextEditingController(text: widget.card.scenario);
    _firstMessageController = TextEditingController(text: widget.card.firstMessage);
    _exampleDialogueController = TextEditingController(text: widget.card.exampleDialogue);
    _worldbook = List.from(widget.card.worldbook);
    _avatar = widget.card.extensions.avatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _personalityController.dispose();
    _scenarioController.dispose();
    _firstMessageController.dispose();
    _exampleDialogueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('编辑角色卡'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: _saveChanges,
                child: const Text('保存'),
              ),
            ],
          ),
          body: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: '基本信息'),
                    Tab(text: '世界书'),
                    Tab(text: '扩展'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildBasicInfoTab(),
                      _buildWorldbookTab(),
                      _buildExtensionsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '角色名称',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '角色描述',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _personalityController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '性格描述',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _scenarioController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '场景设定',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _firstMessageController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '首条消息',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _exampleDialogueController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '示例对话',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldbookTab() {
    return Column(
      children: [
        Expanded(
          child: _worldbook.isEmpty
              ? const Center(
                  child: Text('暂无世界书条目'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _worldbook.length,
                  itemBuilder: (context, index) {
                    final entry = _worldbook[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(entry.name),
                        subtitle: Text(
                          entry.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: entry.enabled,
                              onChanged: (value) {
                                setState(() {
                                  _worldbook[index] = WorldbookEntry(
                                    name: entry.name,
                                    content: entry.content,
                                    keywords: entry.keywords,
                                    enabled: value,
                                  );
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _worldbook.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        onTap: () => _editWorldbookEntry(index),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _addWorldbookEntry,
            icon: const Icon(Icons.add),
            label: const Text('添加世界书条目'),
          ),
        ),
      ],
    );
  }

  void _addWorldbookEntry() {
    _showWorldbookEntryDialog(null, (entry) {
      setState(() {
        _worldbook.add(entry);
      });
    });
  }

  void _editWorldbookEntry(int index) {
    _showWorldbookEntryDialog(_worldbook[index], (entry) {
      setState(() {
        _worldbook[index] = entry;
      });
    });
  }

  void _showWorldbookEntryDialog(
    WorldbookEntry? entry,
    Function(WorldbookEntry) onSave,
  ) {
    final nameController = TextEditingController(text: entry?.name ?? '');
    final contentController = TextEditingController(text: entry?.content ?? '');
    final keywordsController =
        TextEditingController(text: entry?.keywords.join(', ') ?? '');
    bool enabled = entry?.enabled ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(entry == null ? '添加世界书条目' : '编辑世界书条目'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: '内容',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: keywordsController,
                  decoration: const InputDecoration(
                    labelText: '关键词 (逗号分隔)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('启用'),
                  value: enabled,
                  onChanged: (value) {
                    setDialogState(() {
                      enabled = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  return;
                }
                onSave(WorldbookEntry(
                  name: nameController.text.trim(),
                  content: contentController.text.trim(),
                  keywords: keywordsController.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList(),
                  enabled: enabled,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtensionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: TextEditingController(text: _avatar ?? ''),
            decoration: const InputDecoration(
              labelText: '头像URL',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _avatar = value.isEmpty ? null : value;
            },
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final updatedCard = widget.card.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      personality: _personalityController.text.trim(),
      scenario: _scenarioController.text.trim(),
      firstMessage: _firstMessageController.text.trim(),
      exampleDialogue: _exampleDialogueController.text.trim(),
      worldbook: _worldbook,
      extensions: CharacterExtensions(
        avatar: _avatar,
        tags: widget.card.extensions.tags,
      ),
      updatedAt: DateTime.now(),
    );

    widget.onSave(updatedCard);
    Navigator.pop(context);
  }
}
