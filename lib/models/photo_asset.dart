import 'dart:math';
import 'dart:typed_data';

enum MediaType {
  photo,
  video,
  screenshot,
  livePhoto;

  String get label {
    switch (this) {
      case MediaType.photo:
        return 'Photo';
      case MediaType.video:
        return 'Video';
      case MediaType.screenshot:
        return 'Screenshot';
      case MediaType.livePhoto:
        return 'Live Photo';
    }
  }
}

class PhotoAsset {
  final String id;
  final String filePath;
  final String fileName;
  final int fileSize;
  final MediaType mediaType;
  final DateTime? creationDate;
  final int width;
  final int height;
  final Duration? duration;
  final Uint8List? thumbnailData;
  bool isBest;
  bool isSelected;

  PhotoAsset({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.mediaType,
    this.creationDate,
    this.width = 0,
    this.height = 0,
    this.duration,
    this.thumbnailData,
    this.isBest = false,
    this.isSelected = false,
  });

  bool get isScreenshot => mediaType == MediaType.screenshot;

  bool get isVideo =>
      mediaType == MediaType.video || mediaType == MediaType.livePhoto;

  String get fileSizeFormatted => formatBytes(fileSize);

  String get resolution =>
      (width > 0 && height > 0) ? '${width}x$height' : 'Unknown';

  String get durationFormatted {
    if (duration == null) return '';
    final totalSeconds = duration!.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  PhotoAsset copyWith({
    String? id,
    String? filePath,
    String? fileName,
    int? fileSize,
    MediaType? mediaType,
    DateTime? creationDate,
    int? width,
    int? height,
    Duration? duration,
    Uint8List? thumbnailData,
    bool? isBest,
    bool? isSelected,
  }) {
    return PhotoAsset(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mediaType: mediaType ?? this.mediaType,
      creationDate: creationDate ?? this.creationDate,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      thumbnailData: thumbnailData ?? this.thumbnailData,
      isBest: isBest ?? this.isBest,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PhotoAsset && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PhotoAsset(id: $id, fileName: $fileName, size: $fileSizeFormatted, type: ${mediaType.label})';
}

/// Formats a byte count into a human-readable string (e.g. "1.5 MB").
String formatBytes(int bytes, {int decimals = 1}) {
  if (bytes <= 0) return '0 B';

  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  final i = (log(bytes) / log(1024)).floor().clamp(0, suffixes.length - 1);
  final value = bytes / pow(1024, i);

  // Drop decimals when the value is a whole number.
  if (value == value.roundToDouble()) {
    return '${value.toInt()} ${suffixes[i]}';
  }
  return '${value.toStringAsFixed(decimals)} ${suffixes[i]}';
}
