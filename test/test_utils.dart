import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A very small HTTP adapter for tests.
class TestAdapter extends HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions) handler;
  TestAdapter(this.handler);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future? cancelFuture) {
    return handler(options);
  }
}
