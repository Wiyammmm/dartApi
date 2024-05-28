import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.patch => _updateList(context, id),
    HttpMethod.delete => _deleteList(context, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _updateList(RequestContext context, String id) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final name = body['name'] as String?;
  try {
    final result = await context.read<Db>().collection('users').updateOne(
        where.eq('_id', ObjectId.parse(id)), modify.set('name', name));
    if (result.nModified == 1) {
      return Response.json(body: {
        'messages': {'code': 0, 'message': "OK"}
      });
    } else {
      return Response.json(body: {
        'messages': {'code': 1, 'message': "NO USER FOUND"}
      });
    }
  } catch (e) {
    return Response(statusCode: HttpStatus.badRequest);
  }
}

Future<Response> _deleteList(RequestContext context, String id) async {
  try {
    final result = await context
        .read<Db>()
        .collection('users')
        .deleteOne({'_id': ObjectId.parse(id)});

    int? code;
    String? message;
    if (result.nRemoved == 1) {
      return Response.json(body: {
        'messages': {'code': 0, 'message': "OK"}
      });
    } else {
      return Response.json(body: {
        'messages': {'code': 1, 'message': "NO USER FOUND"}
      });
    }
  } catch (e) {
    return Response.json(body: {
      'messages': {'code': 1, 'message': e}
    });
  }
}
