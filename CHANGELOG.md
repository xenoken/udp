## 5.0.2
- Fixed an exception occurring when binding UDP receivers bound to a multicast endpoint.
- Added additional documentation for Endpoints.
- Minor changes.

## 5.0.1
- Updated README.md.

## 5.0.0
- removed "UDP.listen" method.
- added "UDP.asStream" method.
- Minor changes.

## 4.0.1
- Fixed formatting

## 4.0.0
- Migration to null safety.
- Minor changes.

## 3.0.3
- Changes to README.md

## 3.0.2

- Package Maintenance.

## 3.0.1

- Minor improvements.

## 3.0.0

- Added: Multicast support !
- Change: the 'timeout' parameter of 'UDP.listen' is now optional. UDP instances can listen indefinitely now.
- Change: 'Endpoint.IsBroadcast' is now a readonly property.
- Change: in 'Endpoint.unicast', port is now optional. 
- Change: 'UDP.listen' returns a Future<bool>.

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
