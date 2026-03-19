import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/baby_provider.dart';
import '../models/models.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  RecordType _selectedType = RecordType.feeding;
  int _daysRange = 7; // 默认显示7天

  @override
  Widget build(BuildContext context) {
    return Consumer<BabyProvider>(
      builder: (context, provider, _) {
        final baby = provider.currentBaby;
        if (baby == null) {
          return const Center(child: Text('请先添加宝宝'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 统计类型选择
              Text(
                '统计类型',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTypeChip(RecordType.feeding, '🍼 喂养'),
                  _buildTypeChip(RecordType.diaper, '👶 尿布'),
                  _buildTypeChip(RecordType.sleep, '😴 睡眠'),
                  _buildTypeChip(RecordType.growth, '📏 成长'),
                ],
              ),

              const SizedBox(height: 16),

              // 时间范围选择
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text('7天')),
                  ButtonSegment(value: 30, label: Text('30天')),
                  ButtonSegment(value: 90, label: Text('90天')),
                ],
                selected: {_daysRange},
                onSelectionChanged: (selection) {
                  setState(() => _daysRange = selection.first);
                },
              ),

              const SizedBox(height: 24),

              // 统计卡片
              _buildStatisticsCard(provider),

              const SizedBox(height: 24),

              // 趋势图表
              if (_selectedType == RecordType.feeding || _selectedType == RecordType.sleep)
                _buildTrendChart(provider),

              // 成长图表
              if (_selectedType == RecordType.growth) _buildGrowthChart(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeChip(RecordType type, String label) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedType = type);
      },
    );
  }

  Widget _buildStatisticsCard(BabyProvider provider) {
    final records = provider.todayRecords.where((r) => r.type == _selectedType).toList();
    final count = records.length;

    String summary = '';
    switch (_selectedType) {
      case RecordType.feeding:
        summary = '今日 ${count} 次喂养';
        break;
      case RecordType.diaper:
        final peeCount = records.where((r) => r.data['diaperType'] == DiaperType.pee.index || r.data['diaperType'] == DiaperType.both.index).length;
        final poopCount = records.where((r) => r.data['diaperType'] == DiaperType.poop.index || r.data['diaperType'] == DiaperType.both.index).length;
        summary = '今日 小便 $peeCount 次 / 大便 $poopCount 次';
        break;
      case RecordType.sleep:
        final totalMinutes = records.fold<int>(0, (sum, r) => sum + (r.data['duration'] ?? 0));
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        summary = '今日睡眠 ${hours}小时${minutes}分钟';
        break;
      case RecordType.growth:
        if (records.isNotEmpty) {
          final latest = records.first;
          summary = '身高 ${latest.data['height'] ?? '-'} cm / 体重 ${latest.data['weight'] ?? '-'} kg';
        } else {
          summary = '今日暂无记录';
        }
        break;
      default:
        summary = '今日 $count 条记录';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTypeIcon(_selectedType),
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeName(_selectedType),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summary,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(BabyProvider provider) {
    // 模拟数据 - 实际应该从数据库获取日期范围内的数据
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = _daysRange - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      // 模拟每天的次数
      final count = (i % 3 + 2).toDouble();
      spots.add(FlSpot((_daysRange - 1 - i).toDouble(), count));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '趋势图',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 7 == 0 && value.toInt() > 0) {
                            return Text('${value.toInt()}天');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthChart(BabyProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '成长曲线',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}月');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 50),
                        FlSpot(1, 55),
                        FlSpot(3, 60),
                        FlSpot(6, 65),
                        FlSpot(9, 70),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3.5),
                        FlSpot(1, 4.5),
                        FlSpot(3, 6.0),
                        FlSpot(6, 7.5),
                        FlSpot(9, 8.5),
                      ],
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('身高(cm)', Colors.blue),
                const SizedBox(width: 24),
                _buildLegend('体重(kg)', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
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

  String _getTypeName(RecordType type) {
    switch (type) {
      case RecordType.feeding:
        return '喂养统计';
      case RecordType.diaper:
        return '尿布统计';
      case RecordType.sleep:
        return '睡眠统计';
      case RecordType.bath:
        return '洗澡统计';
      case RecordType.growth:
        return '成长统计';
      case RecordType.photo:
        return '照片统计';
    }
  }
}
