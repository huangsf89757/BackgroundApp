//
//  AppDelegate.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/7.
//

import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var timerCount = 0
    private var notifyCount = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 生命周期
        addAppLifeCycleObserver()
        // 通知
        requestNotificationPermission()
        // 移除已有的本地通知
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        // 定时器
        NotificationCenter.default.addObserver(self, selector: #selector(timerAction(_:)), name: NSNotification.Name("Notify_timer"), object: nil)
        GlobalTimer.shared.start()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        print("Scene:", "configurationForConnectingSceneSession")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        print("Scene:", "didDiscardSceneSessions")
    }
    
}

// MARK: - Life cycle
extension AppDelegate {
    private func addAppLifeCycleObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidFinishLaunching), name: UIApplication.didFinishLaunchingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    @objc
    private func appDidFinishLaunching() {
        print("App:", "didFinishLaunching")
    }
    
    @objc
    private func appDidBecomeActive() {
        print("App:", "didBecomeActive")
    }
    
    @objc
    private func appWillResignActive() {
        print("App:", "willResignActive")
    }
    
    @objc
    private func appDidEnterBackground() {
        print("App:", "didEnterBackground")
        self.timerCount = 0
        self.notifyCount = 0
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        //            print("Test:", "appDidEnterBackground", "[1]")
        //        }
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        //            print("Test:", "appDidEnterBackground", "[2]")
        //        }
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        //            print("Test:", "appDidEnterBackground", "[3]")
        //        }
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
        //            print("Test:", "appDidEnterBackground", "[4]")
        //        }
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        //            print("Test:", "appDidEnterBackground", "[5]")
        //        }
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
        //            print("Test:", "appDidEnterBackground", "[6]")
        //        }
    }
    
    @objc
    private func appWillEnterForeground() {
        print("App:", "willEnterForeground")
    }
    
    @objc
    private func appWillTerminate() {
        print("App:", "willTerminate")
    }
    
    @objc
    private func appDidReceiveMemoryWarning() {
        print("App:", "didReceiveMemoryWarning")
    }
}

// MARK: - Notification
extension AppDelegate {
    /// 申请通知权限
    private func requestNotificationPermission() {
        print("Notification:", "requestNotificationPermission", "start")
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification:", "requestNotificationPermission", "permission granted")
            } else {
                print("Notification:", "requestNotificationPermission", "permission denied")
            }
        }
    }
    
    /// 显示通知（本地和远程）
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
        print("Notification[L/R]:", "willPresentNotification", notification.request.content.userInfo)
    }
}

// MARK: - 远程通知
extension AppDelegate {
    static func registerRemoteNotification() {
        UIApplication.shared.registerForRemoteNotifications()
        print("Notification[R]:", "registerRemoteNotification", "start")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Notification[R]:", "registerRemoteNotification", "success", deviceToken.toHexString())
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("Notification[R]:", "registerRemoteNotification", "failure", error.localizedDescription)
    }
    
    /// 点击远程通知
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Notification[R]:", "didReceiveRemoteNotification", userInfo)
        completionHandler(.noData)
    }
}

// MARK: - 本地通知
extension AppDelegate: UNUserNotificationCenterDelegate {
    /// 点击本地通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        print("Notification[L]:", "didReceiveNotification", response.notification.request.content.userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        if let notification = notification {
            print("Notification[L]:", "openSettingsForNotification", notification.request.content.userInfo)
        } else {
            print("Notification[L]:", "openSettingsForNotification", "nil")
        }
    }
}

// MARK: - Timer
extension AppDelegate {
    @objc private func timerAction(_ sender: Notification) {
        guard let userInfo = sender.userInfo else { return }
        //        guard let time = userInfo["time"] as? Date else { return }
        guard let timeStr = userInfo["timeStr"] as? String else { return }
        
        // 后台运行时，定时10s提醒用户：我还活着
        if UIApplication.shared.applicationState == .background {
            self.timerCount += 1
            if self.timerCount % 10 == 0 {
                self.notifyCount += 1
                self.addBackgroundAliveNotification(timeStr: timeStr)
            }
        }
    }
    
    private func addBackgroundAliveNotification(timeStr: String) {
        guard UIApplication.shared.applicationState == .background else {
            return
        }
        let title = "本地通知[Alive][\(notifyCount)]"
        let body = timeStr
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "com.microtechmd.BackgroundApp.alive", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification[L]:", "addBackgroundAliveNotification failure: \(error)")
            } else {
                print("Notification[L]:", "addBackgroundAliveNotification success: \(title) \(body)")
            }
        }
    }
}

// MARK: - BG Fetch
extension AppDelegate {
    static func setBgFetchMinTime() {
        let interval: TimeInterval = 1 * 60
        print("BG Fetch:", "setMinimumBackgroundFetchInterval(\(interval))")
        UIApplication.shared.setMinimumBackgroundFetchInterval(interval)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("BG Fetch:", "performFetchWithCompletionHandler")
        //        print("BG Fetch:", "handle task start")
        //        let cleanDocument = TestFile.cleanDocument()
        //        if cleanDocument {
        //            print("BG Fetch:", "handle task, cleanDocument success")
        //        } else {
        //            print("BG Fetch:", "handle task, cleanDocument failure")
        //        }
        //        print("BG Fetch:", "handle task end")
        
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let vc = window.rootViewController as? ResumeTestVC else {
            print("BG Fetch:", "bluetoothVC = nil")
            return
        }
        if vc.value == 0 {
//            vc.value = 1
//            print("BG Fetch:", "0 -> 1") // 不保活
            
//            vc.value = 2
//            print("BG Fetch:", "0 -> 2") // 不保活
            
//            vc.value = 3
//            print("BG Fetch:", "0 -> 3") // 保活
        }
        else if vc.value == 1 {
//            vc.value = 2
//            print("BG Fetch:", "1 -> 2") // 不保活
            
//            vc.value = 3
//            print("BG Fetch:", "1 -> 3") // 保活
        }
        else if vc.value == 2 {
//            vc.value = 3
//            print("BG Fetch:", "2 -> 3") // 保活
        }
        
        completionHandler(.noData)
    }
}
