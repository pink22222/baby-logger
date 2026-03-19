import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/baby_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<BabyProvider>(
        builder: (context, provider, _) {
          return ListView(
            children: [
              // 宝宝管理
              _buildSectionHeader('宝宝管理'),
              ...provider.babies.map((baby) => ListTile(
                    leading: CircleAvatar(child: Text(baby.name.substring(0, 1))),
                    title: Text(baby.name),
                    subtitle: Text(baby.ageString),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showBabyDetails(context, provider, baby),
                  )),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.add)),
                title: const Text('添加宝宝'),
                onTap: () {
                  Navigator.pop(context);
                  // 回到首页并触发添加宝宝
                },
              ),

              const Divider(),

              // 数据管理
              _buildSectionHeader('数据管理'),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: const Text('导出数据'),
                subtitle: const Text('将记录导出为CSV文件'),
                onTap: () => _showExportDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.restore_outlined),
                title: const Text('导入数据'),
                subtitle: const Text('从备份文件导入'),
                onTap: () => _showImportDialog(context),
              ),

              const Divider(),

              // 关于
              _buildSectionHeader('关于'),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('关于养娃记录'),
                subtitle: const Text('版本 1.0.0'),
                onTap: () => _showAboutDialog(context),
              ),

              const Divider(),

              // 危险操作
              _buildSectionHeader('危险操作'),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('删除所有数据', style: TextStyle(color: Colors.red)),
                onTap: () => _showDeleteAllDialog(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showBabyDetails(BuildContext context, BabyProvider provider, dynamic baby) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑宝宝信息'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 导航到编辑页面
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除宝宝', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteBabyDialog(context, provider, baby);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteBabyDialog(BuildContext context, BabyProvider provider, dynamic baby) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除宝宝'),
        content: Text('确定删除 "${baby.name}" 吗？所有相关记录都将被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteBaby(baby.id);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, BabyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除所有数据'),
        content: const Text('此操作不可恢复！所有宝宝、记录和提醒都将被永久删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 删除所有宝宝
              for (var baby in provider.babies) {
                provider.deleteBaby(baby.id);
              }
              Navigator.pop(context);
            },
            child: const Text('删除全部', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出数据'),
        content: const Text('数据导出功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入数据'),
        content: const Text('数据导入功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '养娃记录',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      children: const [
        Text('一款简洁好用的育儿记录App，参考Piyo日志设计。'),
        SizedBox(height: 8),
        Text('帮你记录宝宝的每一个成长瞬间。'),
      ],
    );
  }
}
