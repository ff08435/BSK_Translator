import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService {
  final _supabase = Supabase.instance.client;

  Future<void> submitFeedback({
    required String name,
    required String gender,
    required String dialect,
    required String modelTranslation,
    required String correctEnglish,
    required String audioFilePath,
  }) async {
    // 1. Upload audio to Supabase Storage
    final file = File(audioFilePath);
    final fileName = 'feedback_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _supabase.storage
        .from('feedback-audio')
        .upload(
          fileName,
          file,
          fileOptions: const FileOptions(contentType: 'audio/aac'),
        );

    // 2. Get public URL
    final audioUrl = _supabase.storage
        .from('feedback-audio')
        .getPublicUrl(fileName);

    // 3. Insert into translator_feedback table
    await _supabase.from('translator_feedback').insert({
      'name': name,
      'gender': gender,
      'dialect': dialect,
      'model_translation': modelTranslation,
      'correct_english': correctEnglish,
      'audio_url': audioUrl,
    });
  }
}
