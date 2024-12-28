//
//  CryptoSearchView.swift
//  CryptoTracker
//
//  Created by Javier Martin on 26/12/24.
//

import SwiftUI
import SwiftData

struct CryptoSearchView: View {
    @ObservedObject var viewModel: CryptoListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var selectedCrypto: Cryptocurrency?
    @State private var showAlert = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            VStack {
                // 🔍 Barra de búsqueda
                HStack {
                    TextField("Buscar criptomoneda...", text: $searchText, onCommit: {
                        if !searchText.isEmpty {
                            viewModel.searchCryptocurrency(query: searchText)
                            print("🔍 Buscando: \(searchText)")
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                    Button(action: {
                        if !searchText.isEmpty {
                            viewModel.searchCryptocurrency(query: searchText)
                            print("🔍 Botón de búsqueda presionado: \(searchText)")
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                    }
                    .padding(.trailing)
                }

                // 🔄 Resultados de búsqueda
                List(viewModel.searchResults) { crypto in
                    Button {
                        selectedCrypto = crypto
                        showAlert = true
                    } label: {
                        HStack {
                            AsyncImage(url: URL(string: crypto.image)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(crypto.name)
                                    .font(.headline)
                                Text(crypto.symbol.uppercased())
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Buscar Criptomoneda")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Añadir Criptomoneda"),
                    message: Text("¿Quieres añadir \(selectedCrypto?.name ?? "esta criptomoneda") a la lista principal?"),
                    primaryButton: .default(Text("Sí")) {
                        if let crypto = selectedCrypto {
                            viewModel.addCryptocurrency(crypto, modelContext: modelContext)
                            presentationMode.wrappedValue.dismiss()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}


#Preview {
    CryptoSearchView(viewModel: CryptoListViewModel())
}
