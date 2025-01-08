//
//  ContentView.swift
//  CryptoTracker
//
//  Created by Javier Martin on 22/12/24.
//

import SwiftUI
import SwiftData

struct CryptoListView: View {
    @StateObject private var viewModel = CryptoListViewModel()
    @State private var selectedCurrency = "eur"
    @State private var selectedCrypto: Cryptocurrency?
    @State private var showDetail = false
    @State private var showFavorites = false // Controla la navegación a la vista de favoritos
    @State private var showSearch = false // Abre la ventana de búsqueda
    @Environment(\.modelContext) private var modelContext
    @StateObject private var detailViewModel = CryptoDetailViewModel()


    var body: some View {
        NavigationView {
            VStack {
                // 🔹 Selector de moneda (EUR / USD) con botones
                HStack(spacing: 16) {
                    Button(action: {
                        selectedCurrency = "eur"
                        viewModel.switchCurrency(to: selectedCurrency)
                    }) {
                        Text("EUR")
                            .font(.headline)
                            .foregroundColor(selectedCurrency == "eur" ? .white : .blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedCurrency == "eur" ? Color.blue : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }

                    Button(action: {
                        selectedCurrency = "usd"
                        viewModel.switchCurrency(to: selectedCurrency)
                    }) {
                        Text("USD")
                            .font(.headline)
                            .foregroundColor(selectedCurrency == "usd" ? .white : .blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedCurrency == "usd" ? Color.blue : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                // 🔹 Botón para ver favoritos
                Button(action: {
                    showFavorites = true
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Ver Favoritos")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .sheet(isPresented: $showFavorites) {
                    FavoritesView(viewModel: viewModel)
                }

                // 🔹 Lista de criptomonedas
                List {
                    ForEach(viewModel.cryptocurrencies) { crypto in
                        Button {
                            selectedCrypto = crypto
                            showDetail = true
                        } label: {
                            CryptoRowView(crypto: crypto, currencySymbol: selectedCurrency == "eur" ? "€" : "$")
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.removeCryptocurrency(at: indexSet, modelContext: modelContext)
                    }
                }
                .onAppear {
                    viewModel.loadInitialData(modelContext: modelContext)
                }
            }
            .navigationTitle("Crypto Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                CryptoSearchView(viewModel: viewModel)
            }
            .alert(item: $viewModel.errorMessage) { errorMessage in
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showDetail) {
                if let selectedCrypto = selectedCrypto {
                    CryptoDetailView(
                                crypto: selectedCrypto,
                                currencySymbol: selectedCurrency == "eur" ? "€" : "$",
                                viewModel: CryptoDetailViewModel(crypto: selectedCrypto)
                            )
                }
            }
        }
    }
}

#Preview {
    CryptoListView()
        .modelContainer(for: Item.self, inMemory: true)
}
