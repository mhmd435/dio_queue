import 'package:dio/dio.dart';

/// Signature deciding whether a request should retry.
typedef ShouldRetry = bool Function(Response? response, DioException? error);

/// Scheduling policy when jobs have equal priority.
enum QueuePolicy { fifo, lifo }

/// State of a job in the queue.
enum JobState { enqueued, running, succeeded, failed, cancelled, paused }

bool _defaultShouldRetry(Response? res, DioException? err) {
  if (err != null) return true;
  final code = res?.statusCode;
  return code != null && code >= 500;
}

/// Configuration controlling retry behaviour.
class RetryPolicy {
  final int maxAttempts;
  final Duration baseDelay;
  final double jitter;
  final bool resetOnNetworkChange;
  final ShouldRetry shouldRetry;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.jitter = 0.2,
    this.resetOnNetworkChange = true,
    this.shouldRetry = _defaultShouldRetry,
  });
}

/// Simple rate limit model.
class RateLimit {
  final int requestsPerPeriod;
  final Duration period;
  const RateLimit(this.requestsPerPeriod, this.period);
}

/// Main configuration for the queue.
class QueueConfig {
  final int maxConcurrent;
  final QueuePolicy policy;
  final RetryPolicy retry;
  final RateLimit? rateLimit;
  final bool deduplicate;
  final bool persist;
  final Duration? jobTTL;

  const QueueConfig({
    this.maxConcurrent = 2,
    this.policy = QueuePolicy.fifo,
    this.retry = const RetryPolicy(),
    this.rateLimit,
    this.deduplicate = true,
    this.persist = false,
    this.jobTTL,
  });
}
