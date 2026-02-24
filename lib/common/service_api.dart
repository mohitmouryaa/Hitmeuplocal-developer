import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hit_me_up/common/common.dart';

/// Single shared Dio instance with sensible timeouts and JSON headers.
/// Interceptors can be added here for auth tokens, logging, or retry logic.
final Dio _dio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 30),
    headers: const {
      'content-type': 'application/json',
      'Accept': 'application/json',
    },
  ),
);

/// Makes a GET or POST API call and returns the decoded JSON map.
/// All network and parsing errors are caught and returned as a typed error map
/// with [kDataCode] and [kDataMessage] keys so callers can handle them uniformly.
Future<Map<String, dynamic>> callApi(
  String httpType,
  dynamic params,
  String url,
) async {
  try {
    final Response<dynamic> response = httpType == 'GET'
        ? await _dio.get<dynamic>(url)
        : await _dio.post<dynamic>(url, data: params);

    final raw = response.data;

    // Dio returns a String when the server omits Content-Type: application/json.
    // Decode manually so the rest of the code always works with a Map.
    final dynamic data = raw is String ? jsonDecode(raw) : raw;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      // Inject HTTP status code under the key callers expect (kDataCode).
      map['status_code'] = response.statusCode ?? 500;
      return map;
    }
    return {
      kDataMessage: 'Unexpected response from server. Please try again.',
      kDataCode: 502,
    };
  } on DioException catch (e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        {
          kDataMessage: 'Server not responding. Please try again later.',
          kDataCode: 408,
        },
      DioExceptionType.connectionError => {
          kDataMessage: 'No internet connection. Please check your network.',
          kDataCode: 503,
        },
      _ => {
          kDataMessage: 'Something went wrong. Please try again later.',
          kDataCode: 500,
        },
    };
  } on Exception {
    return {
      kDataMessage: 'Unable to connect to server. Please try again.',
      kDataCode: 500,
    };
  }
}
