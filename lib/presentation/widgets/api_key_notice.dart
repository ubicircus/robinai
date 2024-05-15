import 'package:flutter/material.dart';

class ApiKeyNotice extends StatefulWidget {
  @override
  _ApiKeyNoticeState createState() => _ApiKeyNoticeState();
}

class _ApiKeyNoticeState extends State {
  bool _fadeIn = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _fadeIn ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1500),
      child: Center(child: Text("Enter API Key")),
      onEnd: () {
        setState(() {
          _fadeIn = !_fadeIn;
        });
      },
    );
  }
}
