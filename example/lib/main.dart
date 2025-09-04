import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterDioQueue queue;
  final events = <String>[];
  int enqueued = 0;

  @override
  void initState() {
    super.initState();
    final dio = Dio(BaseOptions(baseUrl: 'https://httpbin.org'));
    queue = FlutterDioQueue(dio: dio);
    queue.events.listen((e) {
      setState(() {
        events.add(e.toString());
      });
    });
  }

  void _enqueue() {
    queue.enqueueRequest(method: 'GET', url: '/delay/1', priority: enqueued++);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_dio_queue example')),
        body: Column(
          children: [
            ElevatedButton(onPressed: _enqueue, child: const Text('Enqueue')),
            Expanded(
              child: ListView(children: events.map(Text.new).toList()),
            )
          ],
        ),
      ),
    );
  }
}
