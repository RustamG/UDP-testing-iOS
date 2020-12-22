//
//  AppleService.swift
//  simple-app
//
//  Created by Rustam G on 22.12.2020.
//

import Foundation
import Network

class AppleNetworkService: NSObject, LocalNetworkService {

    var listening: Bool = false
    var onUdpMessageReceived: ((UdpMessage) -> Void)?
    
    private var pingConnection: NWConnection?
    private var udpListener: NWListener?
    private var udpConnection: NWConnection?
    private var backgroundQueueUdpListener  = DispatchQueue.global()

    func startListeningUDP() {

        let params = NWParameters.udp
        params.allowLocalEndpointReuse = true
        udpListener = try? NWListener(using: params, on: NWEndpoint.Port(integerLiteral: NetworkConstants.udpPort))

        udpListener?.service = NWListener.Service.init(type: "_appname._udp")

        self.udpListener?.stateUpdateHandler = { update in
          debugPrint("UdpListener.update")
          debugPrint(update)
          switch update {
          case .failed:
            debugPrint("UdpListener.failed")
            self.stopListeningUDP()
          default:
            debugPrint("default update")
          }
        }
        self.udpListener?.newConnectionHandler = { connection in
          debugPrint("new connection arrived")
          debugPrint(connection)
          self.createConnection(connection: connection)
        }
        udpListener?.start(queue: self.backgroundQueueUdpListener)
        listening = true
    }

    func stopListeningUDP() {

        self.udpListener?.cancel()
        self.udpConnection?.cancel()
        listening = false
    }

    func ping() {

        let connection = NWConnection(host: NWEndpoint.Host(NetworkConstants.pingHost),
                                      port: .init(integerLiteral: NetworkConstants.pingPort),
                                      using: .tcp)

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
                debugPrint("pingConnection.state.setup")
            case .preparing:
                debugPrint("pingConnection.state.preparing")
            case .ready:
                debugPrint("pingConnection.state.ready")
                self.handleHasPermissions()
                self.cancelPingConnection()
            case let .failed(error):
                debugPrint("pingConnection.state.failed(\(error)")
                self.cancelPingConnection()
            case .cancelled:
                debugPrint("pingConnection.state.cancelled")
            @unknown default:
                debugPrint("pingConnection.state.unknown")
            }
        }
        pingConnection = connection
        connection.start(queue: DispatchQueue.main)
    }

    func cancelPingConnection() {

        self.pingConnection?.cancel()
        self.pingConnection = nil
    }

    private func createConnection(connection: NWConnection) {

        self.udpConnection = connection

        connection.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .ready:
                debugPrint("ready")
                self.receiveMessage(from: connection)
            case .setup:
                debugPrint("setup")
            case .cancelled:
                debugPrint("cancelled")
            case .preparing:
                debugPrint("Preparing")
            default:
                debugPrint("waiting or failed")
            }
        }
        connection.start(queue: .global())
    }

    private func receiveMessage(from connection: NWConnection) {

        connection.receiveMessage { [weak self] (data, context, _, error) in
            guard
                let self = self,
                let data = data,
                let content = String(data: data, encoding: String.Encoding.utf8) else {
                debugPrint("Couldn't read data")
                return
            }
            connection.cancel()

            let sender: String

            switch connection.endpoint {
            case let .hostPort(host, _):
                sender = "\(host)"
            default:
                sender = ""
            }

            let message = UdpMessage(senderHost: sender, content: content)
            self.onUdpMessageReceived?(message)
        }
    }
}
