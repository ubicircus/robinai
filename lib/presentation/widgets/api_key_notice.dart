import 'package:flutter/material.dart';

class ApiKeyNotice extends StatefulWidget {
  @override
  _ApiKeyNoticeState createState() => _ApiKeyNoticeState();
}

class _ApiKeyNoticeState extends State<ApiKeyNotice> {
  bool _fadeIn = true;

  @override
  void initState() {
    super.initState();
    _startBlinking();
  }

  void _startBlinking() {
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _fadeIn = !_fadeIn;
        });
        _startBlinking();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _fadeIn ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1500),
      child: Center(child: Text("Enter API Key")),
    );
  }
}
