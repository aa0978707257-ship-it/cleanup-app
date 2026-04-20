import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/photo_scanner_service.dart';
import '../../services/subscription_manager.dart';
import '../../utils/app_theme.dart';

class SmartCleanView extends StatefulWidget {
  const SmartCleanView({super.key});

  @override
  State<SmartCleanView> createState() => _SmartCleanViewState();
}

class _SmartCleanViewState extends State<SmartCleanView> {
  int _selectedCategory = 0;
  final Set<String> _selectedIds = {};

  final _categories = ['Duplicates', 'Similar', 'Screenshots', 'Videos', 'Compress'];

  @override
  Widget build(BuildContext context) {
    final scanner = context.watch<PhotoScannerService>();
    final sub = context.watch<SubscriptionManager>();

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Clean')),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final count = _countFor(i, scanner);
                final selected = _selectedCategory == i;
                return FilterChip(
                  label: Text('${_categories[i]} ($count)'),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = i),
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: scanner.scanResult.allAssets.isEmpty && !scanner.isScanning
                ? _buildEmptyState(scanner)
                : scanner.isScanning
                    ? _buildScanningState(scanner)
                    : _buildContent(scanner),
          ),

          // Bottom action bar
          if (scanner.scanResult.allAssets.isNotEmpty && _selectedIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${_selectedIds.length} items selected',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleDelete(scanner, sub),
                        icon: const Icon(Icons.delete),
                        label: Text('Delete ${_selectedIds.length} Items'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.dangerColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(PhotoScannerService scanner) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No scan results yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Run a Smart Scan to find cleanable items'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => scanner.startFullScan(),
            child: const Text('Start Scan'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningState(PhotoScannerService scanner) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(scanner.currentPhase.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${(scanner.scanProgress * 100).toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildContent(PhotoScannerService scanner) {
    final groups = _groupsFor(_selectedCategory, scanner);
    final assets = _assetsFor(_selectedCategory, scanner);

    // Asset grid categories: Similar, Screenshots, Videos, Compress
    if (_selectedCategory >= 1) {
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
        itemCount: assets.length,
        itemBuilder: (ctx, i) => _buildThumbnail(assets[i]),
      );
    }

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (ctx, i) => _buildGroupRow(groups[i]),
    );
  }

  Widget _buildGroupRow(DuplicateGroup group) {
    // Keep the first asset as "best"; the rest are deletion candidates.
    final bestId = group.assets.first.id;
    final candidates = group.assets.sublist(1);
    final savableBytes = candidates.fold<int>(0, (sum, a) => sum + a.size);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text('${group.assets.length} items',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(_formatBytes(savableBytes),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(width: 8),
              // Select all candidates
              GestureDetector(
                onTap: () {
                  setState(() {
                    final ids = candidates.map((a) => a.id).toSet();
                    if (ids.every(_selectedIds.contains)) {
                      _selectedIds.removeAll(ids);
                    } else {
                      _selectedIds.addAll(ids);
                    }
                  });
                },
                child: Icon(
                  candidates.every((a) => _selectedIds.contains(a.id))
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: group.assets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 4),
            itemBuilder: (ctx, i) {
              final asset = group.assets[i];
              final isBest = asset.id == bestId;
              return _buildSelectableThumbnail(asset, isBest);
            },
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildSelectableThumbnail(PhotoAsset asset, bool isBest) {
    final isSelected = _selectedIds.contains(asset.id);

    return GestureDetector(
      onTap: () {
        if (!isBest) {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(asset.id);
            } else {
              _selectedIds.add(asset.id);
            }
          });
        }
      },
      child: Stack(
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                  : null,
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: asset.thumbnail != null
                  ? Image.memory(asset.thumbnail!, fit: BoxFit.cover)
                  : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          if (isBest)
            Positioned(
              top: 4, left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Best',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          if (!isBest)
            Positioned(
              bottom: 4, right: 4,
              child: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? AppTheme.primaryColor : Colors.white70,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(PhotoAsset asset) {
    final isSelected = _selectedIds.contains(asset.id);
    return GestureDetector(
      onTap: () => setState(() {
        isSelected ? _selectedIds.remove(asset.id) : _selectedIds.add(asset.id);
      }),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                  : null,
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: asset.thumbnail != null
                  ? Image.memory(asset.thumbnail!, fit: BoxFit.cover)
                  : const Icon(Icons.image),
            ),
          ),
          Positioned(
            bottom: 4, right: 4,
            child: Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppTheme.primaryColor : Colors.white70,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  int _countFor(int category, PhotoScannerService scanner) {
    final r = scanner.scanResult;
    switch (category) {
      case 0: return r.duplicateGroups.fold<int>(0, (sum, g) => sum + g.assets.length);
      case 1: return r.similarGroups.fold<int>(0, (sum, g) => sum + g.assets.length);
      case 2: return r.screenshots.length;
      case 3: return r.videos.length;
      case 4: return r.largeFiles.length;
      default: return 0;
    }
  }

  List<DuplicateGroup> _groupsFor(int category, PhotoScannerService scanner) {
    final r = scanner.scanResult;
    switch (category) {
      case 0: return r.duplicateGroups;
      default: return [];
    }
  }

  List<PhotoAsset> _assetsFor(int category, PhotoScannerService scanner) {
    final r = scanner.scanResult;
    switch (category) {
      case 1: return r.similarGroups.expand((g) => g.assets).toList();
      case 2: return r.screenshots;
      case 3: return r.videos;
      case 4: return r.largeFiles;
      default: return [];
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _handleDelete(PhotoScannerService scanner, SubscriptionManager sub) {
    if (!sub.isPro) {
      if (!sub.requirePro()) return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photos'),
        content: Text(
            'Move ${_selectedIds.length} items to Recently Deleted? You can recover them within 30 days.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final toDelete = scanner.scanResult.duplicateGroups
                  .expand((g) => g.assets)
                  .where((a) => _selectedIds.contains(a.id))
                  .toList();
              await scanner.deleteAssets(toDelete);
              setState(() => _selectedIds.clear());
            },
            child: Text('Delete ${_selectedIds.length}',
                style: const TextStyle(color: AppTheme.dangerColor)),
          ),
        ],
      ),
    );
  }
}
