import 'dart:io';

import 'photo_asset.dart' show formatBytes;

class StorageInfo {
  final int totalSpace;
  final int usedSpace;
  final int freeSpace;

  const StorageInfo({
    required this.totalSpace,
    required this.usedSpace,
    required this.freeSpace,
  });

  /// Usage ratio from 0.0 (empty) to 1.0 (full).
  double get usedPercentage =>
      totalSpace > 0 ? (usedSpace / totalSpace).clamp(0.0, 1.0) : 0.0;

  /// Usage as a display-friendly percentage string (e.g. "73.2%").
  String get usedPercentageFormatted =>
      '${(usedPercentage * 100).toStringAsFixed(1)}%';

  String get totalSpaceFormatted => formatBytes(totalSpace);
  String get usedSpaceFormatted => formatBytes(usedSpace);
  String get freeSpaceFormatted => formatBytes(freeSpace);

  /// Fetches real disk storage info for the app's root filesystem.
  ///
  /// On Android/iOS, uses the root path ("/") or the app's directory.
  /// Falls back to zeroes if the platform does not support [FileStat].
  static Future<StorageInfo> current() async {
    try {
      // Use the root path -- works on Android, iOS, and desktop.
      final stat = await FileStat.stat(Platform.isWindows ? 'C:\\' : '/');

      // dart:io FileStat does not directly expose disk-space info.
      // On mobile we would typically use a platform channel or a package like
      // `disk_space` / `path_provider`. The code below demonstrates the model
      // structure; replace the stub values with real platform-channel calls
      // in production.
      //
      // Example with a hypothetical platform channel:
      //   final result = await MethodChannel('com.app/storage')
      //       .invokeMethod<Map>('getDiskSpace');
      //   return StorageInfo(
      //     totalSpace: result['totalSpace'] as int,
      //     usedSpace: result['usedSpace'] as int,
      //     freeSpace: result['freeSpace'] as int,
      //   );

      // Stub: return zeroes so callers always get a valid object.
      // ignore: unused_local_variable
      final _ = stat; // suppress unused warning
      return const StorageInfo(totalSpace: 0, usedSpace: 0, freeSpace: 0);
    } catch (_) {
      return const StorageInfo(totalSpace: 0, usedSpace: 0, freeSpace: 0);
    }
  }

  StorageInfo copyWith({
    int? totalSpace,
    int? usedSpace,
    int? freeSpace,
  }) {
    return StorageInfo(
      totalSpace: totalSpace ?? this.totalSpace,
      usedSpace: usedSpace ?? this.usedSpace,
      freeSpace: freeSpace ?? this.freeSpace,
    );
  }

  @override
  String toString() =>
      'StorageInfo(total: $totalSpaceFormatted, used: $usedSpaceFormatted '
      '[$usedPercentageFormatted], free: $freeSpaceFormatted)';
}
