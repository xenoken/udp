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

import 'dart:async';
import 'dart:io';

import 'udp_endpoint.dart';

typedef DatagramCallback = void Function(Datagram?);

/// [UDP] sends or receives UDP packets.
///
/// a [UDP] instance can send packets to or receive packets from [Endpoint]s.
class UDP {
  bool _listening = false;

  bool _closed = false;

  /// returns True if this [UDP] instance is closed.
  bool get closed => _closed;

  StreamSubscription? _streamSubscription;

  final Endpoint _localep;

  /// the [Endpoint] this [UDP] instance is bound to.
  Endpoint get local => _localep;

  RawDatagramSocket? _socket;

  /// a reference to underlying [RawDatagramSocket].
  RawDatagramSocket? get socket => _socket;

  // internal ctor
  UDP._(this._localep);

  /// Creates a new [UDP] instance.
  ///
  /// The [UDP] instance is created by the OS and bound to a local [Endpoint].
  ///
  /// [localEndpoint] - the local endpoint.
  ///
  /// returns the [UDP] instance.
  static Future<UDP> bind(Endpoint localEndpoint) async {
    var ep = localEndpoint;

    if (localEndpoint.isMulticast) {
      ep = Endpoint.any(port: localEndpoint.port);
    }

    return await RawDatagramSocket.bind(ep.address, ep.port!.value)
        .then((socket) {
      var udp = UDP._(localEndpoint);

      if (localEndpoint.isMulticast) {
        socket.joinMulticast(localEndpoint.address!);
      }

      udp._socket = socket;

      return udp;
    });
  }

  /// Sends some [data] to a [remoteEndpoint].
  ///
  /// [data] - the data to send.
  /// [remoteEndpoint] - the remote endpoint.
  ///
  /// returns the number of bytes sent.
  /// if the udp was already closed at the time of the call, returns -1.
  Future<int> send(List<int> data, Endpoint remoteEndpoint) async {
    if (_socket == null || _closed) return -1;

    return Future.microtask(() async {
      var prevState = _socket!.broadcastEnabled;

      if (remoteEndpoint.isBroadcast) {
        _socket!.broadcastEnabled = true;
      }

      var _dataCount =
          _socket!.send(data, remoteEndpoint.address!, remoteEndpoint.port!.value);

      _socket!.broadcastEnabled = prevState;

      return _dataCount;
    });
  }

  /// Tells the [UDP] instance to listen for incoming messages.
  ///
  /// Optionally, a [timeout] can be specified. if it is, the [UDP] instance
  /// stops listening after the duration has passed.
  ///
  /// whenever new data is received, it is bundled in a [Datagram] and passed
  /// to the specified [callback].
  ///
  /// A udp instance can be listened to only once.
  ///
  /// returns a [Future] that completes when the time runs out.
  /// the returned value is false if:
  ///
  /// - the udp instance was already listened to;
  ///
  /// - the udp instance is closed;
  ///
  /// - the udp internal state is not valid (e.g. no valid socket);
  ///
  /// the returned value is true otherwise.
  Future<bool> listen(DatagramCallback callback, {Duration? timeout}) async {
    // callback must not be null.
    assert(callback != null);

    if (_socket == null || _closed || _listening) return Future.value(false);

    _listening = true;

    _streamSubscription = _socket!.listen((event) {
      if (event == RawSocketEvent.read) {
        callback(_socket!.receive());
      }
    });

    if (timeout == null) return Future.value(true);

    return Future.delayed(timeout).then((value) {
      _streamSubscription?.cancel();
      return true;
    });
  }

  /// closes the [UDP] instance and the underlying socket.
  void close() {
    _listening = false;

    _closed = true;

    _streamSubscription?.cancel();

    _socket?.close();
  }
}
