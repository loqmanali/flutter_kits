import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// A widget that displays a YouTube video using InAppWebView.
/// This widget loads the YouTube mobile watch page and injects CSS
/// to hide all UI elements except the video player.
class YouTubePlayerWidget extends StatelessWidget {
  /// The YouTube video ID to play.
  final String videoId;

  /// Background color shown while loading.
  final Color backgroundColor;

  const YouTubePlayerWidget({
    super.key,
    required this.videoId,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    final watchUrl = 'https://m.youtube.com/watch?v=$videoId';

    return Container(
      color: backgroundColor,
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(watchUrl)),
        initialSettings: InAppWebViewSettings(
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          iframeAllowFullscreen: true,
          allowsBackForwardNavigationGestures: false,
          preferredContentMode: UserPreferredContentMode.MOBILE,
          disableVerticalScroll: true,
          disableHorizontalScroll: true,
        ),
        onLoadStop: (controller, url) async {
          await _injectPlayerStyles(controller);
        },
      ),
    );
  }

  /// Injects CSS to hide YouTube UI and make player fullscreen.
  Future<void> _injectPlayerStyles(InAppWebViewController controller) async {
    await controller.evaluateJavascript(
      source: r'''
      (function() {
        var css = document.createElement('style');
        css.type = 'text/css';
        css.innerHTML = `
          ytm-mobile-topbar-renderer,
          .mobile-topbar-header,
          ytm-slim-video-information-renderer,
          ytm-slim-owner-renderer,
          ytm-slim-video-action-bar-renderer,
          ytm-comments-entry-point-teaser-renderer,
          ytm-item-section-renderer,
          ytm-rich-section-renderer,
          ytm-pivot-bar-renderer,
          ytm-mealbar-promo-renderer,
          ytm-single-column-watch-next-results-renderer,
          .watch-below-the-player {
            display: none !important;
          }
          html, body {
            overflow: hidden !important;
            background: #000 !important;
          }
          #player {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100vw !important;
            height: 100vh !important;
            z-index: 99999 !important;
          }
          .html5-video-player {
            width: 100% !important;
            height: 100% !important;
          }
          video {
            object-fit: contain !important;
          }
        `;
        document.head.appendChild(css);
        window.scrollTo(0, 0);
      })();
    ''',
    );
  }

  /// Extracts video ID from a YouTube URL or embed code.
  static String? extractVideoId(String input) {
    // Try embed URL pattern
    final embedRegex = RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]+)');
    final embedMatch = embedRegex.firstMatch(input);
    if (embedMatch != null) {
      return embedMatch.group(1);
    }

    // Try watch URL pattern
    final watchRegex = RegExp(r'[?&]v=([a-zA-Z0-9_-]+)');
    final watchMatch = watchRegex.firstMatch(input);
    if (watchMatch != null) {
      return watchMatch.group(1);
    }

    // Try youtu.be short URL pattern
    final shortRegex = RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)');
    final shortMatch = shortRegex.firstMatch(input);
    if (shortMatch != null) {
      return shortMatch.group(1);
    }

    return null;
  }
}
