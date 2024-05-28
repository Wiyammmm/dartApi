import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:myapi/validator.dart';

Future<Response> onRequest(RequestContext context) async {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.get => _getToken(context),
    HttpMethod.post => _validateToken(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _getToken(RequestContext context) async {
  bool isValidCred = await validator.isValidCredforToken(context);

  if (!isValidCred) {
    return Response(statusCode: HttpStatus.nonAuthoritativeInformation);
  }
  // final token = authHeader.substring(7);
  final jwt = JWT({}, issuer: "Me");
  // Set token expiration claim

// Sign it (default with HS256 algorithm)
  final token = jwt.sign(
    SecretKey('SEASECRET'),
    expiresIn: Duration(seconds: 30),
  );
  final list = <String, dynamic>{'token': token};
  final result = await context.read<Db>().collection('token').insertOne(list);

  return Response.json(body: {
    'messages': {'code': 0, 'message': 'Ok'},
    'result': result.document
  });
}

Future<Response> _validateToken(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final token = body['token'] as String;
  try {
    // Verify a token (SecretKey for HMAC & PublicKey for all the others)
    final jwt = JWT.verify(token, SecretKey('SEASECRET'));

    print('Payload: ${jwt.payload}');
    return Response.json(body: {
      'messages': {'code': 0, 'message': 'Ok'}
    });
  } on JWTExpiredException {
    final result = await context
        .read<Db>()
        .collection('token')
        .deleteOne({'token': token});
    if (result.nRemoved == 1) {
      return Response.json(body: {
        'messages': {'code': 1, 'message': 'Expired'},
      });
    } else {
      return Response.json(body: {
        'messages': {'code': 1, 'message': 'No token existing'},
      });
    }
  } on JWTException catch (ex) {
    print(ex.message); // ex: invalid signature
    return Response.json(body: {
      'messages': {'code': 1, 'message': '${ex.message}}'}
    });
  } catch (e) {
    return Response(statusCode: HttpStatus.badRequest);
  }
}
