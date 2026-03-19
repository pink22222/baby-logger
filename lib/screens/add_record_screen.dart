import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/baby_provider.dart';
import '../models/models.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  RecordType? _selectedType;
  final _noteController = TextEditingController();

  // 喂养相关
  FeedingType? _feedingType;
  int? _feedingMinutes;
  int? _bottleAmount;

  // 尿布相关
  DiaperType? _diaperType;

  // 睡眠相关
  TimeOfDay? _sleepTime;
  TimeOfDay? _wakeTime;

  // 洗澡
  bool _bathDone = false;

  // 成长
  double? _height;
  double? _weight;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (_selectedType == null) return;

    final provider = context.read<BabyProvider>();
    Map<String, dynamic> data = {};

    switch (_selectedType!) {
      case RecordType.feeding:
        if (_feedingType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请选择喂养方式')),
          );
          return;
        }
        data = {
          'feedingType': _feedingType!.index,
          if (_feedingMinutes != null) 'minutes': _feedingMinutes,
          if (_bottleAmount != null) 'amount': _bottleAmount,
        };
        break;

      case RecordType.diaper:
        if (_diaperType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请选择尿布情况')),
          );
          return;
        }
        data = {'diaperType': _diaperType!.index};
        break;

      case RecordType.sleep:
        if (_sleepTime == null || _wakeTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请选择睡眠时间')),
          );
          return;
        }
        final sleepDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          _sleepTime!.hour,
          _sleepTime!.minute,
        );
        final wakeDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          _wakeTime!.hour,
          _wakeTime!.minute,
        );
        final duration = wakeDateTime.difference(sleepDateTime).inMinutes;
        data = {
          'sleepTime': sleepDateTime.millisecondsSinceEpoch,
          'wakeTime': wakeDateTime.millisecondsSinceEpoch,
          'duration': duration,
        };
        break;

      case RecordType.bath:
        data = {'bathed': _bathDone};
        break;

      case RecordType.growth:
        if (_height == null && _weight == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请输入身高或体重')),
          );
          return;
        }
        data = {
          if (_height != null) 'height': _height,
          if (_weight != null) 'weight': _weight,
        };
        break;

      case RecordType.photo:
        // 照片单独处理
        break;
    }

    provider.addRecord(
      _selectedType!,
      data,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    Navigator.pop(context);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // TODO: 保存照片并创建记录
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('照片功能开发中')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加记录'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 记录类型选择
          Text(
            '记录类型',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip(RecordType.feeding, '🍼 喂养', Icons.restaurant),
              _buildTypeChip(RecordType.diaper, '👶 尿布', Icons.baby_changing_station),
              _buildTypeChip(RecordType.sleep, '😴 睡眠', Icons.bedtime),
              _buildTypeChip(RecordType.bath, '🛁 洗澡', Icons.bathtub),
              _buildTypeChip(RecordType.growth, '📏 成长', Icons.straighten),
              _buildTypeChip(RecordType.photo, '📷 照片', Icons.photo_camera),
            ],
          ),

          const SizedBox(height: 24),

          if (_selectedType != null) ...[
            Text(
              '详细信息',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailsForm(),
          ],

          const SizedBox(height: 24),

          // 备注
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: '备注（可选）',
              hintText: '添加一些备注...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(RecordType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
    );
  }

  Widget _buildDetailsForm() {
    switch (_selectedType!) {
      case RecordType.feeding:
        return _buildFeedingForm();
      case RecordType.diaper:
        return _buildDiaperForm();
      case RecordType.sleep:
        return _buildSleepForm();
      case RecordType.bath:
        return _buildBathForm();
      case RecordType.growth:
        return _buildGrowthForm();
      case RecordType.photo:
        return _buildPhotoForm();
    }
  }

  Widget _buildFeedingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('喂养方式'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('母乳'),
              selected: _feedingType == FeedingType.breast,
              onSelected: (selected) {
                setState(() => _feedingType = selected ? FeedingType.breast : null);
              },
            ),
            ChoiceChip(
              label: const Text('奶粉'),
              selected: _feedingType == FeedingType.bottle,
              onSelected: (selected) {
                setState(() => _feedingType = selected ? FeedingType.bottle : null);
              },
            ),
            ChoiceChip(
              label: const Text('辅食'),
              selected: _feedingType == FeedingType.solid,
              onSelected: (selected) {
                setState(() => _feedingType = selected ? FeedingType.solid : null);
              },
            ),
          ],
        ),

        if (_feedingType == FeedingType.breast) ...[
          const SizedBox(height: 16),
          const Text('喂养时长（分钟）'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: (_feedingMinutes ?? 15).toDouble(),
                  min: 1,
                  max: 60,
                  divisions: 59,
                  label: '${_feedingMinutes ?? 15} 分钟',
                  onChanged: (value) {
                    setState(() => _feedingMinutes = value.round());
                  },
                ),
              ),
              SizedBox(width: 60, child: Text('${_feedingMinutes ?? 15}分钟')),
            ],
          ),
        ],

        if (_feedingType == FeedingType.bottle) ...[
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: '奶量（ml）',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _bottleAmount = int.tryParse(value);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDiaperForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('尿布情况'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('仅小便'),
              selected: _diaperType == DiaperType.pee,
              onSelected: (selected) {
                setState(() => _diaperType = selected ? DiaperType.pee : null);
              },
            ),
            ChoiceChip(
              label: const Text('仅大便'),
              selected: _diaperType == DiaperType.poop,
              onSelected: (selected) {
                setState(() => _diaperType = selected ? DiaperType.poop : null);
              },
            ),
            ChoiceChip(
              label: const Text('都有'),
              selected: _diaperType == DiaperType.both,
              onSelected: (selected) {
                setState(() => _diaperType = selected ? DiaperType.both : null);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSleepForm() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.bedtime),
          title: const Text('入睡时间'),
          trailing: Text(
            _sleepTime != null
                ? _sleepTime!.format(context)
                : '点击选择',
          ),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _sleepTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              setState(() => _sleepTime = time);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.wb_sunny),
          title: const Text('醒来时间'),
          trailing: Text(
            _wakeTime != null
                ? _wakeTime!.format(context)
                : '点击选择',
          ),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _wakeTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              setState(() => _wakeTime = time);
            }
          },
        ),
        if (_sleepTime != null && _wakeTime != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '睡眠时长: ${_calculateSleepDuration()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
      ],
    );
  }

  String _calculateSleepDuration() {
    final sleepMinutes = _sleepTime!.hour * 60 + _sleepTime!.minute;
    final wakeMinutes = _wakeTime!.hour * 60 + _wakeTime!.minute;
    var duration = wakeMinutes - sleepMinutes;
    if (duration < 0) duration += 24 * 60;
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    return '${hours}小时${minutes}分钟';
  }

  Widget _buildBathForm() {
    return SwitchListTile(
      title: const Text('今天洗过澡了'),
      value: _bathDone,
      onChanged: (value) => setState(() => _bathDone = value),
    );
  }

  Widget _buildGrowthForm() {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: '身高（cm）',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            _height = double.tryParse(value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: '体重（kg）',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            _weight = double.tryParse(value);
          },
        ),
      ],
    );
  }

  Widget _buildPhotoForm() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.photo_library, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('从相册选择'),
          ),
        ],
      ),
    );
  }
}
