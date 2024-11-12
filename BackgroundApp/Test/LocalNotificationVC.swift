//
//  LocalNotificationVC.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/8.
//

import Foundation
import UIKit

class LocalNotificationVC: DemoVC {
    
    override func viewDidLoad() {
        type = .localNotification
        super.viewDidLoad()
    }
    
    override func timerEvent(time: Date, timeStr: String) {
        addResumeLocalNotification(time: time, timeStr: timeStr)
    }
    
    func addResumeLocalNotification(time: Date, timeStr: String) {
        let identifier = "com.microtechmd.BackgroundApp.resume.localNotification"
        // 移除
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier]) // 移除未交付的通知
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier]) // 移除已交付的通知
        self.log("removeResumeLocalNotification success")
        // 新建
        let timeInterval: TimeInterval = 60
        let title = "本地通知[Resume(L)]"
        let body = timeStr + " Resume(\(timeInterval))"
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.log("addResumeLocalNotification failure: \(error)")
            } else {
                self.log("addResumeLocalNotification success: \(title) \(body)")
            }
        }
    }
}
