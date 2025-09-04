/// Interface describing storage for persisted queue jobs.
import 'queue_job.dart';

/// Storage backend for persisting jobs.
abstract class QueueStorage {
  Future<void> init();
  Future<void> upsert(QueueJob job);
  Future<QueueJob?> getById(String id);
  Future<List<QueueJob>> getAll({JobState? state});
  Future<void> delete(String id);
  Future<void> clear();
}
