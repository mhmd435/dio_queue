/// Interface describing storage for persisted queue jobs.
library;

import 'queue_config.dart';
import 'queue_job.dart';

/// Storage backend for persisting jobs.
abstract class QueueStorage {
  /// Initialises the storage backend.
  Future<void> init();

  /// Inserts or updates the given [job].
  Future<void> upsert(QueueJob job);

  /// Retrieves a job by [id] or returns `null` if not found.
  Future<QueueJob?> getById(String id);

  /// Returns all stored jobs, optionally filtered by [state].
  Future<List<QueueJob>> getAll({JobState? state});

  /// Removes the job with the given [id].
  Future<void> delete(String id);

  /// Clears all persisted jobs.
  Future<void> clear();
}
