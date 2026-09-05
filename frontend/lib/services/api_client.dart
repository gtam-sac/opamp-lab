import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  final String baseUrl;

  const ApiClient({this.baseUrl = kApiBaseUrl});

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(
    String path, {
    String? token,
  }) {
    return _request(
      () => http
          .get(
            Uri.parse('$baseUrl$path'),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 10)),
    );
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) {
    return _request(
      () => http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10)),
    );
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    String? token,
  }) {
    return _request(
      () => http
          .delete(
            Uri.parse('$baseUrl$path'),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 10)),
    );
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() request,
  ) async {
    http.Response response;

    try {
      response = await request();
    } on TimeoutException {
      throw const ApiException(
        'Could not reach the server. Is the backend running?',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'Could not reach the server. Is the backend running?',
      );
    }

    Map<String, dynamic> decoded = {};
    if (response.body.trim().isNotEmpty) {
      try {
        final value = jsonDecode(response.body);
        if (value is Map<String, dynamic>) {
          decoded = value;
        }
      } on FormatException {
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw ApiException(
            'Request failed (${response.statusCode}).',
            statusCode: response.statusCode,
          );
        }
        throw const ApiException('The server returned an invalid response.');
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded['message'];
    throw ApiException(
      message is String && message.isNotEmpty
          ? message
          : 'Request failed (${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }
}
