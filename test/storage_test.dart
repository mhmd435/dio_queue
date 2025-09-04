import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';

void main() {
  test('memory storage basics', () async {
    final storage = MemoryQueueStorage();
    await storage.init();
    final job = QueueJob(id: '1', method: 'GET', url: '/');
    await storage.upsert(job);
    expect((await storage.getById('1'))?.id, '1');
    await storage.delete('1');
    expect(await storage.getAll(), isEmpty);
  });
}
