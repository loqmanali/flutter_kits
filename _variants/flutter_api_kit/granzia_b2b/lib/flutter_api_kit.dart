/// flutter_api_kit
///
/// A reusable, framework-agnostic Dio-based API toolkit for Flutter.
/// See `README.md` for an architectural overview.
library flutter_api_kit;

// Config
export 'src/config/api_kit_config.dart';
export 'src/config/api_token_type.dart';
export 'src/config/auth_options.dart';

// Interfaces (the extension points consumers implement)
export 'src/interfaces/api_client.dart';
export 'src/interfaces/token_storage.dart';
export 'src/interfaces/language_provider.dart';
export 'src/interfaces/force_update_handler.dart';

// Implementations
export 'src/implementations/dio_api_client.dart';
export 'src/implementations/in_memory_token_storage.dart';

// Interceptors (exposed so consumers can compose their own Dio instance)
export 'src/interceptors/auth_interceptor.dart';
export 'src/interceptors/language_interceptor.dart';
export 'src/interceptors/version_interceptor.dart';
export 'src/interceptors/force_update_interceptor.dart';
export 'src/interceptors/api_key_interceptor.dart';
export 'src/interceptors/pretty_dio_logger.dart';
export 'src/interceptors/interceptor_logger_config.dart';

// Exceptions
export 'src/exceptions/api_exception.dart';

// Failures
export 'src/failures/failure.dart';

// Utilities
export 'src/utilities/error_mapper.dart';
export 'src/utilities/api_response_reader.dart';
export 'src/utilities/json_safe.dart';
