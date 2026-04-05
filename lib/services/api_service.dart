import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ApiService {
  static const String baseUrl = "https://fatima983-burushaski-backend.hf.space";

  Future<String?> uploadAudio(String filePath) async {
    // Step 1: Upload the file first
    var uploadUrl = Uri.parse("$baseUrl/gradio_api/upload");
    var uploadRequest = http.MultipartRequest("POST", uploadUrl);
    uploadRequest.files.add(
      await http.MultipartFile.fromPath('files', filePath),
    );

    var uploadResponse = await uploadRequest.send();
    var uploadBody = await uploadResponse.stream.bytesToString();

    if (uploadResponse.statusCode != 200) {
      return "File upload failed: ${uploadResponse.statusCode} — $uploadBody";
    }

    var uploadedFiles = jsonDecode(uploadBody);
    String uploadedPath = uploadedFiles[0];

    // Step 2: Call the transcribe endpoint with JSON
    var predictUrl = Uri.parse("$baseUrl/gradio_api/call/transcribe");
    var predictResponse = await http.post(
      predictUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "data": [
          {
            "path": uploadedPath,
            "meta": {"_type": "gradio.FileData"}
          }
        ]
      }),
    );

    if (predictResponse.statusCode != 200) {
      return "Predict failed: ${predictResponse.statusCode} — ${predictResponse.body}";
    }

    var jsonResponse = jsonDecode(predictResponse.body);
    String eventId = jsonResponse["event_id"];

    // Step 3: Wait for model to finish
    await Future.delayed(Duration(seconds: 20));

    // Step 4: Poll for the result
    var resultUrl = Uri.parse("$baseUrl/gradio_api/call/transcribe/$eventId");
    var resultResponse = await http.get(resultUrl);

    if (resultResponse.statusCode == 200) {
      var lines = resultResponse.body.split('\n');
      for (var line in lines) {
        if (line.startsWith('data:')) {
          var data = jsonDecode(line.substring(5).trim());
          return data[0].toString();
        }
      }
      return "Parsing failed: ${resultResponse.body}";
    }

    return "Result fetch failed: ${resultResponse.statusCode}";
  }
}
