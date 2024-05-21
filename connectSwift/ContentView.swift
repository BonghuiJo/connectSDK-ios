//
//  ContentView.swift
//  connectSwift
//
//  Created by BonghuiJo on 5/20/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Title")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                HStack {
                                   NavigationLink(destination: ConnectSdkView()) {
                                       Text("ConnectSDK")
                                           .font(.title2)
                                           .padding()
                                           .background(Color.blue)
                                           .foregroundColor(.white)
                                           .cornerRadius(10)
                                   }
                                   NavigationLink(destination: BluetoothView()) {
                                       Text("Bluetooth")
                                           .font(.title2)
                                           .padding()
                                           .background(Color.blue)
                                           .foregroundColor(.white)
                                           .cornerRadius(10)
                                   }
                               }
                Spacer()
            }
            .padding()
        
        }
    }
}

#Preview {
    ContentView()
}

