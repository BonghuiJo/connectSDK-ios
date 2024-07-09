//
//  connectSDK.swift
//  connectSwift
//
//  Created by BonghuiJo on 5/20/24.
//

import SwiftUI
import ConnectSDK
struct ConnectSdkView: View {
    @StateObject private var discoveryListener = DiscoveryListener()
    @StateObject private var webOSTVService = WebOSTVService()
    
    
    //기본버튼 디자인
    func basicBtn(text: String)-> some View {
        Text(text)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    var body: some View {
        
        VStack {
            HStack {
                Button(action: {
                    discoveryListener.startScan()
                }) {
                    basicBtn(text: "Start Scan")
                }
                Button(action: {
                    discoveryListener.stopScan()
                }) {
                    basicBtn(text: "Stop Scan")
                }
            }
            
            Spacer(minLength: 20)
            
            List(discoveryListener.devices, id: \.self) { device in
                HStack {
                    Text(device.friendlyName ?? "Unknown Device")
                    Spacer()
                }
                .contentShape(Rectangle()) // HStack 전체를 터치 가능 영역
                .onTapGesture {
                        webOSTVService.initialize(device: device) //연결매서드 호출
                        discoveryListener.disconnectFromDevice(device)//디바이스 리스트 초기화 및 deviceStore삭제
                }
            }
            
            
            HStack{
                Button(action: {
                    webOSTVService.volumeUp()
                }) {
                    basicBtn(text: "VolumeUp")
                }
                Button(action: {
                    webOSTVService.volumeDown()
                }) {
                    basicBtn(text: "VolumeDown")
                }
            }
            Spacer()
            
            HStack{
                Button(action: {
                    webOSTVService.mouseClick()
                }){
                    basicBtn(text: "Click")
                }
                Button(action: {
                    webOSTVService.mouseLeft()
                }){
                    basicBtn(text: "←M")
                }
                Button(action: {
                    webOSTVService.mouseRight()
                }){
                    basicBtn(text: "M→")
                }
            }
            
            HStack{
                Button(action: {
                    webOSTVService.keyHome()
                }){
                    basicBtn(text: "keyHome")
                }
                Button(action: {
                    webOSTVService.keyLeft()
                }){
                    basicBtn(text: "←Key")
                }
                Button(action: {
                    webOSTVService.keyRight()
                }){
                    basicBtn(text: "Key→")
                }
            }
        }
        .navigationTitle("ConnectSDK View")
    }
    
    
    
}
#Preview {
    ConnectSdkView()
}

