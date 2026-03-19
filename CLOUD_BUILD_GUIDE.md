# 云编译设置指南

## 第一步：创建GitHub仓库

1. 打开 https://github.com 并登录
2. 点击右上角 **+** → **New repository**
3. 仓库名称填写 `baby-logger`
4. 选择 **Private**（私有）或 **Public**（公开）
5. **不要**勾选任何初始化选项（README等）
6. 点击 **Create repository**

## 第二步：推送代码

在终端运行以下命令（把 `YOUR_USERNAME` 换成你的GitHub用户名）：

```bash
cd E:\autoclaw\baby_logger
git remote add origin https://github.com/YOUR_USERNAME/baby-logger.git
git add .
git commit -m "Initial commit - Baby Logger App"
git branch -M main
git push -u origin main
```

## 第三步：开启GitHub Actions

1. 打开你的GitHub仓库
2. 点击 **Actions** 标签
3. GitHub会自动检测到workflow，点击 **I understand my workflows, go ahead and enable them**
4. 以后每次push代码，会自动编译iOS和Android

## 第四步：下载编译好的App

### Android APK
- 编译完成后在 **Actions** → 点击最新的workflow运行
- 找到 **Artifacts** → 下载 **app-packages**
- APK在 `app-release.apk`

### iOS（需要Mac才能安装）
- iOS编译需要macOS环境
- GitHub Actions的macOS是付费的（但有免费额度）
- 如需iOS真机安装，建议使用 [Codemagic](https://codemagic.io) 免费服务

## Codemagic免费云编译iOS（可选）

1. 注册 https://codemagic.io (用GitHub登录)
2. 点击 **Add app** → 选择你的GitHub仓库
3. 选择Flutter项目
4. 点击 **Finish** → **Start new build**
5. 选择分支，点击 **Start build**

Codemagic每月有500分钟的免费iOS编译时长，对于个人使用足够了。

## 遇到问题？

常见问题：
- **git push失败** - 可能需要生成GitHub Personal Access Token
- **编译失败** - 检查Actions日志，通常是依赖问题

有问题随时告诉我！
