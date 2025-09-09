import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dio_queue/flutter_dio_queue.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  late Dio dio;
  late FlutterDioQueue queue;
  final events = <String>[];
  int priority = 0;

  @override
  void initState() {
    super.initState();
    
    dio = Dio(BaseOptions(baseUrl: 'https://httpbin.org'));
    queue = FlutterDioQueue(
      dio: dio,
      storage: HiveQueueStorage(boxName: 'fdq_jobs'),
      config: QueueConfig(
        maxConcurrent: 2,
        autoStart: true,
        retry: RetryPolicy(maxAttempts: 3),
        rateLimit: RateLimit(5, const Duration(seconds: 1)),
        persist: false,
      ),
    );
    // Divert requests that include the `x-queue: true` header into the queue.
    dio.interceptors.add(QueueInterceptor(queue));
    queue.events.listen((e) {
      setState(() {
        events.add(e.toString());
      });
    });
  }

  void _enqueueDirect() {
    queue.enqueueRequest(
      method: HttpMethod.get,
      url: '/delay/1',
      priority: priority++,
    );
  }

  void _enqueueViaInterceptor() {
    dio.get('/delay/1', options: Options(headers: {'x-queue': true}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_dio_queue Example')),
        body: Column(
          children: [
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _enqueueDirect,
                  child: const Text('Enqueue'),
                ),
                ElevatedButton(
                  onPressed: _enqueueViaInterceptor,
                  child: const Text('Via interceptor'),
                ),
                ElevatedButton(
                  onPressed: queue.pause,
                  child: const Text('Pause'),
                ),
                ElevatedButton(
                  onPressed: queue.resume,
                  child: const Text('Resume'),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: events.map(Text.new).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
