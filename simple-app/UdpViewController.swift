//
//  ViewController.swift
//  simple-app
//
//  Created by Rustam G on 19.12.2020.
//

import CocoaAsyncSocket
import Network
import UIKit


class UdpViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var pingButton: UIButton!
    @IBOutlet weak var startStopButton: UIButton!

    var service: LocalNetworkService!

    private lazy var dateFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    private var listening = false {
        didSet {
            startStopButton.setTitle(listening ? "Stop" : "Start", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = ""

        service.onUdpMessageReceived = { [weak self] message in
            guard let self = self else { return }
            let logEntry = "⏬\(self.dateFormatter.string(from: Date())) \(message.senderHost) -> \(message.content)\n"
            debugPrint(logEntry)
            DispatchQueue.main.async { [weak self] in
                self?.textView.text += logEntry
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        service.stopListeningUDP()
    }

    @IBAction func pingClicked(_ sender: Any) {

        service.ping()
    }

    @IBAction func clearClicked(_ sender: Any) {

        textView.text = ""
    }

    @IBAction func startStopClicked(_ sender: Any) {

        if listening {
            stopListeningUDP()
        } else {
            startListeningUDP()
        }
    }

    private func startListeningUDP() {

        service.startListeningUDP()
        listening = service.listening
    }

    private func stopListeningUDP() {

        service.stopListeningUDP()
        listening = service.listening
    }

    private func stopPingConnection() {

        service.cancelPingConnection()
    }
}
