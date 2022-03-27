/*
 *
 *  Copyright 2019-2022 Kennedy Tochukwu Ekeoha
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
import 'dart:collection';

import 'udp_endpoint.dart';

typedef DatagramCallback = void Function(Datagram?);

/// [UDP] sends or receives UDP packets.
///
/// a [UDP] instance can send packets to or receive packets from [Endpoint]s.
class UDP {
  /// Returns True if this [UDP] instance is closed.
  bool get closed => _closed;

  /// The [Endpoint] this [UDP] instance is bound to.
  Endpoint get local => _localep;

  /// Reference to underlying [RawDatagramSocket].
  RawDatagramSocket? get socket => _socket;

  // Reference to the local endpoint
  final Endpoint _localep;

  // Reference to the internal socket
  RawDatagramSocket? _socket;

  // Reference to the socket broadcast stream
  Stream? _socketBroadcastStream;

  // Reference to the UDP instance broadcast stream
  Stream<Datagram?>? _udpBroadcastStream;

  // Reference to the internal stream controller
  StreamController? _streamController;

  // Stores the set of internal stream subscriptions
  final HashSet<StreamSubscription> _streamSubscriptions =
      HashSet<StreamSubscription>();

  // Is the UDP instance closed?
  bool _closed = false;

  // Internal ctor
  UDP._(this._localep);

  /// Creates a new [UDP] instance.
  ///
  /// The [UDP] instance is created by the OS and bound to a local [Endpoint].
  ///
  /// [ep] - the local endpoint.
  ///
  /// returns the [UDP] instance.
  static Future<UDP> bind(Endpoint ep) async {
    var udp = UDP._(ep);

    if (ep.isMulticast) {
      var anyAddress = InternetAddress.anyIPv4;
      udp._socket = await RawDatagramSocket.bind(anyAddress, ep.port!.value);
      udp._socket!.joinMulticast(ep.address!);
    } else {
      udp._socket = await RawDatagramSocket.bind(ep.address!, ep.port!.value);
    }

    return udp;
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

      var _dataCount = _socket!
          .send(data, remoteEndpoint.address!, remoteEndpoint.port!.value);

      _socket!.broadcastEnabled = prevState;

      return _dataCount;
    });
  }

  /// Tells the [UDP] instance to listen for incoming messages.
  ///
  /// Optionally, a [timeout] can be specified. if it is, the [UDP] instance
  /// stops listening after the duration has passed. The instance is closed too,
  /// making the instance unusable after the timeout runs out.
  ///
  /// Whenever new data is received, it is bundled in a [Datagram] and pushed into the stream.
  ///
  /// Returns a [Stream] that can be listened to.
  Stream<Datagram?> asStream({Duration? timeout}) {
    _streamController ??= StreamController<Datagram>();

    _udpBroadcastStream ??= (_streamController as StreamController<Datagram?>)
        .stream
        .asBroadcastStream();

    if (_socket == null || _closed) return _udpBroadcastStream!;

    if (_socketBroadcastStream == null) {
      _socketBroadcastStream = _socket!.asBroadcastStream();

      var streamSubscription = _socketBroadcastStream!.listen((event) {
        if (event == RawSocketEvent.read) {
          (_streamController as StreamController<Datagram?>)
              .add(_socket!.receive());
        }
      });

      if (!_streamSubscriptions.contains(streamSubscription)) {
        _streamSubscriptions.add(streamSubscription);
      }
    }

    if (timeout == null) return _udpBroadcastStream!;

    Future.delayed(timeout).then((value) => close());

    return _udpBroadcastStream!;
  }

  /// Closes the [UDP] instance and the underlying socket.
  void close() {
    _closed = true;
    _socket?.close();
    _socket = null;
    _socketBroadcastStream = null;
    _streamController?.close();
    _streamSubscriptions.forEach((streamSubscription) {
      streamSubscription.cancel();
    });
    _streamSubscriptions.clear();
  }
}
