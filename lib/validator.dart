import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Validator validator = Validator();

class Validator {
  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
      multiLine: false,
    );
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    // Minimum length requirement
    if (password.length < 8) {
      return false;
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return false;
    }

    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return false;
    }

    // Check for at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      return false;
    }

    // Check for at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return false;
    }

    return true;
  }

  Future<bool> isValidCredforToken(RequestContext context) async {
    final authHeader = context.request.headers['authorization'];
    if (authHeader == null || !authHeader.startsWith('Basic ')) {
      // Unauthorized if no or invalid token provided
      return false;
    }
    final credentials = authHeader.substring('Basic '.length);
    final decodedCredentials = utf8.decode(base64.decode(credentials));
    final List<String> parts = decodedCredentials.split(':');

    // Check if the format of the credentials is valid
    if (parts.length != 2) {
      return false;
    }
    // Extract username and password
    final username = parts[0];
    final password = parts[1];
    final result = await context
        .read<Db>()
        .collection('admin')
        .findOne({'username': username});

    if (result != null) {
      final passwordEncrypted = result['password'] as String;
      if (BCrypt.checkpw(password, passwordEncrypted)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }

    // Check if username and password are valid
  }
}
