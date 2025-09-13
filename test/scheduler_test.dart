import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';

import 'test_utils.dart';

void main() {
  test('respects priority', () async {
    final dio = Dio()
      ..httpClientAdapter = TestAdapter((req) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return ResponseBody.fromString(req.path, 200);
      });
    final queue = FlutterDioQueue(dio: dio, config: const QueueConfig(maxConcurrent: 1));
    final completed = <String>[];
    queue.events
        .where((e) => e.job.state == JobState.succeeded)
        .listen((e) => completed.add(e.job.url));
    queue.enqueueRequest(method: HttpMethod.get, url: 'a', priority: 0);
    queue.enqueueRequest(method: HttpMethod.get, url: 'b', priority: 5);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(completed, ['b', 'a']);
  });

  test('max concurrent', () async {
    final dio = Dio()
      ..httpClientAdapter = TestAdapter((req) async {
        await Future.delayed(const Duration(milliseconds: 30));
        return ResponseBody.fromString(req.path, 200);
      });
    final queue = FlutterDioQueue(dio: dio, config: const QueueConfig(maxConcurrent: 2));
    var running = 0;
    var max = 0;
    queue.events.listen((e) {
      if (e.job.state == JobState.running) {
        running++;
        if (running > max) max = running;
      } else if (e.job.state == JobState.succeeded) {
        running--;
      }
    });
    queue.enqueueRequest(method: HttpMethod.get, url: '1');
    queue.enqueueRequest(method: HttpMethod.get, url: '2');
    queue.enqueueRequest(method: HttpMethod.get, url: '3');
    await Future.delayed(const Duration(milliseconds: 200));
    expect(max, lessThanOrEqualTo(2));
  });

  test('auto start disabled processes in LIFO order after start', () async {
    final dio = Dio()
      ..httpClientAdapter = TestAdapter((req) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return ResponseBody.fromString(req.path, 200);
      });
    final queue = FlutterDioQueue(
      dio: dio,
      config: const QueueConfig(
        maxConcurrent: 1,
        policy: QueuePolicy.lifo,
        autoStart: false,
      ),
    );
    final completed = <String>[];
    queue.events
        .where((e) => e.job.state == JobState.succeeded)
        .listen((e) => completed.add(e.job.url));
    queue.enqueueRequest(method: HttpMethod.get, url: 'a');
    queue.enqueueRequest(method: HttpMethod.get, url: 'b');
    // Nothing should run until start is invoked.
    await Future.delayed(const Duration(milliseconds: 50));
    expect(completed, isEmpty);
    queue.start();
    await queue.drain();
    expect(completed, ['b', 'a']);
  });
}
