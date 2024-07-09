//
//  webOSTVService.swift
//  connectSwift
//
//  Created by BonghuiJo on 5/23/24.
//

import Foundation
import ConnectSDK

class WebOSTVService: NSObject, ObservableObject, ConnectableDeviceDelegate, DeviceServiceDelegate {
    
    private var mDevice: ConnectableDevice?
    private var deviceService: DeviceService?
    weak var discoveryListener: DiscoveryListener? // weak 참조로 변경
    
    func initialize(device: ConnectableDevice) {
        mDevice = device
        mDevice?.delegate = self
        deviceService?.delegate = self
        
        deviceService = self.mDevice?.service(withName: "webOS TV")
        deviceService?.connect()  //connectableDeviceConnectionRequired 함수동작 -> 핀코드 동작 설정
        
        print("연결 시도")
        print("connectedService : \(String(describing: mDevice?.connectedServiceNames()))")
        print("requiresPairing : \(String(describing: deviceService?.requiresPairing))")
    }
    
    func disConnect(_ deviceService: ConnectableDevice){
        //        deviceService.service(withName: "webOS TV").disconnect()
        deviceService.disconnect()
    }
    
    
    //기기 컨트롤 매서드
    func volumeUp(){
        mDevice?.volumeControl().volumeUp(success: { _ in
            print("volume up")
        }, failure: { error in
            print("volume up error \(String(describing: error))")
        })
    }
    func volumeDown(){
        mDevice?.volumeControl().volumeDown(success: { _ in
            print("volume Down")
        }, failure: { error in
            print("volume Down error \(String(describing: error))")
        })
    }
    func mouseClick(){
        mDevice?.mouseControl().click(success: { _ in
            print("click success")
        }, failure: { error in
            print("click error \(String(describing: error))")
        })
    }
    func mouseLeft(){
        mDevice?.mouseControl().move(CGVector.init(dx: -10, dy: 0)
                                     , success: { _ in print("move left success")}
                                     , failure: { error in print("fail\(String(describing:error?.localizedDescription))")
        })
    }
    func mouseRight(){
        mDevice?.mouseControl().move(CGVector.init(dx: +10, dy: 0)
                                     , success: { _ in print("move right success")}
                                     , failure: { error in print("fail\(String(describing:error?.localizedDescription))")
        })
    }
    func keyHome(){
        mDevice?.keyControl().home(success: { _ in
            print("key Home")
        }, failure: { error in
            print("key home \(String(describing: error))")
        })
    }
    func keyLeft(){
        mDevice?.keyControl().left(success: { _ in
            print("key left")
        }, failure: { error in
            print("key left \(String(describing: error))")
        })
    }
    func keyRight(){
        mDevice?.keyControl().right(success: { _ in
            print("key right")
        }, failure: { error in
            print("key right \(String(describing: error))")
        })
    }
    func inputText(){
        mDevice?.textInputControl().sendText("h"
                                             , success: { _ in print("success")}
                                             , failure: {error in print("fail\(String(describing:error?.localizedDescription))")})
    }
    
    
    
    
    // ConnectableDeviceDelegate 매서드
    func connectableDeviceConnectionRequired(_ device: ConnectableDevice!, for service: DeviceService!) {
        print("ServiceID \(String(describing: service.serviceDescription.serviceId))")
        //핀코드 설정
        self.mDevice?.setPairingType(DeviceServicePairingTypePinCode)
    }
    func connectableDeviceReady(_ device: ConnectableDevice!) { //기기 연결 준비되었을 때
        print("Connected to device: \(device.friendlyName ?? "Unknown Device")")
    }
    func connectableDevicePairingSuccess(_ device: ConnectableDevice!, service: DeviceService!) { //기기 연결 되었을때
        print("pairingType:\(String(describing:deviceService?.pairingType))")
    }
    func connectableDeviceDisconnected(_ device: ConnectableDevice!, withError error: Error!) { //기기와 연결 끊어졌을 때
        if let e = error {
            print("Disconnected from \(device.friendlyName ?? "Unknown Device"): \(e.localizedDescription)")
        }
    }
    
    
    // DeviceServiceDelegate 매서드
    func deviceServiceConnectionRequired(_ service: DeviceService!) { // 서비스 연결 필요할 때
        print("Connection required for service: \(service.serviceDescription?.serviceId ?? "Unknown Service ID")")
    }
    func deviceServiceConnectionSuccess(_ service: DeviceService!) {   //서비스에 성공적으로 연결되었을 때
        print("Connected to service \(service.serviceDescription?.friendlyName ?? "Unknown Device")")
    }
    func deviceService(_ service: DeviceService!, disconnectedWithError error: Error!) { //서비스 연결중 오류 발생 시
        if let error = error {
            print("Disconnected with error: \(error.localizedDescription)")
        } else {
            print("Disconnected Service")
        }
    }
    func deviceService(_ service: DeviceService!, didFailConnectWithError error: Error!) { //서비스 연결 시도가 실패했을 때
        print("Connection failed with error: \(error.localizedDescription)")
    }
    
    
    //페어링 관련 매서드
    func deviceService(_ service: DeviceService!, pairingRequiredOf pairingType: DeviceServicePairingType, withData pairingData: Any!) { //서비스에 페어링이 필요할 때
        print("Pairing required for service: \(service.serviceDescription?.friendlyName ?? "Unknown Device")")
        //        deviceService?.pair(withData: pairingData)
    }
    func deviceServicePairingSuccess(_ service: DeviceService!) { //서비스 페어링 완료되었을때
        print("Pairing success for service: \(service.serviceDescription?.friendlyName ?? "Unknown Device")")
    }
    func deviceService(_ service: DeviceService!, pairingFailedWithError error: Error!) {
        // 페어링 실패했을 때
        print("Pairing service failed with error: \(error.localizedDescription)")
        
        // UIAlertController 생성
        let alertController = UIAlertController(title: "실패",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
        // OK 버튼 추가
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                    self.discoveryListener?.initialize() // weak 참조를 사용하여 초기화 함수 호출
                }
                alertController.addAction(okAction)
        
        // 메인 스레드에서 경고창 표시
        DispatchQueue.main.async {
            // 현재 활성화된 UIWindowScene 찾기(사용중인 창에 경고창 띄우기)
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                
                // UIWindowScene의 첫 번째 키 윈도우 가져오기
                if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    if let rootViewController = window.rootViewController {
                        // 최상위 ViewController 찾기
                        var topController = rootViewController
                        while let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                        }
                        // 경고창 표시
                        topController.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }//deviceService 페어링 실패
    
}
