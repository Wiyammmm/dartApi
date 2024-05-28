import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:myapi/validator.dart';

Future<Response> onRequest(RequestContext context) async {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.post => login(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> login(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String;
    final password = body['password'] as String;
    print(body);
    print('email: $email');
    if (!validator.isValidEmail(email)) {
      return Response.json(body: {
        'messages': {'code': 1, 'message': 'Invalid Email'},
      });
    }
    if (!validator.isValidPassword(password)) {
      return Response.json(body: {
        'messages': {'code': 1, 'message': 'Invalid Format Password'},
      });
    }

    final result =
        await context.read<Db>().collection('users').findOne({'email': email});
    if (result != null) {
      final passwordEncrypted = result['password'] as String;
      if (BCrypt.checkpw(password, passwordEncrypted)) {
        return Response.json(body: {
          'messages': {'code': 0, 'message': 'OK'},
        });
      } else {
        return Response.json(body: {
          'messages': {'code': 1, 'message': 'Invalid Email or Password'},
        });
      }
    } else {
      return Response.json(body: {
        'messages': {'code': 1, 'message': 'Invalid Email or Password'},
      });
    }
  } catch (e) {
    print(e);
    return Response(statusCode: HttpStatus.badRequest);
  }
}
