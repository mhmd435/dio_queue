import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';

void main() {
  test('toJson omits FormData bodies', () {
    final job = QueueJob(
      id: '1',
      method: HttpMethod.post,
      url: '/upload',
      body: FormData.fromMap({'key': 'value'}),
    );
    final json = job.toJson();
    expect(json['body'], isNull);
  });
}
