# SillyTavern角色卡生成器

一款能够生成适用于SillyTavern平台的JSON包含世界书）的Android格式角色卡（移动应用。

## 功能特性

### 核心功能
- **角色卡生成**: 基于用户输入生成符合SillyTavern格式规范的JSON角色卡
- **世界书模块**: 自动生成关联的世界书条目（地点、NPC、物品、事件等）
- **实时预览**: 生成结果实时展示JSON结构
- **富文本编辑**: 支持对角色内容手动调整
- **一键重生成**: 保留配置参数重新生成

### API配置
- 支持自定义API链接配置（HTTP/HTTPS）
- 自动获取可用AI模型列表
- 模型参数保存与快速切换
- 请求超时处理与错误提示

### 数据存储
- 用户配置持久化保存
- 生成历史记录管理
- JSON文件导出/分享

## 技术栈

- **Flutter 3.x** - 跨平台UI框架
- **BLoC** - 状态管理
- **http** - 网络请求
- **shared_preferences** - 本地数据存储
- **Material Design 3** - UI设计规范

## 项目结构

```
lib/
├── core/                    # 核心功能
│   ├── constants/           # 常量定义
│   ├── errors/              # 错误处理
│   └── network/             # 网络请求封装
├── data/                    # 数据层
│   ├── models/              # 数据模型
│   ├── repositories/        # 仓库实现
│   └── sources/             # 数据源
├── domain/                  # 领域层
│   └── repositories/        # 仓库接口
├── presentation/            # 展示层
│   ├── bloc/                # BLoC状态管理
│   ├── pages/               # 页面
│   └── widgets/             # 组件
└── main.dart                # 应用入口
```

## 快速开始

### 前提条件
- Flutter SDK 3.x
- Android SDK 21+
- Java 17

### 构建运行

```bash
# 获取依赖
flutter pub get

# 运行调试版本
flutter run

# 构建调试APK
flutter build apk --debug

# 构建发布APK
flutter build apk --release
```

### GitHub Actions 自动构建

项目配置了GitHub Actions工作流，推送代码后会自动构建APK。

1. Fork本项目
2. 推送代码到main分支
3. 在Actions页面查看构建结果
4. 下载生成的APK

## API配置

### 支持的API类型
- OpenAI API
- Ollama (本地部署)
- KoboldCPP
- TextGen WebUI
- 其他兼容OpenAI API格式的服务

### 配置步骤
1. 打开应用「设置」页面
2. 输入API地址（如 `http://localhost:11434`）
3. 如需要，输入API密钥
4. 点击「测试连接」
5. 选择可用模型

详细配置说明请参考 [API文档](API_DOC.md)

## 生成角色卡格式

应用生成的角色卡符合SillyTavern格式，包含：

```json
{
  "name": "角色名称",
  "description": "角色描述",
  "personality": "性格描述",
  "scenario": "场景设定",
  "first_message": "首条消息",
  "example_dialogue": "示例对话",
  "worldbook": [
    {
      "name": "世界书条目名称",
      "content": "条目内容",
      "keywords": ["关键词1", "关键词2"],
      "enabled": true
    }
  ],
  "extensions": {
    "avatar": "头像URL",
    "tags": ["标签1", "标签2"]
  }
}
```

## 许可证

MIT License
