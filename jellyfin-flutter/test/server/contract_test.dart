// Checks every endpoint and JSON field the app uses (lib/api/contract.dart)
// against the OpenAPI document of the test server. A server upgrade that
// renames or drops something the app relies on fails here.
@Tags(['server'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/contract.dart';
import 'package:jellyfin_flutter/api/json_shape.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';

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

  /// Every key of [shape] missing from [schema], as dotted paths.
  List<String> missing(JsonShape shape, Map<String, dynamic> schema) {
    final props = (resolve(schema)['properties'] as Map?) ?? const {};
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

      if (endpoint.response case final JsonShape response) {
        final schema = jsonSchema(responses['200'] as Map<String, dynamic>?);
        expect(schema, isNotNull, reason: 'no JSON 200 response');
        expect(missing(response, schema!), isEmpty, reason: 'response');
      } else {
        expect(responses.keys, contains('204'));
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
