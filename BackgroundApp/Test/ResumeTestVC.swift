//
//  ResumeTestVC.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/12.
//

import UIKit
import CoreBluetooth

class ResumeTestVC: DemoVC {
    
    // 0: nil
    // 1: init centralManager
    // 2: scan nil
    // 3: scan 181F
    var value = 3 {
        didSet {
            if value > 0 {
                centralManager = CBCentralManager(delegate: self, queue: nil, options: [
                    CBCentralManagerOptionShowPowerAlertKey: true,
                ])
                self.log("init centralManager")
            }
            if value > 2, centralManager.state == .poweredOn {
                centralManager.scanForPeripherals(withServices: [CBUUID(string: uuid_181f)])
                self.log("starScanPeripheral", "181F")
            }
            else if value > 1, centralManager.state == .poweredOn {
                centralManager.scanForPeripherals(withServices: nil)
                self.log("starScanPeripheral", "nil")
            }
        }
    }
   
    private var centralManager: CBCentralManager!
    private let uuid_181f = "181F"
    
    override func viewDidLoad() {
        type = .bluetooth
        super.viewDidLoad()
        AppDelegate.setBgFetchMinTime()
        
        
        guard value > 0 else {
            return
        }
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [
            CBCentralManagerOptionShowPowerAlertKey: true,
        ])
        self.log("init centralManager")
    }
   
}

extension ResumeTestVC: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.log("didUpdateState", central.state.rawValue)
        if central.state == .poweredOn {
            if value > 2 { 
                central.scanForPeripherals(withServices: [CBUUID(string: uuid_181f)])
                self.log("starScanPeripheral", "181F")
            }
            else if value > 1 {
                central.scanForPeripherals(withServices: nil)
                self.log("starScanPeripheral", "nil")
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.log("didDiscoverPeripheral", peripheral.name ?? "UNKNOWN", peripheral.identifier, "\(RSSI) dBm")
    }
}
