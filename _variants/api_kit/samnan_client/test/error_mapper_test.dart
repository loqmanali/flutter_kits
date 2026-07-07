import 'package:api_kit/api_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorMapper.mapExceptionToFailure', () {
    test('server exceptions → ServerFailure', () {
      expect(
        ErrorMapper.mapExceptionToFailure(const ServerException('boom')),
        isA<ServerFailure>(),
      );
      expect(
        ErrorMapper.mapExceptionToFailure(
          const InternalServerErrorException('boom'),
        ),
        isA<ServerFailure>(),
      );
    });

    test('auth + unauthorized → AuthFailure', () {
      expect(
        ErrorMapper.mapExceptionToFailure(const AuthException()),
        isA<AuthFailure>(),
      );
      expect(
        ErrorMapper.mapExceptionToFailure(const UnauthorizedException()),
        isA<AuthFailure>(),
      );
    });

    test('no internet → NetworkFailure', () {
      expect(
        ErrorMapper.mapExceptionToFailure(const NoInternetConnectionException()),
        isA<NetworkFailure>(),
      );
    });

    test('not found → NotFoundFailure', () {
      expect(
        ErrorMapper.mapExceptionToFailure(const NotFoundException()),
        isA<NotFoundFailure>(),
      );
    });

    test('timeout → TimeoutFailure', () {
      expect(
        ErrorMapper.mapExceptionToFailure(const TimeoutException()),
        isA<TimeoutFailure>(),
      );
    });

    test('validation carries field errors through', () {
      final failure = ErrorMapper.mapExceptionToFailure(
        const ValidationException(
          message: 'invalid',
          fieldErrors: {'email': 'required'},
        ),
      );
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).fieldErrors, {'email': 'required'});
    });

    test('unknown ApiException → UnexpectedFailure', () {
      expect(
        ErrorMapper.mapExceptionToFailure(const BadCertificateException()),
        isA<UnexpectedFailure>(),
      );
    });

    test('non-ApiException → UnexpectedFailure with message', () {
      final failure =
          ErrorMapper.mapExceptionToFailure(const FormatException('bad'));
      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, contains('bad'));
    });

    test('message is preserved end to end', () {
      final failure =
          ErrorMapper.mapExceptionToFailure(const ServerException('db down'));
      expect(ErrorMapper.getErrorMessage(failure), 'db down');
    });
  });

  group('ApiException', () {
    test('toString includes status code when present', () {
      expect(
        const UnauthorizedException('nope').toString(),
        'nope (Code: 401)',
      );
      expect(const AuthException('plain').toString(), 'plain');
    });

    test('value equality (Equatable)', () {
      expect(
        const ApiException('x', statusCode: 400),
        const ApiException('x', statusCode: 400),
      );
      expect(
        const ApiException('x', statusCode: 400),
        isNot(const ApiException('x', statusCode: 401)),
      );
    });

    test('well-known status codes are set', () {
      expect(const BadRequestException().statusCode, 400);
      expect(const ForbiddenException().statusCode, 403);
      expect(const NotFoundException().statusCode, 404);
      expect(const ServiceUnavailableException().statusCode, 503);
    });
  });
}
