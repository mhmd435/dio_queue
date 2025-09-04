import 'dart:math';

import 'queue_config.dart';

final _rand = Random();

/// Calculates exponential backoff with optional jitter.
Duration computeBackoff(RetryPolicy policy, int attempt) {
  var delay = policy.baseDelay * (1 << (attempt - 1));
  final jitter = delay.inMilliseconds * policy.jitter;
  final delta = _rand.nextDouble() * jitter * 2 - jitter;
  final ms = max(0, delay.inMilliseconds + delta.round());
  return Duration(milliseconds: ms);
}
