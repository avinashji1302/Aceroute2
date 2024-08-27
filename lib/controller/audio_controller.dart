// audio_controller.dart

import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioController {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  List<String> _recordings = [];
  String? _currentRecordingPath;
  String? _playingPath;
  bool _isPlaying = false;

  bool get isRecording => _isRecording;
  List<String> get recordings => _recordings;
  bool get isPlaying => _isPlaying;
  String? get playingPath => _playingPath;

  Future<void> init() async {
    await _recorder.openRecorder();
    await _player.openPlayer();
    await _loadRecordings();

    // Set up a listener for player state changes
    _player.onProgress!.listen((e) {
      if (e != null && e.duration != null && e.position != null) {
        if (e.position! >= e.duration!) {
          _isPlaying = false;
          _playingPath = null;
        } 
      }
    });
  }

  Future<void> _loadRecordings() async {
    final directory = await getApplicationDocumentsDirectory();
    final recordingDir = Directory(directory.path);
    final List<FileSystemEntity> files = recordingDir.listSync();

    _recordings = files
        .where((file) => file is File && file.path.endsWith('.aac'))
        .map((file) => file.path)
        .toList();
  }

  Future<void> startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(toFile: path);
    _isRecording = true;
    _currentRecordingPath = path;
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    if (_currentRecordingPath != null) {
      _recordings.add(_currentRecordingPath!);
      _currentRecordingPath = null;
    }
    _isRecording = false;
  }

  Future<void> togglePlayback(String path) async {
    if (_isPlaying && _playingPath == path) {
      await _player.stopPlayer();
      _isPlaying = false;
      _playingPath = null;
    } else {
      if (_isPlaying) {
        await _player.stopPlayer();
      }
      await _player.startPlayer(
        fromURI: path,
        codec: Codec.aacADTS,
      );
      _isPlaying = true;
      _playingPath = path;
    }
  }

  Future<void> deleteRecording(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      _recordings.remove(path);
    }
  }

  Future<void> playRecording(String path) async {
    await _player.startPlayer(
      fromURI: path,
      codec: Codec.aacADTS,
    );
  }

  Future<void> dispose() async {
    await _recorder.closeRecorder();
    await _player.closePlayer();
  }
}
