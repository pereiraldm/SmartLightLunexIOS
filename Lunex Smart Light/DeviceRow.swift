//
//  DeviceRow.swift
//  Lunex Smart Light
//
//  Created by Lucas Pereira on 22/04/24.
//

import SwiftUI
import CoreBluetooth

struct DeviceRow: View {
    var device: CBPeripheral
    @EnvironmentObject var bluetoothViewModel: BluetoothViewModel
    @State private var isSelected: Bool = false
    @State private var isShowingRenameSheet = false
    @State private var newName: String = ""
    @State private var deviceToRename: CBPeripheral?

    var body: some View {
        HStack {
            Text(bluetoothViewModel.getDisplayName(for: device))
                .foregroundColor(.white)
                .onTapGesture {
                    isSelected.toggle()
                    bluetoothViewModel.toggleDeviceSelection(device)
                }
            Spacer()
            Image(systemName: "pencil.line")
                .foregroundColor(Color.init(hex: "#FFFFFF"))
                .onTapGesture {
                    self.deviceToRename = device
                    self.newName = bluetoothViewModel.getDisplayName(for: device)
                    self.isShowingRenameSheet = true
                }
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(Color.init(hex: "#FFFFFF"))
                .onTapGesture {
                    isSelected.toggle()
                    bluetoothViewModel.toggleDeviceSelection(device)
                }
        }
        .padding()
        .background(isSelected ? Color.gray.opacity(0.3) : Color.clear) // Change here for a different background color
        .contentShape(Rectangle()) // This ensures the entire area of the row is tappable
        .onTapGesture {
            isSelected.toggle()
            if isSelected {
                bluetoothViewModel.selectedDevices.insert(device)
            } else {
                bluetoothViewModel.selectedDevices.remove(device)
            }
        }
        .onAppear {
            isSelected = bluetoothViewModel.selectedDevices.contains(device)
        }
        .sheet(isPresented: $isShowingRenameSheet) {
            RenameDeviceSheet(
                isPresented: self.$isShowingRenameSheet,
                deviceName: self.$newName,
                onSave: {
                    if let device = self.deviceToRename {
                        self.bluetoothViewModel.renameDevice(device, to: self.newName)
                    }
                }
            )
        }
    }
}

struct RenameDeviceSheet: View {
    @Binding var isPresented: Bool
    @Binding var deviceName: String
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 20) // Espaçador no topo
                
                TextField("Insira o nome desejado...", text: $deviceName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(
                    HStack {
                        Spacer()
                        if !deviceName.isEmpty {
                            Button(action: { self.deviceName = "" }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                )

                HStack {
                    Button("Redefinir") {
                        deviceName = "SmartLight"
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Spacer() // Espaçador entre os botões
                    
                    Button("Salvar") {
                        onSave()
                        isPresented = false
                    }
                    .disabled(deviceName.isEmpty) // Desabilita o botão se o nome estiver vazio
                    .padding()
                    .background(deviceName.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Spacer() // Espaçador no final
            }
            .padding(.horizontal)
            .navigationTitle("Renomear Dispositivo")
            .navigationBarItems(trailing: Button("Fechar") {
                isPresented = false
            })
        }
    }
}
