class GxUpdateException implements Exception {
  const GxUpdateException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() {
    if (cause == null) return 'GxUpdateException: $message';
    return 'GxUpdateException: $message; cause=$cause';
  }
}

class GxUpdateHttpException extends GxUpdateException {
  const GxUpdateHttpException(
    super.message, {
    required this.statusCode,
    this.body,
    super.cause,
  });

  final int statusCode;
  final String? body;

  @override
  String toString() =>
      'GxUpdateHttpException: $message; statusCode=$statusCode; body=$body';
}

class GxUpdateCancelledException extends GxUpdateException {
  const GxUpdateCancelledException()
      : super('Update package download was cancelled.');

  @override
  String toString() => 'GxUpdateCancelledException: $message';
}
