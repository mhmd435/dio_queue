import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';

import 'test_utils.dart';

void main() {
  test('retries on failure', () async {
    var attempts = 0;
    final dio = Dio()
      ..httpClientAdapter = TestAdapter((req) async {
        attempts++;
        if (attempts < 2) {
          throw DioException(requestOptions: req, type: DioExceptionType.connectionError, error: 'fail');
        }
        return ResponseBody.fromString('ok', 200);
      });
    final queue = FlutterDioQueue(
      dio: dio,
      config: QueueConfig(retry: RetryPolicy(maxAttempts: 3, baseDelay: const Duration(milliseconds: 10), jitter: 0)),
    );
    final future = queue.events.firstWhere((e) => e.job.state == JobState.succeeded);
    queue.enqueueRequest(method: 'GET', url: '/');
    final event = await future;
    expect(event.job.attempts, 2);
    expect(attempts, 2);
  });
}
