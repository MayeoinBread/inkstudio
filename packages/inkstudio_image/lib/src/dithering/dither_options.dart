class DitherOptions {
  final bool serpentine;
  // General for error-based algs
  final double errorStrength;

  // For ordered algs
  // Must be 2, 4, or 8
  final int orderedMatrixSize;
  // 0-100
  final int orderedStrength;

  // Adaptive Atkinson
  // 0.05-0.4
  final double edgeDetectionThreshold;
  // 0.0 - 1.0, 0.35
  final double smoothAreaDiffusion;

  const DitherOptions({
    this.serpentine = false,
    this.errorStrength = 0.8,
    this.orderedMatrixSize = 4,
    this.orderedStrength = 45,
    this.edgeDetectionThreshold = 0.2,
    this.smoothAreaDiffusion = 0.35
  });

  DitherOptions copyWith({
    bool? serpentine,
    double? errorStrength,
    int? orderedMatrixSize,
    int? orderedStrength,
    double? edgeDetectionThreshold,
    double? smoothAreaDiffusion
  }) {
    return DitherOptions(
      serpentine: serpentine ?? this.serpentine,
      errorStrength: errorStrength ?? this.errorStrength,
      orderedMatrixSize: orderedMatrixSize ?? this.orderedMatrixSize,
      orderedStrength: orderedStrength ?? this.orderedStrength,
      edgeDetectionThreshold: edgeDetectionThreshold ?? this.edgeDetectionThreshold,
      smoothAreaDiffusion: smoothAreaDiffusion ?? this.smoothAreaDiffusion
    );
  }
}