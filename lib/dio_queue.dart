import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';

/// Sequential request queue for the [Dio] HTTP client.
///
/// `DioQueue` wraps an existing [Dio] instance and ensures that enqueued
/// requests are executed one at a time in the order they were added. This is
/// useful when working with APIs that enforce strict rate limits or when you
/// need to serialize writes.
///
/// ```dart
/// final queue = DioQueue(Dio());
/// final first = queue.enqueue((dio) => dio.get('/first'));
/// final second = queue.enqueue((dio) => dio.get('/second'));
///
/// final responses = await Future.wait([first, second]);
/// print(responses.first.data);
/// ```
class DioQueue {
  /// Creates a queue that wraps the provided [dio] client.
  DioQueue(this._dio);

  final Dio _dio;
  final Queue<_QueuedRequest<dynamic>> _queue = Queue<_QueuedRequest<dynamic>>();
  bool _running = false;

  /// Enqueues a [request] for sequential execution and returns its response.
  ///
  /// The [request] callback receives the wrapped [Dio] instance and should
  /// return a `Future` produced by calling one of the `Dio` request methods.
  /// Requests are executed in first-in, first-out order, and only one request
  /// runs at a time.
  Future<Response<T>> enqueue<T>(Future<Response<T>> Function(Dio dio) request) {
    final completer = Completer<Response<T>>();
    _queue.add(_QueuedRequest<T>(request, completer));
    _process();
    return completer.future;
  }

  void _process() {
    if (_running || _queue.isEmpty) return;
    _running = true;
    final job = _queue.removeFirst();
    job.request(_dio).then(job.completer.complete).catchError(
      job.completer.completeError,
    ).whenComplete(() {
      _running = false;
      _process();
    });
  }
}

/// Internal representation of a queued [request].
class _QueuedRequest<T> {
  _QueuedRequest(this.request, this.completer);

  final Future<Response<T>> Function(Dio dio) request;
  final Completer<Response<T>> completer;
}
