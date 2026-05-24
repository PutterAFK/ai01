import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mindmate/core/constants/app_colors.dart';

class NetworkStatusBanner extends StatefulWidget {

  final Widget child;

  const NetworkStatusBanner({
    super.key,
    required this.child,
  });

  @override
  State<NetworkStatusBanner> createState() =>
      _NetworkStatusBannerState();
}

class _NetworkStatusBannerState
    extends State<NetworkStatusBanner> {

  bool _isConnected = true;

  Timer? _timer;

  @override
  void initState() {

    super.initState();

    _checkConnection();

    // เช็คทุก 5 วินาที
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        _checkConnection();
      },
    );
  }

  @override
  void dispose() {

    _timer?.cancel();

    super.dispose();
  }

  Future<void> _checkConnection() async {

    // Flutter Web / Edge / Chrome
    if (kIsWeb) {

      if (!_isConnected && mounted) {
        setState(() {
          _isConnected = true;
        });
      }

      return;
    }

    // Mobile / Desktop
    try {

      final result =
          await InternetAddress.lookup(
        'google.com',
      ).timeout(
        const Duration(seconds: 3),
      );

      final connected =
          result.isNotEmpty &&
          result[0].rawAddress.isNotEmpty;

      if (mounted &&
          connected != _isConnected) {

        setState(() {
          _isConnected = connected;
        });
      }

    } catch (_) {

      if (mounted && _isConnected) {

        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        // Banner Internet
        AnimatedContainer(
          duration:
              const Duration(milliseconds: 300),

          height:
              _isConnected ? 0 : 36,

          color: AppColors.error,

          child: _isConnected
              ? const SizedBox()

              : const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 16,
                    ),

                    SizedBox(width: 8),

                    Text(
                      'ไม่มีการเชื่อมต่ออินเตอร์เน็ต',

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),

        // Main Content
        Expanded(
          child: widget.child,
        ),
      ],
    );
  }
}