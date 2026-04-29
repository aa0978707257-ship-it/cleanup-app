import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class EmailCleanupView extends StatelessWidget {
  const EmailCleanupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('信箱清理')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.email_rounded, size: 40, color: AppTheme.primary),
              ),
              const SizedBox(height: 24),
              const Text('清理你的收件匣', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 10),
              const Text('連接 Gmail 帳號，一鍵清除促銷郵件、垃圾信和大型附件',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.5)),
              const SizedBox(height: 12),
              // Privacy bullets
              _bullet(Icons.lock_rounded, '郵件僅在裝置上處理'),
              _bullet(Icons.cloud_off_rounded, '不會上傳到任何伺服器'),
              _bullet(Icons.restore_rounded, '刪除的郵件移到垃圾桶，可復原'),
              const SizedBox(height: 32),
              Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(50),
                  boxShadow: [AppTheme.colorShadow(AppTheme.primary)]),
                child: Material(color: Colors.transparent, child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Gmail 連接功能將在正式版啟用'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    );
                  },
                  child: const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.email_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('連接 Gmail', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ])),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _bullet(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: AppTheme.success),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
    ]),
  );
}
