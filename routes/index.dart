import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final response = {
    'message': 'Hello, Dart Frog!',
  };
  return Response.json(body: response);
}
