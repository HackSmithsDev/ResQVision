import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:resq_scout/data/backend_api.dart';

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
        expect(body['device_info'], 'ResQ Scout');
        expect(body['device_id'], startsWith('resq-scout-'));
        return http.Response(jsonEncode({'access_token': 'issued-token'}), 200);
      }),
    );

    final result = await client.login(
      email: 'operator@example.test',
      password: 'password',
    );

    expect(result['access_token'], 'issued-token');
  });
}
