import 'package:flutter/material.dart';

class NetworkStatusBanner extends StatelessWidget {

  final Widget child;

  const NetworkStatusBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    // ปิด banner ชั่วคราว
    return child;
  }
}