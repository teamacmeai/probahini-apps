import 'dart:convert';
import 'package:probahini/utils/api_settings.dart';

class ChatService {
  final ApiSettings _apiSettings = ApiSettings(endPoint: 'chat');

  Future<Map<String, dynamic>> sendChatQuery({
    required String userId,
    required String query,
  }) async {
    try {
      final data = jsonEncode({'user_id': userId, 'query': query});

      final response = await _apiSettings.postMethod(data);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to send chat query: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending chat query: $e');
    }
  }
}
