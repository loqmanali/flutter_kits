import 'dart:async';
import 'dart:convert';
import 'dart:io' show Directory, File;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

/// Where the JSON DB, fonts and images come from.
///
/// Implementations never throw for a missing resource — they return null so the
/// caller can fall back (manifest -> monolith -> default font size), mirroring
/// the web runtime's XHR error paths.
abstract class MadinaSource {
  /// [path] is relative to the source's root, e.g.
  /// `db/Madina05-Hafs-16px/manifest.json`.
  ///
  /// [forceFresh] skips the cache. Used for `manifest.json` only: it is small,
  /// and always refetching it is what lets a changed `content_hash` be noticed
  /// on every load instead of once per session.
  Future<Map<String, dynamic>?> loadJson(String path,
      {bool forceFresh = false});

  /// [url] is the DB header's `font_url`, e.g. `assets/fonts/Hafs.woff2`.
  Future<Uint8List?> loadFont(String url);

  /// Drops every cached entry whose path starts with [prefix].
  void clearCache(String prefix);
}

/// Reads everything from the package's bundled assets. Works fully offline.
class MadinaAssetSource extends MadinaSource {
  MadinaAssetSource({this.package = 'quran_madina_kit', this.root = 'assets/'});

  final String package;
  final String root;

  final Map<String, Map<String, dynamic>> _cache = {};
  final Map<String, Future<Map<String, dynamic>?>> _pending = {};

  String _key(String path) => 'packages/$package/$root$path';

  @override
  Future<Map<String, dynamic>?> loadJson(
    String path, {
    bool forceFresh = false,
  }) {
    if (!forceFresh && _cache.containsKey(path)) {
      return Future.value(_cache[path]);
    }
    final inFlight = _pending[path];
    if (inFlight != null) return inFlight;

    final future = () async {
      try {
        final raw = await rootBundle.loadString(_key(path));
        final data = json.decode(raw) as Map<String, dynamic>;
        _cache[path] = data;
        return data;
      } on Object {
        return null; // asset absent or malformed: let the caller fall back
      } finally {
        _pending.remove(path);
      }
    }();
    _pending[path] = future;
    return future;
  }

  @override
  Future<Uint8List?> loadFont(String url) async {
    // The DB header names the web asset (.woff2); the bundle ships the .ttf
    // Flutter can load. Same sfnt tables, so the metrics are identical.
    final name = url.split('/').last.replaceAll('.woff2', '.ttf');
    try {
      final data =
          await rootBundle.load('packages/$package/${root}fonts/$name');
      return data.buffer.asUint8List();
    } on Object {
      return null;
    }
  }

  @override
  void clearCache(String prefix) =>
      _cache.removeWhere((key, _) => key.startsWith(prefix));
}

/// Fetches from a CDN, with an in-memory cache and an optional on-disk cache.
///
/// No `path_provider` dependency: the host app supplies [cacheDir] if it wants
/// persistence across launches.
///
/// Note: the published `quran-madina-html` CDN serves `.woff2` fonts, which
/// Flutter cannot parse. Point [base] at a mirror that serves `.ttf`, or bundle
/// the fonts and use [MadinaAssetSource] for them.
class MadinaNetworkSource extends MadinaSource {
  MadinaNetworkSource({
    this.base = 'https://unpkg.com/quran-madina-html/',
    this.cacheDir,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String base;
  final Directory? cacheDir;
  final http.Client _client;

  final Map<String, Map<String, dynamic>> _cache = {};
  final Map<String, Future<Map<String, dynamic>?>> _pending = {};

  Uri _uri(String path) => Uri.parse('$base$path');

  File? _cacheFile(String path) {
    final dir = cacheDir;
    if (dir == null) return null;
    return File('${dir.path}/${path.replaceAll('/', '_')}');
  }

  @override
  Future<Map<String, dynamic>?> loadJson(
    String path, {
    bool forceFresh = false,
  }) {
    if (!forceFresh) {
      final hit = _cache[path];
      if (hit != null) return Future.value(hit);
      final inFlight = _pending[path];
      if (inFlight != null) return inFlight;
    }

    final future = () async {
      try {
        if (!forceFresh) {
          final file = _cacheFile(path);
          if (file != null && file.existsSync()) {
            final data =
                json.decode(await file.readAsString()) as Map<String, dynamic>;
            _cache[path] = data;
            return data;
          }
        }
        final res = await _client.get(_uri(path));
        if (res.statusCode != 200) return null;
        // Decoded from bytes, not res.body: a server that omits charset=utf-8
        // would otherwise mangle the Arabic text into latin-1.
        final text = utf8.decode(res.bodyBytes);
        final data = json.decode(text) as Map<String, dynamic>;
        _cache[path] = data;
        final file = _cacheFile(path);
        if (file != null) {
          try {
            await file.parent.create(recursive: true);
            await file.writeAsString(text);
          } on Object {
            // Disk cache is best-effort; the memory cache still holds it.
          }
        }
        return data;
      } on Object {
        return null;
      } finally {
        _pending.remove(path);
      }
    }();
    if (!forceFresh) _pending[path] = future;
    return future;
  }

  @override
  Future<Uint8List?> loadFont(String url) async {
    try {
      final uri = RegExp('^(https?:)?//').hasMatch(url)
          ? Uri.parse(url)
          : _uri(url.replaceFirst(RegExp('^/'), ''));
      final res = await _client.get(uri);
      return res.statusCode == 200 ? res.bodyBytes : null;
    } on Object {
      return null;
    }
  }

  @override
  void clearCache(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
    final dir = cacheDir;
    if (dir == null || !dir.existsSync()) return;
    final filePrefix = prefix.replaceAll('/', '_');
    for (final entry in dir.listSync()) {
      if (entry is File && entry.uri.pathSegments.last.startsWith(filePrefix)) {
        try {
          entry.deleteSync();
        } on Object {
          // Best-effort.
        }
      }
    }
  }
}
