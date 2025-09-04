import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dio_queue/dio_queue.dart';

void main() {
  test('processes requests one at a time', () async {
    final adapter = _TrackingAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final queue = DioQueue(dio);

    final futures = [
      queue.enqueue((d) => d.get('/1')),
      queue.enqueue((d) => d.get('/2')),
      queue.enqueue((d) => d.get('/3')),
    ];

    await Future.wait(futures);
    expect(adapter.maxConcurrent, 1);
  });
}

class _TrackingAdapter extends HttpClientAdapter {
  int _current = 0;
  int maxConcurrent = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future? cancelFuture) async {
    _current++;
    maxConcurrent = max(maxConcurrent, _current);
    await Future.delayed(const Duration(milliseconds: 20));
    _current--;
    return ResponseBody.fromString('ok', 200);
  }

  @override
  void close({bool force = false}) {}
}
