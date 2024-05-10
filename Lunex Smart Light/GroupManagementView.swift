//
//  GroupManagementView.swift
//  Lunex Smart Light
//
//  Created by Lucas Pereira on 19/04/24.
//

import SwiftUI
import CoreBluetooth

struct GroupManagementView: View {
    @EnvironmentObject var bluetoothViewModel: BluetoothViewModel
    @State private var selectedDevices = Set<CBPeripheral>()
    @State private var groupName = ""

    var body: some View {
        NavigationView {
            List(bluetoothViewModel.discoveredDevices, id: \.identifier) { device in
                MultipleSelectionRow(device: device, isSelected: selectedDevices.contains(device)) {
                    if selectedDevices.contains(device) {
                        selectedDevices.remove(device)
                    } else {
                        selectedDevices.insert(device)
                    }
                }
            }
            .navigationTitle("Create Group")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Group") {
                        let newGroup = BluetoothViewModel.DeviceGroup(name: groupName, devices: Array(selectedDevices))
                        bluetoothViewModel.deviceGroups.append(newGroup)
                    }
                }
            }
        }
    }
}


struct MultipleSelectionRow: View {
    var device: CBPeripheral
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            Text(device.name ?? "Unknown")
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
        .onTapGesture(perform: action)
    }
}

