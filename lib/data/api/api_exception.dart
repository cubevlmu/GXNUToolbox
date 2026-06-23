class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}

class ApiLoginExpiredException extends ApiException {
  const ApiLoginExpiredException() : super('Login expired');

  @override
  String toString() => 'ApiLoginExpiredException';
}

class ApiInvalidResponseException extends ApiException {
  const ApiInvalidResponseException(super.message);

  @override
  String toString() => 'ApiInvalidResponseException: $message';
}

class ApiProtectionRequiredException extends ApiException {
  const ApiProtectionRequiredException(super.message);

  @override
  String toString() => 'ApiProtectionRequiredException: $message';
}

class ApiRateLimitedException extends ApiException {
  const ApiRateLimitedException(super.message);

  @override
  String toString() => 'ApiRateLimitedException: $message';
}

class ApiUnexpectedHtmlException extends ApiInvalidResponseException {
  const ApiUnexpectedHtmlException(super.message);

  @override
  String toString() => 'ApiUnexpectedHtmlException: $message';
}

class ApiRedirectException extends ApiException {
  const ApiRedirectException(super.message);

  @override
  String toString() => 'ApiRedirectException: $message';
}
