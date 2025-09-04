import 'dart:async';

import 'queue_job.dart';
import 'queue_storage.dart';

/// In-memory storage used by default.
class MemoryQueueStorage implements QueueStorage {
  final Map<String, QueueJob> _jobs = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> upsert(QueueJob job) async {
    _jobs[job.id] = job;
  }

  @override
  Future<QueueJob?> getById(String id) async => _jobs[id];

  @override
  Future<List<QueueJob>> getAll({JobState? state}) async {
    var values = _jobs.values.toList();
    if (state != null) {
      values = values.where((j) => j.state == state).toList();
    }
    return values;
  }

  @override
  Future<void> delete(String id) async {
    _jobs.remove(id);
  }

  @override
  Future<void> clear() async => _jobs.clear();
}
