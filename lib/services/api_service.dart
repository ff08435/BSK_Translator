import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static const String baseUrl = "http://192.168.84.1:8000"; // For Android Emulator
  // For real device on same WiFi: replace with your PC IPv4, e.g. "http://192.168.1.7:8000"

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
