//  CryptoDetailView.swift
//  CryptoTracker
//
//  Created by Javier Martin on 23/12/24.
//
import SwiftUI
import Charts

struct CryptoDetailView: View {
    let crypto: Cryptocurrency
    let currencySymbol: String
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @StateObject var viewModel: CryptoDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isFavorite: Bool = false
    @State private var selectedDays: Int = 30
    @State private var isLoading: Bool = true
    @Environment(\.modelContext) private var modelContext

  
    private let dayOptions: [Int] = [7, 30, 90, 365]
    private let dayLabels: [Int: String] = [
        7: "7 Días",
        30: "30 Días",
        90: "90 Días",
        365: "365 Días"
    ]

    var body: some View {
        Group {
            if isLoading {
               
                VStack {
                    ProgressView("Cargando datos...")
                        .padding()
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        //  Encabezado
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }

                            Spacer()

                            HStack {
                                AsyncImage(url: URL(string: crypto.image)) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .shadow(radius: 4)

                                Text(crypto.symbol.uppercased())
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            }

                            Spacer()
                            //estrella añadir/eliminar favorito
                            Button(action: {
                                
                                if isFavorite {
                                    favoritesViewModel.removeFavorite(for: crypto, modelContext: modelContext)
                                } else {
                                    favoritesViewModel.addFavorite(for: crypto, modelContext: modelContext)
                                }

                                
                                isFavorite.toggle()
                            }) {
                                // mostrar la estrella según el estado actual
                                Image(systemName: isFavorite ? "star.fill" : "star")
                                    .foregroundColor(isFavorite ? .yellow : .black)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)

                        // Nombre y Precio
                        VStack(alignment: .leading, spacing: 8) {
                            Text(crypto.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)

                            HStack {
                                Text(String(format: "%.2f \(currencySymbol)", crypto.currentPrice))
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

                        // Picker para seleccionar el rango de ttiempo
                        VStack(alignment: .leading) {
                            Text("Rango de Tiempo")
                                .font(.headline)
                                .padding(.bottom, 4)
                                .padding(.horizontal)

                            Picker("Selecciona Rango", selection: $viewModel.selectedDays) {
                                ForEach(dayOptions, id: \.self) { day in
                                    Text(dayLabels[day] ?? "\(day) Días").tag(day)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            .onChange(of: viewModel.selectedDays) {
                                viewModel.fetchHistoricalPrices(
                                    for: crypto.id,
                                    vsCurrency: currencySymbol == "€" ? "eur" : "usd"
                                )
                            }
                        }

                        Divider()

                        // grafico de Precios Históricos
                        VStack(alignment: .leading) {
                            Text("Gráfico de Precios Históricos")
                                .font(.headline)
                                .padding(.bottom, 4)
                                .foregroundColor(.black)

                            if viewModel.isLoading {
                                ProgressView("Cargando datos históricos...")
                                    .padding()
                            } else if !viewModel.historicalPrices.isEmpty {
                                Chart {
                                    ForEach(viewModel.historicalPrices) { price in
                                        LineMark(
                                            x: .value("Fecha", price.date),
                                            y: .value("Precio", price.price)
                                        )
                                        .foregroundStyle(.blue)
                                        .lineStyle(StrokeStyle(lineWidth: 2))
                                    }
                                }
                                .chartYScale(domain: 0...((viewModel.historicalPrices.map { $0.price }.max() ?? 10) * 1.1))
                                .frame(height: 300)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(radius: 5)
                                )
                                .padding()
                            } else {
                                Text("Se ha llegado al límite de solicitudes, inténtelo de nuevo más tarde.")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)

                        Divider()

                        //  características adicionales
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Características")
                                .font(.headline)
                                .padding(.bottom, 4)
                                .foregroundColor(.black)

                            VStack(alignment: .leading, spacing: 8) {
                                FeatureRow(title: "Capitalización de Mercado", value: String(format: "%.0f \(currencySymbol)", crypto.marketCap))
                                FeatureRow(title: "Volumen de Mercado (24h)", value: String(format: "%.0f \(currencySymbol)", crypto.totalVolume))
                                FeatureRow(title: "Suministro Circulante", value: String(format: "%.0f", crypto.circulatingSupply))
                                FeatureRow(title: "Suministro Total", value: String(format: "%.0f", crypto.totalSupply ?? 0))
                                FeatureRow(title: "Suministro Máximo", value: String(format: "%.0f", crypto.maxSupply ?? 0))
                                FeatureRow(title: "ATH (Máximo Histórico)", value: String(format: "%.2f \(currencySymbol)", crypto.ath ?? 0))
                                FeatureRow(title: "ATL (Mínimo Histórico)", value: String(format: "%.2f \(currencySymbol)", crypto.atl ?? 0))
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.horizontal)

                        Divider()
                    }
                }
            }
        }
        .onAppear {
            
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // para poder mostrarlo correctamente 
                if viewModel.crypto == nil {
                    viewModel.crypto = crypto
                }
                viewModel.fetchHistoricalPrices(for: crypto.id, vsCurrency: currencySymbol == "€" ? "eur" : "usd")
                isFavorite = favoritesViewModel.isFavorite(crypto.id)
                isLoading = false
            }
        }
    }
}


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



struct HistoricalPrice: Identifiable {
    let id = UUID()
    let date: String
    let price: Double
}
