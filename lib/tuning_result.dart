import 'package:tuner_poc/tuning_data.dart';

class TuningResult {
  final String targetNote;
  final double targetFrequency;
  final double frequencyDifference;

  const TuningResult({
    required this.targetNote,
    required this.targetFrequency,
    required this.frequencyDifference,
  });

  TuningStatus get status {
    if (frequencyDifference < -5) {
      return TuningStatus.wayTooLow;
    } else if (frequencyDifference > 5) {
      return TuningStatus.wayTooHigh;
    } else if (frequencyDifference < -1) {
      return TuningStatus.tooLow;
    } else if (frequencyDifference > 1) {
      return TuningStatus.tooHigh;
    } else {
      return TuningStatus.tuned;
    }
  }
}
