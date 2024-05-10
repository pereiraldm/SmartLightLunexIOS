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
    @State var isShowingRenameSheet = false
        @State private var tempDeviceName = ""
        @State private var deviceToRename: CBPeripheral?
        @State private var showAlert = false
        @State private var showingSettingsAlert = false

    
        
        var body: some View {
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(Color.black)
                        .edgesIgnoringSafeArea(.top)
                        .frame(height: 40)
            
                    HStack {
                        Text("DISPOSITIVOS PAREADOS")
                            .foregroundColor(Color.white)
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
                                    message: Text(bluetoothViewModel.isBluetoothEnabled ? "O Bluetooth do dispositivo está ligado." : "O Bluetooth do dispositivo está desligado. Por favor, habilite o Bluetooth para conectar."),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .background(Color.black)
                    .edgesIgnoringSafeArea(.horizontal)
                }
                List(bluetoothViewModel.discoveredDevices, id: \.identifier) { device in
                    DeviceRow(device: device)
                        .listRowBackground(Color(hex: "#1b2c5d"))
                }
                .listStyle(PlainListStyle())
                .background(Color(hex: "#1b2c5d"))
                if bluetoothViewModel.isScanning {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                Button(action: {
                    bluetoothViewModel.scanForDevices()
                    self.scanForDevicesOrRequestPermission()
                }) {
                    Text("BUSCAR DISPOSITIVOS")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showingSettingsAlert) {
                    Alert(
                        title: Text("Permissão de Bluetooth Necessária"),
                        message: Text("Por favor, habilite a permissão do Bluetooth nas configurações para conectar."),
                        primaryButton: .default(Text("Configurações"), action: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }),
                        secondaryButton: .cancel()
                    )
                }
                .padding(.bottom, 10)

                Button(action: {
                    // Connect to all selected devices
                    bluetoothViewModel.toggleConnectionForSelectedDevices()
                }) {
                    Text(bluetoothViewModel.isConnected ? "DESCONECTAR" : "CONECTAR")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(bluetoothViewModel.isConnected ? Color.red : Color.green)
                        .cornerRadius(10)
                }
                .padding(.bottom, 10)
            }
            .edgesIgnoringSafeArea(.top)
            .background(Color(hex: "#1b2c5d").edgesIgnoringSafeArea([.leading, .trailing]))
            .background(Color.init(hex: "#f37021").edgesIgnoringSafeArea(.bottom))
        }
        
        private func scanForDevicesOrRequestPermission() {
            let cbManager = bluetoothViewModel.centralManager
            switch cbManager?.state {
            case .poweredOn:
                bluetoothViewModel.scanForDevices()
            case .unauthorized:
                self.showingSettingsAlert = true
            default:
                break
            }
        }
    }

    extension BluetoothViewModel {
        var isConnected: Bool {
            !connectedDevices.isEmpty
        }
        
        func toggleConnectionForSelectedDevices() {
            if isConnected { // If any device is connected, disconnect them
                disconnectAllSelectedDevices()
            } else { // Otherwise, connect to all selected devices
                connectToAllSelectedDevices()
            }
        }
        
        func connectToAllSelectedDevices() {
            for device in selectedDevices {
                connectToDevice(device)
            }
        }
        
        func disconnectAllSelectedDevices() {
            for device in selectedDevices {
                disconnectDevice(device)
            }
        }
        
        func disconnectDevice(_ device: CBPeripheral) {
            if connectedDevices.contains(device) {
                centralManager.cancelPeripheralConnection(device)
                // Optionally, remove from the connectedDevices set in the didDisconnect delegate method
            }
        }

        func connectToDevice(_ device: CBPeripheral) {
            if !connectedDevices.contains(device) {
                centralManager.connect(device, options: nil)
            }
        }
    }



class BluetoothViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var primaryDevice: CBPeripheral?
    @Published var discoveredDevices = [CBPeripheral]()
    var primaryDeviceUUID: UUID?
    @Published var deviceGroups: [DeviceGroup] = []
    @Published var connectedDevices = Set<CBPeripheral>()
    var deviceConnectionStates = [UUID: Bool]()
    @Published var selectedDevices = Set<CBPeripheral>()
    @Published var lampWhiteState: Bool = false
    @Published var lampYellowState: Bool = false
    @Published var connectedDeviceName: String? = nil
    @Published var temperature: String = "--"
    @Published var humidity: String = "--"
    @Published var whiteHotLightOn: Bool = false
    @Published var whiteColdLightOn: Bool = false
    @Published var customDeviceNames = [UUID: String]() {
        didSet {
            saveCustomNames()
        }
    }
    @Published var isBluetoothEnabled: Bool = false {
        didSet {
            print("Bluetooth está agora \(isBluetoothEnabled ? "ligado" : "desligado")")
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
    
    struct DeviceGroup {
        var id: UUID = UUID()
        var name: String
        var devices: [CBPeripheral]
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        loadCustomNames()
    }
    
    private func saveCustomNames() {
        let stringDictionary = customDeviceNames.mapKeys { $0.uuidString }
        UserDefaults.standard.set(stringDictionary, forKey: "CustomDeviceNames")
    }

    private func loadCustomNames() {
        if let savedNames = UserDefaults.standard.dictionary(forKey: "CustomDeviceNames") as? [String: String] {
            self.customDeviceNames = savedNames.reduce(into: [UUID: String]()) { result, pair in
                if let uuid = UUID(uuidString: pair.key) {
                    result[uuid] = pair.value
                }
            }
        }
    }
    
    func connectToGroup(_ group: DeviceGroup) {
        for device in group.devices {
            if !connectedDevices.contains(device) {
                centralManager.connect(device, options: nil)
            }
        }
    }
    
    func disconnectFromGroup(_ group: DeviceGroup) {
        for device in group.devices {
            if connectedDevices.contains(device) {
                centralManager.cancelPeripheralConnection(device)
                connectedDevices.remove(device)
            }
        }
    }

    func sendCommandToAllDevices(_ command: String) {
        for device in connectedDevices {
            sendCommand(command, to: device)
        }
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

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedDevices.insert(peripheral)
        deviceConnectionStates[peripheral.identifier] = true
        updatePrimaryDevice()
        print("Connected to \(peripheral.name ?? "a device")")
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: "FFE0")])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedDevices.remove(peripheral)
        deviceConnectionStates[peripheral.identifier] = false
        updatePrimaryDevice()
        print("Disconnected from: \(peripheral.name ?? "Unknown Device")")
    }

