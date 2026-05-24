import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class AIService {

  final String baseUrl =
      'https://mental-ai1.onrender.com';

  final String apiKey =
      'my-secret-key';

  Future<String> sendMessage({
    required String message,
    required String userId,
  }) async {

    try {

      final response =
          await http.post(

        Uri.parse(
          '$baseUrl/chat',
        ),

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
        const Duration(
          seconds: 30,
        ),
      );

      final data =
          jsonDecode(
        utf8.decode(
          response.bodyBytes,
        ),
      );

      if (
          response.statusCode == 200
      ) {

        return data['reply']
            ?? 'AI ไม่ตอบกลับ';

      } else {

        return 'Server Error: ${response.statusCode}';

      }

    } on TimeoutException {

      return 'เซิร์ฟเวอร์ตอบสนองช้า';

    } catch (e) {

      return 'เกิดข้อผิดพลาด: $e';

    }
  }
}