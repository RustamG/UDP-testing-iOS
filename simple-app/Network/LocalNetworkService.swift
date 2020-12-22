//
//  LocalNetworkService.swift
//  simple-app
//
//  Created by Rustam G on 22.12.2020.
//

import Foundation

protocol LocalNetworkService: class {

    var listening: Bool { get }

    var onUdpMessageReceived: ((UdpMessage) -> Void)? { get set}

    func ping()
    func cancelPingConnection()
    func startListeningUDP()
    func stopListeningUDP()

    func handleNoPermissions()
    func handleHasPermissions()
}

extension LocalNetworkService {

    func handleNoPermissions() {

        debugPrint("No permission for Local Network yet. iOS may show permission request at this point.")
        // we can run a timer that would check the pingConnection state after certain period.
    }
    
    func handleHasPermissions() {

        debugPrint("Ping went successful. We assume, local network works.")
    }
}

struct UdpMessage {

    var senderHost: String
    var content: String
}
