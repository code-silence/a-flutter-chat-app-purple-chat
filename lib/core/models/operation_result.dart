class OperationResult<T> {
  final bool success;
  final String message;
  final T? data;

  const OperationResult({
    required this.success,
    required this.message,
    this.data,
  });

  factory OperationResult.success({
    String message = '',
    T? data,
  }) {
    return OperationResult(
      success: true,
      message: message,
      data: data,
    );
  }

  factory OperationResult.failure({
    required String message,
  }) {
    return OperationResult(
      success: false,
      message: message,
    );
  }
}