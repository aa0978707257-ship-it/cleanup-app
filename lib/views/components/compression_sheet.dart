import 'package:flutter/material.dart';
import '../../services/photo_scanner_service.dart';
import '../../utils/app_theme.dart';

/// Bottom sheet for choosing compression quality level
class CompressionSheet extends StatefulWidget {
  final PhotoAsset asset;

  const CompressionSheet({super.key, required this.asset});

  @override
  State<CompressionSheet> createState() => _CompressionSheetState();
}

class _CompressionSheetState extends State<CompressionSheet> {
  int _selectedLevel = 1; // 0=低, 1=中, 2=高

  static const _levels = [
    _Level('低壓縮', '最佳畫質', 0.85, Icons.hd_rounded, AppTheme.success),
    _Level('中壓縮', '推薦，平衡畫質與大小', 0.6, Icons.tune_rounded, AppTheme.primary),
    _Level('高壓縮', '最小檔案，畫質略降', 0.3, Icons.compress_rounded, AppTheme.warning),
  ];

  @override
  Widget build(BuildContext context) {
    final originalSize = widget.asset.size;
    final estimatedSize = (originalSize * _levels[_selectedLevel].quality).toInt();
    final savings = originalSize - estimatedSize;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(50))),
          const SizedBox(height: 20),

          const Text('選擇壓縮品質', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 20),

          // Quality levels
          ...List.generate(_levels.length, (i) {
            final level = _levels[i];
            final selected = _selectedLevel == i;
            final est = (originalSize * level.quality).toInt();

            return GestureDetector(
              onTap: () => setState(() => _selectedLevel = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? level.color.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? level.color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: selected ? level.color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(level.icon, color: selected ? level.color : AppTheme.textMuted, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(level.label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                            color: selected ? level.color : AppTheme.textPrimary)),
                        Text(level.desc, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_fmt(est), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                            color: selected ? level.color : AppTheme.textSecondary)),
                        Text('-${((1 - level.quality) * 100).toInt()}%',
                            style: TextStyle(fontSize: 10, color: selected ? level.color : AppTheme.textMuted, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Size comparison
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _sizeColumn('原始大小', _fmt(originalSize), AppTheme.textSecondary),
                const Icon(Icons.arrow_forward_rounded, color: AppTheme.textMuted, size: 18),
                _sizeColumn('壓縮後', _fmt(estimatedSize), AppTheme.primary),
                const Icon(Icons.trending_down_rounded, color: AppTheme.success, size: 18),
                _sizeColumn('節省', _fmt(savings), AppTheme.success),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Compress button
          Container(
            width: double.infinity, height: 52,
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(50),
              boxShadow: [AppTheme.colorShadow(AppTheme.primary)]),
            child: Material(color: Colors.transparent, child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => Navigator.pop(context, _levels[_selectedLevel].quality),
              child: Center(child: Text('壓縮 (節省 ${_fmt(savings)})',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
            )),
          ),
        ],
      ),
    );
  }

  Widget _sizeColumn(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
    ]);
  }

  String _fmt(int b) {
    if (b < 1024) return '$b B';
    if (b < 1048576) return '${(b / 1024).toStringAsFixed(1)} KB';
    if (b < 1073741824) return '${(b / 1048576).toStringAsFixed(1)} MB';
    return '${(b / 1073741824).toStringAsFixed(1)} GB';
  }
}

class _Level {
  final String label, desc;
  final double quality;
  final IconData icon;
  final Color color;
  const _Level(this.label, this.desc, this.quality, this.icon, this.color);
}
