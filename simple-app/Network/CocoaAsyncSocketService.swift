//
//  CocoaAsyncSocketService.swift
//  simple-app
//
//  Created by Rustam G on 22.12.2020.
//

import CocoaAsyncSocket
import Foundation
import Network

class CocoaAsyncSocketService: NSObject, LocalNetworkService {

    var listening: Bool = false
    var onUdpMessageReceived: ((UdpMessage) -> Void)?

    private var pingConnection: NWConnection?
    private var socket: GCDAsyncUdpSocket?
    private var backgroundQueueUdpListener  = DispatchQueue.global()

    func startListeningUDP() {

        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: backgroundQueueUdpListener)
        socket?.setIPv4Enabled(true)
        socket?.setIPv6Enabled(false)
        do {
            try socket?.bind(toPort: NetworkConstants.udpPort)
            try socket?.enableBroadcast(true)
            try socket?.beginReceiving()
            listening = true
        } catch _ as NSError {
            debugPrint("Issue with setting up listener")
        }
    }

    func stopListeningUDP() {

        socket?.close()
        socket = nil
        listening = false
    }

    func ping() {

        let connection = NWConnection(host: NWEndpoint.Host(NetworkConstants.pingHost),
                                      port: .init(integerLiteral: NetworkConstants.pingPort),
                                      using: .udp)

        connection.stateUpdateHandler = { [weak self] _ in
            guard let self = self else { return }

            switch connection.state {
            case let .waiting(error):
                if #available(iOS 14.2, *) {
                    if case .localNetworkDenied? = connection.currentPath?.unsatisfiedReason {
                        self.handleNoPermissions()
                        return
                    }
                } else {
                    if case let .posix(code) = error {
                        if code == .ENETDOWN {
                            self.handleNoPermissions()
                        }
                    }
                }
            case .setup:
                debugPrint("connection.state.setup")
            case .preparing:
                debugPrint("connection.state.preparing")
            case .ready:
                debugPrint("connection.state.ready")
                self.handleHasPermissions()
                self.cancelPingConnection()
            case let .failed(error):
                debugPrint("connection.state.failed(\(error)")
                self.cancelPingConnection()
            case .cancelled:
                debugPrint("connection.state.cancelled")
            @unknown default:
                debugPrint("connection.state.unknown")
            }
        }
        pingConnection = connection
        connection.start(queue: DispatchQueue.main)
    }

    func cancelPingConnection() {

        self.pingConnection?.cancel()
        self.pingConnection = nil
    }
}

extension CocoaAsyncSocketService: GCDAsyncUdpSocketDelegate {

    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {

        guard let content = String(data: data, encoding: .utf8) else {
            return
        }

        let sender = GCDAsyncUdpSocket.host(fromAddress: address) ?? ""
        let message = UdpMessage(senderHost: sender, content: content)

        onUdpMessageReceived?(message)
    }
}
