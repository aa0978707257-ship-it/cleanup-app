import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'email_cleanup_view.dart';
import 'calendar_cleanup_view.dart';
import 'charging_animation_view.dart';

class ToolsView extends StatelessWidget {
  const ToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('工具')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('清理工具'),
          _toolCard(context, icon: Icons.email_rounded, title: '信箱清理',
              subtitle: '清除促銷郵件和垃圾信', color: AppTheme.primary,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmailCleanupView()))),
          _toolCard(context, icon: Icons.calendar_month_rounded, title: '行事曆清理',
              subtitle: '移除過期事件和已完成提醒', color: AppTheme.danger,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarCleanupView()))),
          const SizedBox(height: 16),
          _sectionTitle('趣味功能'),
          _toolCard(context, icon: Icons.bolt_rounded, title: '充電動畫',
              subtitle: '自訂你的充電畫面', color: Colors.amber,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChargingAnimationView()))),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _toolCard(BuildContext context,
      {required IconData icon, required String title,
      required String subtitle, required Color color, required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
