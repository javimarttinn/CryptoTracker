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
            let group = DispatchGroup()
            
            group.enter()
            API.shared.fetchCryptocurrencyDetails(id: crypto.id, vsCurrency: "eur") { result in
                DispatchQueue.main.async {
                    if case .success(let cryptoEUR) = result {
                        self.manualCryptocurrenciesEUR.append(cryptoEUR)
                    }
                    group.leave()
                }
            }
            
            group.enter()
            API.shared.fetchCryptocurrencyDetails(id: crypto.id, vsCurrency: "usd") { result in
                DispatchQueue.main.async {
                    if case .success(let cryptoUSD) = result {
                        self.manualCryptocurrenciesUSD.append(cryptoUSD)
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
    
    
    // MARK: - Favoritos: Añadir y Eliminar
    func toggleFavorite(for crypto: Cryptocurrency, modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<CryptoFavorite>(predicate: #Predicate { $0.id == crypto.id })
        do {
            if let existingFavorite = try modelContext.fetch(fetchDescriptor).first {
                // Si ya está en favoritos, eliminarlo
                modelContext.delete(existingFavorite)
                print("❌ Eliminado de favoritos: \(crypto.name)")
            } else {
                // Si no está en favoritos, añadirlo
                let newFavorite = CryptoFavorite(id: crypto.id)
                modelContext.insert(newFavorite)
                print("⭐ Añadido a favoritos: \(crypto.name)")
            }
            try modelContext.save()
            loadFavoriteCryptocurrencies(modelContext: modelContext)
        } catch {
            errorMessage = ErrorMessage(message: "Error al modificar favoritos: \(error.localizedDescription)")
        }
    }

    // MARK: - Cargar Favoritos al Iniciar
    func loadFavoriteCryptocurrencies(modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<CryptoFavorite>()
        do {
            let favoriteIDs = try modelContext.fetch(fetchDescriptor).map { $0.id }
            let group = DispatchGroup()
            var loadedFavorites: [Cryptocurrency] = []
            
            for id in favoriteIDs {
                group.enter()
                API.shared.fetchCryptocurrencyDetails(id: id, vsCurrency: selectedCurrency) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let crypto):
                            loadedFavorites.append(crypto)
                        case .failure(let error):
                            self.errorMessage = ErrorMessage(message: "Error al cargar favorito \(id): \(error.localizedDescription)")
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.favoriteCryptocurrencies = loadedFavorites
            }
        } catch {
            errorMessage = ErrorMessage(message: "Error al cargar favoritos: \(error.localizedDescription)")
        }
    }


    // MARK: - Actualizar Favoritos
    func updateFavorites() {
        favoriteCryptocurrencies = (cryptocurrenciesEUR + cryptocurrenciesUSD)
            .filter { $0.isFavorite }
    }


}
