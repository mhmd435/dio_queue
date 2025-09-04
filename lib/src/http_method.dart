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

extension HttpMethodX on HttpMethod {
  String get value => name.toUpperCase();

  static HttpMethod fromString(String method) =>
      HttpMethod.values.byName(method.toLowerCase());
}
