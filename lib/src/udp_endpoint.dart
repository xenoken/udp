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
import 'udp_port.dart';

/// [Endpoint] represents a destination for UDP packets.
///
/// Bundles an [InternetAddress] and a [Port].
class Endpoint {
  InternetAddress _address;

  /// The address of this endpoint.
  InternetAddress get address => _address;

  Port _port;

  /// The port of this endpoint.
  Port get port => _port;

  /// Whether the endpoint is a broadcast endpoint.
  bool _isBroadcast = false;

  /// Whether the endpoint is a broadcast endpoint.
  bool get isBroadcast => _isBroadcast;

  /// Whether the endpoint is a broadcast endpoint.
  set isBroadcast(bool isBroadcast) {
    _isBroadcast = isBroadcast;
  }

  static Endpoint _any = Endpoint._(InternetAddress.anyIPv4, Port(0));

  /// Creates a Broadcast endpoint.
  ///
  ///
  Endpoint.broadcast({port = Port.any}) {
    this._address = InternetAddress("255.255.255.255");
    this._port = port;
    this.isBroadcast = true;
  }

  /// The address of the local machine 127.0.0.1.
  ///
  /// [port] represents the port the endpoint is bound to.
  Endpoint.loopback({port = Port.any}) {
    this._address = InternetAddress.loopbackIPv4;
    this._port = port;
  }

  /// Creates a Unicast endpoint
  ///
  ///
  Endpoint.unicast(this._address, this._port);

  /// Creates a random Endpoint.
  ///
  /// This leaves the OS to choose an appropriate [InternetAddress] and [Port].
  factory Endpoint.any() => _any;

  // internal constructor.
  Endpoint._(this._address, this._port);
}
