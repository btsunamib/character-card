# API调用文档与参数说明

## 概述

SillyTavern角色卡生成器通过调用兼容OpenAI API格式的后端服务来生成角色卡内容。本文档说明API的配置方法和参数说明。

## 支持的API类型

本应用支持任何兼容OpenAI API格式的AI后端服务，包括：

- **OpenAI API** (api.openai.com)
- **Ollama** (本地部署)
- **KoboldCPP**
- **TextGen WebUI**
- **其他兼容API**

## API配置

### 基本配置

在应用的「设置」页面中配置以下内容：

| 参数 | 说明 | 示例 |
|------|------|------|
| API地址 | AI服务的URL地址 | `http://localhost:5000` |
| API密钥 | 访问密钥（部分服务需要） | `sk-xxxxx` |

### API地址格式

```
http://localhost:5000        # 本地Ollama
http://localhost:7860        # TextGen WebUI
https://api.openai.com/v1    # OpenAI官方API
```

## 模型参数

### 选择模型

配置API后，应用会自动获取可用的模型列表。常用模型：

| 模型 | 描述 |
|------|------|
| gpt-3.5-turbo | OpenAI性价比最高的模型 |
| gpt-4 | OpenAI更强大的模型 |
| llama2 | Meta开源模型 |
| mistral | Mistral AI模型 |
| neural-chat | Intel模型 |

### Temperature (温度)

控制输出的随机性：

- **值域**: 0.1 - 2.0
- **推荐值**: 0.7 - 0.9
- **低值 (0.1-0.4)**: 输出更确定性、保守
- **高值 (1.5-2.0)**: 输出更有创意、随机

### Max Tokens (最大令牌数)

限制单次生成的token数量：

- **值域**: 512 - 8192
- **推荐值**: 2048 - 4096
- 角色卡生成建议设置4096以上

## NSFW内容控制

应用提供三级NSFW内容控制：

| 级别 | 名称 | 说明 |
|------|------|------|
| 0 | 严格禁止 | 完全不生成任何NSFW内容 |
| 1 | AI自动判断 | 由AI根据上下文自行判断 |
| 2 | 允许生成 | 允许生成各类角色内容 |

## 响应格式

应用期望API返回以下格式的响应：

```json
{
  "choices": [
    {
      "message": {
        "content": "生成的JSON内容"
      }
    }
  ]
}
```

## 错误处理

| 错误类型 | 可能原因 | 解决方法 |
|----------|----------|----------|
| 网络连接失败 | API地址错误/服务未启动 | 检查API地址是否正确 |
| 请求超时 | 网络延迟/模型响应慢 | 增加超时时间或检查网络 |
| 认证失败 | API密钥无效 | 检查API密钥是否正确 |
| 频率超限 | 请求过于频繁 | 等待后重试 |

## 本地部署Ollama

如需本地部署AI模型，推荐使用Ollama：

```bash
# 安装Ollama
brew install ollama    # macOS
# 或从官网下载Windows版本

# 启动服务
ollama serve

# 拉取模型
ollama pull llama2
```

Ollama默认地址：`http://localhost:11434`

## 示例配置

### Ollama配置

```
API地址: http://localhost:11434
API密钥: (留空)
模型: llama2
```

### OpenAI配置

```
API地址: https://api.openai.com/v1
API密钥: sk-your-api-key
模型: gpt-3.5-turbo
```
