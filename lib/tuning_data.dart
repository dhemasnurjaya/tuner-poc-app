enum TuningStatus {
  initial,
  tuned,
  tooLow,
  tooHigh,
  wayTooLow,
  wayTooHigh,
}

class TuningData {
  /// The name of the instrument.
  final String instrumentName;

  /// The note frequencies in Hz.
  final Map<String, double> noteFrequencies;

  const TuningData({
    required this.instrumentName,
    required this.noteFrequencies,
  });
}

const tunings = <TuningData>[
  TuningData(
    instrumentName: 'Guitar (Standard 6-String)',
    noteFrequencies: {
      'E2': 82.41,
      'A2': 110.0,
      'D3': 146.83,
      'G3': 196.0,
      'B3': 246.94,
      'E4': 329.63,
    },
  ),
  TuningData(
    instrumentName: 'Bass (Standard 5-String)',
    noteFrequencies: {
      'B0': 30.87,
      'E1': 41.2,
      'A1': 55.0,
      'D2': 73.42,
      'G2': 98.0,
    },
  ),
];
