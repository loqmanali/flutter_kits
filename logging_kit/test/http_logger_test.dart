import 'package:flutter_test/flutter_test.dart';
import 'package:logging_kit/logging_kit.dart';

void main() {
  late List<String> captured;

  setUp(() {
    captured = <String>[];
    AppLogger.reset();
    AppLogger.setEnabled(true);
    AppLogger.setLevel(AppLogLevel.debug);
    AppLogger.setLogHandler((level, message, error, stackTrace) {
      captured.add(message);
    });
  });

  tearDown(AppLogger.reset);

  group('redactHttpValue', () {
    test('redacts a matching key nested inside a list inside a map', () {
      final body = {
        'user': {
          'items': [
            {'password': 'secret1', 'name': 'ok'},
            {'token': 'secret2'},
          ],
        },
      };

      final redacted = redactHttpValue(body, HttpLogPolicy.defaultRedactKeys)
          .toString();

      expect(redacted, isNot(contains('secret1')));
      expect(redacted, isNot(contains('secret2')));
      expect(redacted, contains('***'));
      expect(redacted, contains('ok')); // non-redacted sibling survives
    });

    test('does not redact a status-code-shaped key named differently', () {
      final body = {'statusCode': 404, 'code': 'abc'};
      final redacted = redactHttpValue(body, HttpLogPolicy.defaultRedactKeys)
          as Map;
      expect(redacted['statusCode'], 404); // untouched: not an exact match
      expect(redacted['code'], '***'); // exact match on the documented list
    });
  });

  group('redactQueryString', () {
    test('redacts only the matching key, leaves others intact', () {
      final out = redactQueryString(
        'password=abc123&page=2',
        HttpLogPolicy.defaultRedactKeys,
      );
      expect(out, 'password=***&page=2');
    });
  });

  group('formatHttpBody truncation', () {
    test('caps pretty-printed output to maxBodyLines with a count marker', () {
      final body = List.generate(60, (i) => {'i': i});
      const policy = HttpLogPolicy(maxBodyLines: 10);

      final out = formatHttpBody(body, policy);
      final lines = out.split('\n');

      expect(lines.last, matches(RegExp(r'^… \d+ more lines not printed$')));
      // maxBodyLines of content + 1 marker line.
      expect(lines.length, 11);
    });

    test('maxBodyChars truncates the raw body before formatting', () {
      final huge = 'x' * 10000;
      const policy = HttpLogPolicy(maxBodyChars: 4000);

      final out = formatHttpBody(huge, policy);

      // Capped near maxBodyChars (plus the trailing ellipsis), nowhere near
      // the original 10,000 chars — the guard ran before any formatting.
      expect(out.length, lessThan(4100));
      expect(out, endsWith('…'));
    });
  });

  group('HttpLogger.logRequest/logResponse summary lines', () {
    test('request summary matches the documented format', () {
      HttpLogger.logRequest(
        HttpLogRequest(
          method: 'GET',
          uri: Uri.parse('https://api.example.com/orders?page=1'),
        ),
      );

      expect(captured, ['→ GET /orders?page=1']);
    });

    test('response summary includes status, timing and size', () {
      HttpLogger.logResponse(
        HttpLogResponse(
          method: 'GET',
          uri: Uri.parse('https://api.example.com/orders?page=1'),
          statusCode: 200,
          duration: const Duration(milliseconds: 394),
          body: 'ok',
        ),
      );

      expect(captured.first, '← 200 GET /orders?page=1 · 394ms · 2B');
    });
  });

  group('login body redaction end-to-end', () {
    test('a login request body never leaks the password', () {
      HttpLogger.logRequest(
        HttpLogRequest(
          method: 'POST',
          uri: Uri.parse('https://api.example.com/login'),
          body: {'phone': '5551234', 'password': 'secret'},
        ),
      );

      final all = captured.join('\n');
      expect(all, isNot(contains('secret')));
      expect(all, contains('***'));
    });
  });

  group('HttpLogPolicy(enabled: false)', () {
    test('logRequest/logResponse/logError emit nothing', () {
      const policy = HttpLogPolicy(enabled: false);
      final uri = Uri.parse('https://api.example.com/x');

      HttpLogger.logRequest(
        HttpLogRequest(method: 'GET', uri: uri, body: {'a': 1}),
        policy: policy,
      );
      HttpLogger.logResponse(
        HttpLogResponse(
          method: 'GET',
          uri: uri,
          statusCode: 200,
          duration: Duration.zero,
          body: {'a': 1},
        ),
        policy: policy,
      );
      HttpLogger.logError(
        HttpLogError(
          method: 'GET',
          uri: uri,
          duration: Duration.zero,
          error: Exception('boom'),
        ),
        policy: policy,
      );

      expect(captured, isEmpty);
    });
  });
}
