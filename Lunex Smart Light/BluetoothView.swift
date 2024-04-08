//
//  BluetoothView.swift
//  Lunex Smart Light
//
//  Created by Lucas Pereira on 12/12/23.
//

import SwiftUI
import CoreBluetooth

struct BluetoothView: View {
    @EnvironmentObject var bluetoothViewModel: BluetoothViewModel
    @State private var isShowingRenameSheet = false // Corrigido aqui
    @State private var tempDeviceName = ""
    @State private var deviceToRename: CBPeripheral?
    @State private var showAlert = false // Estado para controlar a visibilidade do alerta
    @State private var showingSettingsAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack  {
                // Isso faz com que o retângulo preto se estenda até as bordas laterais, ignorando as áreas seguras
                Rectangle()
                .fill(Color.black)
                .edgesIgnoringSafeArea(.top)
                .frame(height: 40)
        
            HStack{
                Text("DISPOSITIVOS PAREADOS")
                    .foregroundColor(Color.white)
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
                            message: Text(bluetoothViewModel.isBluetoothEnabled ? "O Bluetooth do dispositivo está ligado." : "O Bluetooth do dispositivo está desligado. Por favor, habilite o Bluetooth para conectar."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            }
            .padding(.horizontal, 10) // se necessário, mas mantenha o padding dentro do HStack para não afetar a largura total
            .frame(height: 40)
            .background(Color.black)
            .edgesIgnoringSafeArea(.horizontal) // Faz com que o background preto se estenda até as bordas laterais
        }
            List(bluetoothViewModel.discoveredDevices, id: \.identifier) { device in
                HStack {
                    Text(bluetoothViewModel.getDisplayName(for: device))
                        .foregroundColor(Color.white)
                    Spacer()
                    Image(systemName: "pencil.line")
                        .onTapGesture {
                            self.deviceToRename = device
                            self.tempDeviceName = bluetoothViewModel.getDisplayName(for: device)
                            self.isShowingRenameSheet = true
                        }
                    Image(systemName: bluetoothViewModel.selectedDevice?.identifier == device.identifier ? "checkmark.circle.fill" : "circle")
                        .onTapGesture {
                            bluetoothViewModel.selectedDevice = device
                        }
                }
                .listRowBackground(Color(hex: "#1b2c5d"))
            }
            .listStyle(PlainListStyle()) // Isto remove o estilo padrão da lista e divisórias
            .background(Color(hex: "#1b2c5d")) // Cor de fundo para a lista inteira
            if bluetoothViewModel.isScanning {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            Button(action: {
                bluetoothViewModel.scanForDevices()
                self.scanForDevicesOrRequestPermission()
            }) {
                Text("Procurar Dispositivos")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding() // Ajuste ou remova este padding
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .alert(isPresented: $showingSettingsAlert) {
                 Alert(
                     title: Text("Permissão de Bluetooth Necessária"),
                     message: Text("Por favor, habilite a permissão do Bluetooth nas configurações para conectar."),
                     primaryButton: .default(Text("Configurações"), action: {
                         // Abre as configurações do aplicativo
                         UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                     }),
                     secondaryButton: .cancel()
                 )
             }
            .padding(.bottom, 10) // Reduzindo o padding inferior
            Button(action: {
                bluetoothViewModel.toggleConnection()
            }) {
                Text(bluetoothViewModel.isConnected ? "Desconectar" : "Conectar")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding() // Ajuste ou remova este padding
                    .background(bluetoothViewModel.isConnected ? Color.red : Color.green)
                    .cornerRadius(10)
            }
            .padding(.bottom, 10) // Reduzindo o padding inferior
        }
           // .padding(.top, 10) // Reduzindo o padding superior
        .edgesIgnoringSafeArea(.top) // Garante que a VStack se estenda até o topo, cobrindo a área do status bar se necessário.
            .background(Color(hex: "#1b2c5d").edgesIgnoringSafeArea([.leading, .trailing]))
            .background(Color.init(hex: "#f37021").edgesIgnoringSafeArea(.bottom)) // Aplica a cor vermelha apenas na parte inferior
            .sheet(isPresented: $isShowingRenameSheet) {
                RenameDeviceView(
                    isPresented: self.$isShowingRenameSheet,
                    deviceName: self.$tempDeviceName,
                    onSave: {
                        if let device = self.deviceToRename {
                            self.bluetoothViewModel.renameDevice(device, to: self.tempDeviceName)
                        }
                    }
                )
            }
        }
    private func scanForDevicesOrRequestPermission() {
        let cbManager = bluetoothViewModel.centralManager
        
        switch cbManager!.state {
        case .poweredOn:
            // O Bluetooth está ligado e disponível. Comece a varredura.
            bluetoothViewModel.scanForDevices()
        case .unauthorized:
            // O usuário negou a permissão. Solicitar novamente indiretamente.
            self.showingSettingsAlert = true
        default:
            // Outros estados do Bluetooth.
            break
        }
    }
}



class BluetoothViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    @Published var discoveredDevices = [CBPeripheral]()
    @Published var selectedDevice: CBPeripheral?
    @Published var lampWhiteState: Bool = false
    @Published var lampYellowState: Bool = false
    @Published var connectedDeviceName: String? = nil
    @Published var temperature: String = "--"
    @Published var humidity: String = "--"
    @Published var whiteHotLightOn: Bool = false
    @Published var whiteColdLightOn: Bool = false
    @Published var customDeviceNames = [UUID: String]()
    @Published var isBluetoothEnabled: Bool = false {
        didSet {
            print("Bluetooth está agora \(isBluetoothEnabled ? "ligado" : "desligado")")
        }
    }
    @Published var isConnected = false {
        didSet {
            print("Estado de conexão alterado: \(isConnected)")
        }
    }
    @Published var isScanning = false
        let scanDuration: TimeInterval = 5 // Duração da varredura em segundos

