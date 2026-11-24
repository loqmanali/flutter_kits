/// Renders Quran pages visually identical to the printed Madina Mushaf,
/// without images, from pre-computed JSON databases.
///
/// A Flutter port of the `quran-madina-html` web runtime; it consumes the same
/// JSON databases byte-for-byte.
library;

export 'src/chrome.dart' show MadinaHeader, translateUri;
export 'src/line.dart' show MadinaLine;
export 'src/source.dart'
    show MadinaAssetSource, MadinaNetworkSource, MadinaSource;
export 'src/theme.dart'
    show
        MadinaConfig,
        MadinaInline,
        MadinaScope,
        MadinaStretchMode,
        MadinaTheme,
        MadinaTranslateHandler;
export 'src/webview.dart' show MadinaWebPage, openMadinaWebPage;
export 'src/widget.dart' show QuranMadinaView;
