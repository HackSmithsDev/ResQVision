import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:resq_scout/data/backend_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test(
    'workspace client sends bearer token and decodes backend records',
    () async {
      late http.Request received;
      final client = BackendApi(
        baseUrl: 'https://api.example.test',
        token: 'sample-token',
        client: MockClient((request) async {
          received = request;
          return http.Response(
            jsonEncode([
              {
                'id': 'record-1',
                'collection': 'drones',
                'data': {'callsign': 'Aircraft 7', 'status': 'ready'},
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final records = await client.listRecords('drones');

      expect(received.url.path, '/workspace/drones');
      expect(received.headers['Authorization'], 'Bearer sample-token');
      expect(records, [
        {'id': 'record-1', 'callsign': 'Aircraft 7', 'status': 'ready'},
      ]);
    },
  );

  test('login reads token from backend response', () async {
    final client = BackendApi(
      baseUrl: 'https://api.example.test',
      client: MockClient((request) async {
        expect(request.url.path, '/auth/login');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'operator@example.test');
        expect(body['password'], 'password');
        expect(body['device_id'], 'scout-installation-id');
        expect(body['device_info'], 'ResQ Scout');
        return http.Response(jsonEncode({'access_token': 'issued-token'}), 200);
      }),
    );

    final result = await client.login(
      email: 'operator@example.test',
      password: 'password',
      deviceId: 'scout-installation-id',
    );

    expect(result['access_token'], 'issued-token');
  });

  test(
    'expired access token is refreshed and the request is retried',
    () async {
      final paths = <String>[];
      String? updatedAccessToken;
      final client = BackendApi(
        baseUrl: 'https://api.example.test',
        token: 'expired-access',
        refreshToken: 'valid-refresh',
        onTokensChanged: (accessToken, refreshToken) async {
          updatedAccessToken = accessToken;
        },
        client: MockClient((request) async {
          paths.add(request.url.path);
          if (request.url.path == '/auth/token/refresh') {
            expect(jsonDecode(request.body), {
              'refresh_token': 'valid-refresh',
            });
            return http.Response(
              jsonEncode({
                'access_token': 'new-access',
                'refresh_token': 'valid-refresh',
              }),
              200,
            );
          }
          if (request.headers['Authorization'] == 'Bearer expired-access') {
            return http.Response('{"detail":"expired"}', 401);
          }
          return http.Response(
            jsonEncode([
              {
                'id': 'record-1',
                'data': {'name': 'Connected'},
              },
            ]),
            200,
          );
        }),
      );

      final records = await client.listRecords('drones');

      expect(paths, [
        '/workspace/drones',
        '/auth/token/refresh',
        '/workspace/drones',
      ]);
      expect(updatedAccessToken, 'new-access');
      expect(records.single['name'], 'Connected');
    },
  );

  test('revoked refresh token clears the local session', () async {
    var sessionExpired = false;
    final client = BackendApi(
      baseUrl: 'https://api.example.test',
      token: 'expired-access',
      refreshToken: 'revoked-refresh',
      onSessionExpired: () async => sessionExpired = true,
      client: MockClient((request) async {
        if (request.url.path == '/auth/token/refresh') {
          return http.Response('{"detail":"Invalid refresh token"}', 401);
        }
        return http.Response('{"detail":"expired"}', 401);
      }),
    );

    await expectLater(
      client.listRecords('drones'),
      throwsA(isA<BackendApiException>()),
    );
    expect(sessionExpired, isTrue);
  });

  test(
    'session notifier persists tokens and restores them after restart',
    () async {
      final storage = _MemorySessionTokenStorage();
      final firstContainer = ProviderContainer(
        overrides: [sessionTokenStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(firstContainer.dispose);
      final session = firstContainer.read(sessionProvider.notifier);
      await firstContainer.read(sessionProvider.future);

      await session.updateTokens('persisted-access', 'persisted-refresh');

      expect(jsonDecode((await storage.read('resq.session_tokens'))!), {
        'access_token': 'persisted-access',
        'refresh_token': 'persisted-refresh',
      });

      final restartedContainer = ProviderContainer(
        overrides: [sessionTokenStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(restartedContainer.dispose);

      expect(
        await restartedContainer.read(sessionProvider.future),
        const SessionTokens(
          accessToken: 'persisted-access',
          refreshToken: 'persisted-refresh',
        ),
      );

      await restartedContainer.read(sessionProvider.notifier).signOut();
      expect(await storage.read('resq.session_tokens'), isNull);
    },
  );
}

class _MemorySessionTokenStorage implements SessionTokenStorage {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}
