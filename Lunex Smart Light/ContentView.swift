//
//  ContentView.swift
//  Lunex Smart Light
//
//  Created by Lucas Pereira on 12/12/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bluetoothViewModel: BluetoothViewModel

    init() {
        // Configure a cor de fundo da TabView
        UITabBar.appearance().backgroundColor = UIColor(named: "#f37021")
        
        // Configure a cor dos itens não selecionados
        UITabBar.appearance().unselectedItemTintColor = UIColor.black
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar()
                .background(Color(hex: "#f37021"))
                // .edgesIgnoringSafeArea(.top)

            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Inicial")
                    }
                AdvancedView()
                    .tabItem {
                        Image(systemName: "slider.vertical.3")
                        Text("Avançado")
                    }
                BluetoothView()
                    .tabItem {
                        Image(systemName: "wave.3.right")
                        Text("Bluetooth")
                    }
                LunexView()
                    .tabItem {
                        Image(systemName: "phone")
                        Text("Lunex")
                    }
            }
            .background(Color(hex: "#f37021"))
            .accentColor(.white)
        }
        .background(Color(hex: "#1b2c5d").edgesIgnoringSafeArea(.all))
        .environmentObject(bluetoothViewModel)
    }
}

struct CustomNavigationBar: View {
    @EnvironmentObject var bluetoothViewModel: BluetoothViewModel

    var body: some View {
        HStack {
            Link(destination: URL(string: "https://www.lunex.com.br")!) {
                Image("logo3")
                    .resizable()
                    .frame(width: 140, height: 60)
            }
          Spacer()
            HStack {
                Image(systemName: "thermometer")
                    .foregroundColor(.red)
                Text(" \(bluetoothViewModel.temperature) °C")
            }
            .padding()
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                Text(" \(bluetoothViewModel.humidity) %")
            }
            .padding()
        }
        .background(Color(hex: "#f37021"))
        .foregroundStyle(Color.black) // Cor dos ícones e texto quando não selecionados
    }
}
