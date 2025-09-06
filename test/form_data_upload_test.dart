import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';
import 'package:hive_test/hive_test.dart';

import 'test_utils.dart';

void main() {
  test('uploads file from disk', () async {
    final temp = await File('${Directory.systemTemp.path}/upload.txt').create();
    await temp.writeAsString('hello');

    late RequestOptions captured;
    final dio = Dio()
      ..httpClientAdapter = TestAdapter((req) async {
        captured = req;
        return ResponseBody.fromString('ok', 200);
      });

    final queue = FlutterDioQueue(dio: dio);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(temp.path, filename: 'upload.txt'),
    });

    final future = queue.events.firstWhere((e) => e.job.state == JobState.succeeded);
    queue.enqueueRequest(method: HttpMethod.post, url: '/upload', data: formData);
    final event = await future;

    expect(event.response?.statusCode, 200);
    expect(captured.data, isA<FormData>());
    expect(captured.contentType, contains('multipart/form-data'));

    await temp.delete();
  });

  test('uploads bytes from memory', () async {
    late RequestOptions captured;
    final dio = Dio()
      ..httpClientAdapter = TestAdapter((req) async {
        captured = req;
        return ResponseBody.fromString('ok', 200);
      });

    final queue = FlutterDioQueue(dio: dio);
    final bytes = utf8.encode('hi');
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: 'bytes.txt'),
    });

    final future = queue.events.firstWhere((e) => e.job.state == JobState.succeeded);
    queue.enqueueRequest(method: HttpMethod.post, url: '/upload', data: formData);
    final event = await future;

    expect(event.response?.statusCode, 200);
    expect(captured.data, isA<FormData>());
    expect(captured.contentType, contains('multipart/form-data'));
  });

  test('throws when file is missing', () async {
    await expectLater(
      () async => MultipartFile.fromFile('does_not_exist.txt'),
      throwsA(isA<FileSystemException>()),
    );
  });

  test('does not persist FormData bodies', () async {
    await setUpTestHive();

    late RequestOptions captured;
    final dio = Dio()
      ..httpClientAdapter = TestAdapter((req) async {
        captured = req;
        return ResponseBody.fromString('ok', 200);
      });

    final storage = HiveQueueStorage(boxName: 'jobs');
    final queue = FlutterDioQueue(
      dio: dio,
      storage: storage,
      config: const QueueConfig(persist: true),
    );
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(utf8.encode('hi'), filename: 'hi.txt'),
    });

    final future =
        queue.events.firstWhere((e) => e.job.state == JobState.succeeded);
    queue.enqueueRequest(method: HttpMethod.post, url: '/upload', data: formData);
    final event = await future;

    expect(event.response?.statusCode, 200);
    expect(captured.data, isA<FormData>());
    expect(await storage.getAll(), isEmpty);
  });
}

