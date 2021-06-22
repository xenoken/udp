/*
 *
 *  Copyright 2019 Kennedy Tochukwu Ekeoha 
 *  
 *  Redistribution and use in source and binary forms, with or without 
 *  modification, are permitted provided that the following conditions 
 *  are met: 
 *  
 *  1. Redistributions of source code must retain the above copyright 
 *  notice, this list of conditions and the following disclaimer. 
 *  
 *  2. Redistributions in binary form must reproduce the above copyright 
 *  notice, this list of conditions and the following disclaimer in the 
 *  documentation and/or other materials provided with the distribution. 
 *  
 *  3. Neither the name of the copyright holder nor the names of its 
 *  contributors may be used to endorse or promote products derived from 
 *  this software without specific prior written permission. 
 *  
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
 *  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
 *  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
 *  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
 *  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY 
 *  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 *  POSSIBILITY OF SUCH DAMAGE.
 *  
 */

import 'dart:cli';
import 'dart:io';

import 'package:test/test.dart';
import 'package:udp/udp.dart';

void main() {
  group("udp", () {
    /*
    UNICAST
    */
    test("Unicast", () async {
      String result = "";

      UDP? receiver, sender;

      waitFor(Future.wait([
        UDP
            .bind(
                Endpoint.unicast(InternetAddress("127.0.0.1"), port: Port(42)))
            .then((udp) {
          receiver = udp;
          return udp.listen((dgram) {
            result = String.fromCharCodes(dgram!.data);
          }, timeout: Duration(seconds: 5));
        }),
        UDP
            .bind(
                Endpoint.unicast(InternetAddress("127.0.0.1"), port: Port(24)))
            .then((udp) {
          sender = udp;
          return udp.send("Foo".codeUnits, Endpoint.broadcast(port: Port(42)));
        })
      ]));

      receiver?.close();
      sender?.close();

      expect(result, equals("Foo"));
    });

    /*
    LOOPBACK
    */
    test("Loopback", () async {
      String result = "";

      UDP? receiver, sender;

      waitFor(Future.wait([
        UDP.bind(Endpoint.loopback(port: Port(42))).then((udp) {
          receiver = udp;
          return udp.listen((dgram) {
            result = String.fromCharCodes(dgram!.data);
          }, timeout: Duration(seconds: 5));
        }),
        UDP.bind(Endpoint.loopback(port: Port(24))).then((udp) {
          sender = udp;
          return udp.send("Foo".codeUnits, Endpoint.loopback(port: Port(42)));
        })
      ]));

      receiver?.close();
      sender?.close();

      expect(result, equals("Foo"));
    });

    /*
    BROADCAST
    */
    test("Broadcast", () async {
      String result = "";

      UDP? receiver, sender;
      waitFor(Future.wait([
        UDP.bind(Endpoint.any(port: Port(42))).then((udp) {
          receiver = udp;
          return udp.listen((dgram) {
            result = String.fromCharCodes(dgram!.data);
          }, timeout: Duration(seconds: 5));
        }),
        UDP.bind(Endpoint.any(port: Port(24))).then((udp) {
          sender = udp;
          return udp.send("Foo".codeUnits, Endpoint.broadcast(port: Port(42)));
        })
      ]));

      receiver?.close();
      sender?.close();

      expect(result, equals("Foo"));
    });

    /*
    MULTICAST
    */
    test("Multicast", () async {
      String result = "";

      UDP? receiver, sender;

      var multicastEndpoint =
          Endpoint.multicast(InternetAddress("239.1.2.3"), port: Port(4540));

      waitFor(Future.wait([
        UDP.bind(multicastEndpoint).then((udp) {
          return udp.listen((dgram) {
            if (dgram == null) return;
            result = String.fromCharCodes(dgram.data);
          }, timeout: Duration(seconds: 10));
        }),
        UDP.bind(Endpoint.any()).then((udp) {
          sender = udp;
          return sender!.send("Foo".codeUnits, multicastEndpoint);
        })
      ]));

      receiver?.close();
      sender?.close();

      expect(result, equals("Foo"));
    });

    /*
    Second listen is not possible.
    */
    test('Second Listen on the same instance should not be possible.',
        () async {
      var udp = await UDP.bind(Endpoint.loopback());

      var receiver = await UDP.bind(Endpoint.loopback());

      String value = 'original';

      await receiver.listen((datagram) {
        print(String.fromCharCodes(datagram!.data));
      }, timeout: Duration(seconds: 5));

      // this listen request doesn't do anything.
      await receiver.listen((datagram) {
        value = 'modified';
        print(String.fromCharCodes(datagram!.data));
      }, timeout: Duration(seconds: 5));

      await udp.send("Foo".codeUnits, Endpoint.broadcast());

      receiver.close();

      udp.close();

      expect(value == 'original', isTrue);
    });

    /*
    A closed UDP instance can't be reused.
    */
    test("Using a closed UDP instance is not possible.", () async {
      var udp = await UDP.bind(Endpoint.loopback());

      var receiver = await UDP.bind(Endpoint.loopback());

      receiver.close();

      udp.close(); // trying to see what happens if a send or receive method is called on a closed udp instance.

      await receiver.listen((datagram) {
        print(String.fromCharCodes(datagram!.data));
      }, timeout: Duration(seconds: 5));

      var dataLength = await udp.send("Foo".codeUnits, Endpoint.broadcast());

      expect(dataLength == -1, isTrue);
    });

    /*
    UDP.Close() sets UDP.closed to TRUE
    */
    test("closed is True for closed udp instances.", () async {
      var udp = await UDP.bind(Endpoint.loopback());

      var receiver = await UDP.bind(Endpoint.loopback());

      receiver.close();

      udp.close();

      expect(receiver.closed && udp.closed, isTrue);
    });

    /*
    UDP listen can run forever if no timeout is set.
    */
    test("UDP listen can run forever if no timeout is set.", () async {
      var receiver = await UDP.bind(Endpoint.any());

      await receiver.listen((datagram) {});

      await Future.delayed(Duration(seconds: 5));

      expect(receiver.closed, isFalse);

      receiver.close();
    });

    /*
    A UDP instance listening indefinitely can be stopped by close.
    */
    test(" A UDP instance listening indefinitely can be stopped by close.",
        () async {
      var receiver = await UDP.bind(Endpoint.any());

      await receiver.listen((datagram) {});

      await Future.delayed(Duration(seconds: 10));

      receiver.close();

      expect(receiver.closed, isTrue);
    });
  });
}
