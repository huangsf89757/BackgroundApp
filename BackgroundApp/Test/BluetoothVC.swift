//
//  BluetoothVC.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/7.
//

import UIKit
import CoreBluetooth

class BluetoothVC: DemoVC {
   
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var service181F: CBService?
    private var characteristicF001: CBCharacteristic?
    private var characteristicF002: CBCharacteristic?
    private var characteristicF003: CBCharacteristic?
    private var characteristicF004: CBCharacteristic?
    private var characteristicF005: CBCharacteristic?
    
    private let sn = "AiDEX X-AN22224EGS"
    private let uuid_181f = "181F"   // service F000
    private let uuid_f001 = "F001"   // characteristic F001
    private let uuid_f002 = "F002"   // characteristic F002
    private let uuid_f003 = "F003"   // characteristic F003
    private let uuid_f004 = "F004"   // characteristic F004
    private let uuid_f005 = "F005"   // characteristic F005

    override func viewDidLoad() {
        type = .bluetooth
        super.viewDidLoad()
        AppDelegate.setBgFetchMinTime()
        // centralManager
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [
            CBCentralManagerOptionShowPowerAlertKey: true,
            CBCentralManagerOptionRestoreIdentifierKey: "com.microtechmd.BackgroundApp.ble",
        ])
    }
   
}

extension BluetoothVC: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.log("didUpdateState", central.state.rawValue)
        if central.state == .poweredOn {
//            central.scanForPeripherals(withServices: nil) // !!!: app处于后台时，不保活
            central.scanForPeripherals(withServices: [CBUUID(string: uuid_181f)])
            self.log("starScanPeripheral", sn)
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        self.log("willRestoreState", dict)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if self.peripheral == nil, peripheral.name == sn {
            self.peripheral = peripheral
            self.log("didDiscoverPeripheral", sn, peripheral.identifier, "\(RSSI) dBm")
            // connectPeripheral
            central.stopScan()
            peripheral.delegate = self
            central.connect(peripheral)
            self.log("startConnectPeripheral", sn)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.log("didConnectPeripheral", peripheral.name ?? "UNKNOWN", peripheral.identifier)
        // discoverServices
        self.log("startDiscoverServices", uuid_181f)
        peripheral.discoverServices([CBUUID(string: uuid_181f)])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        self.log("didFailToConnectPeripheral", peripheral.name ?? "UNKNOWN", peripheral.identifier)
        reset()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        self.log("didDisconnectPeripheral", peripheral.name ?? "UNKNOWN", peripheral.identifier)
        reset()
    }
    
    private func reset() {
        self.peripheral = nil
        self.service181F = nil
        self.characteristicF001 = nil
        self.characteristicF002 = nil
        self.characteristicF003 = nil
    }
}

extension BluetoothVC: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard let services = peripheral.services else { return }
        let serviceF000 = services.first { service in
            service.uuid.uuidString == self.uuid_181f
        }
        if self.service181F == nil, let serviceF000 = serviceF000 {
            self.log("didDiscoverServices", self.uuid_181f)
            self.service181F = serviceF000
            // discoverCharacheristics
            let uuids = [uuid_f001, uuid_f002, uuid_f003]
            let UUIDs = uuids.map { uuid in
                CBUUID(string: uuid)
            }
            peripheral.discoverCharacteristics(UUIDs, for: serviceF000)
            self.log("startDiscoverCharacteristics", uuids)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard let characteristics = service.characteristics else { return }
        let characteristicF001 = characteristics.first { characteristic in
            characteristic.uuid.uuidString == uuid_f001
        }
        if self.characteristicF001 == nil, let characteristicF001 = characteristicF001 {
            self.log("didDiscoverCharacteristic", uuid_f001)
            self.characteristicF001 = characteristicF001
            
            // enableNotify
            peripheral.setNotifyValue(true, for: characteristicF001)
            self.log("startSetNotifyValue", uuid_f001, true)
        }
        
        let characteristicF002 = characteristics.first { characteristic in
            characteristic.uuid.uuidString == uuid_f002
        }
        if self.characteristicF002 == nil, let characteristicF002 = characteristicF002 {
            self.log("didDiscoverCharacteristic", uuid_f002)
            self.characteristicF002 = characteristicF002
            
            // enableNotify
            peripheral.setNotifyValue(true, for: characteristicF002)
            self.log("startSetNotifyValue", uuid_f002, true)
        }
        
        let characteristicF003 = characteristics.first { characteristic in
            characteristic.uuid.uuidString == uuid_f003
        }
        if self.characteristicF003 == nil, let characteristicF003 = characteristicF003 {
            self.log("didDiscoverCharacteristic", uuid_f003)
            self.characteristicF003 = characteristicF003
            
            // enableNotify
            peripheral.setNotifyValue(true, for: characteristicF003)
            self.log("startSetNotifyValue", uuid_f003, true)
        }
        
        let characteristicF004 = characteristics.first { characteristic in
            characteristic.uuid.uuidString == uuid_f004
        }
        if self.characteristicF004 == nil, let characteristicF004 = characteristicF004 {
            self.log("didDiscoverCharacteristic", uuid_f004)
            self.characteristicF004 = characteristicF004
            
            // enableNotify
            peripheral.setNotifyValue(true, for: characteristicF004)
            self.log("startSetNotifyValue", uuid_f004, true)
        }
        
        let characteristicF005 = characteristics.first { characteristic in
            characteristic.uuid.uuidString == uuid_f005
        }
        if self.characteristicF005 == nil, let characteristicF005 = characteristicF005 {
            self.log("didDiscoverCharacteristic", uuid_f005)
            self.characteristicF003 = characteristicF005
            
            // enableNotify
            peripheral.setNotifyValue(true, for: characteristicF005)
            self.log("startSetNotifyValue", uuid_f005, true)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        if characteristic.uuid.uuidString == uuid_f001 {
            self.log("didSetNotifyValue", uuid_f001, characteristic.isNotifying)
        }
        if characteristic.uuid.uuidString == uuid_f002 {
            self.log("didSetNotifyValue", uuid_f002, characteristic.isNotifying)
        }
        if characteristic.uuid.uuidString == uuid_f003 {
            self.log("didSetNotifyValue", uuid_f003, characteristic.isNotifying)
        }
        if characteristic.uuid.uuidString == uuid_f004 {
            self.log("didSetNotifyValue", uuid_f004, characteristic.isNotifying)
        }
        if characteristic.uuid.uuidString == uuid_f005 {
            self.log("didSetNotifyValue", uuid_f005, characteristic.isNotifying)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if characteristic.uuid.uuidString == uuid_f001 {
            self.log("didUpdateCharacteristicValue", uuid_f001, characteristic.value?.toHexString() ?? "nil")
        }
        if characteristic.uuid.uuidString == uuid_f002 {
            self.log("didUpdateCharacteristicValue", uuid_f002, characteristic.value?.toHexString() ?? "nil")
        }
        if characteristic.uuid.uuidString == uuid_f003 {
            self.log("didUpdateCharacteristicValue", uuid_f003, characteristic.value?.toHexString() ?? "nil")
        }
        if characteristic.uuid.uuidString == uuid_f004 {
            self.log("didUpdateCharacteristicValue", uuid_f004, characteristic.value?.toHexString() ?? "nil")
        }
        if characteristic.uuid.uuidString == uuid_f005 {
            self.log("didUpdateCharacteristicValue", uuid_f005, characteristic.value?.toHexString() ?? "nil")
        }
    }
    
}
