import 'package:uuid/uuid.dart';

enum RecordType { feeding, diaper, sleep, bath, growth, photo }

enum FeedingType { breast, bottle, solid }

enum DiaperType { pee, poop, both }

class Baby {
  final String id;
  final String name;
  final DateTime birthDate;
  final String? avatarPath;
  final DateTime createdAt;

  Baby({
    String? id,
    required this.name,
    required this.birthDate,
    this.avatarPath,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  int get ageInDays => DateTime.now().difference(birthDate).inDays;
  int get ageInMonths => (ageInDays / 30).floor();
  int get ageInYears => (ageInDays / 365).floor();

  String get ageString {
    if (ageInYears > 0) {
      return '${ageInYears}岁${ageInMonths % 12}个月';
    } else if (ageInMonths > 0) {
      return '${ageInMonths}个月';
    } else {
      return '${ageInDays}天';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.millisecondsSinceEpoch,
        'avatarPath': avatarPath,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Baby.fromMap(Map<String, dynamic> map) => Baby(
        id: map['id'],
        name: map['name'],
        birthDate: DateTime.fromMillisecondsSinceEpoch(map['birthDate']),
        avatarPath: map['avatarPath'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      );
}

class Record {
  final String id;
  final String babyId;
  final RecordType type;
  final DateTime time;
  final Map<String, dynamic> data;
  final String? note;
  final DateTime createdAt;

  Record({
    String? id,
    required this.babyId,
    required this.type,
    required this.time,
    required this.data,
    this.note,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'babyId': babyId,
        'type': type.index,
        'time': time.millisecondsSinceEpoch,
        'data': data.entries.map((e) => '${e.key}:${e.value}').join('|'),
        'note': note,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Record.fromMap(Map<String, dynamic> map) {
    final dataMap = <String, dynamic>{};
    if (map['data'] != null && map['data'].toString().isNotEmpty) {
      for (var item in map['data'].toString().split('|')) {
        final parts = item.split(':');
        if (parts.length >= 2) {
          dataMap[parts[0]] = parts.sublist(1).join(':');
        }
      }
    }
    return Record(
      id: map['id'],
      babyId: map['babyId'],
      type: RecordType.values[map['type']],
      time: DateTime.fromMillisecondsSinceEpoch(map['time']),
      data: dataMap,
      note: map['note'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}

class Reminder {
  final String id;
  final String babyId;
  final String title;
  final String content;
  final RecordType recordType;
  final List<int> weekdays; // 1-7, 空表示每天
  final int hour;
  final int minute;
  final bool enabled;
  final DateTime createdAt;

  Reminder({
    String? id,
    required this.babyId,
    required this.title,
    required this.content,
    required this.recordType,
    this.weekdays = const [],
    required this.hour,
    required this.minute,
    this.enabled = true,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'babyId': babyId,
        'title': title,
        'content': content,
        'recordType': recordType.index,
        'weekdays': weekdays.join(','),
        'hour': hour,
        'minute': minute,
        'enabled': enabled ? 1 : 0,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Reminder.fromMap(Map<String, dynamic> map) => Reminder(
        id: map['id'],
        babyId: map['babyId'],
        title: map['title'],
        content: map['content'],
        recordType: RecordType.values[map['recordType']],
        weekdays: map['weekdays']?.toString().isNotEmpty == true
            ? (map['weekdays'] as String).split(',').map(int.parse).toList()
            : [],
        hour: map['hour'],
        minute: map['minute'],
        enabled: map['enabled'] == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      );
}
