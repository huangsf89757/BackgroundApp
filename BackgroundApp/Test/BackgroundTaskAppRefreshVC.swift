//
//  BackgroundTaskAppRefreshVC.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/12.
//

import Foundation
import UIKit
import BackgroundTasks

class BackgroundTaskAppRefreshVC: DemoVC {
    let identifier = "com.microtechmd.BackgroundApp.background.task.appRefresh"
    
    override func viewDidLoad() {
        type = .bgTaskAppRefresh
        super.viewDidLoad()
        let _ = TestFile.cleanDocument()
        rhythm = 10
        register()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    // 前台时，每分钟生成一份「测试文件」
    override func timerEvent(time: Date, timeStr: String) {
        guard UIApplication.shared.applicationState == .active else {
            return
        }
        let _ = TestFile.generate(time: time)
    }
        
    // 进入后台后，提交后台任务
    @objc
    private func appDidEnterBackground() {
        submit()
    }
}

extension BackgroundTaskAppRefreshVC {
    // 注册
    func register() {
        let isSuccess = BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
            guard let task = task as? BGAppRefreshTask else {
                self.log("task is not a BGAppRefreshTask obj")
                return
            }
            self.handle(task: task)
        }
        if isSuccess {
            self.log("register success")
        } else {
            self.log("register failure")
        }
    }
    
    // 提交
    func submit() {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60) // 设置任务的最早开始时间
        do {
            try BGTaskScheduler.shared.submit(request)
            self.log("submit success")
            self.log("debug") // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.microtechmd.BackgroundApp.background.fetch"]
        } catch {
            self.log("submit failure: \(error)")
        }
    }
    
    // 处理
    func handle(task: BGAppRefreshTask) {
        self.log("handle task start")
        task.expirationHandler = {
            self.log("handle task, expiration")
        }
        let cleanDocument = TestFile.cleanDocument()
        if cleanDocument {
            self.log("handle task, cleanDocument success")
            task.setTaskCompleted(success: true)
        } else {
            self.log("handle task, cleanDocument failure")
            task.setTaskCompleted(success: false)
        }
        self.log("handle task end")
    }
}
