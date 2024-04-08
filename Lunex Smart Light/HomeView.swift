//
//  AdvancedView.swift
//  Lunex Smart Light
//
//  Created by Lucas Pereira on 12/12/23.
//

import SwiftUI

struct HomeView: View {
    @State private var isConnected = false // Exemplo, deve ser atualizado com a lógica real
    @State private var showAlert = false // Estado para controlar a visibilidade do alerta
    @EnvironmentObject var bluetoothViewModel: BluetoothViewModel
    @State private var isBluetoothEnabled = true // Este estado deve ser atualizado com a lógica real do Bluetooth
    
    private var showVideoManualAlert: Bool {
        UserDefaults.standard.bool(forKey: "showVideoManualAlert") == false
    }
    
    var body: some View {
        ZStack {
        // Cor de fundo que abrange toda a tela
        Color(hex: "#1b2c5d")
                .edgesIgnoringSafeArea([.leading, .trailing])
            
            VStack {
                Image(bluetoothViewModel.isBluetoothEnabled ? "bluetooth-2" : "bluetooth-3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(bluetoothViewModel.isBluetoothEnabled ? .green : .red)

                    .onTapGesture {
                        showAlert = true // Atualiza o estado para mostrar o alerta
                    }
                    .padding()
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text(bluetoothViewModel.isBluetoothEnabled ? "Bluetooth Ligado" : "Bluetooth Desligado"),
                            message: Text(bluetoothViewModel.isBluetoothEnabled ? "O Bluetooth do seu aparelho está ligado." : "O Bluetooth do seu aparelho está desligado. Por favor, habilite o Bluetooth para conectar."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                
                Rectangle()
                    .fill(Color(hex: "#f37021"))
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    .overlay(
                        Text(bluetoothViewModel.selectedDevice != nil ? "DISPOSITIVO CONECTADO: \(bluetoothViewModel.selectedDevice?.name ?? "")" : "NENHUM DISPOSITIVO CONECTADO")
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
                    
                    Button(action: {
                        let command = "00"
                        bluetoothViewModel.sendCommand(command)
                        bluetoothViewModel.updateLampStatesForCommand(command)
                    }) {
                        ZStack {
                            Color(hex: "#f37021").cornerRadius(10)
                            
                            Text("DESLIGAR")
                                .bold()
                                .foregroundColor(Color(hex: "#1b2c5d"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    //.background(Color(hex: "#f37021"))
                    
                    Button(action: {
                        let command = "01"
                        bluetoothViewModel.sendCommand(command)
                        bluetoothViewModel.updateLampStatesForCommand(command)
                    }) {
                        ZStack {
                            Color(hex: "#f37021").cornerRadius(10)
                            
                            Text("FRIO")
                                .bold()
                                .foregroundColor(Color(hex: "#1b2c5d"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    //.background(Color(hex: "#f37021"))
                    
                    Button(action: {
                        let command = "11"
                        bluetoothViewModel.sendCommand(command)
                        bluetoothViewModel.updateLampStatesForCommand(command)
                    }) {
                        ZStack {
                            Color(hex: "#f37021").cornerRadius(10)
                            
                            Text("NEUTRO")
                                .bold()
                                .foregroundColor(Color(hex: "#1b2c5d"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    //.background(Color(hex: "#f37021"))
                    
                    Button(action: {
                        let command = "10"
                        bluetoothViewModel.sendCommand(command)
                        bluetoothViewModel.updateLampStatesForCommand(command)
                    }) {
                        ZStack {
                            Color(hex: "#f37021").cornerRadius(10)
                            
                            Text("QUENTE")
                                .bold()
                                .foregroundColor(Color(hex: "#1b2c5d"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    //.background(Color(hex: "#f37021"))
                    
                } else {
                }
                Text("''Para conectar ao dispositivo, vá para a tela de Bluetooth.''")
                    .italic()
                    .font(.system(.body, design: .serif))
                    .foregroundColor(Color(hex: "#818181"))
                Text("''Acesse a tela Lunex para ver o vídeo do manual de uso.''")
                    .italic()
                    .font(.system(.body, design: .serif))
                    .foregroundColor(Color(hex: "#818181"))

            }
            .padding(.horizontal)
            .padding(.bottom, 50) // Isto adiciona espaço no fundo para não sobrepor a TabView
    }
        .navigationTitle("Inicial")
        .background(Color.init(hex: "#f37021").edgesIgnoringSafeArea(.bottom)) // Aplica a cor vermelha apenas na parte inferior
        .onAppear {
               self.showAlert = self.showVideoManualAlert
           }
        .alert(isPresented: $showAlert) {
           Alert(
               title: Text("Bem-vindo!"),
               message: Text("Assista ao vídeo do manual de uso."),
               primaryButton: .default(Text("Assistir"), action: {
                   // Abre o link do vídeo
                   if let url = URL(string: "https://youtu.be/5czw-sAOq2U"), UIApplication.shared.canOpenURL(url) {
                       UIApplication.shared.open(url)
                   }
               }),
               secondaryButton: .destructive(Text("Não mostrar novamente"), action: {
                   // Define a chave 'showVideoManualAlert' como verdadeira para não mostrar o alerta novamente
                   UserDefaults.standard.set(true, forKey: "showVideoManualAlert")
               })
           )
       }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(BluetoothViewModel())
    }
}
