import 'package:dio/dio.dart';

import 'queue_job.dart';

extension RequestOptionsQueue on RequestOptions {
  /// Creates a [QueueJob] from these options.
  QueueJob toQueueJob({
    required String id,
    int priority = 0,
    Set<String> tags = const {},
    String? idempotencyKey,
    Duration? timeout,
  }) {
    return QueueJob(
      id: id,
      method: method,
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