    func updateLampStates(whiteHotValue: Int, whiteColdValue: Int) {
        lampWhiteState = whiteColdValue > 0
        lampYellowState = whiteHotValue > 0
    }
    
    // Timer para atualizar a temperatura e umidade após 30 segundos de inatividade
    var updateTimer: Timer?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func scanForDevices() {
        discoveredDevices = []
        isScanning = true
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
        // Inicia o timer para parar a varredura
        DispatchQueue.main.asyncAfter(deadline: .now() + scanDuration) {
            self.stopScanning()
        }
    }
    
    // Implemente a lógica para parar a varredura
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            isBluetoothEnabled = true
       } else {
           isBluetoothEnabled = false
       }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "SmartLight" {
            if !discoveredDevices.contains(peripheral) {
                discoveredDevices.append(peripheral)
            }
        }
    }


    func connectToDevice() {
        if let device = selectedDevice {
            centralManager.connect(device, options: nil)
        }
    }

    func toggleConnection() {
        if let device = selectedDevice {
            if isConnected {
                print("Tentando desconectar do dispositivo")
                centralManager.cancelPeripheralConnection(device)
            } else {
                print("Tentando conectar ao dispositivo")
                centralManager.connect(device, options: nil)
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Conectado ao dispositivo: \(peripheral.name ?? "")")
        isConnected = true
        connectedDeviceName = peripheral.name
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: "FFE0")])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("Serviço descoberto: \(service.uuid)")
            peripheral.discoverCharacteristics([CBUUID(string: "FFE1")], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("Característica descoberta: \(characteristic.uuid)")
            if characteristic.uuid == CBUUID(string: "FFE1") {
                print("Característica para comandos encontrada. Inscrevendo para notificações.")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            receivedData(data)
        }
    }

      func receivedData(_ data: Data) {
          if let dataString = String(data: data, encoding: .utf8) {
              print("Dados recebidos: \(dataString)")  // Adicione esta linha para debug
              processData(dataString)
              
              // Reinicia o timer cada vez que novos dados são recebidos
              restartUpdateTimer()
          }
      }

      func processData(_ data: String) {
          let components = data.components(separatedBy: ";")
          for component in components {
              if component.starts(with: "T:") {
                  let tempString = String(component.dropFirst(2)).dropLast()
                  DispatchQueue.main.async {
                      self.temperature = String(tempString)
                      print("Temperatura atualizada: \(self.temperature)") // Para debug
                  }
              } else if component.starts(with: "U:") {
                  let humidityString = String(component.dropFirst(2)).dropLast()
                  DispatchQueue.main.async {
                      self.humidity = String(humidityString)
                      print("Umidade atualizada: \(self.humidity)") // Para debug
                  }
              } else if component.starts(with: "H:") {
                 let hotValue = Int(component.dropFirst(2)) ?? 0
                 DispatchQueue.main.async {
                     self.whiteHotLightOn = hotValue > 0
                 }
              } else if component.starts(with: "C:") {
                 let coldValue = Int(component.dropFirst(2)) ?? 0
                 DispatchQueue.main.async {
                     self.whiteColdLightOn = coldValue > 0
                 }
             }
         }
     }
    
    // Reinicia o timer para limpar os valores após 30 segundos
        private func restartUpdateTimer() {
            updateTimer?.invalidate() // Cancela o timer anterior, se existir
            updateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
                self?.temperature = "--"
                self?.humidity = "--"
            }
        }
                  
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Desconectado do dispositivo: \(peripheral.name ?? "")")
        isConnected = false
        connectedDeviceName = nil
    }
    
    func renameDevice(_ device: CBPeripheral, to newName: String) {
            customDeviceNames[device.identifier] = newName
        }

        func getDisplayName(for device: CBPeripheral) -> String {
            if let customName = customDeviceNames[device.identifier] {
                return customName
            }
            return device.name ?? "Dispositivo Desconhecido"
        }
    }

extension BluetoothViewModel {
    func sendCommand(_ command: String) {
    print("Tentando enviar comando: \(command), isConnected: \(isConnected)")
        guard let device = selectedDevice, isConnected else {
            print("Dispositivo não está conectado.")
            return
        }

        // Defina os UUIDs para o serviço e a característica
        let serviceUUID = CBUUID(string: "FFE0")
        let characteristicUUID = CBUUID(string: "FFE1")

        // Encontre o serviço que corresponde ao UUID
        guard let service = device.services?.first(where: { $0.uuid == serviceUUID }) else { return }

        // Encontre a característica que corresponde ao UUID
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else { return }

        // Converta o comando em dados e escreva na característica
        if let data = command.data(using: .utf8) {
            device.writeValue(data, for: characteristic, type: .withResponse)
            print("Comando enviado: \(command)") // Adiciona esta linha
        }
    }
    
    func updateLampStatesForCommand(_ command: String) {
        switch command {
        case "01": // Frio
            lampWhiteState = true
            lampYellowState = false
        case "10": // Quente
            lampWhiteState = false
            lampYellowState = true
        case "11": // Neutro
            lampWhiteState = true
            lampYellowState = true
        case "00": // Desligar
            lampWhiteState = false
            lampYellowState = false
        default:
            break
        }
    }
}


