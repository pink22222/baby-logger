import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';
import '../models/models.dart';

class QuickAddBar extends StatelessWidget {
  const QuickAddBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickAddButton(context, RecordType.feeding, '🍼', '喂养'),
          _buildQuickAddButton(context, RecordType.diaper, '👶', '尿布'),
          _buildQuickAddButton(context, RecordType.sleep, '😴', '睡眠'),
          _buildQuickAddButton(context, RecordType.bath, '🛁', '洗澡'),
          _buildQuickAddButton(context, RecordType.growth, '📏', '成长'),
          _buildQuickAddButton(context, RecordType.photo, '📷', '照片'),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(BuildContext context, RecordType type, String emoji, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _quickAdd(context, type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  void _quickAdd(BuildContext context, RecordType type) {
    final provider = context.read<BabyProvider>();

    switch (type) {
      case RecordType.feeding:
        // 快速添加一次喂养
        _showQuickFeedingDialog(context, provider);
        break;
      case RecordType.diaper:
        _quickAddDiaper(context, provider);
        break;
      case RecordType.sleep:
        _showQuickSleepDialog(context, provider);
        break;
      case RecordType.bath:
        _quickAddBath(context, provider);
        break;
      case RecordType.growth:
        _showQuickGrowthDialog(context, provider);
        break;
      case RecordType.photo:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('照片功能请从添加记录入口')),
        );
        break;
    }
  }

  void _showQuickFeedingDialog(BuildContext context, BabyProvider provider) {
    FeedingType? selectedType = FeedingType.breast;

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('快速添加喂养', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('🍼 母乳'),
                      selected: selectedType == FeedingType.breast,
                      onSelected: (selected) {
                        if (selected) setState(() => selectedType = FeedingType.breast);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('🍼 奶粉'),
                      selected: selectedType == FeedingType.bottle,
                      onSelected: (selected) {
                        if (selected) setState(() => selectedType = FeedingType.bottle);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('🍚 辅食'),
                      selected: selectedType == FeedingType.solid,
                      onSelected: (selected) {
                        if (selected) setState(() => selectedType = FeedingType.solid);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.addRecord(RecordType.feeding, {
                        'feedingType': selectedType!.index,
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('添加'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _quickAddDiaper(BuildContext context, BabyProvider provider) {
    provider.addRecord(RecordType.diaper, {'diaperType': DiaperType.both.index});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已添加尿布记录')),
    );
  }

  void _showQuickSleepDialog(BuildContext context, BabyProvider provider) {
    TimeOfDay? sleepTime;

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('记录睡眠', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.bedtime),
                  title: const Text('入睡时间'),
                  trailing: Text(sleepTime != null ? sleepTime!.format(context) : '点击选择'),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: sleepTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() => sleepTime = time);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (sleepTime == null) return;
                      
                      final now = DateTime.now();
                      final sleepDateTime = DateTime(
                        now.year, now.month, now.day,
                        sleepTime!.hour, sleepTime!.minute,
                      );
                      final duration = now.difference(sleepDateTime).inMinutes;
                      
                      provider.addRecord(RecordType.sleep, {
                        'sleepTime': sleepDateTime.millisecondsSinceEpoch,
                        'wakeTime': now.millisecondsSinceEpoch,
                        'duration': duration > 0 ? duration : 0,
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('记录醒来'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _quickAddBath(BuildContext context, BabyProvider provider) {
    provider.addRecord(RecordType.bath, {'bathed': true});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已添加洗澡记录')),
    );
  }

  void _showQuickGrowthDialog(BuildContext context, BabyProvider provider) {
    final heightController = TextEditingController();
    final weightController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('记录成长', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(
                  labelText: '身高 (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: '体重 (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final height = double.tryParse(heightController.text);
                    final weight = double.tryParse(weightController.text);
                    
                    if (height == null && weight == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请输入身高或体重')),
                      );
                      return;
                    }
                    
                    provider.addRecord(RecordType.growth, {
                      if (height != null) 'height': height,
                      if (weight != null) 'weight': weight,
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
