//
//  GlobalTimer.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/7.
//

import Foundation
import UIKit

class GlobalTimer {
    static let delay: TimeInterval = 10
    private var timer: Timer!
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter
    }()
    static let shared = GlobalTimer()
    private init() {
        timer = Timer(timeInterval: 1, repeats: true, block: { timer in
            let time = Date()
            let timeStr = self.formatter.string(from: time)
            print("GlobalTimer:", timeStr)
            NotificationCenter.default.post(name: NSNotification.Name("Notify_timer"), object: nil, userInfo: ["time": time,  "timeStr": timeStr])
        })
        RunLoop.current.add(timer, forMode: .common)
        timer.fireDate = Date.distantFuture
    }
    
    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.delay) {
            self.timer.fireDate = Date.distantPast
            print("GlobalTimer:", "start")
        }
    }
    func pause() {
        timer.fireDate = Date.distantFuture
        print("GlobalTimer:", "pause")
    }
}
