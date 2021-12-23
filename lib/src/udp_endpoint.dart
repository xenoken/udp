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
  InternetAddress? _address;

  /// The address of this endpoint.
  InternetAddress? get address => _address;

  Port? _port;

  /// The port of this endpoint.
  Port? get port => _port;

  /// Whether the endpoint is a broadcast endpoint.
  bool _isBroadcast = false;

  /// Whether the endpoint is a broadcast endpoint.
  bool get isBroadcast => _isBroadcast;

  /// Whether the endpoint is a multicast endpoint.
  bool _isMulticast = false;

  /// Whether the endpoint is a multicast endpoint.
  bool get isMulticast => _isMulticast;

  /// Creates a Unicast endpoint.
  Endpoint.unicast(this._address, {Port port = Port.any}) {
    _port = port;
  }

  /// Creates a Broadcast endpoint.
  Endpoint.broadcast({Port port = Port.any}) {
    _address = InternetAddress('255.255.255.255');
    _port = port;
    _isBroadcast = true;
  }

  /// An endpoint with the address of the local machine 127.0.0.1.
  ///
  /// [port] represents the port the endpoint is bound to.
  Endpoint.loopback({Port port = Port.any}) {
    _address = InternetAddress.loopbackIPv4;
    _port = port;
  }

  /// Creates a Multicast endpoint.
  ///
  /// [_address] should be a valid Multicast address in the range 224.0.0.0
  /// to 239.255.255.255.
  Endpoint.multicast(this._address, {Port port = Port.any}) {
    _port = port;
    _isMulticast = true;
  }

  /// Creates a random Endpoint.
  ///
  /// The OS will choose an appropriate [InternetAddress] and [Port].
  Endpoint.any({port = Port.any}) {
    _address = InternetAddress.anyIPv4;
    _port = port;
  }

  // internal constructor.
  Endpoint._(this._address, this._port);
}
