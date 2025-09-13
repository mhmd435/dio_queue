/// High-level API for interacting with the request queue.
import 'dart:async';
import 'package:dio/dio.dart';

import 'connectivity_watcher.dart';
import 'logger.dart';
import 'metrics.dart';
import 'queue_config.dart';
import 'queue_event.dart';
import 'queue_job.dart';
import 'queue_storage.dart';
import 'memory_storage.dart';
import 'scheduler.dart';
import 'http_method.dart';

/// Public facade for the queue system.
class FlutterDioQueue {
  final Scheduler _scheduler;

  /// Storage backend used for persisting jobs.
  final QueueStorage storage;

  /// Creates a queue bound to [dio]. Optionally provide a custom [storage],
  /// [config], [connectivity] watcher and [logger].
  FlutterDioQueue({
    /// Dio instance used to execute requests.
    required Dio dio,

    /// Storage backend for persisting queued jobs.
    QueueStorage? storage,

    /// Behavioural configuration for the queue.
    QueueConfig config = const QueueConfig(),

    /// Connectivity watcher used to pause when offline.
    ConnectivityWatcher? connectivity,

    /// Logger for diagnostic output.
    QueueLogger? logger,
  })  : storage = storage ?? MemoryQueueStorage(),
        _scheduler = Scheduler(
          dio: dio,
          storage: storage ?? MemoryQueueStorage(),
          config: config,
          connectivity: connectivity,
          logger: logger,
        ) {
    unawaited(this.storage.init());
  }

  /// Stream of job state change events.
  Stream<QueueEvent> get events => _scheduler.events;

  /// Stream of metrics about the queue.
  Stream<QueueMetrics> get metrics => _scheduler.metrics;

  /// Enqueues a prepared [QueueJob] and returns its id.
  Future<String> enqueue(QueueJob job) => _scheduler.enqueue(job);

  /// Cancels a job by [jobId].
  Future<void> cancel(String jobId) => _scheduler.cancel(jobId);

  /// Cancels all jobs tagged with [tag].
  Future<void> cancelByTag(String tag) => _scheduler.cancelByTag(tag);

  /// Starts processing of queued jobs when [QueueConfig.autoStart] is `false`.
  void start() => _scheduler.start();

  /// Pauses scheduling of new jobs; running jobs continue.
  void pause() => _scheduler.pause();

  /// Resumes scheduling after a pause.
  void resume() => _scheduler.resume();

  /// Waits for the queue to become idle (no queued or running jobs).
  Future<void> drain() => _scheduler.drain();

  /// Convenience builder to enqueue a request without manually constructing a
  /// [QueueJob].
  String enqueueRequest({
    /// HTTP method of the request.
    required HttpMethod method,

    /// Endpoint URL path.
    required String url,

    /// Optional request headers.
    Map<String, dynamic>? headers,

    /// Request body data.
    dynamic data,

    /// Query parameters for the request.
    Map<String, dynamic>? query,

    /// Key used to deduplicate jobs.
    String? idempotencyKey,

    /// Tags associated with the request.
    Set<String> tags = const {},

    /// Priority of the job; higher runs first.
    int priority = 0,

    /// Timeout for the request.
    Duration? timeout,

    /// Whether this job is the last request in a sequence.
    bool isLastRequest = false,
  }) {
    final job = QueueJob(
      id: _randomId(),
      method: method,
      url: url,
      headers: headers,
      body: data,
      query: query,
      idempotencyKey: idempotencyKey,
      tags: tags,
      priority: priority,
      timeout: timeout,
      isLastRequest: isLastRequest,
    );
    _scheduler.enqueue(job);
    return job.id;
  }

  String _randomId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
      (DateTime.now().microsecondsSinceEpoch % 1000).toString();
}
