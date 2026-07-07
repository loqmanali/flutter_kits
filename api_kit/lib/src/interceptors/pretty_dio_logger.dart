import 'dart:developer' as developer;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'interceptor_logger_config.dart';

const _timeStampKey = '_pdl_timeStamp_';

/// Default sink for Dio logs — routes through `dart:developer` so output goes
/// to the IDE debug log channel instead of the raw `print` stream.
void _defaultLogPrint(Object object) {
  developer.log(object.toString(), name: 'api_kit');
}

/// Log levels with associated colors
enum LogLevel {
  request,
  response,
  error,
  info,
  warning;

  String get color {
    switch (this) {
      case LogLevel.request:
        return InterceptorLoggerConfig.getColor('blue')!;
      case LogLevel.response:
        return InterceptorLoggerConfig.getColor('green')!;
      case LogLevel.error:
        return InterceptorLoggerConfig.getColor('red')!;
      case LogLevel.info:
        return InterceptorLoggerConfig.getColor('cyan')!;
      case LogLevel.warning:
        return InterceptorLoggerConfig.getColor('yellow')!;
    }
  }
}

/// Strategy Pattern: Interface for formatting output
abstract class LogFormatter {
  String format(String message, {LogLevel level = LogLevel.info});
  String formatHeader(String header, {required LogLevel level});
  String formatBox(String header, String text, {required LogLevel level});
}

/// Concrete implementation of LogFormatter with colors
class ColoredLogFormatter implements LogFormatter {
  final bool enableColors;
  final int maxWidth;

  const ColoredLogFormatter({
    this.enableColors = true,
    this.maxWidth = InterceptorLoggerConfig.prettyBoxWidth,
  });

  @override
  String format(String message, {LogLevel level = LogLevel.info}) {
    if (!enableColors) return message;
    return '${level.color}$message${InterceptorLoggerConfig.getColor('reset')}';
  }

  @override
  String formatHeader(String header, {required LogLevel level}) {
    if (!enableColors) return header;
    return '${InterceptorLoggerConfig.getColor('bold')}${level.color}$header${InterceptorLoggerConfig.getColor('reset')}';
  }

  @override
  String formatBox(String header, String text, {required LogLevel level}) {
    final coloredHeader = formatHeader(header, level: level);
    final line = '═' * maxWidth;
    return '''
${level.color}╔╣${InterceptorLoggerConfig.getColor('reset')} $coloredHeader
${level.color}║${InterceptorLoggerConfig.getColor('reset')}  $text
${level.color}╚$line╝${InterceptorLoggerConfig.getColor('reset')}''';
  }
}

/// Configuration class for PrettyDioLogger
class LoggerConfig {
  final bool request;
  final bool requestHeader;
  final bool requestBody;
  final bool responseBody;
  final bool responseHeader;
  final bool error;
  final bool compact;
  final int maxWidth;
  final bool enableColors;
  final void Function(Object object) logPrint;
  final bool Function(RequestOptions options, FilterArgs args)? filter;
  final bool enabled;
  final LogFormatter formatter;

  const LoggerConfig({
    this.request = true,
    this.requestHeader = false,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.maxWidth = 90,
    this.compact = true,
    this.enableColors = true,
    this.logPrint = _defaultLogPrint,
    this.filter,
    this.enabled = true,
    LogFormatter? formatter,
  }) : formatter = formatter ?? const ColoredLogFormatter();
}

/// Builder Pattern for creating LoggerConfig
class LoggerConfigBuilder {
  bool _request = true;
  bool _requestHeader = false;
  bool _requestBody = false;
  bool _responseHeader = false;
  bool _responseBody = true;
  bool _error = true;
  bool _compact = true;
  int _maxWidth = 90;
  bool _enableColors = true;
  void Function(Object object) _logPrint = _defaultLogPrint;
  bool Function(RequestOptions options, FilterArgs args)? _filter;
  bool _enabled = true;
  LogFormatter? _formatter;

  LoggerConfigBuilder setRequest(bool value) {
    _request = value;
    return this;
  }

  LoggerConfigBuilder setRequestHeader(bool value) {
    _requestHeader = value;
    return this;
  }

  LoggerConfigBuilder setRequestBody(bool value) {
    _requestBody = value;
    return this;
  }

  LoggerConfigBuilder setResponseHeader(bool value) {
    _responseHeader = value;
    return this;
  }

  LoggerConfigBuilder setResponseBody(bool value) {
    _responseBody = value;
    return this;
  }

