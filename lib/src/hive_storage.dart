/// Persistent queue storage backed by Hive.
import 'package:hive/hive.dart';

import 'queue_config.dart';
import 'queue_job.dart';
import 'queue_storage.dart';

/// Hive-based persistent storage.
class HiveQueueStorage implements QueueStorage {
  /// Name of the Hive box used for persistence.
  final String boxName;

  Box<Map>? _box;

  /// Creates a Hive-based storage using [boxName].
  HiveQueueStorage({required this.boxName});

  @override
  /// Opens the Hive box.
  Future<void> init() async {
    _box = await Hive.openBox<Map>(boxName);
  }

  Box<Map> get _ensureBox {
    final box = _box;
    if (box == null) {
      throw StateError('Storage not initialized');
    }
    return box;
    }

  @override
  /// Stores or replaces [job] in the box.
  Future<void> upsert(QueueJob job) async {
    await _ensureBox.put(job.id, job.toJson());
  }

  @override
  /// Retrieves a job by [id] or returns `null`.
  Future<QueueJob?> getById(String id) async {
    final map = _ensureBox.get(id);
    if (map == null) return null;
    return QueueJob.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  /// Returns all stored jobs, optionally filtered by [state].
  Future<List<QueueJob>> getAll({JobState? state}) async {
    return _ensureBox.values
        .map((m) => QueueJob.fromJson(Map<String, dynamic>.from(m)))
        .where((j) => state == null || j.state == state)
        .toList();
  }

  @override
  /// Deletes the job identified by [id].
  Future<void> delete(String id) async => _ensureBox.delete(id);

  @override
  /// Clears all jobs from storage.
  Future<void> clear() async => _ensureBox.clear();
}
