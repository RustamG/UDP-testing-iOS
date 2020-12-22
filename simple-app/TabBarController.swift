//
//  TabBarController.swift
//  simple-app
//
//  Created by Rustam G on 22.12.2020.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupTabs()
    }

    private func setupTabs() {

        viewControllers = createViewControllers()
    }

    private func createViewControllers() -> [UIViewController] {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cocoaAsyncViewController = storyboard.instantiateViewController(withIdentifier: "UdpViewController") as! UdpViewController
        cocoaAsyncViewController.tabBarItem = UITabBarItem(title: "CocoaAsyncSocket", image: nil, tag: 0)
        cocoaAsyncViewController.service = CocoaAsyncSocketService()

        let appleNetworkViewController = storyboard.instantiateViewController(withIdentifier: "UdpViewController") as! UdpViewController
        appleNetworkViewController.tabBarItem = UITabBarItem(title: "Apple Network", image: nil, tag: 1)
        appleNetworkViewController.service = AppleNetworkService()

        return [cocoaAsyncViewController, appleNetworkViewController]
    }
}
