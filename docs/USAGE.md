# File Uploads

The queue works with Dio's `FormData` to support multipart file uploads on
Android, iOS and Web. Construct a `FormData` instance and pass it directly to
`enqueueRequest` without JSON encoding.

```dart
final queue = FlutterDioQueue(dio: Dio());

final file = File('path/to/pic.jpg');
final form = FormData.fromMap({
  'file': await MultipartFile.fromFile(file.path, filename: 'pic.jpg'),
});

queue.enqueueRequest(
  method: HttpMethod.post,
  url: '/upload',
  data: form,
);
```

For Web or in-memory data, use `MultipartFile.fromBytes`:

```dart
final form = FormData.fromMap({
  'file': MultipartFile.fromBytes(bytes, filename: 'pic.jpg'),
});
```

The queue sets `multipart/form-data` automatically when a `FormData` body is
detected. If the referenced file does not exist, `MultipartFile.fromFile` will
throw a `FileSystemException`.

