import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';
import 'package:hive_test/hive_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('hive storage waits for initialization before use', () async {
    final dio = Dio()
      ..httpClientAdapter = TestAdapter((req) async {
        return ResponseBody.fromString('ok', 200);
      });
    final storage = HiveQueueStorage(boxName: 'queue');
    final queue = FlutterDioQueue(dio: dio, storage: storage);

    final eventFuture =
        queue.events.firstWhere((e) => e.job.state == JobState.succeeded);
    queue.enqueueRequest(method: HttpMethod.get, url: '/');
    final event = await eventFuture;
    expect(event.job.state, JobState.succeeded);
  });

  test('init is idempotent', () async {
    final storage = HiveQueueStorage(boxName: 'queue');
    await Future.wait([storage.init(), storage.init(), storage.init()]);
    await storage.upsert(QueueJob(id: '1', method: HttpMethod.get, url: '/'));
    expect((await storage.getById('1'))?.id, '1');
  });
}
