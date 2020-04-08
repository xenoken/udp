Lightweight UDP library for Dart.

## Usage

A simple usage example:

```dart
import 'package:udp/udp.dart';


main() async {
  
    // creates a UDP instance and binds it to the first available network
    // interface on port 65000.
    var sender = await UDP.bind(Endpoint.any(port: Port(65000)));
  
    // send a simple string to a broadcast endpoint on port 65001.
    var dataLength = await sender.send("Hello World!".codeUnits,
    Endpoint.broadcast(port: Port(65001)));
  
    stdout.write("${dataLength} bytes sent.");
  
    // creates a new UDP instance and binds it to the local address and the port
    // 65002.
    var receiver = await UDP.bind(Endpoint.loopback(port: Port(65002)));
  
    // receiving\listening
    await receiver.listen((datagram) {
      var str = String.fromCharCodes(datagram.data);
      stdout.write(str);
    }, timeout: Duration(seconds: 20));
  
    // close the UDP instances and their sockets.
    sender.close();
    receiver.close();
  
  
   // MULTICAST
    var multicastEndpoint =
        Endpoint.multicast(InternetAddress("239.1.2.3"), port: Port(54321));
  
    var receiver = await UDP.bind(multicastEndpoint);
  
    var sender = await UDP.bind(Endpoint.any());
  
    unawaited(receiver.listen((datagram) {
      if (datagram != null) {
        var str = String.fromCharCodes(datagram?.data);
  
        stdout.write(str);
      }
    }));
  
    await sender.send("Foo".codeUnits, multicastEndpoint);
  
    await Future.delayed(Duration(seconds:5));
  
    sender.close();
    receiver.close();
  
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://github.com/xenoken/udp/issues
