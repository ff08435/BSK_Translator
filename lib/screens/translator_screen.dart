//translator_screen.dart
import 'package:flutter/material.dart';
import 'package:yaran/utils/colors.dart';
import 'package:yaran/utils/constants.dart';
import 'package:yaran/widgets/record_button.dart';
import 'package:yaran/services/auth_service.dart';
import 'package:yaran/services/audio_service.dart';
import 'package:yaran/screens/welcome_screen.dart';
import 'package:yaran/services/api_service.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({Key? key}) : super(key: key);

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final _authService = AuthService();
  final _audioService = AudioService();
  bool _isRecording = false;
  String _translationText = AppConstants.translationPlaceholder;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _audioService.init();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _handleRecordPress() async {
  if (_isRecording) {
    // Stop recording
    final path = await _audioService.stopRecording();
    setState(() {
      _isRecording = false;
      _audioPath = path;
      _translationText = 'Processing audio...';
    });

    // SEND AUDIO TO BACKEND
    if (path != null) {
      final result = await ApiService().uploadAudio(path);

      setState(() {
        _translationText = result ?? "Error contacting backend.";
      });
    }
  } else {
    // Start recording
    final started = await _audioService.startRecording();
    if (started) {
      setState(() {
        _isRecording = true;
        _translationText = AppConstants.recording;
      });
    }
  }
}


  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: const Text(
          AppConstants.appName,
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.accentOrange),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Language Selector Bar
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.secondaryDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppConstants.sourceLang,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.accentOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppConstants.targetLang,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Record Button
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RecordButton(
                      isRecording: _isRecording,
                      onPressed: _handleRecordPress,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isRecording
                          ? AppConstants.recording
                          : AppConstants.tapToSpeak,
                      style: TextStyle(color: AppColors.textGray, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            // Translation Output Area
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppConstants.targetLang,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_audioPath != null)
                        IconButton(
                          icon: const Icon(
                            Icons.volume_up,
                            color: AppColors.accentOrange,
                          ),
                          onPressed: () {
                            // TODO: Play audio
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _translationText,
                        style: TextStyle(
                          color:
                              _translationText ==
                                      AppConstants.translationPlaceholder
                                  ? AppColors.textDarkGray
                                  : AppColors.textWhite,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (_audioPath != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            color: AppColors.textGray,
                            size: 20,
                          ),
                          onPressed: () {
                            // TODO: Copy to clipboard
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
