import 'dart:convert';

import 'package:dio/dio.dart';

import 'network_monitor_service.dart';
import 'network_request_record.dart';

class NetworkUsageInterceptor extends Interceptor {
  static const _startTimeKey = '_networkMonitorStart';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _recordRequest(response.requestOptions, response.statusCode ?? 0, response.data);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _recordRequest(
      err.requestOptions,
      err.response?.statusCode ?? 0,
      err.response?.data,
    );
    handler.next(err);
  }

  void _recordRequest(RequestOptions options, int statusCode, dynamic responseData) {
    try {
      final service = NetworkMonitorService.instance;
      if (!service.isInitialized) return;

      final startMs = options.extra[_startTimeKey] as int?;
      final duration = startMs != null
          ? Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - startMs)
          : Duration.zero;

      final requestSize = _estimateSize(options.data) + _estimateHeadersSize(options.headers);
      final responseSize = _estimateSize(responseData);

      service.addRecord(NetworkRequestRecord(
        url: options.uri.toString(),
        method: options.method,
        statusCode: statusCode,
        requestSizeBytes: requestSize,
        responseSizeBytes: responseSize,
        timestamp: DateTime.now(),
        duration: duration,
        source: 'dio',
      ));
    } catch (_) {}
  }

  int _estimateSize(dynamic data) {
    if (data == null) return 0;
    if (data is String) return utf8.encode(data).length;
    if (data is List<int>) return data.length;
    if (data is Map || data is List) {
      try {
        return utf8.encode(jsonEncode(data)).length;
      } catch (_) {
        return 0;
      }
    }
    if (data is FormData) return data.length;
    return data.toString().length;
  }

  int _estimateHeadersSize(Map<String, dynamic> headers) {
    var size = 0;
    headers.forEach((key, value) {
      size += key.length + value.toString().length + 4;
    });
    return size;
  }
}
