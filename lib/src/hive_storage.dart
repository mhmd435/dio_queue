import 'package:hive/hive.dart';

import 'queue_config.dart';
import 'queue_job.dart';
import 'queue_storage.dart';

/// Hive-based persistent storage.
class HiveQueueStorage implements QueueStorage {
  /// Name of the Hive box used for persistence.
  final String boxName;

  Box<Map>? _box;
  Future<void>? _init;

  /// Creates a Hive-based storage using [boxName].
  HiveQueueStorage({required this.boxName});

  @override
  /// Opens the Hive box.
  Future<void> init() {
    return _init ??= () async {
      try {
        _box = await Hive.openBox<Map>(boxName);
      } on NoSuchMethodError catch (_) {
        throw StateError(
          'Hive is not initialized. Call Hive.initFlutter() or Hive.init() before using HiveQueueStorage.',
        );
      }
    }();
  }

  Future<Box<Map>> _getBox() async {
    await init();
    final box = _box;
    if (box == null) {
      throw StateError('Storage not initialized');
    }
    return box;
  }

  @override
  /// Stores or replaces [job] in the box.
  Future<void> upsert(QueueJob job) async {
    final box = await _getBox();
    await box.put(job.id, job.toJson());
  }

  @override
  /// Retrieves a job by [id] or returns `null`.
  Future<QueueJob?> getById(String id) async {
    final box = await _getBox();
    final map = box.get(id);
    if (map == null) return null;
    return QueueJob.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  /// Returns all stored jobs, optionally filtered by [state].
  Future<List<QueueJob>> getAll({JobState? state}) async {
    final box = await _getBox();
    return box.values
        .map((m) => QueueJob.fromJson(Map<String, dynamic>.from(m)))
        .where((j) => state == null || j.state == state)
        .toList();
  }

  @override
  /// Deletes the job identified by [id].
  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  /// Clears all jobs from storage.
  Future<void> clear() async {
    final box = await _getBox();
    await box.clear();
  }
}
