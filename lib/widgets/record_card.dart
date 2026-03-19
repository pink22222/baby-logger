import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class RecordCard extends StatelessWidget {
  final Record record;
  final VoidCallback? onDelete;
  final bool showTime;

  const RecordCard({
    super.key,
    required this.record,
    this.onDelete,
    this.showTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(record.type).withOpacity(0.2),
          child: Text(
            _getTypeEmoji(record.type),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(_getTitle()),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTime)
              Text(
                DateFormat('HH:mm').format(record.time),
                style: TextStyle(color: Colors.grey[600]),
              ),
            Text(
              _getSubtitle(),
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            if (record.note != null && record.note!.isNotEmpty)
              Text(
                '备注: ${record.note}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
              ),
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => _confirmDelete(context),
              )
            : null,
        isThreeLine: showTime || (record.note != null && record.note!.isNotEmpty),
      ),
    );
  }

  String _getTitle() {
    switch (record.type) {
      case RecordType.feeding:
        return '🍼 喂养';
      case RecordType.diaper:
        return '👶 换尿布';
      case RecordType.sleep:
        return '😴 睡眠';
      case RecordType.bath:
        return '🛁 洗澡';
      case RecordType.growth:
        return '📏 成长记录';
      case RecordType.photo:
        return '📷 照片';
    }
  }

  String _getSubtitle() {
    switch (record.type) {
      case RecordType.feeding:
        final feedingType = FeedingType.values[record.data['feedingType'] ?? 0];
        switch (feedingType) {
          case FeedingType.breast:
            final minutes = record.data['minutes'] ?? 0;
            return '母乳 ${minutes}分钟';
          case FeedingType.bottle:
            final amount = record.data['amount'] ?? 0;
            return '奶粉 ${amount}ml';
          case FeedingType.solid:
            return '辅食';
        }

      case RecordType.diaper:
        final diaperType = DiaperType.values[record.data['diaperType'] ?? 0];
        switch (diaperType) {
          case DiaperType.pee:
            return '仅小便';
          case DiaperType.poop:
            return '仅大便';
          case DiaperType.both:
            return '小便+大便';
        }

      case RecordType.sleep:
        final duration = record.data['duration'] ?? 0;
        final hours = duration ~/ 60;
        final minutes = duration % 60;
        if (hours > 0) {
          return '睡眠 ${hours}小时${minutes}分钟';
        }
        return '睡眠 ${minutes}分钟';

      case RecordType.bath:
        return record.data['bathed'] == true ? '已洗澡' : '未洗澡';

      case RecordType.growth:
        final height = record.data['height'];
        final weight = record.data['weight'];
        final parts = <String>[];
        if (height != null) parts.add('身高 ${height}cm');
        if (weight != null) parts.add('体重 ${weight}kg');
        return parts.join(' / ');

      case RecordType.photo:
        return '成长照片';
    }
  }

  Color _getTypeColor(RecordType type) {
    switch (type) {
      case RecordType.feeding:
        return Colors.blue;
      case RecordType.diaper:
        return Colors.orange;
      case RecordType.sleep:
        return Colors.purple;
      case RecordType.bath:
        return Colors.teal;
      case RecordType.growth:
        return Colors.green;
      case RecordType.photo:
        return Colors.pink;
    }
  }

  String _getTypeEmoji(RecordType type) {
    switch (type) {
      case RecordType.feeding:
        return '🍼';
      case RecordType.diaper:
        return '👶';
      case RecordType.sleep:
        return '😴';
      case RecordType.bath:
        return '🛁';
      case RecordType.growth:
        return '📏';
      case RecordType.photo:
        return '📷';
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除记录'),
        content: const Text('确定删除这条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
