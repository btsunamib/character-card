import 'package:flutter/material.dart';

class JsonPreviewWidget extends StatelessWidget {
  final String jsonContent;

  const JsonPreviewWidget({
    super.key,
    required this.jsonContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (jsonContent.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.code,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '角色卡预览 (JSON)',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                jsonContent,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
