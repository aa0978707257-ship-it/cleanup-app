import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class CalendarCleanupView extends StatelessWidget {
  const CalendarCleanupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('行事曆清理')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_month_rounded, size: 40, color: AppTheme.danger),
              ),
              const SizedBox(height: 24),
              const Text('清理行事曆', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 10),
              const Text('移除過期事件、已完成的提醒事項和重複事件',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.5)),
              const SizedBox(height: 32),
              // Placeholder items
              _item(Icons.event_busy_rounded, '過期事件', '0 個', AppTheme.danger),
              const SizedBox(height: 10),
              _item(Icons.check_circle_rounded, '已完成提醒', '0 個', AppTheme.success),
              const SizedBox(height: 10),
              _item(Icons.copy_rounded, '重複事件', '0 個', AppTheme.warning),
              const SizedBox(height: 32),
              Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(gradient: AppTheme.dangerGradient, borderRadius: BorderRadius.circular(50),
                  boxShadow: [AppTheme.colorShadow(AppTheme.danger)]),
                child: Material(color: Colors.transparent, child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('行事曆清理功能將在正式版啟用'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    );
                  },
                  child: const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.cleaning_services_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('開始掃描', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ])),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _item(IconData icon, String title, String count, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [AppTheme.softShadow]),
    child: Row(children: [
      Container(width: 38, height: 38,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
        child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 12),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
      const Spacer(),
      Text(count, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
    ]),
  );
}
