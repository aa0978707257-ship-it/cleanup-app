import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../services/photo_scanner_service.dart';
import '../../services/subscription_manager.dart';
import '../../models/storage_info.dart';
import '../../utils/app_theme.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  StorageInfo? _storageInfo;

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    final info = await StorageInfo.current();
    if (mounted) setState(() => _storageInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    final scanner = context.watch<PhotoScannerService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cleanup')),
      body: RefreshIndicator(
        onRefresh: _loadStorage,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Storage Card
            if (_storageInfo != null) _buildStorageCard(_storageInfo!),
            const SizedBox(height: 16),

            // Smart Scan Button
            _buildScanButton(scanner),
            const SizedBox(height: 8),

            // Scan Progress
            if (scanner.isScanning)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(value: scanner.scanProgress),
              ),

            // Results Summary
            if (scanner.scanResult.allAssets.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildResultsSummary(scanner),
            ],

            const SizedBox(height: 16),

            // Feature Grid
            _buildFeatureGrid(scanner),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard(StorageInfo info) {
    final color = info.usedPercentage > 0.85
        ? AppTheme.dangerColor
        : info.usedPercentage > 0.7
            ? AppTheme.warningColor
            : AppTheme.primaryColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Storage',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  Text(info.usedSpaceFormatted,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  Text('of ${info.totalSpaceFormatted}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.check_circle, color: AppTheme.successColor, size: 14),
                    const SizedBox(width: 4),
                    Text('${info.freeSpaceFormatted} free',
                        style: TextStyle(
                            color: AppTheme.successColor, fontSize: 12)),
                  ]),
                ],
              ),
            ),
            CircularPercentIndicator(
              radius: 35,
              lineWidth: 6,
              percent: info.usedPercentage.clamp(0, 1),
              center: Text('${(info.usedPercentage * 100).toInt()}%',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              progressColor: color,
              backgroundColor: Colors.grey[200]!,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(PhotoScannerService scanner) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.appGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: scanner.isScanning ? null : () => scanner.startFullScan(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (scanner.isScanning)
                  const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                else
                  const Icon(Icons.auto_awesome, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  scanner.isScanning
                      ? scanner.currentPhase.name
                      : 'Smart Scan',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSummary(PhotoScannerService scanner) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('You can free up',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(
              _formatBytes(scanner.scanResult.totalSavingsEstimate),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.dangerColor,
                    foregroundColor: Colors.white),
                child: const Text('Clean All'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildFeatureGrid(PhotoScannerService scanner) {
    final totalDuplicates = scanner.scanResult.duplicateGroups.fold<int>(0, (sum, g) => sum + g.assets.length);
    final totalSimilar = scanner.scanResult.similarGroups.fold<int>(0, (sum, g) => sum + g.assets.length);
    final features = [
      _FeatureItem(Icons.copy, 'Duplicates',
          '$totalDuplicates found', AppTheme.dangerColor),
      _FeatureItem(Icons.photo_library, 'Similar',
          '$totalSimilar found', AppTheme.warningColor),
      _FeatureItem(Icons.screenshot, 'Screenshots',
          '${scanner.scanResult.screenshots.length} found', AppTheme.successColor),
      _FeatureItem(Icons.compress, 'Compress',
          '${scanner.scanResult.largeFiles.length} large files', AppTheme.secondaryColor),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: features.map((f) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(f.icon, color: f.color),
              const SizedBox(height: 8),
              Text(f.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(f.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  _FeatureItem(this.icon, this.title, this.subtitle, this.color);
}
