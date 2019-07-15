Lightweight UDP library for Dart.

## Usage

A simple usage example:

```dart
import 'package:udp/udp.dart';


main() async {

  // creates a UDP instance and binds it to the local address and the port 42.
  var sender = await UDP.bind(Endpoint.loopback(port:Port(42)));

  // send a simple string to a broadcast endpoint on port 21.
  var dataLength = await sender.send("Hello World!".codeUnits,
      Endpoint.broadcast(port: Port(21)));

  stdout.write("${dataLength} bytes sent.");

  // creates a new UDP instance and binds it to the local address and the port
  // 39.
  var receiver = await UDP.bind(Endpoint.loopback(port:Port(39)));

  // receiving\listening
  await receiver.listen((datagram) {
    var str = String.fromCharCodes(datagram.data);
    stdout.write(str);
  },Duration(seconds:20));


  // close the UDP instances and their sockets.
  sender.close();
  receiver.close();
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://github.com/xenoken/udp/issues
