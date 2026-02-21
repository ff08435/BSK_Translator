import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class AudioService {
  FlutterSoundRecorder? _audioRecorder;
  String? _audioPath;
  bool _isInitialized = false;

  Future<void> init() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
    _isInitialized = true;

    // Request microphone permission
    await _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }
  }

  Future<bool> startRecording() async {
    try {
      if (!_isInitialized || _audioRecorder == null) {
        await init();
      }

      // Get directory to save recording
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _audioPath = '${directory.path}/recording_$timestamp.aac';

      // Start recording
      await _audioRecorder!.startRecorder(
        toFile: _audioPath,
        codec: Codec.aacADTS,
      );

      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      await _audioRecorder!.stopRecorder();
      return _audioPath;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  Future<bool> isRecording() async {
    return _audioRecorder?.isRecording ?? false;
  }

  void dispose() {
    _audioRecorder?.closeRecorder();
    _audioRecorder = null;
    _isInitialized = false;
  }

  // Upload audio to Firebase Storage (to be implemented later)
  Future<String?> uploadAudio(String filePath) async {
    // TODO: Implement Firebase Storage upload
    // This will be connected to your backend
    return null;
  }
}
