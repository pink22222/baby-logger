import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/baby_provider.dart';
import '../models/models.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提醒'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReminderDialog(context),
          ),
        ],
      ),
      body: Consumer<BabyProvider>(
        builder: (context, provider, _) {
          if (provider.reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('还没有提醒', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('点击右上角添加提醒', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.reminders.length,
            itemBuilder: (context, index) {
              final reminder = provider.reminders[index];
              return _buildReminderCard(context, provider, reminder);
            },
          );
        },
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, BabyProvider provider, Reminder reminder) {
    final timeString = TimeOfDay(hour: reminder.hour, minute: reminder.minute)
        .format(context);
    final weekdaysString = reminder.weekdays.isEmpty
        ? '每天'
        : reminder.weekdays.map((d) => ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][d - 1]).join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: reminder.enabled
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey[300],
          child: Icon(
            _getTypeIcon(reminder.recordType),
            color: reminder.enabled ? null : Colors.grey,
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            decoration: reminder.enabled ? null : TextDecoration.lineThrough,
            color: reminder.enabled ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reminder.content),
            const SizedBox(height: 4),
            Text(
              '$timeString · $weekdaysString',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: reminder.enabled,
              onChanged: (_) => provider.toggleReminder(reminder),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditReminderDialog(context, reminder);
                } else if (value == 'delete') {
                  _showDeleteConfirm(context, provider, reminder);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('编辑')),
                const PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getTypeIcon(RecordType type) {
    switch (type) {
      case RecordType.feeding:
        return Icons.restaurant;
      case RecordType.diaper:
        return Icons.baby_changing_station;
      case RecordType.sleep:
        return Icons.bedtime;
      case RecordType.bath:
        return Icons.bathtub;
      case RecordType.growth:
        return Icons.straighten;
      case RecordType.photo:
        return Icons.photo_camera;
    }
  }

  void _showAddReminderDialog(BuildContext context) {
    _showReminderForm(context, null);
  }

  void _showEditReminderDialog(BuildContext context, Reminder reminder) {
    _showReminderForm(context, reminder);
  }

  void _showReminderForm(BuildContext context, Reminder? existingReminder) {
    final titleController = TextEditingController(text: existingReminder?.title ?? '');
    final contentController = TextEditingController(text: existingReminder?.content ?? '');
    RecordType selectedType = existingReminder?.recordType ?? RecordType.feeding;
    TimeOfDay selectedTime = existingReminder != null
        ? TimeOfDay(hour: existingReminder.hour, minute: existingReminder.minute)
        : TimeOfDay.now();
    final selectedWeekdays = List<int>.from(existingReminder?.weekdays ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existingReminder == null ? '添加提醒' : '编辑提醒',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '如：喂奶时间到了',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: '内容',
                  hintText: '如：宝宝该吃奶了',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              const Text('提醒类型'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('🍼 喂养'),
                    selected: selectedType == RecordType.feeding,
                    onSelected: (selected) {
                      if (selected) setState(() => selectedType = RecordType.feeding);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('💊 用药'),
                    selected: selectedType == RecordType.diaper,
                    onSelected: (selected) {
                      if (selected) setState(() => selectedType = RecordType.diaper);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('提醒时间'),
                trailing: Text(selectedTime.format(context)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
              const SizedBox(height: 8),

              const Text('重复'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('每天'),
                    selected: selectedWeekdays.isEmpty,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => selectedWeekdays.clear());
                      }
                    },
                  ),
                  for (int i = 1; i <= 7; i++)
                    FilterChip(
                      label: Text(['一', '二', '三', '四', '五', '六', '日'][i - 1]),
                      selected: selectedWeekdays.contains(i),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedWeekdays.add(i);
                          } else {
                            selectedWeekdays.remove(i);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty) return;

                    final provider = context.read<BabyProvider>();
                    if (existingReminder == null) {
                      provider.addReminder(
                        title: titleController.text,
                        content: contentController.text,
                        recordType: selectedType,
                        hour: selectedTime.hour,
                        minute: selectedTime.minute,
                        weekdays: selectedWeekdays,
                      );
                    } else {
                      provider.updateReminder(Reminder(
                        id: existingReminder.id,
                        babyId: existingReminder.babyId,
                        title: titleController.text,
                        content: contentController.text,
                        recordType: selectedType,
                        hour: selectedTime.hour,
                        minute: selectedTime.minute,
                        weekdays: selectedWeekdays,
                        enabled: existingReminder.enabled,
                        createdAt: existingReminder.createdAt,
                      ));
                    }
                    Navigator.pop(context);
                  },
                  child: Text(existingReminder == null ? '添加' : '保存'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, BabyProvider provider, Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除提醒'),
        content: Text('确定删除 "${reminder.title}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteReminder(reminder.id);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
