/// Core scheduler responsible for executing queued jobs.
import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import 'backoff.dart';
import 'connectivity_watcher.dart';
import 'logger.dart';
import 'metrics.dart';
import 'queue_config.dart';
import 'queue_event.dart';
import 'queue_job.dart';
import 'queue_storage.dart';
import 'rate_limiter.dart';
import 'http_method.dart';

class Scheduler {
  final Dio dio;
  final QueueStorage storage;
  final QueueConfig config;
  final QueueLogger logger;
  final ConnectivityWatcher? connectivity;

  final RateLimiter _rateLimiter;
  final StreamController<QueueEvent> _events = StreamController.broadcast();
  final StreamController<QueueMetrics> _metrics = StreamController.broadcast();

  final List<QueueJob> _queue = [];
  final Map<String, CancelToken> _running = {};
  final Map<String, String> _fingerprints = {};

  bool _paused = false;
  bool _online = true;

  Scheduler({
    required this.dio,
    required this.storage,
    required this.config,
    QueueLogger? logger,
    this.connectivity,
  })  : logger = logger ?? ConsoleQueueLogger(),
        _rateLimiter = RateLimiter(config.rateLimit) {
    connectivity?.onStatus.listen((online) {
      _online = online;
      if (online && config.retry.resetOnNetworkChange) {
        for (final job in _queue) {
          job.attempts = 0;
        }
      }
      _trySchedule();
    });
  }

  Stream<QueueEvent> get events => _events.stream;
  Stream<QueueMetrics> get metrics => _metrics.stream;

  Future<String> enqueue(QueueJob job) async {
    if (config.deduplicate) {
      final existing = _fingerprints[job.fingerprint];
      if (existing != null) return existing;
    }
    _queue.add(job);
    _fingerprints[job.fingerprint] = job.id;
    await storage.upsert(job);
    _emitEvent(job);
    _updateMetrics();
    _trySchedule();
    return job.id;
  }

  Future<void> cancel(String id) async {
    final token = _running.remove(id);
    token?.cancel();
    final idx = _queue.indexWhere((j) => j.id == id);
    QueueJob? job;
    if (idx != -1) {
      job = _queue.removeAt(idx);
    }
    if (job != null) {
      job.state = JobState.cancelled;
      await storage.delete(id);
      _emitEvent(job);
    }
    _updateMetrics();
  }

  Future<void> cancelByTag(String tag) async {
    final ids = _queue.where((j) => j.tags.contains(tag)).map((j) => j.id).toList();
    for (final id in ids) {
      await cancel(id);
    }
  }

  void pause() {
    _paused = true;
  }

  void resume() {
    _paused = false;
    _trySchedule();
  }

  void _trySchedule() {
    if (_paused || !_online) return;
    _queue.sort((a, b) {
      final p = b.priority.compareTo(a.priority);
      if (p != 0) return p;
      return config.policy == QueuePolicy.fifo
          ? a.enqueuedAt.compareTo(b.enqueuedAt)
          : b.enqueuedAt.compareTo(a.enqueuedAt);
    });
    while (_running.length < config.maxConcurrent && _queue.isNotEmpty) {
      final job = _queue.removeAt(0);
      _run(job);
    }
    _updateMetrics();
  }

  Future<void> _run(QueueJob job) async {
    final token = CancelToken();
    _running[job.id] = token;
    job.state = JobState.running;
    job.startedAt = DateTime.now();
    _emitEvent(job);
    _updateMetrics();

    Response? response;
    while (true) {
      await _rateLimiter.take();
      try {
        final opts = Options(method: job.method.value, headers: job.headers);
        final res = await dio.request(
          job.url,
          data: job.body,
          queryParameters: job.query,
          options: opts,
          cancelToken: token,
        );
        job.attempts++;
        response = res;
        if (config.retry.shouldRetry(res, null) &&
            job.attempts < config.retry.maxAttempts) {
          final delay = computeBackoff(config.retry, job.attempts);
          logger.log('Retrying ${job.id} in ${delay.inMilliseconds}ms');
          await Future.delayed(delay);
          continue;
        }
        job.state = JobState.succeeded;
        job.finishedAt = DateTime.now();
        await storage.delete(job.id);
        break;
      } on DioException catch (e) {
        job.attempts++;
        job.lastError = e;
        response = e.response;
        if (config.retry.shouldRetry(e.response, e) &&
            job.attempts < config.retry.maxAttempts) {
          final delay = computeBackoff(config.retry, job.attempts);
          logger.log('Retrying ${job.id} after error in ${delay.inMilliseconds}ms');
          await Future.delayed(delay);
          continue;
        }
        job.state = JobState.failed;
        job.finishedAt = DateTime.now();
        await storage.delete(job.id);
        break;
      }
    }
    _running.remove(job.id);
    _fingerprints.remove(job.fingerprint);
    _emitEvent(job, response);
    _updateMetrics();
    _trySchedule();
  }

  void _emitEvent(QueueJob job, [Response? response]) {
    _events.add(QueueEvent(job, response));
  }

  void _updateMetrics() {
    _metrics.add(
      QueueMetrics(
        queued: _queue.length,
        running: _running.length,
      ),
    );
  }
}
