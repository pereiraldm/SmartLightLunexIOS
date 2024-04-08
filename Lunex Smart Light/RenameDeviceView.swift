//
//  RenameDeviceView.swift
//  Lunex Smart Light
//
//  Created by Lucas Pereira on 29/01/24.
//

import SwiftUI

struct RenameDeviceView: View {
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
                        deviceName = "Smart Light"
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


