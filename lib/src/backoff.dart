/// Utilities for computing retry backoff delays.
library;

import 'dart:math';

import 'queue_config.dart';

final _rand = Random();

/// Calculates an exponential backoff delay for a retry [attempt].
///
/// The [policy] determines the base delay and jitter to apply. The [attempt]
/// value is 1-indexed and represents how many times the job has been retried
/// so far.
Duration computeBackoff(RetryPolicy policy, int attempt) {
  var delay = policy.baseDelay * (1 << (attempt - 1));
  final jitter = delay.inMilliseconds * policy.jitter;
  final delta = _rand.nextDouble() * jitter * 2 - jitter;
  final ms = max(0, delay.inMilliseconds + delta.round());
  return Duration(milliseconds: ms);
}
