//
//  DiscoveryListener.swift
//  connectSwift
//
//  Created by BonghuiJo on 5/24/24.
//

import Foundation
import ConnectSDK
import CoreLocation
import SwiftUI

class DiscoveryListener: NSObject, ObservableObject, DiscoveryManagerDelegate, CLLocationManagerDelegate {
    private var discoveryManager: DiscoveryManager?
    private var locationManager: CLLocationManager!
    
    @Published var webOSTVService = WebOSTVService()
    @Published var devices: [ConnectableDevice] = []
    @Published var deviceCount: Int = 0
    @Published var isScanning: Bool = false

    override init() {
          super.init()
          setupLocationManager()
          initialize()
          
          // WebOSTVService의 discoveryListener 설정....
          webOSTVService.discoveryListener = self
      }
    
    //위치 권한
    private func setupLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("Location access granted.")
        } else {
            print("Location access denied.")
        }
    }

    func initialize() {
        discoveryManager = DiscoveryManager.shared()
        discoveryManager?.pairingLevel = DeviceServicePairingLevelOn
        discoveryManager?.delegate = self

        print("discoveryManager 초기화")
    }
    
    func startScan() {
        guard !isScanning else { return }
        self.isScanning = true
        
        discoveryManager?.stopDiscovery()
        discoveryManager?.startDiscovery()
        print("디바이스 스캔 시작")
        
        DispatchQueue.main.async{
            self.devices.removeAll()
        }
    }
    
    func stopScan() {
        discoveryManager?.stopDiscovery()
        self.isScanning = false
        
        print("디바이스 스캔 중지")
    }

    func connectToDevice(_ device: ConnectableDevice) {
        stopScan()
        webOSTVService.initialize(device: device)
    }
    
    func disconnectFromDevice(_ device: ConnectableDevice) {
        DispatchQueue.main.async {
            self.devices.removeAll { $0 == device } //검색된 디바이스 리스트 초기화
            self.discoveryManager?.deviceStore.removeAll() //deviceStore 삭제
        }
    }

    
    
    // DiscoveryManagerDelegate methods
    func discoveryManager(_ manager: DiscoveryManager!, didFind device: ConnectableDevice!) {
        //AirPlayService(애플기기) 모든 기기 검색
        DispatchQueue.main.async {
//            guard !self.devices.contains(device) else { return }//중복방지
//            self.devices.append(device) //검색된 디바이스 리스트 추가
//            self.deviceCount = self.devices.count
//            print("onDeviceAdded: \(String(describing: device.services   ))")
//            print("onDeviceAdded: \(String(describing: device.friendlyName))")
//            print("현재 디바이스 수: \(self.deviceCount)")
        }
    }
    func discoveryManager(_ manager: DiscoveryManager!, didUpdate device: ConnectableDevice!) {
        //webOSService 기기 검색
        DispatchQueue.main.async {
            // device.services 개수가 2개 이상인 경우에만 배열에 추가
                   guard device.services.count >= 2 else {return}
                   // 중복 방지
                   guard !self.devices.contains(device) else {return}
                   // 검색된 디바이스 리스트 추가
                   self.devices.append(device)
        }
        print("onDeviceUpdated: \(String(describing: device.friendlyName)) \(String(describing: device.services))")
    }
    func discoveryManager(_ manager: DiscoveryManager!, didLose device: ConnectableDevice!) {
        DispatchQueue.main.async {
            print("onDeviceRemoved: \(String(describing: device.friendlyName))")
            self.devices.removeAll { $0 == device }
            self.deviceCount = self.devices.count
            print("현재 디바이스 수: \(self.deviceCount)")
        }
    }
    func discoveryManager(_ manager: DiscoveryManager!, discoveryFailed error: Error!) {
        DispatchQueue.main.async {
            print("onDiscoveryFailed: \(String(describing: error))")
            self.isScanning = false // 스캔 실패 시
        }
    }
}
