/// Events describing changes to queue job state.
import 'package:dio/dio.dart';

import 'queue_job.dart';

/// Event emitted for job state changes.
class QueueEvent {
  /// The job whose state changed.
  final QueueJob job;

  /// The Dio [Response] associated with the job, if available.
  ///
  /// This is populated when a request completes (either successfully or
  /// with an error response). It will be `null` for other state changes
  /// such as when a job is enqueued or starts running.
  final Response? response;

  /// Creates an event for [job] optionally carrying a [response].
  QueueEvent(this.job, [this.response]);

  @override
  String toString() => 'QueueEvent(id: ${job.id}, state: ${job.state})';
}
