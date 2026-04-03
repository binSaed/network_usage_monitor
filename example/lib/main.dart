import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network_usage_monitor/network_usage_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NetworkMonitorService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Usage Monitor Example',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Dio _dio;
  late final MonitoredHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _dio = Dio()..interceptors.add(NetworkUsageInterceptor());
    _httpClient = MonitoredHttpClient(http.Client());
  }

  @override
  void dispose() {
    _httpClient.close();
    _dio.close();
    super.dispose();
  }

  Future<void> _makeDioRequest() async {
    try {
      await _dio.get('https://jsonplaceholder.typicode.com/posts/1');
    } catch (_) {}
  }

  Future<void> _makeHttpRequest() async {
    try {
      await _httpClient
          .get(Uri.parse('https://jsonplaceholder.typicode.com/users/1'));
    } catch (_) {}
  }

  void _openMonitor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NetworkMonitorPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Monitor Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: _makeDioRequest,
              child: const Text('Make Dio Request'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _makeHttpRequest,
              child: const Text('Make HTTP Request'),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: _openMonitor,
              child: const Text('Open Network Monitor'),
            ),
          ],
        ),
      ),
    );
  }
}
