import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static const Map<String, dynamic> _defaults = {
    'ai_base_url': 'https://mental-ai1.onrender.com',
    'ai_api_key': '',  // ค่า default ว่างไว้ก่อน
  };

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.setDefaults(_defaults);
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // ใช้ค่า Default ถ้าโหลดไม่ได้
    }
  }

  // ดึง AI Base URL
  String get aiBaseUrl => _remoteConfig.getString('ai_base_url');

  // ดึง AI API Key
  String get aiApiKey => _remoteConfig.getString('ai_api_key');
}