import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:tuner_poc/tuning_data.dart';
import 'package:tuner_poc/tuning_result.dart';

const sampleRate = 44100;
const bufferSize = 2048;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _recorder = FlutterAudioCapture();
  final _pitchDetector = PitchDetector();

  bool? _recordInitResult = false;
  TuningData _tuningData = tunings[0];
  bool _capturing = false;
  String _frequency = '0';
  String _note = '-';
  TuningStatus _tuningStatus = TuningStatus.initial;

  @override
  void initState() {
    _recorder.init().then((result) {
      _recordInitResult = result;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tuner POC'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButton<TuningData>(
                isExpanded: true,
                value: _tuningData,
                items: tunings
                    .map<DropdownMenuItem<TuningData>>((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.instrumentName),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _tuningData = value!);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_recordInitResult ?? false) && _capturing
                    ? _stopRecording
                    : _startRecording,
                child: Text(_capturing ? 'Stop' : 'Start'),
              ),
              const SizedBox(height: 20),
              Text(
                _note,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                '$_frequency Hz',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text(
                '$_tuningStatus',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    // assumes that the permission has already been granted
    await _recorder.start(
      _audioListener,
      _onError,
      sampleRate: sampleRate,
      bufferSize: bufferSize,
    );

    setState(() => _capturing = true);
  }

  Future<void> _audioListener(Float32List data) async {
    final audioData = Float64List.fromList(data.cast<double>());
    final audioSample = audioData.toList();
    final result = await _pitchDetector.getPitchFromFloatBuffer(audioSample);

    if (result.pitched) {
      final closestNoteFreq = findClosestValue(
        _tuningData.noteFrequencies.values.toList(),
        result.pitch,
      );
      final closestNote = _tuningData.noteFrequencies.keys.firstWhere(
          (key) => _tuningData.noteFrequencies[key] == closestNoteFreq);
      final tuningResult = TuningResult(
        targetNote: closestNote,
        targetFrequency: closestNoteFreq,
        frequencyDifference: result.pitch - closestNoteFreq,
      );

      setState(() {
        _note =
            '${tuningResult.targetNote} (${tuningResult.targetFrequency} Hz)';
        _tuningStatus = tuningResult.status;
        _frequency = result.pitch.toStringAsFixed(2);
      });

      log('pitch: ${result.pitch}, probability: ${result.probability}');
    }
  }

  void _onError(Object error) {
    log(error.toString());
  }

  Future<void> _stopRecording() async {
    await _recorder.stop();
    setState(() => _capturing = false);
  }

  double findClosestValue(List<double> list, double target) =>
      list.reduce((a, b) => (a - target).abs() < (b - target).abs() ? a : b);

  @override
  Future<void> dispose() async {
    await _recorder.stop();
    super.dispose();
  }
}
