import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../config/api_config.dart';

/// Virtual Tour Viewer - PRIORITY 1
/// Displays 360° virtual tour using Marzipano in WebView
class VirtualTourViewer extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;

  const VirtualTourViewer.remote({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<VirtualTourViewer> createState() => _VirtualTourViewerState();
}

class _VirtualTourViewerState extends State<VirtualTourViewer> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _error = null;
          }),
          onPageFinished: (_) => setState(() {
            _isLoading = false;
          }),
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = 'Failed to load 360° tour: ${error.description}';
            });
          },
        ),
      );

    final viewerUrl = ApiConfig.viewerUrl(widget.propertyId);
    _webViewController.loadRequest(Uri.parse(viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '360° Virtual Tour',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              widget.propertyTitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
            },
            tooltip: 'Reload tour',
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () {
              // Toggle fullscreen
              // Note: Full implementation would require platform-specific code
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rotate device for fullscreen experience'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Fullscreen',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Virtual Tour...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          if (_error != null && !_isLoading)
            Container(
              color: Colors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _error = null;
                          });
                          _webViewController.reload();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildControlsInfo(),
    );
  }
}

  Widget _buildControlsInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlHint(Icons.touch_app, 'Drag to rotate'),
            _buildControlHint(Icons.zoom_in, 'Pinch to zoom'),
            _buildControlHint(Icons.ads_click, 'Click arrows to navigate'),
          ],
        ),
      ),
    );
  }

  Widget _buildControlHint(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
