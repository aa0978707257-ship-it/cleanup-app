import 'photo_asset.dart';

enum DuplicateType {
  exactDuplicate,
  similar,
  screenshot,
  similarVideo;

  String get label {
    switch (this) {
      case DuplicateType.exactDuplicate:
        return 'Exact Duplicate';
      case DuplicateType.similar:
        return 'Similar';
      case DuplicateType.screenshot:
        return 'Screenshot';
      case DuplicateType.similarVideo:
        return 'Similar Video';
    }
  }
}

class DuplicateGroup {
  final String id;
  final DuplicateType type;
  final List<PhotoAsset> assets;
  String? bestAssetId;

  DuplicateGroup({
    required this.id,
    required this.type,
    required this.assets,
    this.bestAssetId,
  });

  /// The asset identified as the "best" keeper in this group.
  /// Falls back to the first asset marked [isBest], or the first asset overall.
  PhotoAsset? get bestAsset {
    if (assets.isEmpty) return null;
    if (bestAssetId != null) {
      final match = assets.where((a) => a.id == bestAssetId);
      if (match.isNotEmpty) return match.first;
    }
    final marked = assets.where((a) => a.isBest);
    if (marked.isNotEmpty) return marked.first;
    return assets.first;
  }

  /// All assets in the group except the best one -- candidates for deletion.
  List<PhotoAsset> get deletionCandidates {
    final best = bestAsset;
    if (best == null) return [];
    return assets.where((a) => a.id != best.id).toList();
  }

  /// Total bytes that can be freed by removing all deletion candidates.
  int get savableBytes {
    return deletionCandidates.fold<int>(0, (sum, a) => sum + a.fileSize);
  }

  /// Human-readable savable bytes (e.g. "12.3 MB").
  String get savableBytesFormatted => formatBytes(savableBytes);

  /// Number of duplicate/similar items (excludes the best asset).
  int get duplicateCount => deletionCandidates.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DuplicateGroup && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DuplicateGroup(id: $id, type: ${type.label}, assets: ${assets.length}, savable: $savableBytesFormatted)';
}
