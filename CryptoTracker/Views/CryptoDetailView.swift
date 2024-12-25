//
//  CryptoDetailView.swift
//  CryptoTracker
//
//  Created by Javier Martin on 23/12/24.
//

import SwiftUI
import Charts

struct CryptoDetailView: View {
    let crypto: Cryptocurrency
    @Environment(\.presentationMode) var presentationMode
    @State private var historicalPrices: [HistoricalPrice] = []
    @State private var isFavorite: Bool = false
    @State private var isLoading: Bool = false
    @State private var selectedDays: Int = 7 // Rango predeterminado: 7 días
    // Opciones de Rango de Tiempo
    private let dayOptions: [Int] = [1, 7, 30, 90, 365]
    private let dayLabels: [Int: String] = [
            1: "1 Día",
            7: "7 Días",
            30: "30 Días",
            90: "90 Días",
            365: "365 Días"
        ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // 🔹 Encabezado
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    HStack () {
                        // Imagen del Logo de la Criptomoneda
                           AsyncImage(url: URL(string: crypto.image)) { image in
                               image
                                   .resizable()
                                   .frame(width: 40, height: 40)
                                   .clipShape(Circle())
                                   .shadow(radius: 4)
                           } placeholder: {
                               ProgressView()
                                   .frame(width: 40, height: 40)
                           }
                        
                        Text(crypto.symbol.uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        
                        Button(action: {
                            isFavorite.toggle()
                        }) {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .foregroundColor(isFavorite ? .yellow : .black)
                        }
                        
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                
                // 🔹 Nombre y Precio
                VStack(alignment: .leading, spacing: 8) {
                    Text(crypto.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    HStack {
                        Text(String(format: "%.2f €", crypto.currentPrice))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text(String(format: "%.2f%%", crypto.priceChangePercentage24h))
                            .font(.headline)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(crypto.priceChangePercentage24h >= 0 ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            )
                            .foregroundColor(crypto.priceChangePercentage24h >= 0 ? .green : .red)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // 🔹 Picker para Seleccionar el Rango de Tiempo
                                VStack(alignment: .leading) {
                                    Text("Rango de Tiempo")
                                        .font(.headline)
                                        .padding(.bottom, 4)
                                        .padding(.horizontal)
                                    
                                    Picker("Selecciona Rango", selection: $selectedDays) {
                                        ForEach(dayOptions, id: \.self) { day in
                                            Text(dayLabels[day] ?? "\(day) Días").tag(day)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding(.horizontal)
                                    .onChange(of: selectedDays) {
                                        loadHistoricalData()
                                    }
                                }
                                
                                Divider()
                                
                                // 🔹 Gráfico de Precios Históricos
                                VStack(alignment: .leading) {
                                    Text("Gráfico de Precios Históricos")
                                        .font(.headline)
                                        .padding(.bottom, 4)
                                        .foregroundColor(.black)
                                    
                                    if isLoading {
                                        ProgressView("Cargando datos históricos...")
                                            .padding()
                                    } else if !historicalPrices.isEmpty {
                                        Chart(historicalPrices) {
                                            LineMark(
                                                x: .value("Fecha", $0.date),
                                                y: .value("Precio", $0.price)
                                            )
                                        }
                                        .frame(height: 200)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    } else {
                                        Text("No hay datos históricos disponibles.")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal)
                
                Divider()
                
                // 🔹 Características Adicionales
                VStack(alignment: .leading, spacing: 12) {
                    Text("Características")
                        .font(.headline)
                        .padding(.bottom, 4)
                        .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(title: "Capitalización de Mercado", value: String(format: "%.0f €", crypto.marketCap))
                        FeatureRow(title: "Volumen de Mercado (24h)", value: "€500,000,000")
                        FeatureRow(title: "Suministro Circulante", value: "19,500,000 BTC")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1)) // Fondo gris claro
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
                
                Divider()
                
                // 🔹 Botones de Acción
                HStack {
                    Button("Eliminar Criptomoneda") {
                        deleteCrypto()
                    }
                    .foregroundColor(.red)
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Volver") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all)) // Fondo blanco en toda la vista
    }
    
    // Datos ficticios para el gráfico
    func loadHistoricalData() {
        isLoading = true
        API.shared.fetchHistoricalPrices(for: crypto.id, vsCurrency: "usd", days: selectedDays) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let prices):
                    historicalPrices = prices
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteCrypto() {
        print("\(crypto.name) eliminada.")
    }
}

// 🔹 Vista Auxiliar para Características
struct FeatureRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}

// Datos Históricos
struct HistoricalPrice: Identifiable {
    let id = UUID()
    let date: String
    let price: Double
}

#Preview {
    CryptoDetailView(crypto: Cryptocurrency(
        id: "1",
        symbol: "BTC",
        name: "Bitcoin",
        image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
        currentPrice: 94409.27,
        marketCap: 800000000000,
        priceChangePercentage24h: -0.21
    ))
}


