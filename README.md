# dio_queue

A lightweight request queue wrapper around the [Dio](https://pub.dev/packages/dio) HTTP client. The queue executes requests sequentially in the order they are added, helping to avoid rate limits and ensuring that only one request is active at a time.

## Features

- Serializes requests so only one runs at once.
- Works with any existing `Dio` instance.
- Returns the normal `Dio` `Response` objects.

## Getting started

Add the package and its dependency to your `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0
  dio_queue: ^0.0.1
```

Run `flutter pub get` to install the packages.

## Usage

```dart
import 'package:dio/dio.dart';
import 'package:dio_queue/dio_queue.dart';

final queue = DioQueue(Dio());

Future<void> makeRequests() async {
  final first = queue.enqueue((dio) => dio.get('/first'));
  final second = queue.enqueue((dio) => dio.get('/second'));

  final results = await Future.wait([first, second]);
  print(results.first.data);
}
```

## Additional information

The project is maintained on GitHub. Issues and pull requests are welcome. If you encounter a problem or have an improvement, please open an issue.
