# flutter_dio_queue

A lightweight request queue for Dio with retries, prioritisation and offline awareness.

```dart
final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
final queue = FlutterDioQueue(
  dio: dio,
  config: QueueConfig(
    maxConcurrent: 3,
    policy: QueuePolicy.fifo,
    retry: RetryPolicy(
      maxAttempts: 4,
      baseDelay: const Duration(milliseconds: 400),
      jitter: 0.25,
    ),
    rateLimit: RateLimit(10, const Duration(seconds: 1)),
    persist: true,
    deduplicate: true,
  ),
  storage: HiveQueueStorage(boxName: 'fdq_jobs'),
);

queue.enqueueRequest(method: 'POST', url: '/notes', data: {'title': 'Hello'});
queue.events.listen((e) {
  debugPrint('Queue: $e');
  if (e.response != null) {
    debugPrint('Response data: ${e.response!.data}');
  }
});
```

See `example/` for a runnable demo and `test/` for usage scenarios.
