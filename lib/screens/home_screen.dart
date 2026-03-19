import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/baby_provider.dart';
import '../models/models.dart';
import '../widgets/record_card.dart';
import '../widgets/quick_add_bar.dart';
import 'add_baby_screen.dart';
import 'add_record_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<BabyProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.babies.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('养娃记录')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '还没有添加宝宝',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddBaby(context),
                    icon: const Icon(Icons.add),
                    label: const Text('添加宝宝'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final baby = provider.currentBaby!;

        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () => _showBabySelector(context, provider),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(baby.name),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RemindersScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeContent(context, provider, baby),
              const CalendarScreen(),
              const StatisticsScreen(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '首页'),
              NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: '日历'),
              NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: '统计'),
            ],
          ),
          floatingActionButton: _currentIndex == 0
              ? FloatingActionButton(
                  onPressed: () => _navigateToAddRecord(context),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  Widget _buildHomeContent(BuildContext context, BabyProvider provider, Baby baby) {
    final dateFormat = DateFormat('MM月dd日 EEEE', 'zh_CN');
    final todayRecords = provider.todayRecords;

    // 按类型分组显示
    final groupedRecords = <RecordType, List<Record>>{};
    for (var record in todayRecords) {
      groupedRecords.putIfAbsent(record.type, () => []).add(record);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 宝宝信息卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      baby.name.substring(0, 1),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(baby.name, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          baby.ageString,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    dateFormat.format(provider.selectedDate),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 快捷记录栏
          const QuickAddBar(),

          const SizedBox(height: 24),

          // 今日记录
          Text(
            '今日记录',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (todayRecords.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.note_add_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('今天还没有记录', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          else
            ...groupedRecords.entries.map((entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _getRecordTypeName(entry.key),
                        style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                      ),
                    ),
                    ...entry.value.map((record) => RecordCard(
                          record: record,
                          onDelete: () => provider.deleteRecord(record.id),
                        )),
                    const SizedBox(height: 8),
                  ],
                )),
        ],
      ),
    );
  }

  String _getRecordTypeName(RecordType type) {
    switch (type) {
      case RecordType.feeding:
        return '🍼 喂养';
      case RecordType.diaper:
        return '👶 尿布';
      case RecordType.sleep:
        return '😴 睡眠';
      case RecordType.bath:
        return '🛁 洗澡';
      case RecordType.growth:
        return '📏 成长';
      case RecordType.photo:
        return '📷 照片';
    }
  }

  void _showBabySelector(BuildContext context, BabyProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('添加宝宝'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddBaby(context);
              },
            ),
            const Divider(),
            ...provider.babies.map((baby) => ListTile(
                  leading: CircleAvatar(child: Text(baby.name.substring(0, 1))),
                  title: Text(baby.name),
                  trailing: baby.id == provider.currentBaby?.id
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    provider.selectBaby(baby);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _navigateToAddBaby(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBabyScreen()),
    );
  }

  void _navigateToAddRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddRecordScreen()),
    );
  }
}
