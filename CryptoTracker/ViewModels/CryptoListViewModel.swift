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
        
        // Cargar criptomonedas manuales en EUR
        group.enter()
        loadManualCryptocurrencies(modelContext: modelContext, vsCurrency: "eur") { cryptos in
            DispatchQueue.main.async {
                self.manualCryptocurrenciesEUR = cryptos
                group.leave()
            }
        }
        
        // Cargar criptomonedas manuales en USD
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
    
    // MARK: - Obtener criptomonedas principales
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
    
    // MARK: - Cargar criptomonedas manuales
    private func loadManualCryptocurrencies(modelContext: ModelContext, vsCurrency: String, completion: @escaping ([Cryptocurrency]) -> Void) {
        let fetchDescriptor = FetchDescriptor<CryptoID>()
        do {
            let cryptoIDs = try modelContext.fetch(fetchDescriptor)
            let group = DispatchGroup()
            var loadedCryptocurrencies: [Cryptocurrency] = []
            
            for cryptoID in cryptoIDs {
                group.enter()
                API.shared.fetchCryptocurrencyDetails(id: cryptoID.id, vsCurrency: vsCurrency) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let crypto):
                            loadedCryptocurrencies.append(crypto)
                        case .failure(let error):
                            self.errorMessage = ErrorMessage(message: "Error al cargar \(cryptoID.id): \(error.localizedDescription)")
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                completion(loadedCryptocurrencies)
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
    
    
    
    
    // MARK: - Añadir criptomonedas manualmente
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
            
            // Añadir a ambas listas manuales
            API.shared.fetchCryptocurrencyDetails(id: crypto.id, vsCurrency: "eur") { result in
                if case .success(let cryptoEUR) = result {
                    DispatchQueue.main.async {
                        self.manualCryptocurrenciesEUR.append(cryptoEUR)
                    }
                }
            }
            
            API.shared.fetchCryptocurrencyDetails(id: crypto.id, vsCurrency: "usd") { result in
                if case .success(let cryptoUSD) = result {
                    DispatchQueue.main.async {
                        self.manualCryptocurrenciesUSD.append(cryptoUSD)
                    }
                }
            }
            
            switchCurrency(to: selectedCurrency)
        }
    }
    
    // MARK: - Eliminar criptomonedas
    func removeCryptocurrency(at indexSet: IndexSet, modelContext: ModelContext) {
        for index in indexSet {
            let crypto = cryptocurrencies[index]
            
            if manualCryptocurrenciesEUR.contains(where: { $0.id == crypto.id }) {
                removeCryptocurrencyFromSwiftData(id: crypto.id, modelContext: modelContext)
            }
            
            if selectedCurrency == "eur" {
                cryptocurrenciesEUR.removeAll { $0.id == crypto.id }
                manualCryptocurrenciesEUR.removeAll { $0.id == crypto.id }
            } else {
                cryptocurrenciesUSD.removeAll { $0.id == crypto.id }
                manualCryptocurrenciesUSD.removeAll { $0.id == crypto.id }
            }
        }
        switchCurrency(to: selectedCurrency)
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
