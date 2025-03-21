import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/device.dart';

class WebViewScreen extends StatelessWidget {
  final Device device;

  const WebViewScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${device.name} WebView'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri('http://${device.ip}')),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
          ),
        ),
      ),
    );
  }
}