  LoggerConfigBuilder setError(bool value) {
    _error = value;
    return this;
  }

  LoggerConfigBuilder setCompact(bool value) {
    _compact = value;
    return this;
  }

  LoggerConfigBuilder setMaxWidth(int value) {
    _maxWidth = value;
    return this;
  }

  LoggerConfigBuilder setEnableColors(bool value) {
    _enableColors = value;
    return this;
  }

  LoggerConfigBuilder setLogPrint(void Function(Object object) value) {
    _logPrint = value;
    return this;
  }

  LoggerConfigBuilder setFilter(
    bool Function(RequestOptions options, FilterArgs args)? value,
  ) {
    _filter = value;
    return this;
  }

  LoggerConfigBuilder setEnabled(bool value) {
    _enabled = value;
    return this;
  }

  LoggerConfigBuilder setFormatter(LogFormatter value) {
    _formatter = value;
    return this;
  }

  LoggerConfig build() {
    return LoggerConfig(
      request: _request,
      requestHeader: _requestHeader,
      requestBody: _requestBody,
      responseHeader: _responseHeader,
      responseBody: _responseBody,
      error: _error,
      compact: _compact,
      maxWidth: _maxWidth,
      enableColors: _enableColors,
      logPrint: _logPrint,
      filter: _filter,
      enabled: _enabled,
      formatter: _formatter ??
          ColoredLogFormatter(
            enableColors: _enableColors,
            maxWidth: _maxWidth,
          ),
    );
  }
}

/// A pretty logger for Dio with colors and design patterns
class PrettyDioLogger extends Interceptor {
  final LoggerConfig config;

  static const int kInitialTab = 1;
  static const String tabStep = '    ';
  static const int chunkSize = 20;

  PrettyDioLogger({LoggerConfig? config})
      : config = config ?? const LoggerConfig();

  /// Factory constructor using builder
  factory PrettyDioLogger.builder(void Function(LoggerConfigBuilder) builder) {
    final configBuilder = LoggerConfigBuilder();
    builder(configBuilder);
    return PrettyDioLogger(config: configBuilder.build());
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final extra = Map.of(options.extra);
    options.extra[_timeStampKey] = DateTime.timestamp().millisecondsSinceEpoch;

    if (!config.enabled ||
        (config.filter != null &&
            !config.filter!(options, FilterArgs(false, options.data)))) {
      handler.next(options);
      return;
    }

    if (config.request) {
      _printRequestHeader(options);
    }
    if (config.requestHeader) {
      _printMapAsTable(
        options.queryParameters,
        header: 'Query Parameters',
        level: LogLevel.info,
      );
      final requestHeaders = <String, dynamic>{};
      requestHeaders.addAll(options.headers);
      if (options.contentType != null) {
        requestHeaders['contentType'] = options.contentType?.toString();
      }
      requestHeaders['responseType'] = options.responseType.toString();
      requestHeaders['followRedirects'] = options.followRedirects;
      if (options.connectTimeout != null) {
        requestHeaders['connectTimeout'] = options.connectTimeout?.toString();
      }
      if (options.receiveTimeout != null) {
        requestHeaders['receiveTimeout'] = options.receiveTimeout?.toString();
      }
      _printMapAsTable(requestHeaders, header: 'Headers', level: LogLevel.info);
      _printMapAsTable(extra, header: 'Extras', level: LogLevel.info);
    }
    if (config.requestBody && options.method != 'GET') {
      final dynamic data = options.data;
      if (data != null) {
        if (data is Map) {
          _printMapAsTable(
            options.data as Map?,
            header: 'Body',
            level: LogLevel.info,
          );
        }
        if (data is FormData) {
          final formDataMap = <String, dynamic>{}
            ..addEntries(data.fields)
            ..addEntries(data.files);
          _printMapAsTable(
            formDataMap,
            header: 'Form data | ${data.boundary}',
            level: LogLevel.info,
          );
        } else {
          _printBlock(data.toString(), level: LogLevel.info);
        }
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!config.enabled ||
        (config.filter != null &&
            !config.filter!(
              err.requestOptions,
              FilterArgs(true, err.response?.data),
            ))) {
      handler.next(err);
      return;
    }

    final triggerTime = err.requestOptions.extra[_timeStampKey];

    if (config.error) {
      if (err.type == DioExceptionType.badResponse) {
        final uri = err.response?.requestOptions.uri;
        int diff = 0;
        if (triggerTime is int) {
          diff = DateTime.timestamp().millisecondsSinceEpoch - triggerTime;
        }
        _printBoxed(
          header:
              'DioError ║ Status: ${err.response?.statusCode} ${err.response?.statusMessage} ║ Time: $diff ms',
          text: uri.toString(),
          level: LogLevel.error,
        );
        if (err.response != null && err.response?.data != null) {
          _log('╔ ${err.type.toString()}', LogLevel.error);
          _printResponse(err.response!, level: LogLevel.error);
        }
        _printLine('╚', '═', level: LogLevel.error);
        _log('', LogLevel.error);
      } else {
        _printBoxed(
          header: 'DioError ║ ${err.type}',
          text: err.message ?? 'Unknown error',
          level: LogLevel.error,
        );
      }
    }
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!config.enabled ||
        (config.filter != null &&
            !config.filter!(
              response.requestOptions,
              FilterArgs(true, response.data),
            ))) {
      handler.next(response);
      return;
    }

    final triggerTime = response.requestOptions.extra[_timeStampKey];

    int diff = 0;
    if (triggerTime is int) {
      diff = DateTime.timestamp().millisecondsSinceEpoch - triggerTime;
    }
    _printResponseHeader(response, diff);
    if (config.responseHeader) {
      final responseHeaders = <String, String>{};
      response.headers
          .forEach((k, list) => responseHeaders[k] = list.toString());
      _printMapAsTable(
        responseHeaders,
        header: 'Headers',
        level: LogLevel.response,
      );
    }

    if (config.responseBody) {
      _log('╔ Body', LogLevel.response);
      _log('║', LogLevel.response);
      _printResponse(response, level: LogLevel.response);
      _log('║', LogLevel.response);
      _printLine('╚', '═', level: LogLevel.response);
    }
    handler.next(response);
  }

