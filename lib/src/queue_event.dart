import 'queue_job.dart';

/// Event emitted for job state changes.
class QueueEvent {
  final QueueJob job;
  QueueEvent(this.job);
  @override
  String toString() => 'QueueEvent(id: ${job.id}, state: ${job.state})';
}
