import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const backendBaseUrl = String.fromEnvironment(
  'RESQ_API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

final accessTokenProvider = NotifierProvider<AccessTokenNotifier, String?>(
  AccessTokenNotifier.new,
);

class AccessTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setToken(String? token) => state = token;
}

final backendApiProvider = Provider<BackendApi>((ref) {
  return BackendApi(
    baseUrl: backendBaseUrl,
    token: ref.watch(accessTokenProvider),
  );
});

final workspaceRecordsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, collection) {
      return ref.watch(backendApiProvider).listRecords(collection);
    });

final backendProfileProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(backendApiProvider).getProfile();
});

class BackendApi {
  BackendApi({required this.baseUrl, this.token, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final String? token;
  final http.Client _client;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token case final value?) 'Authorization': 'Bearer $value',
  };

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_id': 'resq-scout-${DateTime.now().microsecondsSinceEpoch}',
        'device_info': 'ResQ Scout',
      }),
    );
    _checkResponse(response);
    final result = jsonDecode(response.body);
    if (result is! Map<String, dynamic> ||
        result['access_token'] is! String) {
      throw const FormatException('Backend login response is invalid.');
    }
    return result;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
    );
    _checkResponse(response);
    return _decodeObject(response.body);
  }

  Future<List<Map<String, dynamic>>> listRecords(String collection) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/workspace/$collection'),
      headers: _headers,
    );
    _checkResponse(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Backend collection response is invalid.');
    }
    return decoded.map((record) {
      if (record is! Map<String, dynamic> ||
          record['data'] is! Map<String, dynamic>) {
        throw const FormatException('Backend record response is invalid.');
      }
      return {
        'id': record['id'],
        ...(record['data'] as Map<String, dynamic>),
      };
    }).toList();
  }

  Future<Map<String, dynamic>> createRecord(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/workspace/$collection'),
      headers: _headers,
      body: jsonEncode({'data': data}),
    );
    _checkResponse(response);
    final record = _decodeObject(response.body);
    return {'id': record['id'], ...data};
  }

  static Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backend response is invalid.');
    }
    return decoded;
  }

  static void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    var message = 'Backend request failed (${response.statusCode}).';
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body['detail'] is String) {
        message = body['detail'] as String;
      }
    } on FormatException {
      // Keep the explicit HTTP status if the server did not return JSON.
    }
    throw BackendApiException(response.statusCode, message);
  }
}

class BackendApiException implements Exception {
  const BackendApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
