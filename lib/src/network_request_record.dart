class NetworkRequestRecord {
  final String url;
  final String method;
  final int statusCode;
  final int requestSizeBytes;
  final int responseSizeBytes;
  final DateTime timestamp;
  final Duration duration;
  final String source;

  NetworkRequestRecord({
    required this.url,
    required this.method,
    required this.statusCode,
    required this.requestSizeBytes,
    required this.responseSizeBytes,
    required this.timestamp,
    required this.duration,
    required this.source,
  });

  String get domain => Uri.tryParse(url)?.host ?? url;

  int get totalBytes => requestSizeBytes + responseSizeBytes;

  String get path => Uri.tryParse(url)?.path ?? '';
}
