import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ApiService {
  static const String baseUrl = "https://fatima983-burushaski-backend.hf.space";

  Future<String?> uploadAudio(String filePath) async {
    // Step 1: Submit the audio file to Gradio
    var url = Uri.parse("$baseUrl/call/transcribe");
    var request = http.MultipartRequest("POST", url);
    request.files.add(
      await http.MultipartFile.fromPath('files', filePath),
    );

    var response = await request.send();
    if (response.statusCode != 200) {
      print("Upload failed: ${response.statusCode}");
      return null;
    }

    // Step 2: Get the event_id from the response
    var responseBody = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseBody);
    String eventId = jsonResponse["event_id"];

    // Step 3: Wait for model to finish
    await Future.delayed(Duration(seconds: 20));

    // Step 4: Poll for the result using the event_id
    var resultUrl = Uri.parse("$baseUrl/call/transcribe/$eventId");
    var resultResponse = await http.get(resultUrl);

    if (resultResponse.statusCode == 200) {
      var lines = resultResponse.body.split('\n');
      for (var line in lines) {
        if (line.startsWith('data:')) {
          var data = jsonDecode(line.substring(5).trim());
          return data[0].toString();
        }
      }
    }

    print("Result fetch failed: ${resultResponse.statusCode}");
    return null;
  }
}
