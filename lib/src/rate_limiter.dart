import 'dart:async';
import 'dart:math';

import 'queue_config.dart';

/// Simple token bucket rate limiter.
class RateLimiter {
  final RateLimit? limit;
  int _tokens = 0;
  DateTime _lastRefill = DateTime.now();

  RateLimiter(this.limit) {
    _tokens = limit?.requestsPerPeriod ?? 0;
  }

  Future<void> take() async {
    final l = limit;
    if (l == null) return;
    while (true) {
      _refill();
      if (_tokens > 0) {
        _tokens--;
        return;
      }
      final until = _lastRefill.add(l.period);
      final wait = until.difference(DateTime.now());
      await Future.delayed(wait > Duration.zero ? wait : l.period);
    }
  }

  void _refill() {
    final l = limit;
    if (l == null) return;
    final now = DateTime.now();
    if (now.difference(_lastRefill) >= l.period) {
      final periods =
          now.difference(_lastRefill).inMilliseconds ~/ l.period.inMilliseconds;
      _tokens = min(l.requestsPerPeriod, _tokens + periods * l.requestsPerPeriod);
      _lastRefill = _lastRefill.add(l.period * periods);
    }
  }
}
