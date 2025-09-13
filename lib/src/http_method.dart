/// Supported HTTP methods for queued requests.
enum HttpMethod {
  get,
  post,
  put,
  delete,
  head,
  patch,
  options,
}

/// Convenience methods for [HttpMethod].
extension HttpMethodX on HttpMethod {
  /// Uppercase string value of the HTTP method.
  String get value => name.toUpperCase();

  /// Parses a method [String] into an [HttpMethod].
  static HttpMethod fromString(String method) =>
      HttpMethod.values.byName(method.toLowerCase());
}
