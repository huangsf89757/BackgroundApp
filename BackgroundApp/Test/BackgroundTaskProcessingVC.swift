//
//  BackgroundTaskProcessingVC.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/11.
//

import Foundation
import UIKit
import BackgroundTasks

/*
 // 前台任务：
 1、定时生成「测试文件」，存入 Document 中
 // 后台任务：
 2、将「测试文件」备份到 Cache 中
 3、模拟一个网络请求操作，将需要上传到服务端的「测试文件」按顺序逐个上传到服务端，上传成功一个就删除一个
 - 可以将「测试文件」想象成分卷压缩后的日志
 - 假设服务端为 Download 文件夹
 4、整个任务如果超时，则从 Cache 中将「测试文件」还原到 Document 中，清空 Cache
 */

class BackgroundTaskProcessingVC: DemoVC {
    let identifier = "com.microtechmd.BackgroundApp.background.task.processing"
    
    override func viewDidLoad() {
        type = .bgTaskProcessing
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

extension BackgroundTaskProcessingVC {
    // 注册
    func register() {
        let isSuccess = BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
            guard let task = task as? BGProcessingTask else {
                self.log("task is not a BGProcessingTask obj")
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
        let request = BGProcessingTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60) // 设置任务的最早开始时间
//        request.requiresNetworkConnectivity = true                      // 设置任务需要网络连接
//        request.requiresExternalPower = false                           // 设置任务不需要充电时才执行
        do {
            try BGTaskScheduler.shared.submit(request)
            self.log("submit success")
            self.log("debug") // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.microtechmd.BackgroundApp.background.processing"]
        } catch {
            self.log("submit failure: \(error)")
        }
    }
    
    // 处理
    func handle(task: BGProcessingTask) {
        self.log("handle task start")
        task.expirationHandler = {
            self.log("handle task, expiration")
            let isRestore = TestFile.restore()
            if isRestore {
                self.log("handle task, expiration, restore success")
                let isCleanCache = TestFile.cleanCache()
                if isCleanCache {
                    self.log("handle task, expiration, cleanCache success")
                } else {
                    self.log("handle task, expiration, cleanCache failure")
                }
            } else {
                self.log("handle task, expiration, restore failure")
            }
        }
        let isBackup = TestFile.backup()
        if isBackup {
            self.log("handle task, backup success")
            let isUpload = TestFile.upload()
            if isUpload {
                self.log("handle task, upload success")
                let isCleanCache = TestFile.cleanCache()
                if isCleanCache {
                    self.log("handle task, cleanCache success")
                    task.setTaskCompleted(success: true)
                } else {
                    self.log("handle task, cleanCache failure")
                    task.setTaskCompleted(success: false)
                }
            } else {
                self.log("handle task, upload failure")
                task.setTaskCompleted(success: false)
            }
        } else {
            self.log("handle task, backup failure")
            task.setTaskCompleted(success: false)
        }
        self.log("handle task end")
    }
}
