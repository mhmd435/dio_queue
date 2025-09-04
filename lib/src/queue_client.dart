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
  final QueueStorage storage;

  FlutterDioQueue({
    required Dio dio,
    QueueStorage? storage,
    QueueConfig config = const QueueConfig(),
    ConnectivityWatcher? connectivity,
    QueueLogger? logger,
  })  : storage = storage ?? MemoryQueueStorage(),
        _scheduler = Scheduler(
          dio: dio,
          storage: storage ?? MemoryQueueStorage(),
          config: config,
          connectivity: connectivity,
          logger: logger,
        ) {
    this.storage.init();
  }

  /// Stream of job state change events.
  Stream<QueueEvent> get events => _scheduler.events;

  /// Stream of metrics about the queue.
  Stream<QueueMetrics> get metrics => _scheduler.metrics;

  /// Enqueues a prepared [QueueJob].
  Future<String> enqueue(QueueJob job) => _scheduler.enqueue(job);

  /// Cancels a job by id.
  Future<void> cancel(String jobId) => _scheduler.cancel(jobId);

  /// Cancels jobs tagged with [tag].
  Future<void> cancelByTag(String tag) => _scheduler.cancelByTag(tag);

  /// Pauses scheduling; running jobs continue.
  void pause() => _scheduler.pause();

  /// Resumes scheduling.
  void resume() => _scheduler.resume();

  /// Convenience builder to enqueue a request without manual [QueueJob].
  String enqueueRequest({
    required HttpMethod method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic data,
    Map<String, dynamic>? query,
    String? idempotencyKey,
    Set<String> tags = const {},
    int priority = 0,
    Duration? timeout,
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
    );
    _scheduler.enqueue(job);
    return job.id;
  }

  String _randomId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
      (DateTime.now().microsecondsSinceEpoch % 1000).toString();
}
