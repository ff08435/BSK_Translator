import 'package:flutter/material.dart';
import 'package:yaran/utils/colors.dart';
import 'package:yaran/services/audio_service.dart';
import 'package:yaran/services/feedback_service.dart';

class FeedbackSheet extends StatefulWidget {
  final String originalTranslation;

  const FeedbackSheet({Key? key, required this.originalTranslation})
    : super(key: key);

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  final _audioService = AudioService();
  final _feedbackService = FeedbackService();
  final _nameController = TextEditingController();
  final _correctTranslationController = TextEditingController();

  String? _selectedGender;
  String? _selectedDialect;
  bool _isRecording = false;
  bool _isSubmitting = false;
  String? _recordedAudioPath;
  String _recordingStatus =
      'Tap the mic to record the correct Burushaski sentence';

  final List<String> _genders = ['Male', 'Female', 'Prefer not to say'];
  final List<String> _dialects = ['Hunza', 'Nagar', 'Yasin', 'Other'];

  @override
  void initState() {
    super.initState();
    _audioService.init();
  }

  @override
  void dispose() {
    _audioService.dispose();
    _nameController.dispose();
    _correctTranslationController.dispose();
    super.dispose();
  }

  Future<void> _handleRecordPress() async {
    if (_isRecording) {
      final path = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _recordedAudioPath = path;
        _recordingStatus = '✓ Recording saved. Tap to re-record if needed.';
      });
    } else {
      final started = await _audioService.startRecording();
      if (started) {
        setState(() {
          _isRecording = true;
          _recordingStatus = 'Recording... Tap again to stop.';
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    // Validate all fields
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name.');
      return;
    }
    if (_selectedGender == null) {
      _showError('Please select your gender.');
      return;
    }
    if (_selectedDialect == null) {
      _showError('Please select your dialect.');
      return;
    }
    if (_recordedAudioPath == null) {
      _showError('Please record the Burushaski sentence.');
      return;
    }
    if (_correctTranslationController.text.trim().isEmpty) {
      _showError('Please enter the correct English translation.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _feedbackService.submitFeedback(
        name: _nameController.text.trim(),
        gender: _selectedGender!,
        dialect: _selectedDialect!,
        modelTranslation: widget.originalTranslation,
        correctEnglish: _correctTranslationController.text.trim(),
        audioFilePath: _recordedAudioPath!,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your feedback has been submitted.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to submit: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textDarkGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Suggest a Correction',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Help us improve the model with your feedback.',
              style: TextStyle(color: AppColors.textGray, fontSize: 14),
            ),

            const SizedBox(height: 24),

            // What the model said
            _SectionLabel(label: "Model's translation"),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.originalTranslation,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Name
            _SectionLabel(label: 'Your name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: _inputDecoration('Enter your name'),
            ),

            const SizedBox(height: 20),

            // Gender
            _SectionLabel(label: 'Gender'),
            const SizedBox(height: 8),
            _DropdownField(
              hint: 'Select gender',
              value: _selectedGender,
              items: _genders,
              onChanged: (val) => setState(() => _selectedGender = val),
            ),

            const SizedBox(height: 20),

            // Dialect
            _SectionLabel(label: 'Dialect'),
            const SizedBox(height: 8),
            _DropdownField(
              hint: 'Select dialect',
              value: _selectedDialect,
              items: _dialects,
              onChanged: (val) => setState(() => _selectedDialect = val),
            ),

            const SizedBox(height: 24),

            // Record button
            _SectionLabel(label: 'Record the correct Burushaski sentence'),
            const SizedBox(height: 14),

            Center(
              child: GestureDetector(
                onTap: _handleRecordPress,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _isRecording
                            ? AppColors.error
                            : (_recordedAudioPath != null
                                ? AppColors.success
                                : AppColors.accentOrange),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? AppColors.error
                                : AppColors.accentOrange)
                            .withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording
                        ? Icons.stop
                        : (_recordedAudioPath != null
                            ? Icons.check
                            : Icons.mic),
                    color: AppColors.textWhite,
                    size: 36,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                _recordingStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      _recordedAudioPath != null
                          ? AppColors.success
                          : AppColors.textGray,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Correct English translation
            _SectionLabel(label: 'Correct English translation'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _correctTranslationController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: _inputDecoration(
                'Type the correct English translation...',
              ),
            ),

            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  disabledBackgroundColor: AppColors.textDarkGray,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.textWhite,
                            strokeWidth: 2.5,
                          ),
                        )
                        : const Text(
                          'Submit Feedback',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textDarkGray),
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentOrange, width: 2),
      ),
    );
  }
}

// Reusable dropdown widget
class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null ? AppColors.accentOrange : Colors.transparent,
          width: 2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: AppColors.textDarkGray),
          ),
          isExpanded: true,
          dropdownColor: AppColors.secondaryDark,
          style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.accentOrange,
          ),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// Section label helper
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.accentOrange,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