//    private func updatePrimaryDevice() {
//        if connectedDevices.count == 1 {
//            primaryDeviceUUID = connectedDevices.first?.identifier
//        } else {
//            primaryDeviceUUID = nil
//            temperature = "--"
//            humidity = "--"
//        }
//    }

    
    // You can also log at the moment of sending commands
    private func sendCommand(_ command: String, to device: CBPeripheral) {
        guard let service = device.services?.first(where: { $0.uuid == CBUUID(string: "FFE0") }),
              let characteristic = service.characteristics?.first(where: { $0.uuid == CBUUID(string: "FFE1") }) else {
            print("Service/Characteristic not found")
            return
        }
        if let data = command.data(using: .utf8) {
            device.writeValue(data, for: characteristic, type: .withResponse)
            print("Command sent: \(command) to \(device.name ?? "Unknown Device")")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            print("No services found")
            return
        }
        for service in services {
            print("Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        guard let characteristics = service.characteristics else {
            print("No characteristics found for service \(service.uuid)")
            return
        }
        for characteristic in characteristics {
            print("Discovered characteristic: \(characteristic.uuid) for service: \(service.uuid)")
            if characteristic.properties.contains(.notify) {
                print("Subscribing to \(characteristic.uuid)")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.uuid == CBUUID(string: "FFE1") {
                print("Found command characteristic, subscribing for updates.")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value, peripheral.identifier == primaryDeviceUUID else {
            return
        }
        receivedData(data)
    }
    
    func receivedData(_ data: Data) {
        if let dataString = String(data: data, encoding: .utf8) {
            // Ensure data is processed only if it comes from the primary device
            if let primaryUUID = primaryDeviceUUID, deviceConnectionStates[primaryUUID] == true {
                print("Dados recebidos: \(dataString) from \(primaryUUID)")
                processData(dataString, from: primaryUUID)
            }
        }
    }
    
    func processData(_ data: String, from deviceId: UUID) {
        // Check if the data is from the primary device
        guard deviceId == primaryDeviceUUID else {
            print("Ignoring data from non-primary device \(deviceId)")
            return
        }

        let components = data.components(separatedBy: ";")
        for component in components {
            if component.starts(with: "T:") && connectedDevices.count == 1 {
                let tempString = String(component.dropFirst(2)).dropLast()
                DispatchQueue.main.async {
                    self.temperature = String(tempString)
                    print("Temperatura atualizada: \(self.temperature)")
                }
            } else if component.starts(with: "U:") && connectedDevices.count == 1 {
                let humidityString = String(component.dropFirst(2)).dropLast()
                DispatchQueue.main.async {
                    self.humidity = String(humidityString)
                    print("Umidade atualizada: \(self.humidity)")
                }
            } else if component.starts(with: "H:") {
                let hotValue = Int(component.dropFirst(2)) ?? 0
                DispatchQueue.main.async {
                    self.whiteHotLightOn = hotValue > 0
                    print("Hot Light On: \(self.whiteHotLightOn)")
                }
            } else if component.starts(with: "C:") {
                let coldValue = Int(component.dropFirst(2)) ?? 0
                DispatchQueue.main.async {
                    self.whiteColdLightOn = coldValue > 0
                    print("Cold Light On: \(self.whiteColdLightOn)")
                }
            }
        }
    }

    private func updatePrimaryDevice() {
        if connectedDevices.count == 1 {
            primaryDeviceUUID = connectedDevices.first?.identifier
        } else {
            primaryDeviceUUID = connectedDevices.first?.identifier
            resetMeasurements()
        }
    }

    private func resetMeasurements() {
        temperature = "--"
        humidity = "--"
    }

    
    
    // Reinicia o timer para limpar os valores após 30 segundos
    private func restartUpdateTimer() {
        updateTimer?.invalidate() // Cancela o timer anterior, se existir
        updateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?.temperature = "--"
            self?.humidity = "--"
        }
    }
    
    func renameDevice(_ device: CBPeripheral, to newName: String) {
        customDeviceNames[device.identifier] = newName
        saveCustomNames()
        self.objectWillChange.send()
    }

    func getDisplayName(for device: CBPeripheral) -> String {
        if let customName = customDeviceNames[device.identifier] {
            return customName
        }
        return device.name ?? "Dispositivo Desconhecido"
    }
    
    func toggleDeviceSelection(_ device: CBPeripheral) {
        if selectedDevices.contains(device) {
            selectedDevices.remove(device)
        } else {
            selectedDevices.insert(device)
        }
    }
    
}

extension BluetoothViewModel {
    
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

extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> Dictionary<T, Value> {
        var newDict = Dictionary<T, Value>()
        for (key, value) in self {
            newDict[transform(key)] = value
        }
        return newDict
    }
}


