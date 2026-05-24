import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {

  final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  static const Map<String, dynamic> _defaults = {

    'ai_base_url':
        'https://mental-ai1.onrender.com',

    // ห้ามใส่ API KEY จริงใน GitHub
    'ai_api_key':
        'YOUR_API_KEY',

  };

  Future<void> initialize() async {

    try {

      await _remoteConfig.setConfigSettings(

        RemoteConfigSettings(

          fetchTimeout:
              const Duration(seconds: 10),

          minimumFetchInterval:
              const Duration(hours: 1),

        ),

      );

      await _remoteConfig.setDefaults(
        _defaults,
      );

      await _remoteConfig.fetchAndActivate();

    } catch (e) {

      print(e);

    }
  }

  String get aiBaseUrl =>
      _remoteConfig.getString(
        'ai_base_url',
      );

  String get aiApiKey =>
      _remoteConfig.getString(
        'ai_api_key',
      );
}