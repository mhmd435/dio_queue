# flutter_dio_queue example

This Flutter application demonstrates how to use the
[`flutter_dio_queue`](https://pub.dev/packages/flutter_dio_queue) package.
It shows how to configure the queue, enqueue requests and intercept Dio calls
so that they are processed through the queue.

## Running

From the repository root:

```bash
cd example
flutter pub get
flutter run
```

## Highlights

* Configure the queue with retry, rate limiting and custom concurrency.
* Listen to queue events to display progress.
* Use `QueueInterceptor` to divert standard Dio requests into the queue.
* Pause and resume processing.

See [`lib/main.dart`](lib/main.dart) for the complete code.
