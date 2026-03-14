import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static const String baseUrl = "https://fatima983-burushaski-backend.hf.space"; 

  Future<String?> uploadAudio(String filePath) async {
    var url = Uri.parse("$baseUrl/translate-audio");

    var request = http.MultipartRequest("POST", url);
    request.files.add(
      await http.MultipartFile.fromPath('file', filePath),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    } else {
      print("Upload failed: ${response.statusCode}");
      return null;
    }
  }
}
