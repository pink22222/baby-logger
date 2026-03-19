# 养娃记录 App

一款简洁好用的育儿记录App，参考Piyo日志设计。

## 功能特性

- 🍼 **喂养记录** - 母乳/奶粉/辅食，记录时长和奶量
- 👶 **尿布记录** - 小便、大便、都有
- 😴 **睡眠记录** - 入睡时间、醒来时间、时长统计
- 🛁 **洗澡记录** - 洗澡时间标记
- 📏 **成长记录** - 身高、体重、头围
- 📅 **日历视图** - 日/周/月切换，查看历史记录
- 📊 **统计图表** - 各维度趋势变化
- 🔔 **提醒功能** - 喂奶、用药等自定义提醒
- 📷 **照片墙** - 绑定日期的成长照片
- 👶 **多宝宝** - 支持管理多个孩子

## 技术栈

- **框架**: Flutter
- **状态管理**: Provider
- **本地存储**: SQLite (sqflite)
- **日历**: table_calendar
- **图表**: fl_chart
- **图片**: image_picker
- **通知**: flutter_local_notifications

## 运行项目

### 前提条件

1. 安装 [Flutter SDK](https://flutter.dev/docs/get-started/install)
2. 配置好 Android/iOS 开发环境

### 启动

```bash
cd baby_logger

# 获取依赖
flutter pub get

# 运行（调试模式）
flutter run
```

## 项目结构

```
baby_logger/
├── lib/
│   ├── main.dart              # 入口文件
│   ├── models/
│   │   └── models.dart        # 数据模型
│   ├── providers/
│   │   └── baby_provider.dart  # 状态管理
│   ├── screens/
│   │   ├── home_screen.dart        # 首页
│   │   ├── add_baby_screen.dart    # 添加宝宝
│   │   ├── add_record_screen.dart  # 添加记录
│   │   ├── calendar_screen.dart   # 日历
│   │   ├── statistics_screen.dart  # 统计
│   │   ├── reminders_screen.dart   # 提醒
│   │   └── settings_screen.dart    # 设置
│   ├── services/
│   │   ├── database_service.dart      # 数据库
│   │   └── notification_service.dart  # 通知
│   └── widgets/
│       ├── quick_add_bar.dart  # 快捷添加
│       └── record_card.dart    # 记录卡片
└── pubspec.yaml
```

## 打包发布

### iOS

```bash
flutter build ios --release
```

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

## 截图预览

（待添加）

## License

MIT
