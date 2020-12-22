# UDP-testing-iOS

### Description
This app was created for testing purposes of receiving UDP-broadcast messages in iOS. The app is split into 2 tabs:
1. CocoaAsyncSocket. Uses [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) library for listening to UDP-broadcasts in the local network.
2. Apple Network. Uses Apple's [Network framework](https://developer.apple.com/documentation/network).

"Ping" button is used to trigger Local Network permission dialog (iOS 14+).
On iOS 14 I couldn't make it to work with Network framework in a reasonable time. However the same code works on iOS 13. 
Observations regarding Local Network permissions are listed below.

### Installation

To install [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) dependency run the following:
```bash
pod install
```

### Observations
1. On iOS 13 receiving UDP-broadcast messages simply works using both CocoaAsyncSocket and Network framework. 
2. On iOS 14 Local Network permission is required for receiving UDP-broadcasts. 
3. As of iOS 14.2 Apple haven't provided the API to check wether the app has Local Network permission. And there's no API to directly ask for the permission.
4. We can trigger requesting the permission by making a connection to something in the network. "Ping" button in the app is used for that. 
After making such test connection the app appears in the `Settings -> Privacy -> Local Network` section, so the user is able to enable/disable the permission.
5. When the permission is missing, the connection state will be `.waiting` with `NWError.posix.ENETDOWN` error. However this error might not uniquely specify that we are missing the permission. 
In iOS 14.**2+** we can understand if there is no permission by performing a check `if case .localNetworkDenied? = connection.currentPath?.unsatisfiedReason`.
6. Sometimes recieving UDP broadcast messages works even with permission beign unchecked. Couldn't figure out the steps to replicate though.
7. The testing should be performed on real iOS devices. It works different in Simulator.
8. CocoaAsyncSocket consumes much less CPU than Network framework when listening to UDP messages. ~1% vs ~5% - tested on iOS 13.

### Other notes
There are messages on Apple developer forum stating that apps should [request](https://developer.apple.com/contact/request/networking-multicast) 
[Networking Multicast entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_networking_multicast) to use Local Network.
Useful information regarding Local Network Permission on Apple Developer [FAQ page](https://developer.apple.com/forums/thread/663858).
