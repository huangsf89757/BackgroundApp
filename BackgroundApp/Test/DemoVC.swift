//
//  DemoVC.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/12.
//

import Foundation
import UIKit

class DemoVC: UIViewController {
    // 类型
    var type: DemoType = .time
    // 节律
    var rhythm = 1
    // 总数
    var count = 0
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.log("viewDidLoad")
        
        // label
        timeLabel.frame = view.bounds
        view.addSubview(timeLabel)
        
        // tip
        var delay = GlobalTimer.delay
        self.timeLabel.text = "\(delay)秒后启动定时器"
        timerTip()
        func timerTip() {
            delay -= 1
            guard delay >= 0 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.timeLabel.text = "\(delay)秒后启动定时器"
                timerTip()
            }
        }
        
        // timer
        NotificationCenter.default.addObserver(self, selector: #selector(timerAction(_:)), name: NSNotification.Name("Notify_timer"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.log("viewWillAppear")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.log("viewDidAppear")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.log("viewWillDisappear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.log("viewDidDisappear")
    }
    
    
    // 在子类中重写
    func timerEvent(time: Date, timeStr: String) {
        
    }
}

extension DemoVC {
    @objc private func timerAction(_ sender: Notification) {
        guard let userInfo = sender.userInfo else { return }
        guard let time = userInfo["time"] as? Date else { return }
        guard let timeStr = userInfo["timeStr"] as? String else { return }
        timeLabel.text = timeStr
        
        count += 1
        if count % rhythm == 0 {
            timerEvent(time: time, timeStr: timeStr)
        }
    }
}


extension DemoVC {
    func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let message = items.map { "\($0)" }.joined(separator: separator)
        print("\(self.type.name):", message)
    }

}
