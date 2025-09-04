/// Persistent queue storage backed by Hive.
import 'package:hive/hive.dart';

import 'queue_job.dart';
import 'queue_storage.dart';

/// Hive-based persistent storage.
class HiveQueueStorage implements QueueStorage {
  final String boxName;
  Box<Map>? _box;

  HiveQueueStorage({required this.boxName});

  @override
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
  Future<void> upsert(QueueJob job) async {
    await _ensureBox.put(job.id, job.toJson());
  }

  @override
  Future<QueueJob?> getById(String id) async {
    final map = _ensureBox.get(id);
    if (map == null) return null;
    return QueueJob.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  Future<List<QueueJob>> getAll({JobState? state}) async {
    return _ensureBox.values
        .map((m) => QueueJob.fromJson(Map<String, dynamic>.from(m)))
        .where((j) => state == null || j.state == state)
        .toList();
  }

  @override
  Future<void> delete(String id) async => _ensureBox.delete(id);

  @override
  Future<void> clear() async => _ensureBox.clear();
}
