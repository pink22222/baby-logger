import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class BabyProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final NotificationService _notifications = NotificationService();

  List<Baby> _babies = [];
  Baby? _currentBaby;
  List<Record> _todayRecords = [];
  List<Reminder> _reminders = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List<Baby> get babies => _babies;
  Baby? get currentBaby => _currentBaby;
  List<Record> get todayRecords => _todayRecords;
  List<Reminder> get reminders => _reminders;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _notifications.initialize();
    await _notifications.requestPermissions();

    _babies = await _db.getBabies();
    if (_babies.isNotEmpty) {
      _currentBaby = _babies.first;
      await _loadTodayRecords();
      await _loadReminders();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectBaby(Baby baby) async {
    _currentBaby = baby;
    await _loadTodayRecords();
    await _loadReminders();
    notifyListeners();
  }

  Future<void> addBaby(String name, DateTime birthDate, {String? avatarPath}) async {
    final baby = Baby(name: name, birthDate: birthDate, avatarPath: avatarPath);
    await _db.insertBaby(baby);
    _babies.insert(0, baby);
    _currentBaby = baby;
    await _loadTodayRecords();
    await _loadReminders();
    notifyListeners();
  }

  Future<void> updateBaby(Baby baby) async {
    await _db.updateBaby(baby);
    final index = _babies.indexWhere((b) => b.id == baby.id);
    if (index != -1) {
      _babies[index] = baby;
      if (_currentBaby?.id == baby.id) {
        _currentBaby = baby;
      }
    }
    notifyListeners();
  }

  Future<void> deleteBaby(String id) async {
    await _db.deleteBaby(id);
    _babies.removeWhere((b) => b.id == id);
    if (_currentBaby?.id == id) {
      _currentBaby = _babies.isNotEmpty ? _babies.first : null;
      if (_currentBaby != null) {
        await _loadTodayRecords();
        await _loadReminders();
      } else {
        _todayRecords = [];
        _reminders = [];
      }
    }
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _loadTodayRecords();
    notifyListeners();
  }

  Future<void> _loadTodayRecords() async {
    if (_currentBaby == null) return;
    _todayRecords = await _db.getRecords(_currentBaby!.id, date: _selectedDate);
    notifyListeners();
  }

  Future<void> _loadReminders() async {
    if (_currentBaby == null) return;
    _reminders = await _db.getReminders(_currentBaby!.id);
    notifyListeners();
  }

  Future<void> addRecord(RecordType type, Map<String, dynamic> data, {String? note}) async {
    if (_currentBaby == null) return;

    final record = Record(
      babyId: _currentBaby!.id,
      type: type,
      time: DateTime.now(),
      data: data,
      note: note,
    );

    await _db.insertRecord(record);
    await _loadTodayRecords();
  }

  Future<void> deleteRecord(String id) async {
    await _db.deleteRecord(id);
    await _loadTodayRecords();
  }

  Future<void> addReminder({
    required String title,
    required String content,
    required RecordType recordType,
    List<int> weekdays = const [],
    required int hour,
    required int minute,
  }) async {
    if (_currentBaby == null) return;

    final reminder = Reminder(
      babyId: _currentBaby!.id,
      title: title,
      content: content,
      recordType: recordType,
      weekdays: weekdays,
      hour: hour,
      minute: minute,
    );

    await _db.insertReminder(reminder);
    await _notifications.scheduleReminder(reminder);
    await _loadReminders();
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _db.updateReminder(reminder);
    await _notifications.cancelReminder(reminder.id);
    if (reminder.enabled) {
      await _notifications.scheduleReminder(reminder);
    }
    await _loadReminders();
  }

  Future<void> toggleReminder(Reminder reminder) async {
    final updated = Reminder(
      id: reminder.id,
      babyId: reminder.babyId,
      title: reminder.title,
      content: reminder.content,
      recordType: reminder.recordType,
      weekdays: reminder.weekdays,
      hour: reminder.hour,
      minute: reminder.minute,
      enabled: !reminder.enabled,
      createdAt: reminder.createdAt,
    );
    await updateReminder(updated);
  }

  Future<void> deleteReminder(String id) async {
    await _db.deleteReminder(id);
    await _notifications.cancelReminder(id);
    await _loadReminders();
  }

  // 获取某类型记录的最新一条
  Record? getLatestRecord(RecordType type) {
    try {
      return _todayRecords.firstWhere((r) => r.type == type);
    } catch (_) {
      return null;
    }
  }

  // 获取指定日期范围内的记录
  Future<List<Record>> getRecordsInRange(DateTime start, DateTime end) async {
    if (_currentBaby == null) return [];
    return await _db.getRecords(_currentBaby!.id, date: _selectedDate);
  }

  // 获取统计数据
  Future<Map<String, dynamic>> getStatistics(RecordType type, DateTime start, DateTime end) async {
    if (_currentBaby == null) return {};
    return await _db.getStatistics(_currentBaby!.id, type, start, end);
  }
}
