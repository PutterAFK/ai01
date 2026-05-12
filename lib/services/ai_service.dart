import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:mindmate/core/utils/network_helper.dart';
import 'remote_config_service.dart';

class AIService {
  final RemoteConfigService _remoteConfig = RemoteConfigService();

  Future<String> sendMessage({
    required String message,
    required String userId,
  }) async {
    final hasInternet = await NetworkHelper.hasInternet();
    if (!hasInternet) {
      throw 'ไม่มีการเชื่อมต่ออินเตอร์เน็ต';
    }

    try {
      // ดึง URL จาก Remote Config (ไม่มีใน source code)
      final baseUrl = _remoteConfig.aiBaseUrl;

      // ดึง API Key จาก Remote Config (ไม่มีใน source code)
      final apiKey = _remoteConfig.aiApiKey;

      // ใช้ Firebase ID Token แทน static key
      final token = await FirebaseAuth.instance
          .currentUser
          ?.getIdToken(true); // true = force refresh

      if (token == null) throw 'กรุณาเข้าสู่ระบบใหม่อีกครั้ง';

      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'X-Firebase-Token': token,
        },
        body: jsonEncode({
          'message': message,
          'user_id': userId,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return data['reply'] ?? 'AI ไม่ตอบกลับ';
      } else if (response.statusCode == 401) {
        throw 'API Key ไม่ถูกต้อง';
      } else if (response.statusCode == 429) {
        throw 'มีผู้ใช้งานจำนวนมาก กรุณาลองใหม่';
      } else if (response.statusCode >= 500) {
        throw 'เซิร์ฟเวอร์กำลังมีปัญหา';
      } else {
        throw 'เกิดข้อผิดพลาด (${response.statusCode})';
      }
    } on SocketException {
      throw 'ไม่มีการเชื่อมต่ออินเตอร์เน็ต';
    } on http.ClientException {
      throw 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้';
    } catch (e) {
      throw e.toString();
    }
  }
}