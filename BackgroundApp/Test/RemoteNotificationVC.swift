//
//  RemoteNotificationVC.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/8.
//

import Foundation
import UIKit

class RemoteNotificationVC: DemoVC {
    override func viewDidLoad() {
        type = .remoteNotification
        super.viewDidLoad()
        AppDelegate.registerRemoteNotification() // !!!: 注意可能跟request授权时的时间上的问题
    }
}

