## 3.0.0

- Added: Muticast support.
- Change: the 'timeout' parameter of UDP.listen is now optional. udp instance are now capable of listening forever.
- Change: Endpoint.IsBroadcast is now a readonly property.
- Change: int Endpoint.unicast, port is now optional. 

## 2.0.0

- Added: 'UDP.closed' property: readonly property that is True on closed UDP instances.
- Added: It is not possible to call 'UDP.listen' on a udp instance that was already listening.
- Added: 'UDP.send' returns -1 on closed instances.
- Change: UDPReceiveCallback renamed to DatagramCallback.

## 1.0.2

- Package Maintenance: description rewritten.


## 1.0.1

- Minor improvements.


## 1.0.0

- Initial version.
