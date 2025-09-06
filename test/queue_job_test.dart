import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';

void main() {
  test('isLastRequest serialises and deserialises correctly', () {
    final job = QueueJob(
      id: '1',
      method: HttpMethod.get,
      url: '/',
      isLastRequest: true,
    );
    final json = job.toJson();
    expect(json['isLastRequest'], isTrue);
    final restored = QueueJob.fromJson(json);
    expect(restored.isLastRequest, isTrue);
  });
}
