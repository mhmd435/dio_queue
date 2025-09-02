/// Basic metrics exposed by the queue.
class QueueMetrics {
  final int queued;
  final int running;
  final int succeeded;
  final int failed;
  final int rateLimited;

  const QueueMetrics({
    this.queued = 0,
    this.running = 0,
    this.succeeded = 0,
    this.failed = 0,
    this.rateLimited = 0,
  });

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
