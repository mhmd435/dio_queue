import 'package:dio/dio.dart';

import 'queue_client.dart';

typedef QueuePredicate = bool Function(RequestOptions options);

/// Dio interceptor that enqueues matching requests instead of sending immediately.
class QueueInterceptor extends Interceptor {
  final FlutterDioQueue queue;
  final QueuePredicate predicate;

  QueueInterceptor(this.queue, {QueuePredicate? predicate})
      : predicate = predicate ?? _headerPredicate;

  static bool _headerPredicate(RequestOptions o) =>
      o.headers['x-queue']?.toString() == 'true';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (predicate(options)) {
      queue.enqueueRequest(
        method: options.method,
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
