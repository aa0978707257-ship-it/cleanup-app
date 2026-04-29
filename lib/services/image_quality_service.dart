import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Detects blurry and low-light photos using image analysis algorithms
class ImageQualityService {
  ImageQualityService._();
  static final instance = ImageQualityService._();

  /// Detect if an image is blurry using Laplacian variance
  /// Lower variance = more blurry
  /// Returns blur score (0-1000+). Below threshold = blurry.
  double calculateBlurScore(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return 999; // Can't decode = assume not blurry

    // Convert to grayscale
    final gray = img.grayscale(image);

    // Resize for performance (analyze at 200px width)
    final resized = img.copyResize(gray, width: 200);

    // Apply Laplacian kernel and calculate variance
    // Laplacian kernel: [0,1,0; 1,-4,1; 0,1,0]
    double sum = 0;
    double sumSq = 0;
    int count = 0;

    for (int y = 1; y < resized.height - 1; y++) {
      for (int x = 1; x < resized.width - 1; x++) {
        // Get pixel luminance values
        final center = resized.getPixel(x, y).luminance * 255;
        final top = resized.getPixel(x, y - 1).luminance * 255;
        final bottom = resized.getPixel(x, y + 1).luminance * 255;
        final left = resized.getPixel(x - 1, y).luminance * 255;
        final right = resized.getPixel(x + 1, y).luminance * 255;

        // Laplacian = -4*center + top + bottom + left + right
        final laplacian = -4 * center + top + bottom + left + right;

        sum += laplacian;
        sumSq += laplacian * laplacian;
        count++;
      }
    }

    if (count == 0) return 999;

    final mean = sum / count;
    final variance = (sumSq / count) - (mean * mean);
    return variance.abs();
  }

  /// Check if image is blurry (variance below threshold)
  bool isBlurry(Uint8List imageBytes, {double threshold = 100}) {
    return calculateBlurScore(imageBytes) < threshold;
  }

  /// Calculate average brightness of an image (0.0 = black, 1.0 = white)
  double calculateBrightness(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return 0.5;

    final resized = img.copyResize(image, width: 100);

    double totalLuminance = 0;
    int count = 0;

    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        totalLuminance += resized.getPixel(x, y).luminance;
        count++;
      }
    }

    return count > 0 ? totalLuminance / count : 0.5;
  }

  /// Check if image is too dark
  bool isDark(Uint8List imageBytes, {double threshold = 0.15}) {
    return calculateBrightness(imageBytes) < threshold;
  }

  /// Check if image is overexposed (too bright)
  bool isOverexposed(Uint8List imageBytes, {double threshold = 0.85}) {
    return calculateBrightness(imageBytes) > threshold;
  }

  /// Comprehensive quality analysis
  ImageQuality analyzeQuality(Uint8List imageBytes) {
    final blurScore = calculateBlurScore(imageBytes);
    final brightness = calculateBrightness(imageBytes);

    final issues = <QualityIssue>[];
    if (blurScore < 100) issues.add(QualityIssue.blurry);
    if (brightness < 0.15) issues.add(QualityIssue.tooDark);
    if (brightness > 0.85) issues.add(QualityIssue.overexposed);

    return ImageQuality(
      blurScore: blurScore,
      brightness: brightness,
      issues: issues,
    );
  }
}

class ImageQuality {
  final double blurScore;
  final double brightness;
  final List<QualityIssue> issues;

  const ImageQuality({required this.blurScore, required this.brightness, required this.issues});

  bool get hasIssues => issues.isNotEmpty;
  bool get isBlurry => issues.contains(QualityIssue.blurry);
  bool get isDark => issues.contains(QualityIssue.tooDark);
  bool get isOverexposed => issues.contains(QualityIssue.overexposed);

  String get issueLabel {
    if (issues.isEmpty) return '良好';
    return issues.map((i) {
      switch (i) {
        case QualityIssue.blurry: return '模糊';
        case QualityIssue.tooDark: return '過暗';
        case QualityIssue.overexposed: return '過曝';
      }
    }).join(' · ');
  }
}

enum QualityIssue { blurry, tooDark, overexposed }
