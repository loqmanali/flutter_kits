import 'dart:async';

import 'package:app_links/app_links.dart';

import '../handlers/route_parser.dart';
import '../models/link_data.dart';

/// Listens for incoming deep links (both hot-start and cold-start) and
/// emits them as parsed [LinkData] on [linkStream].
///
/// Only links matching the schemes / hosts configured on
/// [DeepLinkKitRuntime] are forwarded — everything else is silently
/// ignored.
class DeepLinkService {
  DeepLinkService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  final StreamController<LinkData> _linkController =
      StreamController<LinkData>.broadcast();
  StreamSubscription<String>? _subscription;

  /// Stream of parsed deep links matching the configured schemes / hosts.
  Stream<LinkData> get linkStream => _linkController.stream;

  /// Whether [init] has already been called.
  bool get isRunning => _subscription != null;

  /// Start listening for deep links.
  ///
  /// Wires up two sources:
  /// 1. Hot-start: links delivered while the app is running.
  /// 2. Cold-start: the link that launched the app (if any).
  Future<void> init() async {
    _subscription ??= _appLinks.stringLinkStream.listen(_processIncomingLink);

    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _processIncomingLink(initialLink.toString());
    }
  }

  void _processIncomingLink(String link) {
    if (!RouteParser.isAppLink(link)) return;

    final linkData = RouteParser.parseLink(link);
    if (!_linkController.isClosed) {
      _linkController.add(linkData);
    }
  }

  /// Cancel the subscription and close the stream.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _linkController.close();
  }
}
