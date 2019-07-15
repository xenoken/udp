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

import 'dart:io';

import 'package:test/test.dart';
import 'package:udp/udp.dart';

void main() {
  group("udp", () {
    test("Unicast", () async {
      // create sender

      String result = "";
      await Future.wait([
        UDP
            .bind(Endpoint.unicast(InternetAddress("127.0.0.1"), Port(42)))
            .then((udp) {
          udp.listen((dgram) {
            result = String.fromCharCodes(dgram.data);
          }, Duration(seconds: 15));
        }),
        UDP.bind(Endpoint.loopback(port: Port(24))).then((udp) {
          udp.send("Foo".codeUnits,
              Endpoint.unicast(InternetAddress("127.0.0.1"), Port(42)));
        })
      ]);

      equals(result == "Foo").describe(StringDescription("Unicast"));
    });

    test("Loopback", () async {
      // create sender

      String result = "";
      await Future.wait([
        UDP.bind(Endpoint.loopback(port: Port(42))).then((udp) {
          udp.listen((dgram) {
            result = String.fromCharCodes(dgram.data);
          }, Duration(seconds: 15));
        }),
        UDP.bind(Endpoint.loopback(port: Port(24))).then((udp) {
          udp.send("Foo".codeUnits, Endpoint.loopback(port: Port(42)));
        })
      ]);

      equals(result == "Foo").describe(StringDescription("Unicast"));
    });

    test("Broadcast", () async {
      // create sender

      String result = "";
      await Future.wait([
        UDP.bind(Endpoint.loopback()).then((udp) {
          udp.listen((dgram) {
            result = String.fromCharCodes(dgram.data);
          }, Duration(seconds: 15));
        }),
        UDP.bind(Endpoint.loopback()).then((udp) {
          udp.send("Foo".codeUnits, Endpoint.broadcast());
        })
      ]);

      equals(result == "Foo").describe(StringDescription("Broadcast"));
    });

    test('Second Listen on the same instance should be possible.', () async {
      var udp = await UDP.bind(Endpoint.loopback());

      var receiver1 = await UDP.bind(Endpoint.loopback());

      String value = 'original';

      await receiver1.listen((datagram) {
        print(String.fromCharCodes(datagram.data));
      }, Duration(seconds: 5));

      // this listen request doesn't do anything.
      await receiver1.listen((datagram) {
        value = 'modified';
        print(String.fromCharCodes(datagram.data));
      }, Duration(seconds: 5));

      await udp.send("Foo".codeUnits, Endpoint.broadcast());

      receiver1.close();

      udp.close();

      expect(value == 'original', isTrue);
    });

    test("Using a closed UDP instance is not possible.", () async {
      var udp = await UDP.bind(Endpoint.loopback());

      var receiver1 = await UDP.bind(Endpoint.loopback());

      receiver1.close();

      udp.close(); // trying to see what happens if a send or receive method is called on a closed udp instance.

      await receiver1.listen((datagram) {
        print(String.fromCharCodes(datagram.data));
      }, Duration(seconds: 5));

      var dataLength = await udp.send("Foo".codeUnits, Endpoint.broadcast());

      expect(dataLength == -1, isTrue);
    });

    test("closed is True for closed udp instances.", () async {
      var udp = await UDP.bind(Endpoint.loopback());

      var receiver1 = await UDP.bind(Endpoint.loopback());

      receiver1.close();

      udp.close();

      expect(receiver1.closed && udp.closed, isTrue);
    });
  });
}
