/// Interceptor that diverts selected requests into the queue for later execution.
import 'package:dio/dio.dart';

import 'queue_client.dart';
import 'http_method.dart';

/// Predicate deciding whether a request should be queued.
typedef QueuePredicate = bool Function(RequestOptions options);

/// Dio interceptor that enqueues matching requests instead of sending
/// immediately.
class QueueInterceptor extends Interceptor {
  /// Queue used to enqueue matching requests.
  final FlutterDioQueue queue;

  /// Function used to determine whether a request should be queued.
  final QueuePredicate predicate;

  /// Creates an interceptor for [queue]. If [predicate] is omitted the request
  /// will be queued when the `x-queue` header is set to `'true'`.
  QueueInterceptor(this.queue, {QueuePredicate? predicate})
      : predicate = predicate ?? _headerPredicate;

  static bool _headerPredicate(RequestOptions o) =>
      o.headers['x-queue']?.toString() == 'true';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (predicate(options)) {
      queue.enqueueRequest(
        method: HttpMethodX.fromString(options.method),
        url: options.path,
        headers: Map<String, dynamic>.from(options.headers),
        data: options.data,
        query: options.queryParameters,
      );
      handler.resolve(
        Response(requestOptions: options, statusCode: 202, data: null),
      );
    } else {
      handler.next(options);
    }
  }
}
