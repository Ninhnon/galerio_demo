import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/webview_service.dart';

class WebViewScreen extends StatefulWidget {
  final String token;
  final String accessToken;
  final String url;
  final Function(String?)? onLogin;

  const WebViewScreen({
    Key? key,
    required this.token,
    required this.accessToken,
    required this.url,
    this.onLogin,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final WebViewService _webViewService = WebViewService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    try {
      await _webViewService.initWebView(
        widget.url,
        widget.token,
        widget.accessToken,
        onLogin: widget.onLogin,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Content'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _webViewService.logout();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              await _webViewService.reload();
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear_cache') {
                await _webViewService.clearCache();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
                }
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'clear_cache',
                    child: Text('Clear Cache'),
                  ),
                ],
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading web content:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initWebView,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (!_isLoading)
            WebViewWidget(controller: _webViewService.controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
