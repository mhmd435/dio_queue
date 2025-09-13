/// Shared configuration models for the queue and retry behaviour.
import 'package:dio/dio.dart';

/// Signature deciding whether a request should retry.
typedef ShouldRetry = bool Function(Response? response, DioException? error);

/// Scheduling policy when jobs have equal priority.
enum QueuePolicy { fifo, lifo }

/// State of a job in the queue.
enum JobState { enqueued, running, succeeded, failed, cancelled, paused }

/// Default [ShouldRetry] implementation used when none is provided.
bool _defaultShouldRetry(Response? res, DioException? err) {
  if (err != null) return true;
  final code = res?.statusCode;
  return code != null && code >= 500;
}

/// Configuration controlling retry behaviour.
class RetryPolicy {
  /// Maximum number of attempts before giving up.
  final int maxAttempts;

  /// Base delay before retrying. Each attempt doubles this value.
  final Duration baseDelay;

  /// Random jitter factor applied to the delay to avoid thundering herd.
  final double jitter;

  /// Whether attempts should reset when network connectivity changes.
  final bool resetOnNetworkChange;

  /// Callback to determine if a given response or error should be retried.
  final ShouldRetry shouldRetry;

  /// Creates a new [RetryPolicy].
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
  /// Maximum number of requests allowed per [period].
  final int requestsPerPeriod;

  /// Window of time used for the rate limit.
  final Duration period;

  /// Creates a new [RateLimit] that allows [requestsPerPeriod] every [period].
  const RateLimit(this.requestsPerPeriod, this.period);
}

/// Main configuration for the queue.
class QueueConfig {
  /// Maximum number of jobs to run in parallel.
  final int maxConcurrent;

  /// How jobs with equal priority should be scheduled.
  final QueuePolicy policy;

  /// Retry behaviour to apply to failed jobs.
  final RetryPolicy retry;

  /// Optional rate limit to throttle outgoing requests.
  final RateLimit? rateLimit;

  /// Whether jobs with identical fingerprints should be deduplicated.
  final bool deduplicate;

  /// Whether jobs should be persisted across restarts.
  final bool persist;

  /// Optional time-to-live for completed jobs.
  final Duration? jobTTL;

  /// Whether the queue should begin processing immediately when jobs
  /// are enqueued.
  ///
  /// When `false`, jobs will remain in the pending state until
  /// [FlutterDioQueue.start] is called.
  final bool autoStart;

  /// Creates a new [QueueConfig] with optional overrides.
  const QueueConfig({
    this.maxConcurrent = 1,
    this.policy = QueuePolicy.fifo,
    this.retry = const RetryPolicy(),
    this.rateLimit,
    this.deduplicate = true,
    this.persist = false,
    this.jobTTL,
    this.autoStart = true,
  });
}
