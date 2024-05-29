import 'dart:io';

import 'package:dartssh2/dartssh2.dart';

const String host = '172.232.77.205';
const int port = 22; // Assign the correct port number
const String username = 'root';
const String password = 'Sburoot@123';
Future<void> main() async {
  final SSHSocket socket = await SSHSocket.connect(host, 22);
  final SSHClient client = SSHClient(
    socket,
    username: username,
    onPasswordRequest: () => password,
  );
  // try {
  //   final result = await client.execute('echo Hello, SSH!');
  //   print(result);
  // } finally {
  //   client.close();
  // }

  final ServerSocket serverSocket = await ServerSocket.bind(
    shared: true,
    '127.0.0.1', // Where you want to forward it
    27017, // Port where you want to forward it
  );
  print('serverSocket: $serverSocket');

  await for (final Socket socket in serverSocket) {
    final SSHForwardChannel forward = await client.forwardLocal(
        '127.0.0.1', // Internal port at the domain of the computer
        27017, // It's port
        localHost: '127.0.0.1',
        localPort: 27017);
    print('forward: $forward');
    forward.stream.cast<List<int>>().pipe(socket);
    socket.pipe(forward.sink);
  }
  print('before');
}
