import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EarthquakeAssemblyScreen extends StatefulWidget {
  const EarthquakeAssemblyScreen({super.key});

  @override
  State<EarthquakeAssemblyScreen> createState() =>
      _EarthquakeAssemblyScreenState();
}

class _EarthquakeAssemblyScreenState extends State<EarthquakeAssemblyScreen> {
  late final WebViewController _controller;

  final String allowedUrl =
      'https://www.turkiye.gov.tr/afet-ve-acil-durum-yonetimi-acil-toplanma-alani-sorgulama';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url == allowedUrl) {
              return NavigationDecision.navigate; // izin ver
            } else {
              return NavigationDecision.prevent; // başka linklere izin verme
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(allowedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toplanma Alanı Öğren')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
