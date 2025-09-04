import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';

void main() {
  test('backoff grows', () {
    final policy = RetryPolicy(baseDelay: const Duration(milliseconds: 10), jitter: 0);
    final d1 = computeBackoff(policy, 1);
    final d2 = computeBackoff(policy, 2);
    expect(d1.inMilliseconds, 10);
    expect(d2.inMilliseconds, 20);
  });

  test('jitter range', () {
    final policy = RetryPolicy(baseDelay: const Duration(milliseconds: 100), jitter: 0.5);
    final d = computeBackoff(policy, 1);
    expect(d.inMilliseconds >= 50 && d.inMilliseconds <= 150, true);
  });
}