  void _log(String message, LogLevel level) {
    config.logPrint(config.formatter.format(message, level: level));
  }

  void _printBoxed({
    required String header,
    required String text,
    required LogLevel level,
  }) {
    final formatted = config.formatter.formatBox(header, text, level: level);
    config.logPrint(formatted);
  }

  void _printResponse(Response response, {required LogLevel level}) {
    if (response.data != null) {
      if (response.data is Map) {
        _printPrettyMap(response.data as Map, level: level);
      } else if (response.data is Uint8List) {
        _log('║${_indent()}[', level);
        _printUint8List(response.data as Uint8List, level: level);
        _log('║${_indent()}]', level);
      } else if (response.data is List) {
        _log('║${_indent()}[', level);
        _printList(response.data as List, level: level);
        _log('║${_indent()}]', level);
      } else {
        _printBlock(response.data.toString(), level: level);
      }
    }
  }

  void _printResponseHeader(Response response, int responseTime) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    final statusCode = response.statusCode ?? 0;
    final level = statusCode >= 200 && statusCode < 300
        ? LogLevel.response
        : LogLevel.error;

    _printBoxed(
      header:
          'Response ║ $method ║ Status: ${response.statusCode} ${response.statusMessage}  ║ Time: $responseTime ms',
      text: uri.toString(),
      level: level,
    );
  }

  void _printRequestHeader(RequestOptions options) {
    final uri = options.uri;
    final method = options.method;
    _printBoxed(
      header: 'Request ║ $method ',
      text: uri.toString(),
      level: LogLevel.request,
    );
  }

  void _printLine(String pre, String suf, {required LogLevel level}) {
    final line = '$pre${'═' * config.maxWidth}$suf';
    _log(line, level);
  }

  void _printKV(String? key, Object? v, {required LogLevel level}) {
    final pre = '╟ $key: ';
    final msg = v.toString();

    if (pre.length + msg.length > config.maxWidth) {
      _log(pre, level);
      _printBlock(msg, level: level);
    } else {
      _log('$pre$msg', level);
    }
  }

  void _printBlock(String msg, {required LogLevel level}) {
    final lines = (msg.length / config.maxWidth).ceil();
    for (var i = 0; i < lines; ++i) {
      _log(
        (i >= 0 ? '║ ' : '') +
            msg.substring(
              i * config.maxWidth,
              math.min<int>(
                i * config.maxWidth + config.maxWidth,
                msg.length,
              ),
            ),
        level,
      );
    }
  }

  String _indent([int tabCount = kInitialTab]) => tabStep * tabCount;

  void _printPrettyMap(
    Map data, {
    int initialTab = kInitialTab,
    bool isListItem = false,
    bool isLast = false,
    required LogLevel level,
  }) {
    var tabs = initialTab;
    final isRoot = tabs == kInitialTab;
    final initialIndent = _indent(tabs);
    tabs++;

    if (isRoot || isListItem) _log('║$initialIndent{', level);

    for (var index = 0; index < data.length; index++) {
      final isLast = index == data.length - 1;
      final key = '"${data.keys.elementAt(index)}"';
      dynamic value = data[data.keys.elementAt(index)];
      if (value is String && value.length > config.maxWidth * 2) {
        final previewLength = math.min<int>(32, value.length);
        final preview = value.substring(0, previewLength);
        value = '<long string len=${value.length}, preview="$preview...">';
      } else if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'([\r\n])+'), " ")}"';
      }
      if (value is Map) {
        if (config.compact && _canFlattenMap(value)) {
          _log('║${_indent(tabs)} $key: $value${!isLast ? ',' : ''}', level);
        } else {
          _log('║${_indent(tabs)} $key: {', level);
          _printPrettyMap(value, initialTab: tabs, level: level);
        }
      } else if (value is List) {
        if (config.compact && _canFlattenList(value)) {
          _log('║${_indent(tabs)} $key: ${value.toString()}', level);
        } else {
          _log('║${_indent(tabs)} $key: [', level);
          _printList(value, tabs: tabs, level: level);
          _log('║${_indent(tabs)} ]${isLast ? '' : ','}', level);
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(tabs);
        final linWidth = config.maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          final lines = (msg.length / linWidth).ceil();
          for (var i = 0; i < lines; ++i) {
            final multilineKey = i == 0 ? '$key:' : '';
            _log(
              '║${_indent(tabs)} $multilineKey ${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}',
              level,
            );
          }
        } else {
          _log('║${_indent(tabs)} $key: $msg${!isLast ? ',' : ''}', level);
        }
      }
    }

    _log('║$initialIndent}${isListItem && !isLast ? ',' : ''}', level);
  }

  void _printList(
    List list, {
    int tabs = kInitialTab,
    required LogLevel level,
  }) {
    for (var i = 0; i < list.length; i++) {
      final element = list[i];
      final isLast = i == list.length - 1;
      if (element is Map) {
        if (config.compact && _canFlattenMap(element)) {
          _log('║${_indent(tabs)}  $element${!isLast ? ',' : ''}', level);
        } else {
          _printPrettyMap(
            element,
            initialTab: tabs + 1,
            isListItem: true,
            isLast: isLast,
            level: level,
          );
        }
      } else {
        dynamic printable = element;
        if (printable is String && printable.length > config.maxWidth * 2) {
          final previewLength = math.min<int>(32, printable.length);
          final preview = printable.substring(0, previewLength);
          printable =
              '<long string len=${printable.length}, preview="$preview...">';
        }
        _log('║${_indent(tabs + 2)} $printable${isLast ? '' : ','}', level);
      }
    }
  }

  void _printUint8List(
    Uint8List list, {
    int tabs = kInitialTab,
    required LogLevel level,
  }) {
    final chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    for (final element in chunks) {
      _log('║${_indent(tabs)} ${element.join(", ")}', level);
    }
  }

  bool _canFlattenMap(Map map) {
    return map.values
            .where((dynamic val) => val is Map || val is List)
            .isEmpty &&
        map.toString().length < config.maxWidth;
  }

  bool _canFlattenList(List list) {
    return list.length < 10 && list.toString().length < config.maxWidth;
  }

  void _printMapAsTable(Map? map, {String? header, required LogLevel level}) {
    if (map == null || map.isEmpty) return;
    _log('╔ $header ', level);
    for (final entry in map.entries) {
      final value = entry.value;
      if (value is String && value.length > config.maxWidth * 2) {
        final previewLength = math.min<int>(32, value.length);
        final preview = value.substring(0, previewLength);
        final summarized =
            '<long string len=${value.length}, preview="$preview...">';
        _printKV(entry.key.toString(), summarized, level: level);
      } else {
        _printKV(entry.key.toString(), value, level: level);
      }
    }
    _printLine('╚', '═', level: level);
  }
}

/// Filter arguments
class FilterArgs {
  final bool isResponse;
  final dynamic data;

  bool get hasStringData => data is String;
  bool get hasMapData => data is Map;
  bool get hasListData => data is List;
  bool get hasUint8ListData => data is Uint8List;
  bool get hasJsonData => hasMapData || hasListData;

  const FilterArgs(this.isResponse, this.data);
}
