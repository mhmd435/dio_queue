# flutter_dio_queue

A lightweight yet robust request queue built on top of Dio. It provides
automatic retries with backoff, prioritisation, rate limiting and offline
awareness. Jobs can be persisted to disk and restored on the next app launch.

## Features

- Queue and prioritise requests made with Dio
- Automatic retry with exponential backoff and jitter
- Optional rate limiting using a token bucket
- Offline detection with automatic pause/resume
- In-memory or persistent Hive based storage
- Simple metrics and event stream for monitoring

## Installation

Add `flutter_dio_queue` to your `pubspec.yaml`. If you plan to use the
persistent `HiveQueueStorage`, include `hive_flutter` and initialize Hive with
`Hive.initFlutter()`:

```yaml
dependencies:
  flutter_dio_queue: ^0.1.3
  hive_flutter: ^1.1.0 # required for HiveQueueStorage
```

Then import the packages:

```dart
import 'package:flutter_dio_queue/flutter_dio_queue.dart';
import 'package:hive_flutter/hive_flutter.dart';
```

## Usage

Create a `FlutterDioQueue` and enqueue requests. Jobs will be executed according
to the supplied configuration. When using the persistent `HiveQueueStorage`,
ensure Hive is initialized before constructing the queue:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  await Hive.initFlutter();
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  final queue = FlutterDioQueue(
    dio: dio,
    config: QueueConfig(
      maxConcurrent: 3,
      policy: QueuePolicy.fifo,
      autoStart: true,
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

  final jobId = queue.enqueueRequest(
    method: HttpMethod.post,
    url: '/notes',
    data: {'title': 'Hello'},
  );

  queue.events.listen((e) {
    debugPrint('Queue: $e');
    if (e.response != null) {
      debugPrint('Response data: ${e.response!.data}');
    }
  });

  // When `autoStart` is set to `false`, explicitly start processing:
  // queue.start();

  // You can also pause/resume or wait for completion with:
  // queue.pause();
  // queue.resume();
  // await queue.drain();
}
```

## Interceptor

You can divert selected Dio requests into the queue using the provided
`QueueInterceptor`. When added, requests containing the `x-queue: true` header
will be enqueued instead of executed immediately.

```dart
dio.interceptors.add(QueueInterceptor(queue));
```

## Example

See the [`example/`](example) directory for a complete runnable demo and the
`test/` folder for additional usage scenarios.
