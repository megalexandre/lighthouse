// Checks every endpoint and JSON field the app uses (lib/api/contract.dart)
// against the OpenAPI document of the test server. A server upgrade that
// renames or drops something the app relies on fails here.
@Tags(['server'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';
import 'package:lighthouse/api/contract.dart';
import 'package:lighthouse/api/json_shape.dart';

void main() {
  late Map<String, dynamic> doc;

  setUpAll(() async => doc = await (await TestServer.start()).openApi());

  Map<String, dynamic> resolve(Map<String, dynamic> schema) {
    if (schema[r'$ref'] case final String ref) {
      final name = ref.split('/').last;
      final schemas = (doc['components'] as Map)['schemas'] as Map;
      return resolve(schemas[name] as Map<String, dynamic>);
    }
    if (schema['allOf'] case [final Map<String, dynamic> only]) {
      return resolve(only);
    }
    return schema;
  }

  /// Every key of [shape] missing from [schema], as dotted paths. An
  /// array schema is checked through its items, a map (an object with
  /// `additionalProperties`, such as Trickplay's id → width → info)
  /// through its values.
  List<String> missing(JsonShape shape, Map<String, dynamic> schema) {
    var resolved = resolve(schema);
    while (true) {
      if (resolved['type'] == 'array') {
        resolved = resolve(resolved['items'] as Map<String, dynamic>);
      } else if (resolved['properties'] == null &&
          resolved['additionalProperties'] is Map<String, dynamic>) {
        resolved = resolve(
          resolved['additionalProperties'] as Map<String, dynamic>,
        );
      } else {
        break;
      }
    }
    final props = (resolved['properties'] as Map?) ?? const {};
    return [
      for (final key in shape.keys)
        if (!props.containsKey(key))
          key
        else if (shape.nested[key] case final JsonShape nested)
          for (final m in missing(nested, props[key] as Map<String, dynamic>))
            '$key.$m',
    ];
  }

  Map<String, dynamic>? jsonSchema(Map<String, dynamic>? holder) =>
      ((holder?['content'] as Map?)?['application/json'] as Map?)?['schema']
          as Map<String, dynamic>?;

  for (final endpoint in apiContract) {
    test('$endpoint', () {
      final path = (doc['paths'] as Map)[endpoint.path] as Map?;
      expect(path, isNotNull, reason: 'no such path on the server');
      final op = path![endpoint.method.toLowerCase()] as Map<String, dynamic>?;
      expect(op, isNotNull, reason: 'path has no ${endpoint.method}');
      final responses = op!['responses'] as Map<String, dynamic>;

      if (endpoint.request case final JsonShape request) {
        final schema = jsonSchema(op['requestBody'] as Map<String, dynamic>?);
        expect(schema, isNotNull, reason: 'takes no JSON body');
        expect(missing(request, schema!), isEmpty, reason: 'request body');
      }

      final params = {
        for (final p in (op['parameters'] as List?) ?? const [])
          if ((p as Map)['in'] == 'query') p['name'] as String,
      };
      expect(
        endpoint.query.where((q) => !params.contains(q)),
        isEmpty,
        reason: 'query parameters',
      );

      switch (endpoint.kind) {
        case ResponseKind.none:
          expect(responses.keys, contains('204'));
        case ResponseKind.file:
          expect(responses.keys, contains('200'));
        case ResponseKind.object || ResponseKind.list:
          final schema = jsonSchema(responses['200'] as Map<String, dynamic>?);
          expect(schema, isNotNull, reason: 'no JSON 200 response');
          final isArray = resolve(schema!)['type'] == 'array';
          expect(
            isArray,
            endpoint.kind == ResponseKind.list,
            reason: 'array or object',
          );
          expect(
            missing(endpoint.response!, schema),
            isEmpty,
            reason: 'response',
          );
      }
    });
  }

  test('the checker notices a field the server does not have', () {
    const bogus = JsonShape({'x': 'NoSuchField'});
    final me = ((doc['paths'] as Map)['/Users/Me'] as Map)['get'] as Map;
    final schema = jsonSchema(
      (me['responses'] as Map)['200'] as Map<String, dynamic>,
    );
    expect(missing(bogus, schema!), ['NoSuchField']);
  });
}
