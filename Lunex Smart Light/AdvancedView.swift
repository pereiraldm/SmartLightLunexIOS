//
//  AdvancedView.swift
//  Lunex Smart Light
//
//  Created by Lucas Pereira on 12/12/23.
//

import SwiftUI

struct AdvancedView: View {
    @EnvironmentObject var bluetoothViewModel: BluetoothViewModel
    @State private var isToggleButtonEnabled: Bool = false
    @State private var sliderValue: Double = 0
    @State private var brightnessValue: Double = 0
    @State private var lastBrightnessValue: Double? = nil
    @State private var lastSliderValue: Double? = nil
    
    var adjustedSliderValue: Double {
        return 3000 + (sliderValue * (6500 - 3000) / 255)
    }

    var body: some View {
        ZStack {
        // Cor de fundo que abrange toda a tela
        Color(hex: "#1b2c5d")
                .edgesIgnoringSafeArea([.leading, .trailing])
            
        VStack {
            Rectangle()
                .fill(Color(hex: "#f37021"))
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                .overlay(
                    Text(displayConnectedDevices())
                        .foregroundColor(Color(hex: "#1b2c5d"))
                        .bold()
                )
            if bluetoothViewModel.isConnected {
                HStack {
                    Image(systemName: bluetoothViewModel.whiteColdLightOn ? "lightbulb.fill" : "lightbulb")
                        .foregroundColor(bluetoothViewModel.whiteColdLightOn ? .white : .gray)
                    
                    Image(systemName: bluetoothViewModel.whiteHotLightOn ? "lightbulb.fill" : "lightbulb")
                        .foregroundColor(bluetoothViewModel.whiteHotLightOn ? .yellow : .gray)
                }
                .padding()
                HStack {
                    Text("ATIVAR")
                        .foregroundColor(Color(hex: "#1b2c5d"))
                        .bold()
                    
                    Toggle("", isOn: $isToggleButtonEnabled)
                        .labelsHidden()
                }
                .padding() // Aplica padding ao HStack para o espaçamento interno
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#f37021"))
                )
                .onChange(of: isToggleButtonEnabled) { isEnabled in
                    if isEnabled {
                        bluetoothViewModel.sendCommandToAllDevices("avancado")
                        // Enviar o valor atual do Slider imediatamente após ativar o ToggleButton
                        bluetoothViewModel.sendCommandToAllDevices("\(sliderValue)")
                    } else {
                        bluetoothViewModel.sendCommandToAllDevices("desligarAvancado")
                    }
                }
                //Spacer()
                VStack(alignment: .leading) {
                Slider(value: $sliderValue, in: 0...255, step: 1)
                    .disabled(!isToggleButtonEnabled)
                    .onChange(of: sliderValue) { newValue in
                        lastSliderValue = newValue
                        // Iniciar um timer para atrasar o envio do comando
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                            if lastSliderValue == newValue { // Verifica se o valor do Slider não mudou
                                let mappedValue = Int(newValue * (1024 / 255))
                                bluetoothViewModel.sendCommandToAllDevices("\(mappedValue)")
                            }
                        }
                    }
                .padding()
                HStack{
                    Text("COR: \(Int(adjustedSliderValue)) (3000 - 6500)") .foregroundColor(Color(hex: "#1b2c5d"))
                        .bold()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#f37021"))
                )
            }
                VStack(alignment: .leading) {
                Slider(value: $brightnessValue, in: 0...100, step: 1)
                    .disabled(!isToggleButtonEnabled)
                    .onChange(of: brightnessValue) { newValue in
                        lastBrightnessValue = newValue
                        // Iniciar um timer para atrasar o envio do comando
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                            if lastBrightnessValue == newValue { // Verifica se o valor do Slider não mudou
                                bluetoothViewModel.sendCommandToAllDevices("INTENSIDADE: \(String(describing: newValue))")
                            }
                        }
                    }
                .padding()
                HStack {
                    Text("INTENSIDADE: \(Int(brightnessValue)) (0 - 100)") .foregroundColor(Color(hex: "#1b2c5d"))
                        .bold()
                }
                
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#f37021"))
                )
            }
               
            } else {

            }
        }
            .padding()
            .navigationTitle("Avançado")
            .onChange(of: bluetoothViewModel.isConnected) { isConnected in
                if !isConnected {
                    isToggleButtonEnabled = false
                    bluetoothViewModel.sendCommandToAllDevices("desligarAvancado") // Desativa o modo avançado
                }
            }
        }
        .onDisappear {
                    // Desabilita o toggle quando a view desaparece
                    isToggleButtonEnabled = false
                }
                .onChange(of: bluetoothViewModel.isConnected) { isConnected in
                    if !isConnected {
                        isToggleButtonEnabled = false
                        // Adicionalmente, envie um comando para desligar o modo avançado
                        bluetoothViewModel.sendCommandToAllDevices("desligarAvancado")
                    }
                }
        .background(Color.init(hex: "#f37021").edgesIgnoringSafeArea(.bottom)) // Aplica a cor vermelha apenas na parte inferior
    }
    
    // Function to determine the display text for connected devices
    private func displayConnectedDevices() -> String {
        let count = bluetoothViewModel.connectedDevices.count
        if count == 1 {
            if let device = bluetoothViewModel.connectedDevices.first {
                let displayName = bluetoothViewModel.getDisplayName(for: device)
                return "DISPOSITIVO CONECTADO: \(displayName)"
            }
        }  else if count > 1 {
            return "DISPOSITIVOS CONECTADOS: \(count)"
        }
        return "NENHUM DISPOSITIVO CONECTADO"
    } 
}

struct AdvancedView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedView().environmentObject(BluetoothViewModel())
    }
}
