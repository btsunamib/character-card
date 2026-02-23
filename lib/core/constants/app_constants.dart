class AppConstants {
  static const String appName = 'SillyTavern角色卡生成器';
  static const String appVersion = '1.0.0';

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const String defaultApiUrl = 'http://localhost:5000';

  static const List<String> nsfwLevels = ['严格禁止', 'AI自动判断', '允许生成'];

  static const Map<String, String> nsfwSystemPrompts = {
    '0': '你是一个严格的角色生成助手，严禁生成任何NSFW（不适合工作场所）内容。请只生成安全、适合所有年龄段的内容。',
    '1': '你是一个角色生成助手，可以根据上下文自动判断内容是否适合。生成角色时以内容质量和连贯性为主。',
    '2': '你是一个角色生成助手，允许生成各类角色内容，包括可能包含成人主题的角色。请确保内容具有创意和故事性。',
  };

  static const String characterCardSystemPrompt = '''你是一个专业的角色卡生成助手，专门为SillyTavern平台生成角色JSON文件。

请根据用户提供的角色信息，生成符合以下SillyTavern格式的角色卡JSON：

```json
{
  "name": "角色名称",
  "description": "角色描述（用于LLM的上下文）",
  "personality": "角色性格描述",
  "scenario": "场景设定",
  "first_message": "首条消息（角色开场白）",
  "example_dialogue": "示例对话",
  "worldbook": [
    {
      "name": "世界书条目名称",
      "content": "条目内容描述",
      "keywords": ["关键词1", "关键词2"],
      "enabled": true
    }
  ],
  "extensions": {
    "avatar": "头像URL（如果有）",
    "tags": ["标签1", "标签2"]
  }
}
```

请确保：
1. 生成完整且有效的JSON格式
2. worldbook至少包含2-3个相关条目
3. first_message要有角色特色
4. example_dialogue要展示角色说话风格
5. description要足够详细以便AI能够准确扮演该角色''';
}
