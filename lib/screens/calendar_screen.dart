import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/baby_provider.dart';
import '../models/models.dart';
import '../widgets/record_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Record> _selectedDayRecords = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BabyProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            TableCalendar(
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                provider.selectDate(selectedDay);
                _loadRecordsForDay(provider, selectedDay);
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonDecoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                formatButtonTextStyle: const TextStyle(fontSize: 14),
              ),
            ),

            const Divider(height: 1),

            // 选中日期的记录列表
            Expanded(
              child: _selectedDayRecords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            '${DateFormat('MM月dd日').format(_selectedDay!)} 没有记录',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _selectedDayRecords.length,
                      itemBuilder: (context, index) {
                        final record = _selectedDayRecords[index];
                        return RecordCard(
                          record: record,
                          showTime: true,
                          onDelete: () async {
                            await provider.deleteRecord(record.id);
                            _loadRecordsForDay(provider, _selectedDay!);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _loadRecordsForDay(BabyProvider provider, DateTime day) async {
    // 实际应该从provider获取，这里简化处理
    setState(() {
      _selectedDayRecords = provider.todayRecords
          .where((r) => isSameDay(r.time, day))
          .toList();
    });
  }
}
