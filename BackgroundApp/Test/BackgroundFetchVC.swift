//
//  BackgroundFetchVC.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/8.
//

import Foundation
import UIKit
import BackgroundTasks

class BackgroundFetchVC: DemoVC {
    override func viewDidLoad() {
        type = .bgFetch
        super.viewDidLoad()
        AppDelegate.setBgFetchMinTime()
    }
}
