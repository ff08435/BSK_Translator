import 'package:flutter/material.dart';
import 'package:yaran/utils/colors.dart';
import 'package:yaran/utils/constants.dart';
import 'package:yaran/widgets/record_button.dart';
import 'package:yaran/services/audio_service.dart';
import 'package:yaran/services/api_service.dart';
import 'package:yaran/screens/feedback_screen.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({Key? key}) : super(key: key);

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final _audioService = AudioService();
  bool _isRecording = false;
  String _translationText = AppConstants.translationPlaceholder;
  String? _audioPath;
  bool _showFeedbackButton = false; // shows after any recording attempt

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
      final path = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _audioPath = path;
        _translationText = 'Processing audio...';
        _showFeedbackButton = false;
      });

      if (path != null) {
        final result = await ApiService().uploadAudio(path);
        setState(() {
          // Show whatever came back, or a friendly error
          _translationText =
              result ??
              'Could not reach the translation server. The backend may be sleeping — try again in a moment.';
          // Show feedback button regardless — user may still want to submit correct translation
          _showFeedbackButton = true;
        });
      }
    } else {
      final started = await _audioService.startRecording();
      if (started) {
        setState(() {
          _isRecording = true;
          _translationText = AppConstants.recording;
          _showFeedbackButton = false;
        });
      }
    }
  }

  void _openFeedbackSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FeedbackSheet(originalTranslation: _translationText),
    );
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Language bar
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

            // Record button
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

            // Translation output box
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
                      // Feedback button — shows after any recording attempt
                      if (_showFeedbackButton)
                        TextButton.icon(
                          onPressed: _openFeedbackSheet,
                          icon: const Icon(
                            Icons.flag_outlined,
                            color: AppColors.accentOrange,
                            size: 18,
                          ),
                          label: const Text(
                            'Suggest correction',
                            style: TextStyle(
                              color: AppColors.accentOrange,
                              fontSize: 13,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
