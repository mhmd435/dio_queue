/// In-memory implementation of the queue storage interface.
import 'dart:async';

import 'queue_job.dart';
import 'queue_storage.dart';

/// In-memory storage used by default.
class MemoryQueueStorage implements QueueStorage {
  final Map<String, QueueJob> _jobs = {};

  @override
  /// No-op initialisation for in-memory storage.
  Future<void> init() async {}

  @override
  /// Stores or replaces [job] in memory.
  Future<void> upsert(QueueJob job) async {
    _jobs[job.id] = job;
  }

  @override
  /// Retrieves a job by [id].
  Future<QueueJob?> getById(String id) async => _jobs[id];

  @override
  /// Returns all jobs, optionally filtered by [state].
  Future<List<QueueJob>> getAll({JobState? state}) async {
    var values = _jobs.values.toList();
    if (state != null) {
      values = values.where((j) => j.state == state).toList();
    }
    return values;
  }

  @override
  /// Removes the job identified by [id].
  Future<void> delete(String id) async {
    _jobs.remove(id);
  }

  @override
  /// Clears all stored jobs.
  Future<void> clear() async => _jobs.clear();
}
