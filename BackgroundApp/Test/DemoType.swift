//
//  DemoType.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/12.
//

import Foundation

enum DemoType {
    case time
    case bluetooth
    case localNotification
    case remoteNotification
    case bgFetch
    case bgTaskAppRefresh
    case bgTaskProcessing
    
    case resumeTest
    
    var name: String {
        switch self {
        case .time:
            return "Time"
        case .bluetooth:
            return "Bluetooth"
        case .localNotification:
            return "Notify[Local]"
        case .remoteNotification:
            return "Notify[Remote]"
        case .bgFetch:
            return "BG Fetch"
        case .bgTaskAppRefresh:
            return "BG Task[AppRefresh]"
        case .bgTaskProcessing:
            return "BG Task[Processing]"
            
        case .resumeTest:
            return "ResumeTest"
        }
    }
}
