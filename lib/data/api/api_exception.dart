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

class ApiRedirectException extends ApiException {
  const ApiRedirectException(super.message);

  @override
  String toString() => 'ApiRedirectException: $message';
}
