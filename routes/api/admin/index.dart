import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.get => _getAdmin(context),
    HttpMethod.post => _addAdmin(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _getAdmin(RequestContext context) async {
  final lists = await context.read<Db>().collection('admin').find().toList();
  return Response.json(body: {'messages': 0, 'message': 'OK', 'result': lists});
}

Future<Response> _addAdmin(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String;
    final username = body['username'] as String;
    final password = body['password'] as String;

    final checkEmail =
        await context.read<Db>().collection('admin').findOne({'email': email});
    if (checkEmail != null) {
      return Response.json(body: {
        'messages': {'code': 1, 'message': 'This email is Already exist'},
      });
    }
    final checkusername = await context
        .read<Db>()
        .collection('admin')
        .findOne({'username': username});

    if (checkusername != null) {
      return Response.json(body: {
        'messages': {'code': 1, 'message': 'This username is Already exist'},
      });
    }

    final hashed = BCrypt.hashpw(password, BCrypt.gensalt());
    final list = <String, dynamic>{
      'username': username,
      'email': email,
      'password': hashed
    };

    final result = await context.read<Db>().collection('admin').insertOne(list);

    if (result.nInserted == 1) {
      return Response.json(body: {
        'messages': {'code': 0, 'message': 'OK'},
      });
    } else {
      return Response.json(body: {
        'messages': {'code': 1, 'message': 'Something went wrong'},
      });
    }
  } catch (e) {
    print(e);
    return Response(statusCode: HttpStatus.badRequest);
  }
}
