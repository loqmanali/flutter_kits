import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// A simple inline WebView for playing non-YouTube video URLs inside the app.
class GenericVideoWebView extends StatelessWidget {
  /// The direct video URL or page URL to load.
  final String videoUrl;

  /// Optional background color around the WebView.
  final Color backgroundColor;

  const GenericVideoWebView({
    super.key,
    required this.videoUrl,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(videoUrl)),
        initialSettings: InAppWebViewSettings(
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          iframeAllowFullscreen: true,
          allowsBackForwardNavigationGestures: false,
        ),
      ),
    );
  }
}
