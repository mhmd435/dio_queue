import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';

import 'test_utils.dart';

void main() {
  test('enqueue and complete', () async {
    final dio = Dio()
      ..httpClientAdapter = TestAdapter((req) async {
        return ResponseBody.fromString('ok', 200);
      });
    final queue = FlutterDioQueue(dio: dio);
    final future = queue.events.firstWhere((e) => e.job.state == JobState.succeeded);
    queue.enqueueRequest(method: HttpMethod.get, url: '/');
    final event = await future;
    expect(event.job.state, JobState.succeeded);
  });
}
