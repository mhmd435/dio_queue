/// Monitors network connectivity changes and exposes an online/offline stream.
library connectivity_watcher;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Wrapper around [Connectivity] to expose online/offline events.
class ConnectivityWatcher {
  final Connectivity _conn;
  final StreamController<bool> _controller = StreamController.broadcast();

  /// Creates a watcher that emits online/offline events using [connectivity].
  ///
  /// When [connectivity] is not provided a default [Connectivity] instance is
  /// used.
  ConnectivityWatcher({Connectivity? connectivity})
      : _conn = connectivity ?? Connectivity() {
    _conn.onConnectivityChanged.listen((result) {
      _controller.add(result != ConnectivityResult.none);
    });
  }

  /// Stream of connectivity status where `true` indicates online.
  Stream<bool> get onStatus async* {
    final initial = await _conn.checkConnectivity();
    yield initial != ConnectivityResult.none;
    yield* _controller.stream;
  }

  /// Disposes resources held by this watcher.
  void dispose() {
    _controller.close();
  }
}
