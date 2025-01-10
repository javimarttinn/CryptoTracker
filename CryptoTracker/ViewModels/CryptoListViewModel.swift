//
//  CryptoListViewModel.swift
//  CryptoTracker
//
//  Created by Javier Martin on 22/12/24.
//

import Foundation
import Combine
import SwiftData

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

class CryptoListViewModel: ObservableObject {
    // Arrays de criptomonedas por moneda
    @Published var cryptocurrenciesEUR: [Cryptocurrency] = []
    @Published var cryptocurrenciesUSD: [Cryptocurrency] = []
    
    // Arrays para criptomonedas manuales
    @Published var manualCryptocurrenciesEUR: [Cryptocurrency] = []
    @Published var manualCryptocurrenciesUSD: [Cryptocurrency] = []
    
    // Array visible en la vista
    @Published var cryptocurrencies: [Cryptocurrency] = []
    
    @Published var errorMessage: ErrorMessage?
    @Published var isDataLoaded = false
    @Published var favoriteCryptocurrencies: [Cryptocurrency] = []
    

    @Published var favoritesViewModel = FavoritesViewModel()
        // El resto de las propiedades y métodos
    


    
    private var selectedCurrency: String = "eur"
    
    // MARK: - Cargar criptomonedas al iniciar la app
    func loadInitialData(modelContext: ModelContext) {
        let group = DispatchGroup()
        
        // Cargar criptomonedas top en EUR
        group.enter()
        fetchTopCryptocurrencies(vsCurrency: "eur") { cryptos in
            DispatchQueue.main.async {
                self.cryptocurrenciesEUR = cryptos
                group.leave()
            }
        }
        
        // Cargar criptomonedas top en USD
        group.enter()
        fetchTopCryptocurrencies(vsCurrency: "usd") { cryptos in
            DispatchQueue.main.async {
                self.cryptocurrenciesUSD = cryptos
                group.leave()
            }
        }
        
        // Cargar criptomonedas manuales y favoritas
        group.enter()
        loadManualCryptocurrencies(modelContext: modelContext, vsCurrency: "eur") { cryptos in
            DispatchQueue.main.async {
                self.manualCryptocurrenciesEUR = cryptos
                group.leave()
            }
        }
        
        group.enter()
        loadManualCryptocurrencies(modelContext: modelContext, vsCurrency: "usd") { cryptos in
            DispatchQueue.main.async {
                self.manualCryptocurrenciesUSD = cryptos
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.switchCurrency(to: self.selectedCurrency)
        }
    }

    
    // MARK: - Alternar entre monedas
    func switchCurrency(to currency: String) {
        self.selectedCurrency = currency
        if currency == "eur" {
            self.cryptocurrencies = cryptocurrenciesEUR + manualCryptocurrenciesEUR
        } else {
            self.cryptocurrencies = cryptocurrenciesUSD + manualCryptocurrenciesUSD
        }
    }
    
   
    private func fetchTopCryptocurrencies(vsCurrency: String, completion: @escaping ([Cryptocurrency]) -> Void) {
        API.shared.fetchTopCryptocurrencies(vsCurrency: vsCurrency) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cryptos):
                    
                    completion(cryptos)
                case .failure(let error):
                    self.errorMessage = ErrorMessage(message: error.localizedDescription)
                    completion([])
                }
            }
        }
    }
    
    private func loadManualCryptocurrencies(modelContext: ModelContext, vsCurrency: String, completion: @escaping ([Cryptocurrency]) -> Void) {
        let fetchDescriptor = FetchDescriptor<CryptoID>()
        do {
            let cryptoIDs = try modelContext.fetch(fetchDescriptor).map { $0.id }
            
            // Usar el nuevo método con múltiples IDs
            API.shared.fetchCryptocurrencyDetails(ids: cryptoIDs, vsCurrency: vsCurrency) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let cryptos):
                        t)")
                        completion(cryptos)
                    case .failure(let error):
                        self.errorMessage = ErrorMessage(message: "Error al cargar criptomonedas manuales: \(error.localizedDescription)")
                        completion([])
                    }
                }
            }
        } catch {
            errorMessage = ErrorMessage(message: "Error al cargar IDs: \(error.localizedDescription)")
            completion([])
        }
    }

    @Published var searchResults: [Cryptocurrency] = []
    
    func searchCryptocurrency(query: String) {
        API.shared.searchCryptocurrency(query: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cryptos):
                    print("✅ Resultados recibidos: \(cryptos.map { $0.name })")
                    self?.searchResults = cryptos
                case .failure(let error):
                    print("❌ Error en la búsqueda: \(error.localizedDescription)")
                    self?.errorMessage = ErrorMessage(message: error.localizedDescription)
                }
            }
        }
    }
    
    
    
    
    func addCryptocurrency(_ crypto: Cryptocurrency, modelContext: ModelContext) {
        if !manualCryptocurrenciesEUR.contains(where: { $0.id == crypto.id }) &&
           !manualCryptocurrenciesUSD.contains(where: { $0.id == crypto.id }) {
            
            let newCryptoID = CryptoID(id: crypto.id)
            modelContext.insert(newCryptoID)
            
            do {
                try modelContext.save()
                print("✅ Criptomoneda añadida y guardada correctamente: \(crypto.name)")
            } catch {
                errorMessage = ErrorMessage(message: "Error al guardar en SwiftData: \(error.localizedDescription)")
            }
            
            // Preparar IDs para la solicitud
            let cryptoIDArray = [crypto.id]
            let group = DispatchGroup()
            
            // Cargar datos en EUR
            group.enter()
            API.shared.fetchCryptocurrencyDetails(ids: cryptoIDArray, vsCurrency: "eur") { result in
                DispatchQueue.main.async {
                    if case .success(let cryptosEUR) = result {
                        self.manualCryptocurrenciesEUR.append(contentsOf: cryptosEUR)
                    }
                    group.leave()
                }
            }
            
            // Cargar datos en USD
            group.enter()
            API.shared.fetchCryptocurrencyDetails(ids: cryptoIDArray, vsCurrency: "usd") { result in
                DispatchQueue.main.async {
                    if case .success(let cryptosUSD) = result {
                        self.manualCryptocurrenciesUSD.append(contentsOf: cryptosUSD)
                    }
                    group.leave()
                }
            }
            
            // Refrescar la vista después de añadir la criptomoneda
            group.notify(queue: .main) {
                print("🔄 Actualizando la vista principal después de añadir una criptomoneda manualmente.")
                self.switchCurrency(to: self.selectedCurrency)
            }
        } else {
            print("⚠️ La criptomoneda ya está en la lista.")
        }
    }


    
    // Eliminar una criptomoneda por su índice
    func removeCryptocurrency(at indexSet: IndexSet, modelContext: ModelContext) {
        for index in indexSet {
            let crypto = cryptocurrencies[index]
            
            // Eliminar de SwiftData
            removeCryptocurrencyFromSwiftData(id: crypto.id, modelContext: modelContext)
            
            // Eliminar de los arrays de memoria (EUR y USD)
            cryptocurrenciesEUR.removeAll { $0.id == crypto.id }
            cryptocurrenciesUSD.removeAll { $0.id == crypto.id }
            manualCryptocurrenciesEUR.removeAll { $0.id == crypto.id }
            manualCryptocurrenciesUSD.removeAll { $0.id == crypto.id }
        }
        
        // Actualizar la lista visible
        DispatchQueue.main.async {
            self.switchCurrency(to: self.selectedCurrency)
        }
    }





    
    
    
    // MARK: - Eliminar una criptomoneda de SwiftData
    func removeCryptocurrencyFromSwiftData(id: String, modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<CryptoID>(predicate: #Predicate { $0.id == id })
        
        do {
            if let cryptoID = try modelContext.fetch(fetchDescriptor).first {
                modelContext.delete(cryptoID)
                try modelContext.save()
                print("✅ Criptomoneda eliminada de SwiftData: \(id)")
            } else {
                print("⚠️ No se encontró la criptomoneda en SwiftData con el ID: \(id)")
            }
        } catch {
            errorMessage = ErrorMessage(message: "Error al eliminar criptomoneda de SwiftData: \(error.localizedDescription)")
            print("❌ Error al eliminar criptomoneda de SwiftData: \(error.localizedDescription)")
        }
    }
    




}

