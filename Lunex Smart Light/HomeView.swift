import SwiftUI
struct HomeView: View {
    @EnvironmentObject var bluetoothViewModel: BluetoothViewModel
    @State private var showAlert = false // To control alert visibility
    @State private var showVideoManualAlert: Bool = UserDefaults.standard.bool(forKey: "showVideoManualAlert") == false
    
    var body: some View {
        ZStack {
            Color(hex: "#1b2c5d").edgesIgnoringSafeArea([.leading, .trailing])
            VStack {
                // Bluetooth status and alert
                Image(bluetoothViewModel.isBluetoothEnabled ? "bluetooth-2" : "bluetooth-3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(bluetoothViewModel.isBluetoothEnabled ? .green : .red)
                    .onTapGesture {
                        showAlert = true
                    }
                    .padding()
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text(bluetoothViewModel.isBluetoothEnabled ? "Bluetooth Ligado" : "Bluetooth Desligado"),
                            message: Text(bluetoothViewModel.isBluetoothEnabled ? "O Bluetooth do seu aparelho está ligado." : "O Bluetooth do seu aparelho está desligado. Por favor, habilite o Bluetooth para conectar."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                
                // Display connected status
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
                // Conditional display based on connection status
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
                        bluetoothViewModel.sendCommandToAllDevices(command)
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
                    
                    Button(action: {
                        let command = "01"
                        bluetoothViewModel.sendCommandToAllDevices(command)
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
                    
                    Button(action: {
                        let command = "11"
                        bluetoothViewModel.sendCommandToAllDevices(command)
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
                    
                    Button(action: {
                        let command = "10"
                        bluetoothViewModel.sendCommandToAllDevices(command)
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
                } else {
                    Text("''Para conectar ao dispositivo, vá para a tela de Bluetooth.''")
                        .italic()
                        .font(.system(.body, design: .serif))
                        .foregroundColor(Color(hex: "#818181"))
                }
                
                // Link to manual and video
                Text("''Acesse a tela Lunex para ver o vídeo do manual de uso.''")
                    .italic()
                    .font(.system(.body, design: .serif))
                    .foregroundColor(Color(hex: "#818181"))
            }
            .padding(.horizontal)  // Ensure padding is applied only horizontally
            .padding(.bottom, 50) // Isto adiciona espaço no fundo para não sobrepor a TabView
        }
        .navigationTitle("Inicial")
        .background(Color.init(hex: "#f37021").edgesIgnoringSafeArea(.bottom))
        .onAppear {
            showAlert = showVideoManualAlert
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Bem-vindo!"),
                message: Text("Assista ao vídeo do manual de uso."),
                primaryButton: .default(Text("Assistir"), action: {
                    // Open the video link
                    if let url = URL(string: "https://youtu.be/5czw-sAOq2U"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .destructive(Text("Não mostrar novamente"), action: {
                    // Do not show the alert again
                    UserDefaults.standard.set(true, forKey: "showVideoManualAlert")
                })
            )
        }
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

