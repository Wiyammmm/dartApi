import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/test.dart';

const String host = '172.232.77.205';
const int port = 22; // Assign the correct port number
const String username = 'root';
const String password = 'Sburoot@123';

Handler middleware(Handler handler) {
  // TODO: implement middleware
  return (context) async {
    final db = await Db.create('mongodb://localhost:27017/usersapp');
    if (!db.isConnected) {
      await db.open();
    }
    print('after');

    final response = await handler.use(provider<Db>((_) => db)).call(context);
    await db.close();
    return response;
  };
}
