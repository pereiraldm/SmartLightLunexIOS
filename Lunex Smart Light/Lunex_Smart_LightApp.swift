//
//  Lunex_Smart_LightApp.swift
//  Lunex Smart Light
//
//  Created by Lucas Pereira on 12/12/23.
//

import SwiftUI

@main
struct Lunex_Smart_LightApp: App {
    @StateObject private var bluetoothViewModel = BluetoothViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bluetoothViewModel)
        }
    }
}
