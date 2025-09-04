/// Basic metrics exposed by the queue.
class QueueMetrics {
  /// Number of jobs currently queued.
  final int queued;

  /// Number of jobs currently executing.
  final int running;

  /// Number of jobs that have succeeded.
  final int succeeded;

  /// Number of jobs that have failed permanently.
  final int failed;

  /// Number of jobs delayed due to rate limiting.
  final int rateLimited;

  /// Creates a new metrics snapshot.
  const QueueMetrics({
    this.queued = 0,
    this.running = 0,
    this.succeeded = 0,
    this.failed = 0,
    this.rateLimited = 0,
  });

  /// Returns a copy with the provided fields updated.
  QueueMetrics copyWith({
    int? queued,
    int? running,
    int? succeeded,
    int? failed,
    int? rateLimited,
  }) =>
      QueueMetrics(
        queued: queued ?? this.queued,
        running: running ?? this.running,
        succeeded: succeeded ?? this.succeeded,
        failed: failed ?? this.failed,
        rateLimited: rateLimited ?? this.rateLimited,
      );

  @override
  String toString() =>
      'QueueMetrics(queued: $queued, running: $running, succeeded: $succeeded, failed: $failed, rateLimited: $rateLimited)';
}
