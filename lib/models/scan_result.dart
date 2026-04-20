import 'duplicate_group.dart';
import 'photo_asset.dart' show PhotoAsset, formatBytes;

class ScanResult {
  final List<DuplicateGroup> duplicateGroups;
  final List<DuplicateGroup> similarGroups;
  final List<PhotoAsset> screenshots;
  final List<PhotoAsset> largeFiles;
  final List<DuplicateGroup> similarVideos;

  const ScanResult({
    this.duplicateGroups = const [],
    this.similarGroups = const [],
    this.screenshots = const [],
    this.largeFiles = const [],
    this.similarVideos = const [],
  });

  /// Total number of exact-duplicate items across all groups (excludes the kept asset per group).
  int get totalDuplicates =>
      duplicateGroups.fold<int>(0, (sum, g) => sum + g.duplicateCount);

  /// Total number of similar items across all similar groups.
  int get totalSimilar =>
      similarGroups.fold<int>(0, (sum, g) => sum + g.duplicateCount);

  /// Total bytes that can be recovered by cleaning up duplicates, similar photos,
  /// screenshots, large files, and similar videos.
  int get totalSavableBytes {
    final fromDuplicates =
        duplicateGroups.fold<int>(0, (sum, g) => sum + g.savableBytes);
    final fromSimilar =
        similarGroups.fold<int>(0, (sum, g) => sum + g.savableBytes);
    final fromScreenshots =
        screenshots.fold<int>(0, (sum, a) => sum + a.fileSize);
    final fromLargeFiles =
        largeFiles.fold<int>(0, (sum, a) => sum + a.fileSize);
    final fromSimilarVideos =
        similarVideos.fold<int>(0, (sum, g) => sum + g.savableBytes);
    return fromDuplicates +
        fromSimilar +
        fromScreenshots +
        fromLargeFiles +
        fromSimilarVideos;
  }

  /// Human-readable total savable bytes.
  String get totalSavableBytesFormatted => formatBytes(totalSavableBytes);

  /// Whether the scan found nothing to clean up.
  bool get isEmpty =>
      duplicateGroups.isEmpty &&
      similarGroups.isEmpty &&
      screenshots.isEmpty &&
      largeFiles.isEmpty &&
      similarVideos.isEmpty;

  /// Total number of groups/items across all categories.
  int get totalIssues =>
      duplicateGroups.length +
      similarGroups.length +
      screenshots.length +
      largeFiles.length +
      similarVideos.length;

  ScanResult copyWith({
    List<DuplicateGroup>? duplicateGroups,
    List<DuplicateGroup>? similarGroups,
    List<PhotoAsset>? screenshots,
    List<PhotoAsset>? largeFiles,
    List<DuplicateGroup>? similarVideos,
  }) {
    return ScanResult(
      duplicateGroups: duplicateGroups ?? this.duplicateGroups,
      similarGroups: similarGroups ?? this.similarGroups,
      screenshots: screenshots ?? this.screenshots,
      largeFiles: largeFiles ?? this.largeFiles,
      similarVideos: similarVideos ?? this.similarVideos,
    );
  }

  @override
  String toString() =>
      'ScanResult(duplicates: ${duplicateGroups.length}, similar: ${similarGroups.length}, '
      'screenshots: ${screenshots.length}, largeFiles: ${largeFiles.length}, '
      'similarVideos: ${similarVideos.length}, savable: $totalSavableBytesFormatted)';
}
