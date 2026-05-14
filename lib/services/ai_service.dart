import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mindmate/core/utils/network_helper.dart';
import 'remote_config_service.dart';

class AIService {
  final RemoteConfigService _remoteConfig =
      RemoteConfigService();

  Future<String> sendMessage({
    required String message,
    required String userId,
  }) async {

    final hasInternet =
        await NetworkHelper.hasInternet();

    if (!hasInternet) {
      throw 'ไม่มีการเชื่อมต่ออินเตอร์เน็ต';
    }

    try {

      final baseUrl =
          _remoteConfig.aiBaseUrl.trim();

      final apiKey =
          _remoteConfig.aiApiKey.trim();

      if (baseUrl.isEmpty) {
        throw 'ยังไม่ได้ตั้งค่า AI URL';
      }

      if (apiKey.isEmpty) {
        throw 'ยังไม่ได้ตั้งค่า API KEY';
      }

      final response =
          await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type':
              'application/json',
          'Authorization':
              'Bearer $apiKey',
        },
        body: jsonEncode({
          'message': message,
          'user_id': userId,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      final data =
          jsonDecode(
        utf8.decode(
          response.bodyBytes,
        ),
      );

      if (
          response.statusCode == 200) {
        return data['reply']
            ?? 'AI ไม่ตอบกลับ';
      }

      if (
          response.statusCode == 401) {
        throw 'ไม่มีสิทธิ์เข้าถึง API';
      }

      if (
          response.statusCode == 429) {
        throw 'มีผู้ใช้งานจำนวนมาก';
      }

      if (
          response.statusCode >= 500) {
        throw 'เซิร์ฟเวอร์มีปัญหา';
      }

      throw 'เกิดข้อผิดพลาด (${response.statusCode})';

    } on SocketException {
      throw 'ไม่มีอินเตอร์เน็ต';
    } on http.ClientException {
      throw 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้';
    } catch (e) {
      throw e.toString();
    }
  }

  // สำหรับ ML Feedback
  Future<void> sendFeedback({
    required String question,
    required String reply,
    required int rating,
    required String userId,
  }) async {

    final baseUrl =
        _remoteConfig.aiBaseUrl.trim();

    final apiKey =
        _remoteConfig.aiApiKey.trim();

    await http.post(
      Uri.parse(
        '$baseUrl/feedback',
      ),
      headers: {
        'Content-Type':
            'application/json',
        'Authorization':
            'Bearer $apiKey',
      },
      body: jsonEncode({
        'user_id': userId,
        'question': question,
        'reply': reply,
        'rating': rating,
      }),
    );
  }
}
