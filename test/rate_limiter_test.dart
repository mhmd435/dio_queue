import 'package:flutter_dio_queue/src/rate_limiter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';

void main() {
  test('enforces limit', () async {
    final rl = RateLimiter(const RateLimit(1, Duration(milliseconds: 50)));
    final sw = Stopwatch()..start();
    await rl.take();
    await rl.take();
    final elapsed = sw.elapsedMilliseconds;
    expect(elapsed >= 50, true);
  });
}
