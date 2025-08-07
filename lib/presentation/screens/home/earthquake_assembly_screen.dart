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
  bool _isLoading = true;

  final String allowedUrl =
      'https://www.turkiye.gov.tr/afet-ve-acil-durum-yonetimi-acil-toplanma-alani-sorgulama';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url == allowedUrl) {
              return NavigationDecision.navigate;
            } else {
              return NavigationDecision.prevent;
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
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
