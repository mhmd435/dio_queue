/// In-memory implementation of the queue storage interface.
import 'dart:async';

import 'queue_config.dart';
import 'queue_job.dart';
import 'queue_storage.dart';

/// In-memory storage used by default.
class MemoryQueueStorage implements QueueStorage {
  final Map<String, QueueJob> _jobs = {};
  Future<void>? _init;

  @override
  /// No-op initialisation for in-memory storage.
  Future<void> init() {
    return _init ??= Future.value();
  }

  @override
  /// Stores or replaces [job] in memory.
  Future<void> upsert(QueueJob job) async {
    await init();
    _jobs[job.id] = job;
  }

  @override
  /// Retrieves a job by [id].
  Future<QueueJob?> getById(String id) async {
    await init();
    return _jobs[id];
  }

  @override
  /// Returns all jobs, optionally filtered by [state].
  Future<List<QueueJob>> getAll({JobState? state}) async {
    await init();
    var values = _jobs.values.toList();
    if (state != null) {
      values = values.where((j) => j.state == state).toList();
    }
    return values;
  }

  @override
  /// Removes the job identified by [id].
  Future<void> delete(String id) async {
    await init();
    _jobs.remove(id);
  }

  @override
  /// Clears all stored jobs.
  Future<void> clear() async {
    await init();
    _jobs.clear();
  }
}
