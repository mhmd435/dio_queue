/// Convenience extensions for converting Dio requests into queue jobs.
import 'package:dio/dio.dart';

import 'queue_job.dart';
import 'http_method.dart';

/// Extension helpers on Dio's [RequestOptions].
extension RequestOptionsQueue on RequestOptions {
  /// Creates a [QueueJob] from these options.
  ///
  /// [id] uniquely identifies the job in storage. [priority] and [tags] control
  /// scheduling order and allow later cancellation. [idempotencyKey] and
  /// [timeout] configure the job's fingerprint and request timeout.
  QueueJob toQueueJob({
    /// Identifier to use for the created job.
    required String id,

    /// Higher values are scheduled before lower ones.
    int priority = 0,

    /// Tags attached to the job for bulk operations.
    Set<String> tags = const {},

    /// Optional value used to deduplicate jobs.
    String? idempotencyKey,

    /// How long the request is allowed to run.
    Duration? timeout,
  }) {
    return QueueJob(
      id: id,
      method: HttpMethodX.fromString(method),
      url: path,
      headers: headers.map((k, v) => MapEntry(k, v)),
      body: data,
      query: queryParameters,
      idempotencyKey: idempotencyKey,
      tags: tags,
      priority: priority,
      timeout: timeout,
    );
  }
}
