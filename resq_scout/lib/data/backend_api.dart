import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const backendBaseUrl = String.fromEnvironment(
  'RESQ_API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

const _sessionTokensKey = 'resq.session_tokens';
const _deviceIdKey = 'resq.device_id';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final sessionTokenStorageProvider = Provider<SessionTokenStorage>(
  (ref) => _SecureSessionTokenStorage(ref.watch(secureStorageProvider)),
);

final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionTokens?>(
  SessionNotifier.new,
);

final backendApiProvider = FutureProvider<BackendApi>((ref) async {
  final tokens = await ref.watch(sessionProvider.future);
  final sessionNotifier = ref.read(sessionProvider.notifier);
  return BackendApi(
    baseUrl: backendBaseUrl,
    token: tokens?.accessToken,
    refreshToken: tokens?.refreshToken,
    onTokensChanged: (accessToken, refreshToken) =>
        sessionNotifier.updateTokens(accessToken, refreshToken),
    onSessionExpired: sessionNotifier.signOut,
  );
});

final workspaceRecordsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      collection,
    ) async {
      final api = await ref.watch(backendApiProvider.future);
      return api.listRecords(collection);
    });

final backendProfileProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final api = await ref.watch(backendApiProvider.future);
  return api.getProfile();
});

class SessionTokens {
  const SessionTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory SessionTokens.fromJson(Map<String, dynamic> json) {
    final accessToken = json['access_token'];
    final refreshToken = json['refresh_token'];
    if (accessToken is! String ||
        accessToken.isEmpty ||
        refreshToken is! String ||
        refreshToken.isEmpty) {
      throw const FormatException('Backend token response is invalid.');
    }
    return SessionTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };

  @override
  bool operator ==(Object other) =>
      other is SessionTokens &&
      other.accessToken == accessToken &&
      other.refreshToken == refreshToken;

  @override
  int get hashCode => Object.hash(accessToken, refreshToken);
}

abstract interface class SessionTokenStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class _SecureSessionTokenStorage implements SessionTokenStorage {
  const _SecureSessionTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class SessionNotifier extends AsyncNotifier<SessionTokens?> {
  @override
  Future<SessionTokens?> build() async {
    final storage = ref.watch(sessionTokenStorageProvider);
    final storedTokens = await storage.read(_sessionTokensKey);
    if (storedTokens == null) return null;
    try {
      final decoded = jsonDecode(storedTokens);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Stored session is invalid.');
      }
      return SessionTokens.fromJson(decoded);
    } on FormatException {
      await storage.delete(_sessionTokensKey);
      return null;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    final storage = ref.read(sessionTokenStorageProvider);
    var deviceId = await storage.read(_deviceIdKey);
    if (deviceId == null) {
      deviceId = 'resq-scout-${DateTime.now().microsecondsSinceEpoch}';
      await storage.write(_deviceIdKey, deviceId);
    }
    final api = BackendApi(baseUrl: backendBaseUrl);
    final tokens = SessionTokens.fromJson(
      await api.login(email: email, password: password, deviceId: deviceId),
    );
    await _persist(tokens);
    state = AsyncData(tokens);
  }

  Future<void> updateTokens(String accessToken, String refreshToken) async {
    final tokens = SessionTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _persist(tokens);
    state = AsyncData(tokens);
  }

  Future<void> signOut() async {
    final storage = ref.read(sessionTokenStorageProvider);
    await storage.delete(_sessionTokensKey);
    state = const AsyncData(null);
  }

  Future<void> _persist(SessionTokens tokens) async {
    final storage = ref.read(sessionTokenStorageProvider);
    await storage.write(_sessionTokensKey, jsonEncode(tokens.toJson()));
  }
}

class BackendApi {
  BackendApi({
    required this.baseUrl,
    String? token,
    this.refreshToken,
    this.onTokensChanged,
    this.onSessionExpired,
    http.Client? client,
  }) : _accessToken = token,
       _client = client ?? http.Client();

  final String baseUrl;
  String? _accessToken;
  String? refreshToken;
  final Future<void> Function(String accessToken, String refreshToken)?
  onTokensChanged;
  final Future<void> Function()? onSessionExpired;
  final http.Client _client;
  Future<void>? _refreshing;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (_accessToken case final value?) 'Authorization': 'Bearer $value',
  };

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_id': deviceId,
        'device_info': 'ResQ Scout',
      }),
    );
    _checkResponse(response);
    return _decodeObject(response.body);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _authorized(
      (headers) =>
          _client.get(Uri.parse('$baseUrl/users/me'), headers: headers),
    );
    return _decodeObject(response.body);
  }

  Future<List<Map<String, dynamic>>> listRecords(String collection) async {
    final response = await _authorized(
      (headers) => _client.get(
        Uri.parse('$baseUrl/workspace/$collection'),
        headers: headers,
      ),
    );
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Backend collection response is invalid.');
    }
    return decoded.map((record) {
      if (record is! Map<String, dynamic> ||
          record['data'] is! Map<String, dynamic>) {
        throw const FormatException('Backend record response is invalid.');
      }
      return {'id': record['id'], ...(record['data'] as Map<String, dynamic>)};
    }).toList();
  }

  Future<Map<String, dynamic>> createRecord(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final response = await _authorized(
      (headers) => _client.post(
        Uri.parse('$baseUrl/workspace/$collection'),
        headers: headers,
        body: jsonEncode({'data': data}),
      ),
    );
    final record = _decodeObject(response.body);
    return {'id': record['id'], ...data};
  }

  Future<http.Response> _authorized(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    var response = await request(_headers);
    if (response.statusCode != 401) {
      _checkResponse(response);
      return response;
    }
    if (refreshToken == null) {
      await onSessionExpired?.call();
      _checkResponse(response);
    }

    try {
      await _refreshAccessToken();
    } on BackendApiException catch (error) {
      if (error.statusCode == 401) await onSessionExpired?.call();
      rethrow;
    }
    response = await request(_headers);
    _checkResponse(response);
    return response;
  }

  Future<void> _refreshAccessToken() async {
    final activeRefresh = _refreshing;
    if (activeRefresh != null) {
      await activeRefresh;
      return;
    }

    late final Future<void> refresh;
    refresh = () async {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/token/refresh'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      _checkResponse(response);
      final decoded = _decodeObject(response.body);
      final updated = SessionTokens.fromJson({
        'access_token': decoded['access_token'],
        'refresh_token': decoded['refresh_token'] ?? refreshToken,
      });
      _accessToken = updated.accessToken;
      refreshToken = updated.refreshToken;
      await onTokensChanged?.call(updated.accessToken, updated.refreshToken);
    }();
    _refreshing = refresh;
    try {
      await refresh;
    } finally {
      if (identical(_refreshing, refresh)) _refreshing = null;
    }
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
