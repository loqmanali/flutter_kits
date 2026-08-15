import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens [url] on a full-screen page inside the app.
///
/// This is the kit's default translate action. Nothing ever leaves the app: a
/// reader tapping "translate" should land on quran.com and be able to come
/// straight back, not be handed off to a browser and lose their place.
///
/// Override it per app with `MadinaConfig.onTranslate` — an app that already
/// has its own in-app browser, router, or bottom sheet should use that instead.
Future<void> openMadinaWebPage(
  BuildContext context,
  Uri url, {
  String? title,
}) =>
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(builder: (_) => MadinaWebPage(url: url, title: title)),
    );

/// A minimal in-app browser: title, close, reload, and a copy-link fallback.
class MadinaWebPage extends StatefulWidget {
  const MadinaWebPage({super.key, required this.url, this.title});

  final Uri url;
  final String? title;

  @override
  State<MadinaWebPage> createState() => _MadinaWebPageState();
}

class _MadinaWebPageState extends State<MadinaWebPage> {
  WebViewController? _controller;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => _progress = p / 100);
          },
        ))
        ..loadRequest(widget.url);
    } on Object {
      // No webview implementation on this platform (macOS, Windows, Linux, and
      // the widget-test environment). The page still shows the link, so the
      // verse stays reachable instead of the app crashing.
      _controller = null;
    }
  }

  Future<void> _copyLink() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(ClipboardData(text: widget.url.toString()));
    messenger?.showSnackBar(
      const SnackBar(content: Text('⎘ تم نسخ الرابط')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? widget.url.host),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.link_rounded),
            tooltip: 'نسخ الرابط',
            onPressed: _copyLink,
          ),
          if (controller != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تحديث',
              onPressed: controller.reload,
            ),
        ],
        bottom: _progress > 0 && _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
      ),
      body: controller == null
          ? _fallback()
          : WebViewWidget(controller: controller),
    );
  }

  Widget _fallback() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public_off_rounded, size: 40),
              const SizedBox(height: 12),
              const Text(
                'لا يوجد متصفح مدمج على هذه المنصة',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              SelectableText(
                widget.url.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _copyLink,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('نسخ الرابط'),
              ),
            ],
          ),
        ),
      );
}
