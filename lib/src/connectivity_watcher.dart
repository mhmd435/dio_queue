import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Wrapper around [Connectivity] to expose online/offline events.
class ConnectivityWatcher {
  final Connectivity _conn;
  final StreamController<bool> _controller = StreamController.broadcast();

  ConnectivityWatcher({Connectivity? connectivity}) : _conn = connectivity ?? Connectivity() {
    _conn.onConnectivityChanged.listen((result) {
      _controller.add(result != ConnectivityResult.none);
    });
  }

  /// Emits `true` when online, `false` when offline.
  Stream<bool> get onStatus async* {
    final initial = await _conn.checkConnectivity();
    yield initial != ConnectivityResult.none;
    yield* _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
