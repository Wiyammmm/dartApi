import 'dart:convert';
import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:myapi/validator.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.get => _getLists(context),
    HttpMethod.post => _createList(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _getLists(RequestContext context) async {
  // final authHeader = context.request.headers['authorization'];
  // if (authHeader == null || !authHeader.startsWith('Bearer ')) {
  //   // Unauthorized if no or invalid token provided
  //   return Response(statusCode: HttpStatus.unauthorized);
  // }

  // final token = authHeader.substring(7);
  final lists = await context.read<Db>().collection('users').find().toList();

  return Response.json(body: {
    'messages': {'code': 0, 'message': 'Ok'},
    'result': lists
  });
}

Future<Response> _createList(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'] as String;
  if (!validator.isValidEmail(email)) {
    return Response.json(body: {
      'messages': {'code': 1, 'message': 'Invalid Email'},
    });
  }

  final checkEmail =
      await context.read<Db>().collection('users').findOne({'email': email});

  if (checkEmail != null) {
    return Response.json(body: {
      'messages': {'code': 1, 'message': 'This email is Already exist'},
    });
  }
  final password = body['password'] as String;
  if (!validator.isValidPassword(password)) {
    return Response.json(body: {
      'messages': {'code': 1, 'message': 'Invalid Format Password'},
    });
  }
  final hashed = BCrypt.hashpw(password, BCrypt.gensalt());

  final list = <String, dynamic>{'email': email, 'password': hashed};

  final result = await context.read<Db>().collection('users').insertOne(list);
  // return Response.json(body: {'result': result.document});
  return Response.json(body: {
    'messages': {
      'code': 0,
      'message': 'OK',
    },
    'result': result.document
  });
}
