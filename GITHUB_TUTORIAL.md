# GitHub Actions 自动构建教程

本教程将指导你如何将项目代码推送到GitHub并配置自动构建APK。

## 准备工作

### 1. 创建GitHub仓库

1. 登录 [GitHub](https://github.com)
2. 点击右上角 `+` 号，选择 `New repository`
3. 填写仓库信息：
   - **Repository name**: `sillytavern-card-generator` (或其他名称)
   - **Description**: `SillyTavern角色卡生成器`
   - **Public** / **Private**: 自行选择
4. 点击 `Create repository`
5. **不要勾选** "Add a README file"（我们已有代码）

### 2. 安装Git（如果未安装）

下载并安装 Git: https://git-scm.com

---

## 本地操作步骤

### 步骤1：初始化Git仓库

在项目目录下执行：

```bash
git init
```

### 步骤2：配置Git用户信息

```bash
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的邮箱"
```

### 步骤3：添加远程仓库

```bash
git remote add origin https://github.com/你的用户名/仓库名.git
```

### 步骤4：添加所有文件

```bash
git add .
```

### 步骤5：创建初始提交

```bash
git commit -m "Initial commit: SillyTavern角色卡生成器"
```

### 步骤6：推送到GitHub

```bash
git branch -M main
git push -u origin main
```

---

## 验证GitHub Actions

### 1. 查看构建状态

1. 打开你的GitHub仓库页面
2. 点击 `Actions` 标签
3. 你会看到构建任务正在运行或已完成

### 2. 下载APK

构建成功后：
1. 进入 `Actions` 页面
2. 点击最新的构建任务
3. 在 `Artifacts` 部分找到 `apk-files`
4. 下载包含debug和release版本APK的压缩包

---

## 自动构建触发方式

### 方式1：推送代码

```bash
# 修改代码后
git add .
git commit -m "更新内容描述"
git push origin main
```

### 方式2：创建Release发布版本

```bash
# 创建版本标签
git tag v1.0.0

# 推送标签
git push origin v1.0.0
```

创建tag后，GitHub Actions会自动构建并发布APK到Release页面。

---

## 配置说明

项目已配置好 `.github/workflows/build_apk.yml`，主要包含：

| 配置项 | 值 |
|--------|-----|
| Flutter版本 | 3.24.0 |
| Java版本 | 17 |
| 构建类型 | debug + release |
| 触发条件 | push到main分支 |

---

## 常见问题

### Q: 构建失败怎么办？
A: 
1. 进入 Actions 页面查看详细错误日志
2. 常见问题：Flutter版本不兼容、依赖问题
3. 可以修改 `build_apk.yml` 中的版本号

### Q: 如何修改Flutter版本？
A: 编辑 `.github/workflows/build_apk.yml`，修改：
```yaml
env:
  flutter_version: '3.24.0'  # 改为你需要的版本
```

### Q: 如何只构建release版本？
A: 修改 workflow 文件，删除 debug 构建部分

---

## 完整命令汇总

```bash
# 初始化并推送（首次）
cd "你的项目路径"
git init
git config --global user.name "你的用户名"
git config --global user.email "你的邮箱"
git remote add origin https://github.com/你的用户名/仓库名.git
git add .
git commit -m "Initial commit"
git branch -M main
git push -u origin main

# 后续更新代码
git add .
git commit -m "修复了某个问题"
git push

# 发布正式版本
git tag v1.0.0
git push origin v1.0.0
```

按照这个教程，你就可以将代码推送到GitHub并自动构建APK了！需要我进一步解释任何步骤吗？
