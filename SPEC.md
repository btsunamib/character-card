# SillyTavern角色卡生成器 - 项目规格说明书

## 1. 项目概述

**项目名称**: SillyTavern角色卡生成器 (SillyTavern Card Generator)

**项目类型**: Android移动应用 (Flutter开发)

**核心功能**: 一款能够生成适用于SillyTavern平台的JSON格式角色卡（包含世界书）的移动应用，支持AI驱动的角色内容生成、实时预览编辑、NSFW内容控制，并提供GitHub Actions自动化APK打包。

---

## 2. 技术栈与依赖

### 框架与语言
- **Flutter**: 3.x (Dart 3.x)
- **最小Android SDK**: 21 (Android 5.0)
- **目标Android SDK**: 34

### 核心依赖
| 包名 | 版本 | 用途 |
|------|------|------|
| flutter_bloc | ^8.1.3 | 状态管理 |
| http | ^1.1.0 | API请求 |
| shared_preferences | ^2.2.2 | 本地数据存储 |
| json_annotation | ^4.8.1 | JSON序列化 |
| json_editor_flutter | ^0.0.4 | JSON编辑/预览 |
| file_picker | ^6.1.1 | 导入/导出文件 |
| path_provider | ^2.1.1 | 文件路径访问 |
| flutter_quill | ^9.0.0 | 富文本编辑器 |
| equatable | ^2.0.5 | 值相等性比较 |
| dartz | ^0.10.1 | 函数式编程 |
| connectivity_plus | ^5.0.2 | 网络状态检测 |
| url_launcher | ^6.2.2 | 外部链接打开 |

---

## 3. 功能列表

### 3.1 角色卡生成系统
- 用户输入界面：角色名称、性格描述、背景故事、对话风格、头像URL等
- AI生成：调用配置的API生成符合SillyTavern格式的JSON角色卡
- 世界书模块：自动生成关联的世界书条目（地点、NPC、物品、事件等）
- 角色卡结构：
  ```json
  {
    "name": "角色名",
    "description": "描述",
    "personality": "性格",
    "scenario": "场景",
    "first_message": "首条消息",
    "example_dialogue": "示例对话",
    "worldbook": [...],
    "extensions": {...}
  }
  ```

### 3.2 API配置与模型管理
- API地址配置：支持HTTP/HTTPS，支持自定义端口
- 连接测试：验证API可用性
- 模型列表获取：自动获取可用模型
- 模型选择：下拉菜单选择，支持记住上次选择
- 参数配置：Temperature、Max Tokens、Top P等
- 敏感词过滤配置

### 3.3 内容预览与编辑
- 实时预览：生成结果实时展示JSON结构
- 富文本编辑：支持对角色描述、首条消息等内容手动修改
- 一键重新生成：保留配置参数重新生成
- 格式化显示：JSON语法高亮
- 撤销/重做：编辑历史记录

### 3.4 NSFW内容控制
- 级别1（严格）：完全禁止NSFW内容生成
- 级别2（自动）：AI根据上下文自动判断
- 级别3（允许）：允许NSFW内容生成
- 界面指示：当前级别清晰显示
- 持久保存：配置随用户设置保存

### 3.5 数据存储
- 用户配置：API地址、模型选择、NSFW级别等
- 生成历史：最近生成的角色卡记录
- 草稿保存：未完成角色卡自动保存
- 导出/导入：JSON文件导出分享

### 3.6 GitHub Actions自动化
- 自动构建：代码推送后自动构建APK
- 版本管理：自动递增版本号
- 构建日志：完整构建记录
- APK输出：构建产物自动发布

---

## 4. UI/UX 设计方向

### 整体视觉风格
- Material Design 3 (Material You)
- 现代化简洁风格，圆角卡片色/设计
- 深浅色主题切换

### 配色方案
- 主色：#6750A4 (紫罗兰色)
- 次色：#625B71
- 强调色：#7D5260
- 背景：#FFFBFE (浅色) / #1C1B1F (深色)

### 布局结构
- 底部导航栏：首页、生成、历史、设置
- 首页：快速生成入口
- 生成页：输入表单 + 预览编辑
- 历史页：生成记录列表
- 设置页：API配置、主题、导出等

### 响应式设计
- 支持手机竖屏/横屏
- 适配不同分辨率：mdpi、hdpi、xhdpi、xxhdpi、xxxhdpi
- 最小宽度：320dp
- 最大内容宽度：600dp（平板优化）

---

## 5. 应用架构

### 分层架构
```
lib/
├── core/           # 核心功能
│   ├── constants/  # 常量定义
│   ├── errors/     # 错误处理
│   ├── network/    # 网络请求封装
│   └── utils/      # 工具函数
├── data/           # 数据层
│   ├── models/     # 数据模型
│   ├── repositories/# 仓库实现
│   └── sources/    # 数据源
├── domain/         # 领域层
│   ├── entities/   # 实体
│   ├── repositories/# 仓库接口
│   └── usecases/   # 用例
├── presentation/   # 展示层
│   ├── bloc/       # BLoC状态管理
│   ├── pages/      # 页面
│   └── widgets/    # 组件
└── main.dart       # 入口
```

### 状态管理
- BLoC模式
- 分模块管理：生成、配置、设置、历史

---

## 6. API集成规范

### 请求格式
```json
POST /v1/chat/completions
{
  "model": "选择的模型",
  "messages": [
    {"role": "system", "content": "系统提示词"},
    {"role": "user", "content": "用户输入的角色信息"}
  ],
  "temperature": 0.7,
  "max_tokens": 4096
}
```

### 错误处理
- 网络超时：30秒超时，显示重试提示
- 认证失败：提示检查API Key
- 限流：显示等待重试
- 未知错误：通用错误提示

---

## 7. 验收标准

1. ✅ 用户可输入角色信息并生成SillyTavern格式JSON
2. ✅ 生成的JSON包含完整的Worldbook模块
3. ✅ API配置成功后可获取并选择模型
4. ✅ 支持实时预览和编辑生成内容
5. ✅ NSFW三级控制功能正常
6. ✅ 用户配置和历史记录正确保存
7. ✅ GitHub Actions成功构建APK
8. ✅ 应用适配主流Android分辨率
